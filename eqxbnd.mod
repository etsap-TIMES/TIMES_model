*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQXBND limits the total exchange from internal + external regions
*   %1 - equation declaration type
*   %2 - bound type for %1
*   %3 - qualifier that bound exists
*=============================================================================*
*GaG Questions/Comments:
*  - BND ts restricted to the PRC_TS level or above?
*  - *** NOTE: IMPort SUMs all EXPorts and vise versa
*-----------------------------------------------------------------------------
*$ONLISTING
*V0.5b 980902 - avoid equations if LO=0/UP=INF
  %EQ%%1_XBND(ALL_REG,%TX%,C,S,IE %SWT%)$((SUM(RPC_IRE(ALL_REG,P,C,IE),1) *
                                   %3)$IRE_XBND(ALL_REG,T,C,S,IE,'%2')) ..

*-----------------------------------------------------------------------------
* if region is internal then handle by
*-----------------------------------------------------------------------------
* sum over all possible at process TS-level
       (SUM((RPC_IRE(REG(ALL_REG),P,C,IE),RTPCS_VARF(REG,T,P,C,TS))$RS_TREE(REG,S,TS),
* sum all the existing activities
            SUM(RTP_VINTYR(REG,V,T,P),
* [UR] model reduction %REDUCE% is set in *.run
              (%VAR%_IRE(REG,V,T,P,C,TS,IE%SOW%)$(NOT RPC_AIRE(REG,P,C)) +
               (%VAR%_ACT(REG,V,T,P,TS%SOW%)*PRC_ACTFLO(REG,V,P,C))$RPC_AIRE(REG,P,C)) *
* bound coarser than variable or bound finer than variable
                (1$TS_MAP(REG,S,TS) + (G_YRFR(REG,S)/G_YRFR(REG,TS))$RS_BELOW(REG,TS,S))
            )
       )) +

*-----------------------------------------------------------------------------
* if region is external then handle the internal guys
*-----------------------------------------------------------------------------
* sum over all possible at process TS-level
*V05c 980811 - use IMP/EXP sets instead of ordering
       (SUM(RPC_IRE(R,P,COM,IMPEXP(IE--1))$((TOP_IRE(ALL_REG,C,R,COM,P) * XPT(IE)) +
                                            (TOP_IRE(R,COM,ALL_REG,C,P) * IMP(IE))),
* sum all the existing activities
            SUM(RS_TREE(R,ALL_TS,TS)$(RTPCS_VARF(R,T,P,COM,TS)*IRE_TSCVT(R,ALL_TS,ALL_REG,S)),
                SUM(RTP_VINTYR(R,V,T,P),
* [UR] model reduction %REDUCE% is set in *.run
                  (%VAR%_IRE(R,V,T,P,COM,TS,IMPEXP%SOW%)$(NOT RPC_AIRE(R,P,COM)) +
                   (%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,COM))$RPC_AIRE(R,P,COM)) *
                    IRE_CCVT(R,COM,ALL_REG,C) * IRE_TSCVT(R,ALL_TS,ALL_REG,S) *
* ALL_TS coarser than variable or finer than variable
                    (1$TS_MAP(R,ALL_TS,TS) + (G_YRFR(R,ALL_TS)/G_YRFR(R,TS))$RS_BELOW(R,TS,ALL_TS))
                )
            )
       ))$(NOT REG(ALL_REG))

  =%1=

       IRE_XBND(ALL_REG,T,C,S,IE,'%2')
  ;
*$OFFLISTING
