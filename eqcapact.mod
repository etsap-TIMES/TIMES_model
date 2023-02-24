*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQCAPACT is the capacity utilization equation
*   %1 - equation declaration type
*   %2 - bound type for %1
*=============================================================================*
* Questions/Comments:
*  - COEF_CPT is defined in COEF_CPT.MOD
*  - COEF_AF established by applying SHAPE in COEF_CPT.MOD
*  - Commodity-specific AF handled by EQ(l)_CAFLAC (VDA extension)
*-----------------------------------------------------------------------------
$SETLOCAL PASS ''
$IF DEFINED RPS_CAFLAC $SETLOCAL PASS %PASS%*(NOT RPS_CAFLAC(R,P,S,'%2'))

  SET AFS(R,T,P,S,BD) //;
* COEF_AFs are always at PRC_TS or above, can be directly used for testing:
$IF %1==L LOOP(V,AFS(RTP_VARA(R,T,P),S,BD)$COEF_AF(R,V,T,P,S,BD)=YES); AFS(RTPS_OFF,BD) = NO;

  %EQ%%1_CAPACT(RTP_VINTYR(%R_V_T%,P),S %SWT%)$(AFS(R,T,P,S,'%2') %PASS%) ..

* normal processes
      SUM(PRC_TS(R,P,TS)$TS_MAP(R,S,TS),%VAR%_ACT(R,V,T,P,TS %SOW%))$(NOT RP_STG(R,P))
      +
* storage: parent timeslice fraction of the number of storage cycles in a year
      SUM(PRC_TS(R,P,TS)$RS_FR(R,TS,S),(%VAR%_ACT(R,V,T,P,TS %SOW%)+VAR_STS(R,V,T,P,TS,'%2'))*RS_FR(R,TS,S)*EXP(PRC_SC(R,P))/RS_STGPRD(R,TS))$RP_STG(R,P)

  =%1=

      (
* process is not vintaged
$IF %VALIDATE% == 'YES' $GOTO CAPIT
        (SUM(MODLYEAR$COEF_CPT(R,MODLYEAR,T,P),
             COEF_CPT(R,MODLYEAR,T,P) * COEF_AF%3(R,MODLYEAR,T,P,S,'%2') *
             (%VARM%_NCAP(R,MODLYEAR,P %SWS%)$T(MODLYEAR) + NCAP_PASTI(R,MODLYEAR,P)$PASTYEAR(MODLYEAR)%RCAPSBM%)
            ) * PRC_CAPACT(R,P)
$LABEL CAPIT
$IF %VALIDATE% == 'YES' (COEF_AF(R,T,T,P,S,'%2') * PRC_CAPACT(R,P) * %VAR%_CAP(R,T,P %SOW%)
        )$(NOT PRC_VINT(R,P)) +

* process is vintaged
        (COEF_AF%3(R,V,T,P,S,'%2') * COEF_CPT(R,V,T,P) * PRC_CAPACT(R,P) *
         (%VARV%_NCAP(R,V,P %SWS%)$T(V) + NCAP_PASTI(R,V,P)$PASTYEAR(V)%RCAPSUB%))$PRC_VINT(R,P)
      ) *

* UR 10/05/00
* capacity of storage process fully available in each time slice
      POWER(G_YRFR(R,S),1-1$RP_STG(R,P))

  ;
