*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* COEF_OBJ.MOD do coefficient calculations for the OBJ
*   %1 - mod or v# for the source code to be used
*=============================================================================*
*  responsible for moving cost data to EACHYEAR from each input period
*-----------------------------------------------------------------------------
* Declarations
  ALIAS(K,EACHYEAR);
  SET Y(ALLYEAR);
  SET Y_EOH(ALLYEAR);
  SET YK(ALLYEAR,ALLYEAR);
  SET TS_ANN(S,S);
  TS_ANN(S,S) = YES;
  TS_ANN(S,ANNUAL) = YES;
  SCALARS YR_V1 /0/, YR_VL /0/, ACL /0/;

* For shaped demand elasticises
  ALIAS(AGE,SPAN);
  SET SHEDJ(LIM,J) 'Elastic demand shape indexes';
  PARAMETER BDSIG(L);
  PARAMETER SHAPED(BD,J,AGE) 'Elastic demand shape curves' //;

* establish eachyear sets matching documentation
  YR_VL = MIYR_VL+DUR_MAX;
  LOOP(RTP(R,PASTMILE(LL),P)$NCAP_ILED(R,LL,P), K(LL+NCAP_ILED(R,LL,P)) = YES);
  Y(K)$((YEARVAL(K) >= MINYR) * (YEARVAL(K) <= YR_VL)) = YES;
  YK(Y,K)$(YEARVAL(K)<=YEARVAL(Y)) = YES;
$IFI '%ANNCOST%'==LEV ACL=MINYR; MINYR=MIYR_V1; RPT_OPT('OBJ','2')=1;
$IFI '%ANNCOST%%CTST%'==LEV MINYR=ACL;
  Y_EOH(EOHYEARS)$(YEARVAL(EOHYEARS) >= MINYR) = YES;

  OPTION CLEAR=FIL;
  YR_V1 = MIN(SMIN(DATAYEAR,YEARVAL(DATAYEAR)),PYR_V1);
  YR_VL = MAX(SMAX(DATAYEAR,YEARVAL(DATAYEAR)),YR_VL);
  FIL(LL)$((YEARVAL(LL) GE YR_V1)*(YEARVAL(LL) LE YR_VL)) = YES;

* interpolate discount rates
$ BATINCLUDE filparam.gms G_DRATE 'R,' CUR  ",'','','','',''" ALLYEAR LL FIL(LL)$ FIL(LL)$

* set discounting factor OBJ_DISC in 'cumulative' way, covering EACHYEAR
* First, initialize the discount factor for YR_V1 to 1.0:
   OBJ_DISC(R,LL,CUR)$(RDCUR(R,CUR)$(YEARVAL(LL)=YR_V1)) = 1;
   IF(G_DYEAR=0,G_DYEAR=SUM(MIYR_1(T),YEARVAL(T)));
* Calculate all discount factors with respect to YR_V1:
   LOOP(FIL(LL-1), OBJ_DISC(R,LL,CUR) = OBJ_DISC(R,FIL,CUR) / (1+G_DRATE(R,LL,CUR)));
* Find the year among FIL that is closest to the base year G_DYEAR:
   F = SUM(MIYR_1(LL),YEARVAL(LL)-MAX(MIN(YR_VL,G_DYEAR),YR_V1));
* Normalize all discount factors so that the base year discount factor = 1.0:
   LOOP(RDCUR(R,CUR),
     Z = SUM(MIYR_1(LL+F),OBJ_DISC(R,LL,CUR)*(1+G_DRATE(R,LL,CUR))**(-(G_DYEAR-YEARVAL(LL))));
     OBJ_DISC(R,FIL(LL),CUR) = OBJ_DISC(R,LL,CUR) / Z);
* Prevent divide-by-zero if zero discount rate
   G_DRATE(R,V,CUR)$((G_DRATE(R,V,CUR) LE 0)$RDCUR(R,CUR)) = 1E-11;
