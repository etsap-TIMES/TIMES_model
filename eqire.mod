*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQIRE ensure that inter-regional imports/exports match up                   *
*=============================================================================*
* Questions/Comments:
* UR 08/24/01: import flows have to be at PRC_TS(REG,P,S), alternative would be to allow RTPCS_VARF
*              to be at a different level using RTCS_TSFR to bring it to the right TSLVL
*-----------------------------------------------------------------------------
*$ONLISTING

   %EQ%_IRE(RTP%RTPX%(REG,%TX%,P),COM,IE,S %SWT%)$(RPCS_VAR(REG,P,COM,S)$RPC_EQIRE(REG,P,COM,IE)) ..


* the imports/exports of commodity COM into REG at timeslice S
      SUM(RTP_VINTYR(REG,V,T,P)$RTPCS_VARF(REG,T,P,COM,S),
          %VAR%_IRE(REG,V,T,P,COM,S,IE%SOW%)$(NOT RPC_AIRE(REG,P,COM))+(%VAR%_ACT(REG,V,T,P,S%SOW%)*PRC_ACTFLO(REG,V,P,COM))$RPC_AIRE(REG,P,COM)
         ) * (1-2*XPT(IE))
      +
* sum also the imports in other regions in case of market-based equation
      SUM(TOP_IRE(REG,COM1,R,C,P)$((NOT SAMEAS(REG,R))$RPC_MARKET(REG,P,COM1,'EXP')),
        SUM((RTP_VINTYR(R,V,T,P),RTPCS_VARF(R,T,P,C,TS),RS_TREE(R,ALL_TS,TS))$IRE_TSCVT(R,ALL_TS,REG,S),
            (%VAR%_IRE(R,V,T,P,C,TS,'IMP'%SOW%)$(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C))
             * IRE_CCVT(R,C,REG,COM1) * IRE_TSCVT(R,ALL_TS,REG,S)
             * RS_FR(R,ALL_TS,TS)*(1+RTCS_FR(R,T,C,ALL_TS,TS))
           ) * IRE_CCVT(REG,COM1,REG,COM)
         )$RPC_MARKET(REG,P,COM,'IMP')
      +
* sum also the imports in other regions in case of market-based equation: EXP case
      SUM(TOP_IRE(REG,COM,R,C,P),
        SUM((RTP_VINTYR(R,V,T,P),RTPCS_VARF(R,T,P,C,TS),RS_TREE(R,ALL_TS,TS))$IRE_TSCVT(R,ALL_TS,REG,S),
            (%VAR%_IRE(R,V,T,P,C,TS,'IMP'%SOW%)$(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C))
             / IRE_FLO(REG,V,P,COM,R,C,TS) * IRE_TSCVT(R,ALL_TS,REG,S)
             * RS_FR(R,ALL_TS,TS)*(1+RTCS_FR(R,T,C,ALL_TS,TS))
           ) * IRE_CCVT(R,C,REG,COM)
         )$XPT(IE)

    =E=

* sum the associated exports
      SUM((TOP_IRE(R,C,REG,COM,P),ALL_TS)$IRE_TSCVT(R,ALL_TS,REG,S),
        SUM((RTP_VINTYR(R,V,T,P),RTPCS_VARF(R,T,P,C,TS))$RS_FR(R,ALL_TS,TS),
            (%VAR%_IRE(R,V,T,P,C,TS,'EXP'%SOW%)$(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C))
* [AL] IRE_TSCVT converts from ALL_TS to S, and RTCS_TSFR from TS to ALL_TS:
             * IRE_FLO(R,V,P,C,REG,COM,S) * IRE_TSCVT(R,ALL_TS,REG,S)
             * RS_FR(R,ALL_TS,TS)*(1+RTCS_FR(R,T,C,ALL_TS,TS))
           ) * IRE_CCVT(R,C,REG,COM)
         )$IMP(IE)

    ;

*$OFFLISTING

