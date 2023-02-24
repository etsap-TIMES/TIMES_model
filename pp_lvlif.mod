*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
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
    IF(NOT RPCS_VAR(R,P,C,S),
     IF(NOT UNCD7(REG,P,COM,R,C,'0','0'), UNCD7(REG,P,COM,R,C,'0','0') = YES;
       IF(NOT RPC_IRE(R,P,C,'IMP'),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 02 'IRE_FLO import commodity not in TOP_IRE'
         PUT QLOG ' WARNING        -    R=',%RL%,' P=',%PL%,' C=',C.TL ;
       );
       IF((NOT SUM((RS_BELOW(R,S,TS),MODLYEAR),IRE_FLO(REG,MODLYEAR,P,COM,R,C,S)))$SAMEAS('ANNUAL',S),
* No values below an ANNUAL level value: inherit value down
            UNCD7(REG,P,COM,R,C,S,'') = YES;
       ELSE UNCD7(REG,P,COM,R,C,TS,'')$RPCS_VAR(R,P,C,TS) = YES;))));
*-----------------------------------------------------------------------------
* Aggregation/inheritance to target timeslices
*-----------------------------------------------------------------------------
  LOOP(UNCD7(REG,P,COM,R,C,TS,''),
    IF(RPCS_VAR(R,P,C,TS),
* Leveling by simultaneous aggregation/inheritance; but only if target level value is not present
     LOOP(RTP(REG,V,P), TS_ARRAY(S) = IRE_FLO(REG,V,P,COM,R,C,S);
       IRE_FLO(REG,V,P,COM,R,C,TS)$(NOT TS_ARRAY(TS)) $=
         SUM(RS_TREE(FINEST(R,S),TS), G_YRFR(R,S) * (TS_ARRAY(S) +
           SUM(RS_BELOW(R,ALL_TS,S)$((NOT SUM(TS_MAP(R,SL,S)$RS_BELOW(R,ALL_TS,SL),TS_ARRAY(SL)))$TS_ARRAY(ALL_TS)),
             TS_ARRAY(ALL_TS))))/G_YRFR(R,TS));
    ELSE MY_ARRAY(V) = IRE_FLO(REG,V,P,COM,R,C,TS);
* Simple direct inheritance down
     IRE_FLO(RTP(REG,V,P),COM,R,C,S)$(RS_BELOW(R,TS,S)$RPCS_VAR(R,P,C,S)) $= MY_ARRAY(V);));
*-----------------------------------------------------------------------------
OPTION CLEAR=UNCD7;

*$OFFLISTING

