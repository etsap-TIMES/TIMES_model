*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* DUMPSOL.MOD displays selected solution results                              *
*   %1 - mod or v# for the source code to be used                             *
*   %2 - NO_EMTY if headers to be surpressed if no row                        *
*=============================================================================*
*GaG Questions/Comments:
*-----------------------------------------------------------------------------
FILE SOLDUMP; PUT SOLDUMP;
SOLDUMP.PW=255;
$SET NO_EMTY '%2'

$BATINCLUDE dumpsol1.mod 'L' VAR_NCAP VAR_CAP VAR_COMPRD
$BATINCLUDE dumpsolv.mod 'L' VAR_ACT VAR_FLO VAR_IRE VAR_SIN VAR_SOUT
$BATINCLUDE dumpsol1.mod 'M' VAR_NCAP VAR_CAP VAR_COMPRD
$BATINCLUDE dumpsolv.mod 'M' VAR_ACT VAR_FLO VAR_IRE VAR_SIN VAR_SOUT

$BATINCLUDE dumpsol1.mod 'L' EQG_COMBAL EQE_COMBAL EQE_COMPRD
$BATINCLUDE dumpsol1.mod 'M' EQG_COMBAL EQE_COMBAL EQE_COMPRD

PARAMETER VARACT(R,T,P) / EMPTY.EMPTY.EMPTY 0 /;
VARACT(RTP(R,T,P)) = SUM((V,S), VAR_ACT.L(R,V,T,P,S));
$BATINCLUDE dumpsol1.mod 'T' VARACT

PUTCLOSE SOLDUMP;
