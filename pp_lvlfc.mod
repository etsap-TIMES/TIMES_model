*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_LVLPC aggregate/inherit attributes if at different than target level
* Parameter arguments must be of the form (R,V,{P/C/P,C},S[,xx]*)
*   %1 - attribute name (FLO_COST, FLO_TAX etc.)
*   %2 - 'P', 'C' 'COM' or 'P,C' depending on attribute
*   %3 - TS set shooting for
*   %4 - remaining indexes (e.g. ',CUR')
*   %5 - UNCD7 residual dimension
*   %6 - ALL_TS or TS depending on whether inheritance is allowed
*   %7 - YEAR set to look for data (DATAYEAR/XMILE/V/'')
*   %8 - Existence qualifier set or YES
*   %9 - Optional indicator for weighting: Use 1 if inheritance is weighted
*  %10 - Optional indexes between TS set items and the S index
*=============================================================================*
OPTION CLEAR=UNCD7;
$SETLOCAL TAKE '%12' SETLOCAL REGY 'R,%7' SETLOCAL TS (NOT %3(R,%2,S))$
$SETLOCAL AWGT 'G_YRFR(R,S)/G_YRFR(R,TS)' SETLOCAL IWGT ''
$IF '%7' == '' $SETLOCAL REGY 'R'
$IF '%6' == 'S2' $SETLOCAL TS ''
$IF '%9' == '1' $SETLOCAL AWGT '1' SETLOCAL IWGT '*G_YRFR(R,S)/G_YRFR(R,%6)'
$IF '%11'=='N' $SETLOCAL TAKE $%1(R,'0',%2%10,'ANNUAL'%4)
$IF '%11'=='N' %1(R,LL--ORD(LL),%2%10,S+STOA(S)%4)$(STOAL(R,S)$%1(R,LL,%2%10,S%4)) = 1;
*-----------------------------------------------------------------------------
* Mark to be levelized if inheritance is allowed or S is not ANNUAL:
LOOP((%REGY%,%2%10,S%4)$(%TS%%1(%REGY%,%2%10,S%4)), UNCD7(%REGY%,%2%10%4%5)$(%8%TAKE%) = YES);
*-----------------------------------------------------------------------------
* Aggregation/inheritance to target timeslices
*-----------------------------------------------------------------------------
LOOP(UNCD7(%REGY%,%2%10%4%5), TS_ARRAY(S) = %1(%REGY%,%2%10,S%4);
 IF((NOT SUM(RS_BELOW(R,'ANNUAL',S)$TS_ARRAY(S),1))$TS_ARRAY('ANNUAL'),
   %1(%REGY%,%2%10,S%4)$%3(R,%2,S) = SUM(ANNUAL(%6),TS_ARRAY(%6)%IWGT%);
 ELSE
* Leveling by simultaneous aggregation/inheritance; but only if target level value is not present
   LOOP(%3(R,%2,TS)$(NOT TS_ARRAY(TS)),
    %1(%REGY%,%2%10,TS%4) $=
     SUM(TS_MAP(R,TS,S)$FINEST(R,S), %AWGT% * (TS_ARRAY(S) +
            SUM(RS_BELOW(R,%6,S)$(TS_ARRAY(%6) AND NOT SUM(SL$RS_BELOW(R,%6,SL),TS_MAP(R,SL,S)*TS_ARRAY(SL))),
                       TS_ARRAY(%6)%IWGT%)));)));
*-----------------------------------------------------------------------------
$IF '%11'==0  %1(%REGY%,%2%10,S%4)$((NOT %1(%REGY%,%2%10,S%4))$%3(R,%2,S)) $= %1(%REGY%,%2%10,'ANNUAL'%4);
$IF NOT '%11'=='' %1(R,LL,%2%10,S%4)$((NOT %3(R,%2,S))%TAKE%) = 0;
