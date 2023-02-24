*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQCOMBND limits the total NET/PRD of a commodity at a level above COM_TS
*   %1 - equation declaration type
*   %2 - bound type for %1
*   %3 - qualifier that bound exists
*   %4 - NET/PRD indicator
*=============================================================================*
*GaG Questions/Comments:
* V0.5c added
*-----------------------------------------------------------------------------
*$ONLISTING
  %EQ%%1_BND%4(RTC(%R_T%,C),S %SWT%)$((RCS_COMTS(R,C,S)$(NOT COM_TS(R,C,S))$%3)$COM_BND%4(R,T,C,S,'%2'))..

* sum over all possible commodity flow at/below TS-level
       SUM(RTCS_VARC(R,T,C,TS)$TS_MAP(R,S,TS), %VAR%_COM%4(R,T,C,TS %SOW%))

  =%1=

       COM_BND%4(R,T,C,S,'%2')
  ;
*$OFFLISTING
