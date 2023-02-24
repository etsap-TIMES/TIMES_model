*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQOBJSALV the objective functions for salvaging
*   - Investment Costs
*   - Taxes and subsidies on investments
*   - Decommissioning
*=============================================================================*
$IF DEFINED OBJSCC $GOTO PREPRO

  PARAMETER SALV_DEC(REG,ALLYEAR,PRC,CUR) //;
  PARAMETER OBJSCC(REG,ALLYEAR,PRC,CUR)   //;
  PARAMETER OBJSIC(REG,ALLYEAR,PRC)       //;
  PARAMETER OBJ_DCEOH(REG,CUR)            //;

$LABEL PREPRO
$SET PFT ''
*===============================================================================
* Check stepped mode
$IF SET TIMESTEP OPTION CLEAR=OBJ_SUMS,CLEAR=OBJ_SUMS3,CLEAR=SALV_INV,CLEAR=OBJSCC;
$IF %STEPPED%==+
$IFI %1==mod $GOTO EQUA
$IF NOT DEFINED VNRET
$IF NOT '%CTST%'=='' $SET PFT (T)
*===============================================================================
* Salvaging of Investments
* LL is investment year; K is commissioning year
*[UR] 19.12.2003 added -1 in line below, since lifetime starts at the beginning of year K
  LOOP(OBJ_SUMII(R,V%PFT%,P,AGE,K_EOH,JOT), Z=NCAP_TLIFE(R,V,P)-1;
    IF(YEARVAL(K_EOH)+ORD(JOT)+Z GT MIYR_VL,
       LOOP(INVSPRED(K_EOH,JOT,LL,K)$(YEARVAL(LL)+Z GT MIYR_VL),OBJ_SUMSI(R,V,P,LL) = YES)));

* No retrofit salvage
  LOOP((RP(R,PRC),P)$PRC_REFIT(RP,P),IF(PRC_REFIT(RP,P)<0, OBJ_SUMSI(R,T,P,K)=NO));
  OPTION OBJ_SUMS <= OBJ_SUMSI;

* Salvaging of Decommissioning
  LOOP(OBJ_SUMIII(OBJ_SUMS(R,V,P),LL,K,Y), OBJ_SUMS3(R,V,P) = YES);
* Salvaging of Decommissioning surveillance
  LOOP(OBJ_SUMIVS(R,V,P,K,Y)$(YEARVAL(K)+NCAP_TLIFE(R,V,P)-1 GT MIYR_VL),
    OBJ_SUMS3(R,V,P) = YES; OBJ_SUMSI(R,V,P,K) = YES);

*===============================================================================
  LOOP(RDCUR(R,CUR),
* Salvage proportion of investments at the commissioning year K:
   SALV_INV(OBJ_SUMSI(R,V,P,K))$OBJ_ICUR(R,V,P,CUR) =
       MIN(1,(((1+G_DRATE(R,V,CUR))*EXP(NCAP_FDR(R,V,P)))**(NCAP_TLIFE(R,V,P)+YEARVAL(K)-MIYR_VL-1)-1) /
             (((1+G_DRATE(R,V,CUR))*EXP(NCAP_FDR(R,V,P)))**NCAP_TLIFE(R,V,P)-1));
  );
* Discount factors for the year EOH+1:
  LOOP(MIYR_1(LL), F = MIYR_VL+1-YEARVAL(MIYR_1); OBJ_DCEOH(RDCUR(R,CUR)) = OBJ_DISC(R,LL+F,CUR));
* Shape-reduced salvage at EOH+1:
  Z = SMAX(T$(B(T)<=MIYR_VL+1),ORD(T)-1);
  LOOP(MIYR_1(T-Z), SALV_INV(OBJ_SUMSI(RTP,K))$NCAP_CPX(RTP) = SALV_INV(RTP,K)*(1+RTP_CPX(RTP,T)));

  OPTION CLEAR = OBJ_SUMSI;
*===============================================================================
* Salvage value of investments at year EOH+1:
* Note that in Cases 2a and 2b investment costs are paid before K
  OBJSCC(OBJ_ICUR(OBJ_SUMS(R,V,P),CUR)) = COR_SALVI(R,V,P,CUR) / OBJ_DCEOH(R,CUR) / OBJ_DIVI(R,V,P) *
    SUM((OBJ_SUMII(R,V,P,AGE,K_EOH,JOT),INVSPRED(K_EOH,JOT,LL,K))$SALV_INV(R,V,P,LL),%CAPJD%
        (OBJ_ICOST(R,K,P,CUR)+OBJ_ITAX(R,K,P,CUR)-OBJ_ISUB(R,K,P,CUR)) * SALV_INV(R,V,P,LL) * OBJ_DISC(R,K,CUR));
* Handle ETL in similar fashion
$IF %ETL%==YES  LOOP((OBJ_SUMS(R,T(V),P),G_RCUR(R,CUR))$SEG(R,P),
$IF %ETL%==YES    OBJSIC(R,T,P) = COR_SALVI(R,T,P,CUR) / OBJ_DCEOH(R,CUR) / OBJ_DIVI(R,T,P) *
$IF %ETL%==YES      SUM((OBJ_SUMII(R,V,P,AGE,K_EOH,JOT),INVSPRED(K_EOH,JOT,LL,K)),%CAPJD% SALV_INV(R,T,P,LL)*OBJ_DISC(R,K,CUR)));
*===============================================================================
* Additional constant term
  OBJ_IAD(RDCUR(R,CUR)) = SUM(OBJ_ICUR(OBJ_SUMS(R,PASTMILE(V),P),CUR)$((OBJ_PASTI(R,V,P,CUR)=0)+0%CTST%),OBJSCC(R,V,P,CUR)*NCAP_PASTI(R,V,P)*OBJ_DCEOH(R,CUR));
