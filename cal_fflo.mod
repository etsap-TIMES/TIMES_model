*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* CAL_FFLO the code associated with the flow variable in the EQ_COMxxx
*   %1 - 'IN/OUT' for consumption/production
**  %2 - 'I/O' for for invest/decommission checks (for now - NO LONGER USED)
*   %3 - * Peak multiplier
*=============================================================================*
*GaG Questions/Comments:
*  - VAR_FLOs according to whether c-in-PCG otherwise RPS_S1
*-----------------------------------------------------------------------------
$IF %REDUCE% == 'YES' $GOTO REDUCE
$SET SHP1 "" SET SHG ",P,CG3,C"
$IF DEFINED RTP_FFCS $SET SHP1 "*(%SHFF%S(R,V%SHG%%SOW%))"
$SET SHP1 "*(%SHFF%X(R,V,T%SHG%)$PRC_VINT(R,P))%SHP1%"
*-----------------------------------------------------------------------------
*V05c 980923 - check that commodity not just capacity related
         SUM(TOP(RP_FLO(R,P),C,'%1')$(NOT RPC_EMIS(R,P,C)),
           SUM(RTPCS_VARF(R,T,P,C,TS),
             SUM(RTP_VINTYR(R,V,T,P), %VAR%_FLO(R,V,T,P,C,TS %SOW%)
* equation coarser than variable or equation finer than variable
*M2T* consider COM_TS shape too, so both TS_MAP and TS_BELOW both embedded
                  %3) * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS)))
         ) +
* [AL] Handle RPC_EMIS flows separately; They cannot be NOFLO
         SUM(TOP(RPC_EMIS(RP_FLO(R,P),C),'%1'),
           SUM((FS_EMIS(R,P,CG3,COM2,C),RTPCS_VARF(R,T,P,COM2,TS))$RS_TREE(R,S,TS),
             SUM(RTP_VINTYR(R,V,T,P),%VAR%_FLO(R,V,T,P,COM2,TS %SOW%) *
                COEF_PTRAN(R,V,P,CG3,COM2,C,TS) %SHP1% %3) *
             RS_FR(R,S,TS)*(1+RTCS_FR(R,T,COM2,S,TS)))) +

$EXIT
*-----------------------------------------------------------------------------
$LABEL REDUCE
* [UR] model reduction %REDUCE% is set in *.run
*[AL] Sum over non-vintaged processes
         SUM(TOP(RP_FLO(R,P),C,'%1')$(NOT PRC_VINT(R,P)),
             SUM((RTP_VINTYR(R,V(T),T,P),RTPCS_VARF(R,T,P,C,TS)),
$              BATINCLUDE cal_red.red C COM TS P T '' T
* equation coarser than variable or equation finer than variable
               %3 * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS)))
         ) +

*[AL] Sum over vintaged processes
         SUM((TOP(PRC_VINT(RP_FLO(R,P)),C,'%1'),RTPCS_VARF(R,T,P,C,TS)),
$              BATINCLUDE cal_red.red C COM TS P T '' V SUM 'RTP_VINTYR(R,V,T,P),' %3
* equation coarser than variable or equation finer than variable
               * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS))
         ) +