*-----------------------------------------------------------------------------
* Calculate present value factors for time in periods
  LOOP(R$(NOT SUM(G_RCUR(RDCUR(R,CUR)),1)),
    Z = SMAX(RDCUR(R,CUR), SUM(T,D(T)*OBJ_DISC(R,T,CUR)));
    LOOP(RDCUR(R,CUR)$Z, F=SUM(T,D(T)*OBJ_DISC(R,T,CUR));
      IF(ABS(F-Z) LT 1E-7, G_RCUR(R,CUR) = YES; Z = 0)));
  OBJ_PVT(R,T,CUR)$RDCUR(R,CUR) = SUM(PERIODYR(T,Y_EOH),OBJ_DISC(R,Y_EOH,CUR));
  COEF_PVT(R,T) = SUM(G_RCUR(R,CUR),OBJ_PVT(R,T,CUR));
  OBJ_RFR(R,V,CUR) $= G_DRATE(R,V,CUR);
  OBJ_RFR(R,V,CUR)$RDCUR(R,CUR) $= G_RFRIR(R,V);
*-----------------------------------------------------------------------------
* move original data from input to annual value arrays
* commodity costs
      OBJ_COMNT(R,DATAYEAR,C,S,COSTYPE,CUR)$(NOT COM_TS(R,C,S)) = 0;
      OBJ_COMPD(R,DATAYEAR,C,S,COSTYPE,CUR)$(NOT COM_TS(R,C,S)) = 0;

* IRE_PRICE - exports negative
* Take IRE_PRICE into account ONLY if the trade is exogenous; map ALL_R into R:
* Additionally allow using R directly as a placeholder of any external region
      LOOP(ALL_R$(NOT REG(ALL_R)),OBJ_IPRIC(R,DATAYEAR,P,C,S,IE,CUR)$RPC_IREIO(R,P,C,IE,'OUT') $=
         IRE_PRICE(R,DATAYEAR,P,C,S,ALL_R,IE,CUR)*(1-2$XPT(IE)));
      OBJ_IPRIC(R,DATAYEAR,P,C,S,IE,CUR)$RPC_IREIO(R,P,C,IE,'OUT') $= IRE_PRICE(R,DATAYEAR,P,C,S,R,IE,CUR)*(1-2$XPT(IE));
* flow costs; remove invalid costs on storage flows
      FLO_COST(R,LL,P,C,S,CUR)$((NOT TOP(R,P,C,'IN'))$RPC_STG(R,P,C)) = 0;
      FLO_DELIV(R,LL,P,C,S,CUR)$((NOT TOP(R,P,C,'OUT'))$RPC_STG(R,P,C)) = 0;
      OBJ_FSUB(R,LL,P,C,S,CUR) $= FLO_TAX(R,LL,P,C,S,CUR);
      OBJ_FSUB(R,LL,P,C,S,CUR)$FLO_SUB(R,LL,P,C,S,CUR) = OBJ_FSUB(R,LL,P,C,S,CUR)-FLO_SUB(R,LL,P,C,S,CUR);
      OBJ_FSUB(R,LL,P,C,S,CUR)$((NOT V(LL))$OBJ_VFLO(R,P,C,CUR,'SUB')) = 0;
      OPTION RPC_CUR <= FLO_COST; OBJ_VFLO(RPC_CUR,'COST') = YES;
      OPTION RPC_CUR <= FLO_DELIV; OBJ_VFLO(RPC_CUR,'COST') = YES;
      OPTION RPC_CUR <= FLO_TAX; OBJ_VFLO(RPC_CUR,'TAX') = YES;
      OPTION RPC_CUR <= FLO_SUB; OBJ_VFLO(RPC_CUR,'SUB') = YES;
* remove proportional subsidy if absolute defined
  IF(CARD(NCAP_ISPCT),OPTION PRC_YMAX<NCAP_ISUB; NCAP_ISPCT(R,LL,P)$PRC_YMAX(R,P)=0);