*===============================================================================
*GG* only if decommissioning lifetime provided by user
  COR_SALVD(RTP(R,V,P),CUR)$OBJ_DCOST(R,V,P,CUR) =
                   (((1-1/(1+NCAP_DRATE(R,V,P)))*(1-1/(1+OBJ_RFR(R,V,CUR))**NCAP_DELIF(R,V,P)))/
                    ((1-1/(1+OBJ_RFR(R,V,CUR)))*(1-1/(1+NCAP_DRATE(R,V,P))**NCAP_DELIF(R,V,P)))
                    )$(NCAP_DRATE(R,V,P) GT 0) + 1$(NCAP_DRATE(R,V,P) EQ 0);
  OBJ_CRFD(RTP(R,V,P),CUR)$OBJ_DCOST(R,V,P,CUR) = COR_SALVD(R,V,P,CUR) * (1-(1/(1+G_DRATE(R,V,CUR)))) / (1-(1+G_DRATE(R,V,CUR))**(-ROUND(NCAP_%DECLIF%(R,V,P))));
*------------------------------------------------------------------------------
* Salvage value of Decommissioning at year EOH+1:
* Documentation defines the value for each decommissioning year Y; here aggregated by vintage
  SALV_DEC(OBJ_SUMS3(R,V,P),CUR)$COR_SALVD(R,V,P,CUR) = COR_SALVD(R,V,P,CUR) / OBJ_DIVIII(R,V,P) / OBJ_DCEOH(R,CUR) *
      SUM(OBJ_SUMIII(R,V,P,LL,K,Y)$SALV_INV(R,V,P,LL),SALV_INV(R,V,P,LL)*OBJ_DCOST(R,K,P,CUR)*OBJ_DISC(R,Y,CUR));
*===============================================================================
$LABEL EQUA
$IFI %2==EXIT $EXIT

*===============================================================================
* Generate Salvage Equation summing over all active indexes by region and currency
*===============================================================================


    %EQ%_OBJSALV(RDCUR(R,CUR) %SOW%) ..

*------------------------------------------------------------------------------
* Cases I - Investment Cost and II - Taxes/Subsidies
*------------------------------------------------------------------------------
* [AL] Note that discounting to EOH+1 is imbedded in OBJSCC and OBJSIC

      SUM(OBJ_SUMS(R,T,P), OBJSCC(R,T,P,CUR) * %VART%_NCAP(R,T,P %SWS%)) * OBJ_DCEOH(R,CUR) +
$IF NOT '%VALIDATE%'==YES
      SUM(OBJ_SUMS(R,PYR(V),P), OBJSCC(R,V,P,CUR) * NCAP_PASTI(R,V,P)) * OBJ_DCEOH(R,CUR) +
$IF %ETL% == YES
      SUM((OBJ_SUMS(R,T,TEG(P)),G_RCUR(R,CUR)), OBJSIC(R,T,P) * %VART%_IC(R,T,P %SWS%)) * OBJ_DCEOH(R,CUR) +

$IF DEFINED VNRET $BATINCLUDE prepret.dsc OBSALV

*------------------------------------------------------------------------------
* Cases III - Decommissioning
*------------------------------------------------------------------------------
* [AL] Note that discounting to EOH+1 is imbedded in SALV_DEC

      SUM(OBJ_SUMS3(R,T,P), %VART%_NCAP(R,T,P %SWS%) * SALV_DEC(R,T,P,CUR)) * OBJ_DCEOH(R,CUR)
      +
* Past investments
      SUM(OBJ_SUMS3(R,PYR,P), NCAP_PASTI(R,PYR,P) * SALV_DEC(R,PYR,P,CUR)) * OBJ_DCEOH(R,CUR)
      +

*------------------------------------------------------------------------------
* Cases IV - Decommissioning Surveillance
*------------------------------------------------------------------------------
* The same proportion SALV_INV is salvaged from investments and surveillance costs
      SUM(OBJ_SUMIVS(R,V,P,K,Y)$SALV_INV(R,V,P,K),
            OBJ_DISC(R,Y,CUR) * OBJ_DLAGC(R,K,P,CUR) * SALV_INV(R,V,P,K) *
            (%VARV%_NCAP(R,V,P %SWS%)$MILESTONYR(V) + NCAP_PASTI(R,V,P)$PASTYEAR(V)))
      +
*------------------------------------------------------------------------------
* LATE REVENUES
*------------------------------------------------------------------------------
* [AL] LATEREVENUES identical to decommissioning, with DCOST replaced by OCOM*VALU
* Revenues are obtained in the proportion 1-SALV_INV of the total revenues

    SUM((OBJ_SUMIII(R,V,P,LL,K,Y),COM)$((NOT Y_EOH(Y))$NCAP_OCOM(R,V,P,COM)),
        (1-SALV_INV(R,V,P,LL)) * NCAP_VALU(R,K,P,COM,CUR) * OBJ_DISC(R,Y,CUR) *
        (%VARV%_NCAP(R,V,P %SWS%)$MILESTONYR(V) + NCAP_PASTI(R,V,P)$PASTYEAR(V)) *
        NCAP_OCOM(R,V,P,COM) / OBJ_DIVIII(R,V,P))


    =E=

      %VAR%_OBJ(R,'OBJSAL',CUR %SOW%);

*$offlisting
