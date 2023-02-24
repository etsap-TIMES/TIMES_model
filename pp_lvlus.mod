*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
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
    IF((NOT %3(R,%7%10,S))$STOA(S),
      IF(NOT UNCD7(UC_N%6,SIDE,R,%2%5,'OUT'%4), UNCD7(UC_N%6,SIDE,R,%2%5,'OUT'%4)=YES;
        F=SMAX(%7%8_TSL(R,%7,TSL),MAX(%9+EPS,ORD(TSL)-1)); IF(F<STOAL(R,S),UNCD7(UC_N%6,SIDE,R,%2%5,'IN'%4)=YES))));
*-----------------------------------------------------------------------------
* Simultaneous aggregation/inheritance to target timeslices
*-----------------------------------------------------------------------------
  LOOP(UNCD7(UC_N%6,SIDE,R,%2%5,IO%4),
    IF(IPS(IO), F=0;
*...Leveling by simultaneous aggregation/inheritance; but only if target level value is not present
    LOOP(T, TS_ARRAY(S) = %1(UC_N%6,SIDE,R,T,%2,S%5);
      %1(UC_N%6,SIDE,R,T,%2,TS%5)$((NOT TS_ARRAY(TS))$%3(R,%7%10,TS)) $=
        SUM(RS_TREE(FINEST(R,S),TS), G_YRFR(R,S) * (TS_ARRAY(S) +
          SUM(RS_BELOW(R,ALL_TS,S)$((NOT SUM(TS_MAP(R,SL,S)$RS_BELOW(R,ALL_TS,SL),TS_ARRAY(SL)))$TS_ARRAY(ALL_TS)),
            TS_ARRAY(ALL_TS))))/G_YRFR(R,TS))
    ELSEIF F,
*...Inherit all from above
    LOOP(T, TS_ARRAY(S) = %1(UC_N%6,SIDE,R,T,%2,S%5);
      LOOP(RJLVL(J,R,TSL)$(ORD(TSL)<4),
        LOOP(TS_GROUP(R,TSL,TS),TS_ARRAY(S)$(NOT TS_ARRAY(S)) $= TS_ARRAY(TS)$RS_BELOW(R,TS,S));
      %1(UC_N%6,SIDE,R,T,%2,S%5)$%3(R,%7%10,S) $= TS_ARRAY(S)));
    ELSE F=1));
*-----------------------------------------------------------------------------
  %1(UC_N%6,SIDE,R,T,%2,S%5)$(%3(R,%7%10,S)$(NOT %1(UC_N%6,SIDE,R,T,%2,S%5))) $= %1(UC_N%6,SIDE,R,T,%2,'ANNUAL'%5);
  OPTION CLEAR=UNCD7;