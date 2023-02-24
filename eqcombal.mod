*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQCOMBAL is the basic commodity balance and the production limit constraint
*   %1 - mod or v# for the source code to be used
*   %2 - equation declaration type
*   %3 - COM_LIM type for %2
*   %4 - BAL/PRD indicator
*   %5 - condition for PRD
*=============================================================================*
*GaG Questions/Comments:
*   - need more control over VAR_COMX so only generate when really OK (=>either COMX_BND/PRICE/UC required)
*   - apply RS_FR/RTCS_FR whenever process has a COM_TS commodity but the variable is not at that level
*-----------------------------------------------------------------------------
*$ONLISTING
*
    %EQ%%2_COM%4(%R_T%,C,S %SWT%)$(RCS_COM%4(R,T,C,S,'%3') %5) ..
*
* production
*
   (
      (

* individual flows
$        BATINCLUDE cal_fflo.%1 OUT O

*V07_1b blending flows
  SUM(BLE_OPR(R,C,OPR),
    RS_FR(R,S,'ANNUAL')*(1+RTCS_FR(R,T,C,S,'ANNUAL')) * BLE_BAL(R,T,C,OPR) * %VAR%_BLND(R,T,C,OPR %SOW%)
  ) +
*V07_1b emissions due to blending operations
  SUM(BLE_ENV(R,C,BLE,OPR), RS_FR(R,S,'ANNUAL') * ENV_BL(R,C,BLE,OPR,T) * %VAR%_BLND(R,T,BLE,OPR %SOW%)
  ) +

*   inter-regional trade to region
*V0.9 022100 - exports could also produce aux
$        BATINCLUDE cal_ire.%1 IMP OUT IE

*   storage
$        BATINCLUDE cal_stgn.%1 OUT IN '*STG_EFF(R,V,P)' '' "(NOT PRC_NSTTS(R,P,TS))"

* (+25-May-2005) Add commodity aggregation to production side
  SUM(COM$COM_AGG(R,T,COM,C), COM_AGG(R,T,COM,C) *
    SUM(RTCS_VARC(R,T,COM,TS)$RS_TREE(R,S,TS),RS_FR(R,S,TS)*(1+RTCS_FR(R,T,COM,S,TS))*
      (%VAR%_COMNET(R,T,COM,TS %SOW%)$RC_AGP(R,COM,'LO') + %VAR%_COMPRD(R,T,COM,TS %SOW%)$RC_AGP(R,COM,'FX')))) +

* capacity related commodity flows
* fixed commodity associated with installed capacity or retirement
$        BATINCLUDE cal_cap.%1 OUT O

* apply commodity infastructure efficiency
      )  *  COM_IE(R,T,C,S)

* If production is summed into variable, use it directly
$IF '%4' == BAL  )$(NOT RHS_COMPRD(R,T,C,S)) + %VAR%_COMPRD(R,T,C,S %SOW%)$(RHS_COMPRD(R,T,C,S)
   )

*
* consumption
*
* when doing FLO then need NET otherwise only want production component
$IF '%4' == PRD  $GOTO ONLY_PRD

* include the elasticity variables (moved to consumption side)
$IF %TIMESED%==YES + SUM(RCJ(R,C,J,BDNEQ(BD))$COM_ELAST(R,T,C,S,BD),BDSIG(BD)*%VAR%_ELAST(R,T,C,S,J,BD %SOW%))

    - (

* individual flows
$        BATINCLUDE cal_fflo.%1 IN I

*V07_1a blending flows
  SUM(BLE_TP(R,T,BLE)$BLE_OPR(R,BLE,C),
    RS_FR(R,S,'ANNUAL')*(1+RTCS_FR(R,T,C,S,'ANNUAL')) * %VAR%_BLND(R,T,BLE,C %SOW%)
  ) +
  SUM(BLE_OPR(R,BLE,OPR)$(BLE_INP(R,BLE,C) * BLE_TP(R,T,BLE)),
    RS_FR(R,S,'ANNUAL')*(1+RTCS_FR(R,T,C,S,'ANNUAL')) * BL_INP(R,BLE,C) * %VAR%_BLND(R,T,BLE,OPR %SOW%)
  ) +

*   inter-regional trade from region
*V0.9 022100 - imports could also require aux
$        BATINCLUDE cal_ire.%1 EXP IN IE

*   storage
$        BATINCLUDE cal_stgn.%1 IN OUT '' 'STG_EFF(R,V,P)*' "((NOT PRC_MAP(R,'NST',P))+PRC_NSTTS(R,P,TS))"

* capacity related commodity flows
* fixed commodity associated with installed capacity or investment
$        BATINCLUDE cal_cap.%1 IN I

      )
$LABEL ONLY_PRD

      =%2=

$    IF '%4' == BAL $GOTO BALEQ
*    production bound/cost/tax/sub/cum
          %VAR%_COMPRD(R,T,C,S %SOW%)$RHS_COMPRD(R,T,C,S)
$IF %TIMESED%==YES  +(SUM(RCJ(R,COM,J,BD)$MI_DMAS(R,C,COM),(DDF_PREF(R,T,COM)*(MI_AGC(R,T,C,COM,J,BD)-1)+RD_SHAR(R,T,COM,C))*BDSIG(BD)*SUM(RTCS_VARC(R,T,COM,TS),%VAR%_ELAST(R,T,COM,TS,J,BD%SOW%)))-%VAR%_COMPRD(R,T,C,S %SOW%))$(COM_ELAST(R,T,C,S,'N')>0)$RD_AGG(R,C)
$    GOTO DONE

$LABEL BALEQ
*    set the RHS according to the type of equation and/or commodity net bound/cost/tax/sub/cum
$    IF '%4%3' == BALFX  %VAR%_COMNET(R,T,C,S %SOW%)$RHS_COMBAL(R,T,C,S) +

*    demand projection
$IFI %STAGES% == YES $SETLOCAL SWS 'PROD(SW_MAP(T,SOW,J,WW)$S_COM_PROJ(R,T,C,J,WW),S_COM_PROJ(R,T,C,J,WW))*'
      ((%SWS% COM_PROJ(R,T,C)$(NOT RD_NLP(R,C)) +%VAR%_DEM(R,T,C%SOW%)$RD_NLP(R,C) +SUM(MI_DMAS(RD_AGG(R,COM),C),RD_SHAR(R,T,COM,C)*%VAR%_COMPRD(R,T,COM,'ANNUAL'%SOW%))) * COM_FR%MX%(R,T,C,S))$DEM(R,C)

$LABEL DONE
     ;
*$OFFLISTING