* V07_1b blending
  OBJ_BLNDV(R,Y_EOH,BLE,OPR,CUR)$(RDCUR(R,CUR)$BLE_OPR(R,BLE,OPR)) = BL_VAROMC(R,BLE,CUR) +
            SUM(COM$BL_DELIVC(R,BLE,COM,CUR), BL_INP(R,BLE,COM) * BL_DELIVC(R,BLE,COM,CUR));

$SET TAKE 'RDCUR(R,CUR)' SET TMP 1
* Can we use macroes?
$IF %OBMAC%==YES $SET TMP 2
$IF DEFINED R_CUREX $SET TAKE 1
*-----------------------------------------------------------------------------
* Establish process-wise subset of EACHYEAR by determining the MIN and MAX years
  MY_ARRAY(V) = MIN(B(V),M(V)-IPD(V));
  PRC_YMIN(RP(R,P)) = SMIN(RTP(R,V,P),MY_ARRAY(V));
  PRC_YMAX(RP(R,P)) = SMAX(RTP(R,PYR,P),YEARVAL(PYR));
* Make sure last commissioning year of repeated investments is included
  LOOP(T, Z = M(T)-E(T)+LAGT(T);
    PRC_YMAX(RP(R,P))$RTP(R,T,P) = MAX(PRC_YMAX(R,P),E(T)+NCAP_ILED(R,T,P)+MAX(Z,NCAP_TLIFE(R,T,P))$(COEF_RPTI(R,T,P) GT 1)));

*-----------------------------------------------------------------------------*
* Interpolation/extrapolation of cost parameters
* EACHYEAR will be sufficient for all capacity related costs
  Z = SMAX(RP,PRC_YMAX(RP));
  OPTION CLEAR=FIL,CLEAR=MY_ARRAY; FIL(K)$(YEARVAL(K) LE Z) = YES;
$IF %VALIDATE%==YES FIL(K)=V(K);
*-----------------------------------------------------------------------------*
$SETLOCAL BEXT '(YEARVAL(FIL) GE PRC_YMIN(R,P))$'
$SETLOCAL FEXT '(YEARVAL(FIL) LE PRC_YMAX(R,P))$'
*-----------------------------------------------------------------------------*
* investment related costs
$BATINCLUDE fillcost OBJ_ICOST R 'P,CUR' ",'0','0','0'" FIL %TAKE% '%BEXT%' '%FEXT%' NCAP_COST OB_ICOST %TMP%
$BATINCLUDE fillcost OBJ_ISUB  R 'P,CUR' ",'0','0','0'" FIL %TAKE% '%BEXT%' '%FEXT%' NCAP_ISUB OB_ISUB %TMP%
$BATINCLUDE fillcost OBJ_ITAX  R 'P,CUR' ",'0','0','0'" FIL %TAKE% '%BEXT%' '%FEXT%' NCAP_ITAX OB_ITAX %TMP%
$BATINCLUDE fillcost NCAP_ISPCT R P ",'0','0','0','0'" FIL 1 '%BEXT%' '%FEXT%' NCAP_ISPCT X_RP %TMP%
  IF(CARD(X_RP),OB_ISUB(RP,CUR,YEAR)$X_RP(RP,YEAR) $= OB_ICOST(RP,CUR,YEAR)*X_RP(RP,YEAR); OPTION CLEAR=X_RP);

* fixed O&M and taxes
$BATINCLUDE fillcost OBJ_FOM R 'P,CUR' ",'0','0','0'" FIL %TAKE% '%BEXT%' '%FEXT%' NCAP_FOM OB_FOM %TMP%
$BATINCLUDE fillcost OBJ_FSB R 'P,CUR' ",'0','0','0'" FIL %TAKE% '%BEXT%' '%FEXT%' NCAP_FSUB OB_FSB %TMP%
$BATINCLUDE fillcost OBJ_FTX R 'P,CUR' ",'0','0','0'" FIL %TAKE% '%BEXT%' '%FEXT%' NCAP_FTAX OB_FTX %TMP%

