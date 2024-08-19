*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2024 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* CAL_FFLO the code associated with the flow variable in the EQ_COMxxx
*   %1 - 'IN/OUT' for consumption/production
**  %2 - 'I/O' for invest/decommission checks (no longer used)
*   %3 - * Peak multiplier
*   %4 - Peak by flow contribution
*=============================================================================*
*GaG Questions/Comments:
*  - VAR_FLOs according to whether c-in-PCG otherwise RPS_S1
*-----------------------------------------------------------------------------
$IF %REDUCE% == YES $GOTO REDUCE
$SET SHP1 "" SET SHG ",P,CG3,C"
$IF DEFINED RTP_FFCS $SET SHP1 "*(%SHFF%S(R,V%SHG%%SOW%))"
$SET SHP1 "*(%SHFF%X(R,V,T%SHG%)$PRC_VINT(R,P))%SHP1%"
*-----------------------------------------------------------------------------
*V05c 980923 - check that commodity not just capacity related
         SUM(TOP(RP_FLO(R,P),C,'%1')$(NOT RPC_EMIS(R,P,C)),
             SUM((RTP_VNTBYR(R,T,P,V),RTPCS_VARF(R,T,P,C,TS)),
* equation coarser than variable or equation finer than variable
* consider COM_TS shape too, so both TS_MAP and RS_BELOW embedded
               %VAR%_FLO(R,V,T,P,C,TS %SOW%) * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS)) %3)%4
         ) +
* Handle RPC_EMIS flows separately; They cannot be NOFLO
         SUM(TOP(RPC_EMIS(RP_FLO(R,P),C),'%1')%4,
           SUM((FS_EMIT(R,P,C,CG3,COM2),RTPCS_VARF(R,T,P,COM2,TS))$RS_FR(R,S,TS),
             SUM(RTP_VNTBYR(R,T,P,V),%VAR%_FLO(R,V,T,P,COM2,TS %SOW%) *
                COEF_PTRAN(R,V,P,CG3,COM2,C,TS) %SHP1% %3) *
             RS_FR(R,S,TS)*(1+RTCS_FR(R,T,COM2,S,TS)))) +
$EXIT
*-----------------------------------------------------------------------------
$LABEL REDUCE
* [UR] model reduction %REDUCE% is set in *.run
* Sum over non-vintaged processes
         SUM(TOP(RP_FLO(R,P),C,'%1')$(NOT PRC_VINT(R,P)),
             SUM(RTPCS_VARF(R,V(T),P,C,TS),
$              BATINCLUDE cal_red.red C COM TS P T '' T
* equation coarser than variable or equation finer than variable
               * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS)) %3)%4
         ) +

* Sum over vintaged processes
         SUM((TOP(PRC_VINT(RP_FLO(R,P)),C,'%1'),RTPCS_VARF(R,T,P,C,TS))%4,
$              BATINCLUDE cal_red.red C COM TS P T '' V SUM 'RTP_VNTBYR(R,T,P,V),' %3
* equation coarser than variable or equation finer than variable
               * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS))
         ) +
