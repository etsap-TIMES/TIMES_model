*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQFLOFR relationship between total flow and the flow in a specific timeslice
*   %1 - equation declaration type
*   %2 - LIM type of FLO_FR
*=============================================================================*
* Questions/Comments:
*  - FLO_FR must be specified on TS-level of the flow or above; value below will be ignored
*  - fraction of flows under parent timelice supported by a parent N (or negative) FLO_FR


  %EQ%%1_FLOFR(RTPC(%R_T%,P,C),S,L(%2)%SWT%)$(SUM(RPCS_VAR(RP_FLO(R,P),C,TS)$TS_MAP(R,S,TS),1)$FLO_FR(R,T,P,C,S,L))..

   SUM(RTP_VINTYR(R,V,T,P),%VAR%_FLO(R,V,T,P,C,S%SOW%)$IPS(L) +
     SUM(RS_BELOW1(R,SL,S),%VAR%_FLO(R,V,T,P,C,SL%SOW%)$FLO_FR(RTPC,SL,'N') +
       SUM(RTPCS_VARF(RTPC,TS)$(FLO_FR(RTPC,S,L)>-INF$RS_FR(R,SL,TS)),
$          BATINCLUDE %cal_red% C COM TS P T
          )$(NOT FLO_FR(RTPC,SL,'N')))$BD(L)) * ABS(FLO_FR(RTPC,S,L))

   =%1=

   SUM((RTP_VINTYR(R,V,T,P),RTPCS_VARF(RTPC,TS))$(STOA(TS)$TS_MAP(R,S,TS)),
$      BATINCLUDE %cal_red% C COM TS P T
      );