* decommissioning (actual & surveillance)
$BATINCLUDE fillcost OBJ_DCOST R 'P,CUR' ",'0','0','0'" FIL %TAKE% '%BEXT%' '%FEXT%' NCAP_DCOST OB_DCC %TMP%
$BATINCLUDE fillcost OBJ_DLAGC R 'P,CUR' ",'0','0','0'" FIL %TAKE% '%BEXT%' '%FEXT%' NCAP_DLAGC OB_DLC %TMP%
*-----------------------------------------------------------------------------*
OPTION CLEAR=FIL; FIL(Y_EOH)$(YEARVAL(Y_EOH) GE MIYR_V1) = YES;
$IFI %VARCOST%==LIN OPTION CLEAR=FIL; FIL(T) = YES;
$IF %VALIDATE%==YES OPTION CLEAR=FIL; FIL(T) = YES;
*-----------------------------------------------------------------------------*
* variable costs
$BATINCLUDE fillcost OBJ_ACOST R 'P,CUR' ",'0','0','0'" FIL RP(R,P) '' '' ACT_COST OB_ACT %TMP%

* commodity costs
$BATINCLUDE fillcost OBJ_COMNT R 'C,S,COSTYPE,CUR' ",'0'" FIL COM_TS(R,C,S) '' '' OBJ_COMNT OB_COM
$BATINCLUDE fillcost OBJ_COMPD R 'C,S,COSTYPE,CUR' ",'0'" FIL COM_TS(R,C,S) '' '' OBJ_COMPD OB_COM
$BATINCLUDE fillcost OBJ_IPRIC R 'P,C,S,IE,CUR' '' FIL RPCS_VAR(R,P,C,S) '' '' OBJ_IPRIC OB_IRE

* flow cost
$set take (RPCS_VAR(R,P,C,S)+ANNUAL(S))
$BATINCLUDE fillcost OBJ_FCOST R 'P,C,S,CUR' ",'0'" FIL %TAKE% '' '' FLO_COST OB_FCOS %TMP%
$BATINCLUDE fillcost OBJ_FDELV R 'P,C,S,CUR' ",'0'" FIL %TAKE% '' '' FLO_DELIV OB_FDEL %TMP%
$BATINCLUDE fillcost OBJ_FTAX  R 'P,C,S,CUR' ",'0'" FIL %TAKE% '' '' OBJ_FSUB OB_FTAX %TMP%
*-----------------------------------------------------------------------------*
  OPTION CLEAR=PRC_YMIN,CLEAR=PRC_YMAX;
  OPTION CLEAR=RPC_CUR,CLEAR=OBJ_FSUB;
