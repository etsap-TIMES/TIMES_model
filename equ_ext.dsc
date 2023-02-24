*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQ_EXT.EXT declarations & call for actual equations                         *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
* Questions/Comments:
*-----------------------------------------------------------------------------
$IF NOT DEFINED PRC_DSCNCAP $EXIT
$SETGLOBAL SOLMIP YES
*-----------------------------------------------------------------------------
* Discrete investments

  EQUATIONS
  %EQ%_DSCNCAP(R,ALLYEAR,P%SWTD%)  'Discrete capacity extension (=E=)'
  %EQ%_DSCONE(R,ALLYEAR,P%SWTD%)   'Discrete capacity extension unity condition (=E=)'
;
$IF '%STAGES%'==YES $%WITSPINE% %SW_STVARS%
*-----------------------------------------------------------------------------
  %EQ%_DSCNCAP(RTP(%R_T%,P)%SWT%)$PRC_DSCNCAP(R,P)..

    %VAR%_NCAP(R,T,P%SOW%) =E=

    SUM(UNIT$NCAP_DISC(R,T,P,UNIT), %VAR%_DNCAP(R,T,P%SOW%,UNIT)*NCAP_DISC(R,T,P,UNIT)) +
    %VAR%_SNCAP(R,T,P%SOW%)$NCAP_SEMI(R,T,P);

  %EQ%_DSCONE(RTP(%R_T%,P)%SWT%)$(NCAP_DISC(R,T,P,'0')$PRC_DSCNCAP(R,P))..

    SUM(UNIT$NCAP_DISC(R,T,P,UNIT), %VAR%_DNCAP(R,T,P%SOW%,UNIT))  =E=  1;

*-----------------------------------------------------------------------------
