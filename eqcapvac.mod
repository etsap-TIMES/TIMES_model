*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQCAPVAC is the capacity utilization equation for vintage-simulated processes
*   %1 - equation lim type
*   %2 - bound type for %1
*=============================================================================*
* Questions/Comments:
* - COEF_CSV is defined in COEF_CSV.MOD
*-----------------------------------------------------------------------------

 EQ%1_CAPVAC(RTP_VINTYR(%R_V_T%,P),S%SWX%)$(%SWTX%AFSV(R,T,P,S,'%2'))..

* Activity level at timeslice S
    SUM(PRC_TS(R,P,TS)$TS_MAP(R,S,TS),%VAR%_ACT(R,V,T,P,TS %SOW%))$(NOT RPS_CAFLAC(R,P,S,'%2')) +
* Flow levels when commodity-specific availabilities
    SUM((RPC_PG(R,P,C),COM_TMAP(R,COM_TYPE(CG),C)), (1/PRC_ACTFLO(R,V,P,C)) /
        (NCAP_AFCS(R,V,P,C,S)+PROD(XPT$NCAP_AFCS(R,V,P,CG,S),NCAP_AFCS(R,V,P,CG,S))$(NOT NCAP_AFCS(R,V,P,C,S))) *
        SUM(RPCS_VAR(R,P,C,TS)$TS_MAP(R,S,TS),%VAR%_FLO(R,V,T,P,C,TS %SOW%)$RP_STD(R,P) +
          SUM(RPC_IRE(R,P,C,IE),%VAR%_IRE(R,V,T,P,C,TS,IE %SOW%))))$RPS_CAFLAC(R,P,S,'%2')

  =%1=

* process is vintaged
    SUM(MODLYEAR(K)$COEF_CSV(R,K,T,P,V),COEF_CSV(R,K,T,P,V)*COEF_AF(R,K,T,P,S,'%2')*%VARM%_NCAP(R,K,P%SWS%)$T(K)+NCAP_PASTI(R,K,P))*PRC_CAPACT(R,P)*G_YRFR(R,S)
  ;


