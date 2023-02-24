*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQOBJANN the objective function components for MACRO
*   - Annualized costs for all components
*=============================================================================*
$IF DEFINED COEF_OBINV%1 $GOTO COEF
  PARAMETER COEF_OBINV%1(R,YEAR,P,CUR) //;
  PARAMETER COEF_OBFIX%1(R,YEAR,P,CUR) //;
  PARAMETER COEF_CRF(R,ALLYEAR,P,CUR) //;
*------------------------------------------------------------------------------
$IF %1==N $GOTO COEF

  SET OBVANN(OBV) / OBJINV, OBJFIX, OBJVAR /;
  SUM_OBJ(OBV('OBJSAL'),OBV)  =  0;
  POSITIVE VARIABLES VAR_ANNCST(OBV,R,ALLYEAR,CUR);
  EQUATIONS
    EQ_OBJANN(OBVANN,REG,CUR)
    EQ_ANNFIX(REG,ALLYEAR,CUR)
    EQ_ANNINV(REG,ALLYEAR,CUR)
    EQ_ANNVAR(REG,ALLYEAR,CUR);

  EQ_OBJANN(OBVANN,RDCUR(R,CUR))..
  VAR_OBJ(R,OBVANN,CUR) =E=  SUM(T, OBJ_PVT(R,T,CUR) * VAR_ANNCST(OBVANN,R,T,CUR))
$IF DEFINED VNRET
  + SUM(OBJ_SUMS(R,V,P)$RVPRL(R,V,P),OBJSCC(R,V,P,CUR)*OBJ_DCEOH(R,CUR)*(VAR_NCAP(R,V,P)$T(V)+NCAP_PASTI(R,V,P)-VAR_SCAP(R,V,'0',P)))$DIAG(OBVANN,'OBJINV')
  ;

$ BATINCLUDE eqobjcst.tm

*===============================================================================
$LABEL COEF
* Calculate coefficients for annualized costs
* Investment costs: Commissioning years
  OPTION CLEAR=OBJ_SUMSI;
  FIL2(V) = B(V)-YEARVAL(V);
  OBJ_SUMSI(RTP(R,V(LL),P),LL+(FIL2(V)+NCAP_ILED(R,V,P))) = YES;

* Annualizing coefficient for investment costs over years of capacity transfer
  COEF_CRF(OBJ_ICUR(R,V,P,CUR)) =
    SUM(RTP_CPTYR(R,TT(V),T,P),COEF_CPT(R,V,T,P)*OBJ_PVT(R,T,CUR)) +
    SUM(OBJ_SUMSI(R,PASTMILE(V),P,K),OBJ_DISC(R,K,CUR)*(1-(1+G_DRATE(R,V,CUR))**(-NCAP_TLIFE(R,V,P)))/(1-(1/(1+G_DRATE(R,V,CUR)))));

* Investment cost coefficient

  COEF_OBINV%1(OBJ_ICUR(R,V,P,CUR)) = (1/COEF_CRF(R,V,P,CUR))$COEF_CRF(R,V,P,CUR) * (

* Cases I - Investment Cost and II - Taxes/Subsidies

    SUM(OBJ_SUMII(R,V,P,LIFE,K_EOH,JOT), %CAPJD%
      SUM(INVSPRED(K_EOH,JOT,LL,K), OBJ_DISC(R,K,CUR) * (1-SALV_INV(R,V,P,LL)$T(V)) *
        (OBJ_ICOST(R,K,P,CUR) + (OBJ_ITAX(R,K,P,CUR) - OBJ_ISUB(R,K,P,CUR))%2)) *
      COR_SALVI(R,V,P,CUR) / OBJ_DIVI(R,V,P))
       +
* Cases III - Decommissioning

    SUM(OBJ_SUMIII(R,V,P,LL,K,Y)$OBJ_DCOST(R,V,P,CUR),
      OBJ_DISC(R,Y,CUR) * COR_SALVD(R,V,P,CUR) * OBJ_DCOST(R,K,P,CUR) / OBJ_DIVIII(R,V,P))
  );

  COEF_OBINV%1(OBJ_ICUR(R,PASTMILE(V),P,CUR))$PRC_RESID(R,'0',P) =
      OBJ_CRF(R,V,P,CUR)*(OBJ_ICOST(R,V,P,CUR)+(OBJ_ITAX(R,V,P,CUR)-OBJ_ISUB(R,V,P,CUR))%2);

