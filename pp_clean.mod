*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*-----------------------------------------------------------------------
* PP_CLEAN.mod - Release memory by clearing items no longer used
*-----------------------------------------------------------------------
* Only items not used in any equations can be cleared; to be careful!
$IF %MEMCLEAN%==NO $EXIT
*-----------------------------------------------------------------------
FLO_SUM(R,ALLYEAR,P,CG1,C,CG2,S) = 0;
FLO_FUNC(R,ALLYEAR,P,CG1,CG2,S) = 0;
NCAP_AF(R,ALLYEAR,P,S,BD) = 0;
NCAP_AFA(R,ALLYEAR,P,BD) = 0;
NCAP_AFS(R,ALLYEAR,P,S,BD) = 0;
NCAP_COST(R,ALLYEAR,P,CUR) = 0;
NCAP_FOM(R,ALLYEAR,P,CUR) = 0;
ACT_COST(R,ALLYEAR,P,CUR) = 0;
FLO_TAX(R,ALLYEAR,P,C,S,CUR) = 0;
FLO_SUB(R,ALLYEAR,P,C,S,CUR) = 0;
FLO_COST(R,ALLYEAR,P,C,S,CUR) = 0;
FLO_DELIV(R,ALLYEAR,P,C,S,CUR) = 0;

$IF NOT SET BENCOST $SETGLOBAL BENCOST NO
$IFI NOT '%BENCOST%'=='NO'
$IFI EXIST timesrng.inc execute 'mv -f timesrng.inc timesrng_bak.inc';

