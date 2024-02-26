*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2024 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_LVLIF set the level of a IRE_FLO attribute using aggregation/inheritance
*   %1 - mod or v# for the source code to be used
*=============================================================================*
*GaG Questions/Comments:
*  - Assumption is that values can be at any level
*-----------------------------------------------------------------------------
*$ONLISTING

  OPTION CLEAR=UNCD7; PUTGRP = 0;
*-----------------------------------------------------------------------------
  LOOP((REG,V,P,COM,R,C,S)$IRE_FLO(REG,V,P,COM,R,C,S),
    IF((NOT RPCS_VAR(R,P,C,S))$STOA(S),
      IF(NOT UNCD7(REG,V,P,COM,R,C,'N'),
        IF(NOT RPC_IRE(R,P,C,'IMP'),TRACKPC(R,P,C)=YES;
        ELSE UNCD7(REG,V,P,COM,R,C,'N') = YES))));
  LOOP(TRACKPC(R,P,C),
$    BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 02 'IRE_FLO import commodity not in TOP_IRE'
     PUT QLOG ' WARNING        -    R=',%RL%,' P=',%PL%,' C=',C.TL );
*-----------------------------------------------------------------------------
* Aggregation/inheritance to target timeslices
*-----------------------------------------------------------------------------
  LOOP(UNCD7(REG,V,P,COM,R,C,L),
* Leveling by simultaneous aggregation/inheritance; but only if target level value not present
     TS_ARRAY(S) = IRE_FLO(REG,V,P,COM,R,C,S);
     IRE_FLO(REG,V,P,COM,R,C,TS)$((NOT TS_ARRAY(TS))$PRC_TS(R,P,TS)) $=
         SUM(RS_TREE(FINEST(R,S),TS), G_YRFR(R,S) * (TS_ARRAY(S) +
           SUM(RS_BELOW(R,ALL_TS,S)$((NOT SUM(TS_MAP(R,SL,S)$RS_BELOW(R,ALL_TS,SL),TS_ARRAY(SL)))$TS_ARRAY(ALL_TS)),
             TS_ARRAY(ALL_TS))))/G_YRFR(R,TS));
*-----------------------------------------------------------------------------
* Simple direct inheritance down
  IRE_FLO(RTP(REG,V,P),COM,R,C,S)$((NOT IRE_FLO(REG,V,P,COM,R,C,S))$PRC_TS(R,P,S)) $= IRE_FLO(REG,V,P,COM,R,C,'ANNUAL');
  OPTION CLEAR=TRACKPC, CLEAR=UNCD7;

*$OFFLISTING
