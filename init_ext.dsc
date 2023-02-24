*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* INIT_EXT.xtd oversees initial preprocessor activities                       *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
* Questions/Comments:
*-----------------------------------------------------------------------------
* Handle automatic activation of discrete extension
$IF DEFINED PRC_DSCNCAP NCAP_DISC(R,T--ORD(T),P,'0')$PRC_DSCNCAP(R,P) = EPS;
$IF DEFINED NCAP_SEMI OPTION PRC_SEMI<NCAP_SEMI; NCAP_DISC(R,LL,P,'0')$PRC_SEMI(R,P)=NCAP_SEMI(R,LL,P)+10$((NOT NCAP_SEMI(R,LL,P))$LASTLL(LL)); PRC_SEMI(R,P)$=NCAP_DISC(R,'0',P,'0');
$IFI %DSCAUTO%==YES 
$IF DEFINED NCAP_DISC OPTION PRC_DSCNCAP < NCAP_DISC;
$IF NOT DEFINED RCAP_BLK
$IF NOT DEFINED PRC_DSCNCAP $SETGLOBAL DSC NO
$IF NOT DEFINED RCAP_BLK  OPTION CLEAR=RCAP_BLK;
$IF NOT DEFINED NCAP_DISC OPTION CLEAR=NCAP_DISC;
$IF NOT DEFINED NCAP_SEMI OPTION CLEAR=NCAP_SEMI;
