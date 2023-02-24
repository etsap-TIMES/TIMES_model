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
*	%8 - optional 'SUM' (only if %7 is not T)
*	%9 - optional 'RTP_VINTYR(R,V,%5,%4),' (only if %7 is not T)
*	%10 - optional multiplier (NCAP_PKCNT)
*=============================================================================================*
$SET SHP1 "" SET SHP2 "" SET SHP3 "" SET VNT '%5' SET TST '$PRC_VINT(R,%4)'
$SET SHG1 ",%4,%PGPRIM%,COM2" SET SHG2 ",%4,%PGPRIM%,%1" SET SHG ',%4,CG1,%1'
$IF NOT '%7'==T $SET VNT V
$IF DEFINED RTP_FFCS
$SET SHP1 "*(%SHFF%S(R,%VNT%%SHG1%%SOW%))" SET SHP2 "*(%SHFF%S(R,%VNT%%SHG2%%SOW%))" SET SHP3 "*(%SHFF%S(R,%VNT%%SHG%%SOW%))"
$IF '%7' == V $SET TST ''
$IF NOT '%7'==T
$SET SHP1 "*(%SHFF%X(R,V,%5%SHG1%)%TST%)%SHP1%" SET SHP2 "*(%SHFF%X(R,V,%5%SHG2%)%TST%)%SHP2%" SET SHP3 "*(%SHFF%X(R,V,%5%SHG%)%TST%)%SHP3%"
*==============================================================================================
(
*  flow variable cannot be replaced
   (%8(%9%VAR%_FLO%6(R,%VNT%,%5,%4,%1,%3%SOW%)%10)$(NOT RPC_EMIS(R,%4,%1))
    +
*   emission flow = flow variable * emission factor
   SUM((FS_EMIS(R,%4,CG1,COM2,%1),ALL_TS)$(RTPCS_VARF(R,%5,%4,COM2,ALL_TS)$RS_FR(R,%3,ALL_TS)),
     %8(%9
        (
*        flow variable cannot be replaced
         %VAR%_FLO%6(R,%VNT%,%5,%4,COM2,ALL_TS%SOW%)$(NOT RPC_ACT(R,%4,COM2)+RPC_FFUNC(R,%4,COM2))
         +
*        flow variable equals activity variable
         (%VAR%_ACT%6(R,%VNT%,%5,%4,ALL_TS%SOW%)*PRC_ACTFLO(R,%VNT%,%4,COM2))$RPC_ACT(R,%4,COM2)
         +
         SUM((RPC_ACT(R,%4,%2),PRC_TS2(R,%4,S2))$RS_FR(R,ALL_TS,S2),
             (
              %VAR%_ACT%6(R,%VNT%,%5,%4,S2%SOW%) * ACT_FLO(R,%VNT%,%4,COM2,ALL_TS)%SHP1%
             ) * RS_FR(R,ALL_TS,S2)*(1+RTCS_FR(R,%5,%2,ALL_TS,S2))
            )$RPC_FFUNC(R,%4,COM2)
        ) * COEF_PTRAN(R,%VNT%,%4,CG1,COM2,%1,ALL_TS)%SHP3% %10
       ) * RS_FR(R,%3,ALL_TS)*(1+RTCS_FR(R,%5,COM2,%3,ALL_TS))
      )$RPC_EMIS(R,%4,%1)
   )$(NOT RPC_ACT(R,%4,%1)+RPC_FFUNC(R,%4,%1))
   +
*  flow variable equals activity variable
   %8(%9%VAR%_ACT%6(R,%VNT%,%5,%4,%3%SOW%)*PRC_ACTFLO(R,%VNT%,%4,%1)%10)$RPC_ACT(R,%4,%1)
   +
   SUM((RPC_ACT(R,%4,%2),PRC_TS2(R,%4,S2))$RS_FR(R,%3,S2),
       (
       %8(%9 %VAR%_ACT%6(R,%VNT%,%5,%4,S2%SOW%) %10 * ACT_FLO(R,%VNT%,%4,%1,%3)%SHP2%)
       ) * RS_FR(R,%3,S2)*(1+RTCS_FR(R,%5,%2,%3,S2))
    )$RPC_FFUNC(R,%4,%1)
)
