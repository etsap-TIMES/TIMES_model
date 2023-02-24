*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================================*
* CAL_RED the code associated with the substitution of flow variables by activity variables
*	%1 - commodity of flow
*	%2 - commodity associated with the activity variable
*	%3 - timeslice index	of flow variable
*	%4 - process index of flow variable
*	%5 - period index of flow variable
*	%6 - for output routine '.L' suffix. otherwise nothing
*	%7 - optional T or V or '' (for non-vintaged / vintaged / general case)
*=============================================================================================*
$SETLOCAL SHP3 "" SET VNT '%5' SET SHG ",%4,CG3,%1" SET TST '$PRC_VINT(R,%4)'
$IF '%7' == V $SET TST ''
$IF NOT '%7' == T $SET VNT V
$IF DEFINED RTP_FFCS $SET SHP3 "*(%SHFF%S(R,%VNT%%SHG%%SOW%))"
$IF %VNT% == V $SET SHP3 "*(%SHFF%X(R,V,%5%SHG%)%TST%)%SHP3%"
*==============================================================================================
%8(%9
*  flow variable cannot be replaced
   %VAR%_FLO%6(R,%VNT%,%5,%4,%1,%3 %SOW%)$(NOT RPC_EMIS(R,%4,%1))
    +
*   emission flow = flow variable * emission factor
   SUM((FS_EMIS(R,%4,CG3,COM2,%1),ALL_TS)$(RS_FR(R,%3,ALL_TS)*RTPCS_VARF(R,%5,%4,COM2,ALL_TS)),
     %VAR%_FLO%6(R,%VNT%,%5,%4,COM2,ALL_TS %SOW%) * COEF_PTRAN(R,%VNT%,%4,CG3,COM2,%1,ALL_TS)%SHP3% *
     RS_FR(R,%3,ALL_TS)*(1+RTCS_FR(R,%5,COM2,%3,ALL_TS))
   )$RPC_EMIS(R,%4,%1)
)
