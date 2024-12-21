*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2024 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* INIT_EXT.xtd oversees initial preprocessor activities                       *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
* Questions/Comments:
*-----------------------------------------------------------------------------
* Handle automatic activation of discrete extension
$ IF DEFINED PRC_DSCNCAP NCAP_DISC(R,T--ORD(T),P,'0')$PRC_DSCNCAP(R,P) = EPS;
  OPTION PRC_SEMI<NCAP_SEMI; NCAP_SEMI(R,'0',P)$((NCAP_SEMI(R,'0',P)=0)$PRC_SEMI(R,P)) = 10;
$ IFE CARD(NCAP_SEMI) PRC_SEMI(R,P) $= NCAP_SEMI(R,'0',P); NCAP_DISC(R,LL,P,'0') $= NCAP_SEMI(R,LL,P); 
$ SET DSC NO
$ IFI %DSCAUTO%==YES
$ IF DEFINED NCAP_DISC OPTION PRC_DSCNCAP < NCAP_DISC;
$ IF DEFINED PRC_DSCNCAP $SET DSC YES
$ IF DEFINED RCAP_BLK $SETGLOBAL SOLMIP YES
$ IF %DSC%==YES $SETGLOBAL SOLMIP YES
$ IF NOT DEFINED NCAP_DISC $CLEAR NCAP_DISC
$ IF NOT DEFINED RCAP_BLK  $CLEAR RCAP_BLK
$ SETGLOBAL DSC %DSC%
