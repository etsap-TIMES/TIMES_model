*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_LVLBR aggregate/inherit relative process bound attributes if different than level
*   %1 - attribute name (NCAP_AF, FLO_SHAR etc.)
*   %2 - other qualifying indexes ('','')
*   %3 - TS set shooting for (PRC_TS, RPS_S1 etc.)
*   %4 - UNCD7 residual dimension
*   %5 - qualifier to allow inheritance if some values found at target slices (0/1)
*   %6 - qualifier triggering the bound conflict test (0/1)
*   %7 - optional index in TS set
*=============================================================================*
OPTION CLEAR=UNCD7;
*-----------------------------------------------------------------------------
LOOP((RTP(R,V,P)%2,S,BD)$((NOT %3(R,P,%7S))$%1(R,V,P%2,S,BD)),
  F = 0; Z = 1;
  LOOP(RS_BELOW(R,TS,S)$Z,
* If value is below target level, aggregate only if value not found at target level
    IF(%1(R,V,P%2,TS,BD), F = 1; 
      IF(%3(R,P,%7TS), Z = 0; IF(NOT UNCD7(R,TS,P%2,TS,BD%4),
$        BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 01 '%1 Bounds conflict: Bound at %3 level and below, lower ignored'
         PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' TS=',TS.TL ;
         UNCD7(R,TS,P%2,TS,BD%4) = YES));
    ELSEIF %3(R,P,%7TS), Z = 0; UNCD7(R,V,P%2,TS,BD%4) = YES));
  IF(Z, Z = SUM(RS_BELOW(R,S,TS)$%1(R,V,P%2,TS,BD),EPS+(%1(R,V,P%2,TS,BD) > EPS)$%3(R,P,%7TS));
* If value above target level and no values found below or above, mark to be inherited down:
    IF(NOT (F+Z), UNCD7(R,V,P%2,S,BD%4) = YES;
* If value is above targets and all other values in the subtree are at non-target slices, mark to be leveled:
    ELSE Z=Z<1; UNCD7(R,V,P%2,TS,BD%4)$(RS_BELOW(R,S,TS)*%3(R,P,%7TS)*(Z+(NOT %1(R,V,P%2,TS,BD))$%5)) = YES)));
*-----------------------------------------------------------------------------
* Aggregation/inheritance to target timeslices
*-----------------------------------------------------------------------------
LOOP(UNCD7(R,V,P%2,TS,BD%4),
 IF(%3(R,P,%7TS),
* Leveling by simultaneous aggregation/inheritance
   TS_ARRAY(ALL_TS) = %1(R,V,P%2,ALL_TS,BD);
    %1(R,V,P%2,TS,BD) $=
      SUM(RS_TREE(FINEST(R,S),TS), G_YRFR(R,S) * (TS_ARRAY(S) + 
           SUM(RS_BELOW(R,ALL_TS,S)$((NOT SUM(TS_MAP(R,SL,S)$RS_BELOW(R,ALL_TS,SL),TS_ARRAY(SL)))$TS_ARRAY(ALL_TS)),
               TS_ARRAY(ALL_TS))))/G_YRFR(R,TS);
* Otherwise just simple direct inheritance down
  ELSE Z = %1(R,V,P%2,TS,BD); %1(R,V,P%2,S,BD)$(RS_BELOW(R,TS,S)$%3(R,P,%7S)) = Z));
*-----------------------------------------------------------------------------
OPTION CLEAR=UNCD7;
IF(%6, PUTGRP = 0;
  LOOP((R,V,P%2,S)$%1(R,V,P%2,S,'FX'),
* check to see if both LO/FX and UP/FX at same S
    IF(%3(R,P,%7S) AND (%1(R,V,P%2,S,'UP') + %1(R,V,P%2,S,'LO')),
$     BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 01 '%1 Bounds conflict: FX + LO/UP at same TS-level, latter ignored'
      PUT QLOG ' WARNING       -     R=',%RL%,' Y=',V.TL,' P=',%PL%,' S=',S.TL ;
      UNCD7(R,V,P%2,S,'0'%4) = YES;));
  IF(PUTGRP, %1(R,V,P%2,S,BDNEQ)$UNCD7(R,V,P%2,S,'0'%4) = 0;
    OPTION CLEAR=UNCD7));
