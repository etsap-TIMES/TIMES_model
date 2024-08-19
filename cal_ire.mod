*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2024 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* CAL_IRE the code associated with the inter-region trade variable in EQ_COMxxx
*   %1 - IMPort/EXPort indicator
*   %2 - IN/OUT nature of the aux/emissions
*   %3 - IE or ''
*   %4 - * Peak multiplier
*=============================================================================*
*GaG Questions/Comments:
*-----------------------------------------------------------------------------
*$ONLISTING

$IF DEFINED RTP_FFCS $SET MX "(%SHFF%S(R,V,P,C,C%SOW%))*"
*V0.9 022100 - handle the fact that called 2x for aux
$SET IE '%3'
$IF '%IE%'=='' $SET IE "'%1'"
$IF '%1%2' == 'EXPOUT' $GOTO AUXONLY
$IF '%1%2' == 'IMPIN'  $GOTO AUXONLY
* actual exchange
*V05c 981016 - change RTPCS_VARFs to ts
         SUM((RPC_IRE(%6R,P%7,C,'%1'),RTP_VNTBYR(R,T,P,V)),
             SUM(RTPCS_VARF(R,T,P,C,TS)$RS_FR(R,S,TS),
                 (%VAR%_IRE(R,V,T,P,C,TS,'%1'%SOW%)$(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C)
                 )%4 * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS)))
         ) +

$IF SET IREAUXBAL %IREAUXBAL% %2 %5
$LABEL AUXONLY
*V0.5b handle auxiliary commodity flows too
*** NOTE: assumes that attribute at the same level as the variable!!
*V0.9 022100 - do IN/OUT explicitly
         SUM((RPC_IRE(%6R,P%7,COM,%IE%),RTPCS_VARF(R,T,P,COM,TS))$(IRE_FLOSUM(R,T,P,COM,TS,%IE%,C,'%2')$RS_FR(R,S,TS)),
             IRE_FLOSUM(R,T,P,COM,TS,%IE%,C,'%2') *
             SUM(RTP_VNTBYR(R,T,P,V), %MX%
                 (%VAR%_IRE(R,V,T,P,COM,TS,%IE%%SOW%)$(NOT RPC_AIRE(R,P,COM))+(%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,COM))$RPC_AIRE(R,P,COM)
                 )%4
             ) * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,COM,S,TS))
         ) +
*$OFFLISTING
