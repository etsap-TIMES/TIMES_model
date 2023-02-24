*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQACTBND limits the activity of vintage processes or higher TS-level bounds
*   %1 - equation declaration type
*   %2 - bound type for %1
*   %3 - qualifier that bound exists
*=============================================================================*
* Questions/Comments:
*  - ACT_BND ts restricted to the PRC_TS level or above
*-----------------------------------------------------------------------------
*V0.5b 980902 - avoid equations if LO=0/UP=INF
*$ONLISTING
* [UR] 21.07.2003 tightended control for generation of equation to RTP_VARA
  %EQ%%1_ACTBND(RTP_VARA(%R_T%,P),S %SWT%)$((RPS_PRCTS(R,P,S)*(PRC_VINT(R,P)+(NOT PRC_TS(R,P,S)))$%3)$ACT_BND(R,T,P,S,'%2'))..

* sum over all possible at process TS-level
       SUM(PRC_TS(R,P,TS)$TS_MAP(R,S,TS),
* sum all the existing activities
           SUM(RTP_VINTYR(R,V,T,P), %VAR%_ACT(R,V,T,P,TS%SOW%))
       )

  =%1=

       ACT_BND(R,T,P,S,'%2')
  ;
*$OFFLISTING
