*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PREP_EXT.xtd oversees extended preprocessor activities                      *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
* Questions/Comments:
* The default option for NCAP_DISC is 10 (no interpolation/extrapolation, 
* but migrate to milestone years)
*-----------------------------------------------------------------------------
$IF NOT DEFINED PRC_DSCNCAP $EXIT

* Inter-/extrapolation
$BATINCLUDE prepparm NCAP_DISC 'R' 'P,UNIT' ",'0','0','0'" MILESTONYR 'RTP(R,MILESTONYR,P)' 1

* Process semicontinuous requests
  NCAP_SEMI(RTP(R,T,P))$PRC_DSCNCAP(R,P) = (NCAP_DISC(RTP,'0')+1)-1;
  NCAP_SEMI(RTP)$SUM(UNIT(J)$NCAP_DISC(RTP,UNIT),1) = 0;