*-----------------------------------------------------------------------------*
$if not %OBMAC%==YES $goto NOMACRO
$macro OBJ_ICOST(r,y,p,m) OB_ICOST(r,p,m,y)
$macro OBJ_ISUB(r,y,p,m) OB_ISUB(r,p,m,y)
$macro OBJ_ITAX(r,y,p,m) OB_ITAX(r,p,m,y)
$macro OBJ_FOM(r,y,p,m) OB_FOM(r,p,m,y)
$macro OBJ_FSB(r,y,p,m) OB_FSB(r,p,m,y)
$macro OBJ_FTX(r,y,p,m) OB_FTX(r,p,m,y)
$macro OBJ_DCOST(r,y,p,m) OB_DCC(r,p,m,y)
$macro OBJ_DLAGC(r,y,p,m) OB_DLC(r,p,m,y)
$macro OBJ_ACOST(r,y,p,m) OB_ACT(r,p,m,y)
$macro OBJ_FCOST(r,y,p,c,s,m) OB_FCOS(r,p,c,s,m,y)
$macro OBJ_FDELV(r,y,p,c,s,m) OB_FDEL(r,p,c,s,m,y)
$macro OBJ_FTAX(r,y,p,c,s,m) OB_FTAX(r,p,c,s,m,y)
$LABEL NOMACRO
*-----------------------------------------------------------------------------*
* investment related costs
*-----------------------------------------------------------------------------*
* capital recovery factors: CRFs now defined in eqobjinv.mod / eqobsalv.mod
*    OBJ_CRF(RTP(R,V,P),CUR)    = (1-(1/(1+(G_DRATE(R,V,CUR)$(NOT NCAP_DRATE(RTP)) + NCAP_DRATE(RTP))))) /
*                                 (1-(1/(1+G_DRATE(R,V,CUR)$(NOT NCAP_DRATE(RTP)) + NCAP_DRATE(RTP)))**NCAP_ELIFE(RTP));
*    OBJ_CRFD(RTP(R,V,P),CUR)$NCAP_DELIF(RTP)  = (1-(1/(1+(G_DRATE(R,V,CUR)$(NOT NCAP_DRATE(RTP)) + NCAP_DRATE(RTP))))) /
*                                 (1-(1/(1+G_DRATE(R,V,CUR)$(NOT NCAP_DRATE(RTP)) + NCAP_DRATE(RTP)))**NCAP_DELIF(RTP));

$IF NOT %VALIDATE%==YES
$IF NOT %TIMESED% ==YES  $GOTO TCOST
*-----------------------------------------------------------------------------
* Calculate coefficients for shaped demand elasticises
* Collect all tuples (J,BD) from COM_ELASTX to SHEDJ(BD,J)
  SHEDJ(BD,J) $= SUM(RTC_SHED(R,T,C,BD,J),1); SHEDJ(BDNEQ,'1') = YES;
* Calculate price changes by percent, and cumulate
  BDSIG(BDNEQ)=CEIL(SMAX(RTC_SHED(R,T,C,BDNEQ,J),COM_VOC(R,T,C,BDNEQ))*100); BDSIG('LO')=MIN(100,BDSIG('LO'));
  SHAPED(SHEDJ(BDNEQ,J),AGE)$(ORD(AGE) LE BDSIG(BDNEQ)) = (1+.01/(1+(ORD(AGE)-1)/100))**(1/MAX(1E-3,SHAPE(J,AGE)));
  LOOP((AGE,SPAN(AGE-1),BDNEQ(BD))$(ORD(AGE) LE BDSIG(BD)),SHAPED(SHEDJ(BD,J),AGE) = SHAPED(BD,J,AGE)*SHAPED(BD,J,SPAN));
*-----------------------------------------------------------------------------
$IF NOT %VALIDATE%==YES $GOTO TCOST
* Flat period assignment
* As original parameters are not filled, flat data must be taken from OBJ_xxx
  LOOP(V, FIL(FIL)=NO; FIL(K)$PERIODYR(V,K) = YES;
      OBJ_ICOST(R,FIL,P,CUR)      $= OBJ_ICOST(R,V,P,CUR);
      OBJ_FOM(R,FIL,P,CUR)        $= OBJ_FOM(R,V,P,CUR);
      OBJ_ACOST(R,FIL,P,CUR)      $= OBJ_ACOST(R,V,P,CUR);
      OBJ_IPRIC(R,FIL,P,C,S,R,IE,CUR) $= OBJ_IPRIC(R,V,P,C,S,R,IE,CUR);
      OBJ_FCOST(R,FIL,P,C,S,CUR)  $= OBJ_FCOST(R,V,P,C,S,CUR);
      OBJ_FDELV(R,FIL,P,C,S,CUR)  $= OBJ_FDELV(R,V,P,C,S,CUR);
  );
*display "*** after flat period assignment ***", obj_icost, obj_fom;

$LABEL TCOST
* ignore investment cost for learned technologies when ETL active: COEF_EXT.ETL
  BDSIG(BDNEQ) = 1-2$BDUPX(BDNEQ);