*------------------------------------------------------------------------------
* Fixed costs: Annualizing coefficient for costs over years of capacity transfer
  COEF_CRF(OBJ_FCUR(R,V,P,CUR)) = SUM(RTP_CPTYR(R,V,T,P),COEF_CPT(R,V,T,P)*OBJ_PVT(R,T,CUR));
$IFI NOT %ANNCOST%==LEV COEF_CRF(OBJ_FCUR(R,PASTMILE(V),P,CUR)) = SUM(OBJ_SUMIV(K_EOH,R,V,P,JOT,LIFE),OBJ_LIFE(K_EOH,R,JOT,LIFE,CUR));

* Fixed cost coefficient

  COEF_OBFIX%1(OBJ_FCUR(R,V,P,CUR)) = (1/COEF_CRF(R,V,P,CUR))$COEF_CRF(R,V,P,CUR) * (

* Case IV - Fixed O&M Cost and Taxes

      SUM(OBJ_SUMIV(K_EOH,R,V,P,JOT,LIFE)$(NOT RTP_ISHPR(R,V,P)),
       SUM(INVSPRED(K_EOH,JOT,LL,K), OBJ_LIFE(LL,R,JOT,LIFE,CUR) * %CAPWD%
        (OBJ_FOM(R,K,P,CUR)+(OBJ_FTX(R,K,P,CUR)-OBJ_FSB(R,K,P,CUR))%2)) / OBJ_DIVIV(R,V,P)) +

      SUM(OBJ_SUMIV(K_EOH,RTP_ISHPR(R,V,P),JOT,LIFE),
        SUM((INVSPRED(K_EOH,JOT,LL,K),OPYEAR(LIFE,AGE),Y_EOH(LL+(ORD(AGE)-1))),
             OBJ_DISC(R,Y_EOH,CUR) * (1+SUM(PERIODYR(T,Y_EOH),RTP_CPX(R,V,P,T))$NCAP_CPX(R,V,P)) * %CAPWD%
                (
                   OBJ_FOM(R,K,P,CUR) * (1+SUM(RTP_SHAPE(R,V,P,'1',J,JJ),SHAPE(J,AGE)*MULTI(JJ,Y_EOH)-1)) +
                   OBJ_FTX(R,K,P,CUR) * (1+SUM(RTP_SHAPE(R,V,P,'2',J,JJ),SHAPE(J,AGE)*MULTI(JJ,Y_EOH)-1))%2 -
                   OBJ_FSB(R,K,P,CUR) * (1+SUM(RTP_SHAPE(R,V,P,'3',J,JJ),SHAPE(J,AGE)*MULTI(JJ,Y_EOH)-1))%2
                )
           ) / OBJ_DIVIV(R,V,P)
         ) +

* Case V - Decommissioning Surveillance
      SUM(OBJ_SUMIVS(R,V,P,K,Y), OBJ_DISC(R,Y,CUR) * OBJ_DLAGC(R,K,P,CUR))
  );

  COEF_OBFIX%1(OBJ_FCUR(R,PASTMILE(V),P,CUR))$PRC_RESID(R,'0',P) =
     COEF_OBFIX%1(R,V,P,CUR) * COEF_CRF(R,V,P,CUR) /
     SUM(VNT(V,T)$PRC_RESID(R,T,P),PRC_RESID(R,T,P)/NCAP_PASTI(R,V,P)*OBJ_PVT(R,T,CUR));
*===============================================================================
  OPTION CLEAR=OBJ_SUMSI,CLEAR=COEF_CRF;