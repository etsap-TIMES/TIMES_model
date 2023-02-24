*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* MOD_VARS.EXT EXTENSION VARIABLES
* called from MAINDRV.MOD
*=============================================================================*
*-----------------------------------------------------------------------------*
* Discrete capacity extensions
*-----------------------------------------------------------------------------*
* Investments
$SETGLOBAL SEMICONT SEMICONT
SOS1 VARIABLE %VAR%_DNCAP(R,ALLYEAR,P%SWD%,UNIT);
%SEMICONT% VARIABLE %VAR%_SNCAP(R,ALLYEAR,P%SWD%);

* Bounds for semicont
%VAR%_SNCAP.LO(R,T,P%SOW%) $= NCAP_SEMI(R,T,P);
%VAR%_SNCAP.UP(R,T,P%SOW%)$NCAP_SEMI(R,T,P) = MAX(NCAP_SEMI(R,T,P),NCAP_BND(R,T,P,'UP'));