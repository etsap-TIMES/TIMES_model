*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQIREBND limits the activity of inter-regional exchange process
*   %1 - equation declaration type
*   %2 - bound type for %1
*   %3 - qualifier that bound exists
*=============================================================================*
*GaG Questions/Comments:
*  - BND ts restricted to the PRC_TS level or above?
*UR* /12/09/99 commodity names can be different in the two regions
*-----------------------------------------------------------------------------
*$ONLISTING
*V0.5b 980902 - avoid equations if LO=0/UP=INF
*V0.6a 990301
  %EQ%%1_IREBND(R,%TX%,C,S,ALL_REG,IE %SWT%)$((RCS_COMTS(R,C,S) * SUM(RPC_IRE(R,P,C,IE),1) AND %3
                              )$IRE_BND(R,T,C,S,ALL_REG,IE,'%2')) ..

  (
* For imports from internal non-marketplace region, sum the associated exports
   SUM(TOP_IRE(REG(ALL_REG),COM,R,C,P)$RPC_EQIRE(R,P,C,'IMP'),
     SUM(SL$(RTPCS_VARF(R,T,P,C,SL)*RS_TREE(R,S,SL)),
       SUM((RTP_VINTYR(REG,V,T,P),RTPCS_VARF(REG,T,P,COM,TS),RS_TREE(REG,ALL_TS,TS))$IRE_TSCVT(REG,ALL_TS,R,SL),
         (%VAR%_IRE(REG,V,T,P,COM,TS,'EXP'%SOW%)$(NOT RPC_AIRE(REG,P,COM))+(%VAR%_ACT(REG,V,T,P,TS%SOW%)*PRC_ACTFLO(REG,V,P,COM))$RPC_AIRE(REG,P,COM))
              * IRE_FLO(REG,V,P,COM,R,C,SL) * IRE_CCVT(REG,COM,R,C) * IRE_TSCVT(REG,ALL_TS,R,SL)
              * RS_FR(REG,ALL_TS,TS)*(1+RTCS_FR(REG,T,COM,ALL_TS,TS))
* bound coarser than variable or bound finer than variable
          ) * (1$TS_MAP(R,S,SL) + (G_YRFR(R,S)/G_YRFR(R,SL))$RS_BELOW(R,SL,S))
        )
      )
   +
* For imports from external regions or marketplace, sum the flows directly in region R
   SUM(RPC_IRE(R,P,C,IE)$((NOT RPC_EQIRE(R,P,C,'IMP'))*SUM(TOP_IRE(ALL_REG,COM,R,C,P),1)),
     SUM((RTP_VINTYR(R,V,T,P),RTPCS_VARF(R,T,P,C,TS))$RS_TREE(R,S,TS),
       (%VAR%_IRE(R,V,T,P,C,TS,IE%SOW%)$(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C))
* bound coarser than variable or bound finer than variable
              * (1$TS_MAP(R,S,TS) + (G_YRFR(R,S)/G_YRFR(R,TS))$RS_BELOW(R,TS,S))
        )
      )
  )$IMP(IE)
  +
  (
* For exports from market region to internal region REG, sum the associated imports into REG
   SUM((RPC_MARKET(R,P,C,'EXP'),TOP_IRE(R,C,REG(ALL_REG),COM,P)),
     SUM((RTP_VINTYR(REG,V,T,P),RTPCS_VARF(REG,T,P,COM,TS),RS_TREE(REG,ALL_TS,TS))$IRE_TSCVT(REG,ALL_TS,R,S),
       (%VAR%_IRE(REG,V,T,P,COM,TS,'IMP'%SOW%)$(NOT RPC_AIRE(REG,P,COM))+(%VAR%_ACT(REG,V,T,P,TS%SOW%)*PRC_ACTFLO(REG,V,P,COM))$RPC_AIRE(REG,P,COM))
              * IRE_CCVT(REG,COM,R,C) * IRE_TSCVT(REG,ALL_TS,R,S)
              * RS_FR(REG,ALL_TS,TS)*(1+RTCS_FR(REG,T,COM,ALL_TS,TS))
          )
        )
  +
* For all other exports, sum the flows directly in region R
*UR* /12/09/99 commodity names can be different in the two regions
   SUM(RPC_IRE(R,P,C,IE)$((NOT RPC_MARKET(R,P,C,'EXP'))*SUM(TOP_IRE(R,C,ALL_REG,COM,P),1)),
     SUM((RTP_VINTYR(R,V,T,P),RTPCS_VARF(R,T,P,C,TS))$RS_TREE(R,S,TS),
       (%VAR%_IRE(R,V,T,P,C,TS,IE%SOW%)$(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C))
* bound coarser than variable or bound finer than variable
              * (1$TS_MAP(R,S,TS) + (G_YRFR(R,S)/G_YRFR(R,TS))$RS_BELOW(R,TS,S))
        )
      )
  )$XPT(IE)


  =%1=

       IRE_BND(R,T,C,S,ALL_REG,IE,'%2')
  ;
*$OFFLISTING
