*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* PP_LVLUS aggregate/inherit UC_N attributes if at different than target level
*   %1 - attribute name (UC_ACT, UC_FLO etc.)
*   %2 - other qualifying indexes before S index (e.g. ',C')
*   %3 - TS set shooting for (PRC_TS, RPCS etc.)
*   %4 - UNCD7 residual dimension
*   %5 - optional remaining indexes (e.g. 'IE')
*   %6 - optional UC_N qualifying indexes (e.g. COM_VAR)
*=============================================================================*
OPTION CLEAR=UNCD7;

LOOP((UC_N%6,SIDE,R,T,%2,S%5)$%1(UC_N%6,SIDE,R,T,%2,S%5),
 IF(NOT %3(R,%2,S), Z = 1;
   IF(NOT UNCD7(UC_N%6,SIDE,R,%2%5,'0'%4), UNCD7(UC_N%6,SIDE,R,%2%5,'0'%4) = YES;
     IF(TS_GROUP(R,'ANNUAL',S), IF(NOT SUM((RS_BELOW(R,S,TS),MILESTONYR),%1(UC_N%6,SIDE,R,MILESTONYR,%2,TS%5)),
* No values below an ANNUAL level value: inherit value down
       Z = 0; UNCD7(UC_N%6,SIDE,R,%2,S%5%4) = YES;));
     IF(Z, UNCD7(UC_N%6,SIDE,R,%2,TS%5%4)$%3(R,%2,TS) = YES;))));
*-----------------------------------------------------------------------------
* Aggregation/inheritance to target timeslices
*-----------------------------------------------------------------------------
LOOP(UNCD7(UC_N%6,SIDE,R,%2,TS%5%4),
 IF(%3(R,%2,TS),
* Leveling by simultaneous aggregation/inheritance; but only if target level value is not present
  LOOP(T, TS_ARRAY(S) = %1(UC_N%6,SIDE,R,T,%2,S%5);
   %1(UC_N%6,SIDE,R,T,%2,TS%5)$(NOT TS_ARRAY(TS)) $=
     SUM(RS_TREE(FINEST(R,S),TS), G_YRFR(R,S) * (TS_ARRAY(S) + 
         SUM(RS_BELOW(R,ALL_TS,S)$((NOT SUM(TS_MAP(R,SL,S)$RS_BELOW(R,ALL_TS,SL),TS_ARRAY(SL)))$TS_ARRAY(ALL_TS)),
            TS_ARRAY(ALL_TS))))/G_YRFR(R,TS));
 ELSE MY_ARRAY(T) = %1(UC_N%6,SIDE,R,T,%2,TS%5); 
* Simple direct inheritance down
   %1(UC_N%6,SIDE,R,T,%2,S%5)$(RS_BELOW(R,TS,S)$%3(R,%2,S)) $= MY_ARRAY(T);));
*-----------------------------------------------------------------------------
OPTION CLEAR=UNCD7;

