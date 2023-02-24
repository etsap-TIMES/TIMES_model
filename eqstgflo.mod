*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQSTGFLO limits the flow of storage process at flow TS-level or higher
*   %1 - IN/OUT
*   %2 - equation declaration type
*   %3 - bound type for %2
*   %4 - qualifier that bound exists
*=============================================================================*
*GaG Questions/Comments:
*  - Bound TS restricted to the PRC_TS level or above
*  - avoid equations if LO=0/UP=INF
*-----------------------------------------------------------------------------
$SET TMP (NOT PRC_MAP(R,'NST',P))+
$IF %1==OUT $SET TMP NOT
*$ONLISTING

  %EQ%%2_STG%1(RTPC(%R_T%,P,C),S %SWT%)$((STG%1_BND(R,T,P,C,S,'%3') NE %4)$(PRC_VINT(R,P)+(NOT RPCS_VAR(R,P,C,S)))
                                         $RPS_PRCTS(R,P,S)$RPC_STG(R,P,C)$STG%1_BND(R,T,P,C,S,'%3')) ..

* sum over all possible flow variables at process TS-level
       SUM(RPCS_VAR(R,P,C,TS)$(RS_FR(R,S,TS) * (%TMP% PRC_NSTTS(R,P,TS))),
           SUM(RTP_VINTYR(R,V,T,P),%VAR%_S%1(R,V,T,P,C,TS %SOW%)*RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS))))

  =%2=

       STG%1_BND(R,T,P,C,S,'%3')
  ;
*$OFFLISTING
