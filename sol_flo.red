*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* SOL_FLO - code associated with the substitution of flow variables
*	%1 - target parameter name
*	%2 - parameter name suffix
*	%3 - VAR_FLO suffix (.L or .M)
*=============================================================================*
$SET SHP1 "" SET SHP2 "" SET SHP3 "" SET TST '$PRC_VINT(R,P)' SET%4 V VAR
$SET SHG1 ",P,%PGPRIM%,C" SET SHG ',P,CG1,C'
$IF DEFINED RTP_FFCS
$SET SHP1 "*(%SHFF%S(R,V%SHG1%%SOW%))" SET SHP3 "*(%SHFF%S(R,V%SHG%%SOW%))"
$SET SHP1 "*(%SHFF%X(R,V,T%SHG1%)%TST%)%SHP1%" SET SHP3 "*(%SHFF%X(R,V,T%SHG%)%TST%)%SHP3%"

* Non-substituted flows
$IF '%2'==''   %1(R,V,T,P,C,S%5) $= %V%_FLO%3(R,V,T,P,C,S%5);

* Activity flows
$IF '%3'=='.L' %1%2(RTP_VINTYR(R,V,T,P),C,S%5)$PRC_TS(R,P,S) $= SUM(RPC_ACT(RP_PGACT(R,P),C),%V%_ACT%3(R,V,T,P,S%5)*PRC_ACTFLO(R,V,P,C));
$IF '%3'=='.M' %1%2(RTP_VINTYR(R,V,T,P),C,S%5)$PRC_TS(R,P,S) $= SUM(RPC_ACT(RP_PGACT(R,P),C),%V%_ACT%3(R,V,T,P,S%5)*(1/PRC_ACTFLO(R,V,P,C)));

* Set NO_ACT flows to activity; they were not substituted
$IF '%3'=='.L' %V%_ACT%3(RTP_VINTYR(R,V,T,P),S%5) $= SUM(RPC_PG(RP_FLO(NO_ACT(R,P)),C),%V%_FLO%3(R,V,T,P,C,S%5)*(1/PRC_ACTFLO(R,V,P,C)));
$IF '%3'=='.L' %V%_ACT%3(RTP_VINTYR(R,V,T,P),S%5) $= SUM(RPC_IRE(RPC_PG(NO_ACT(R,P),C),IE)$RP_AIRE(R,P,IE),%V%_IRE%3(R,V,T,P,C,S,IE%5)*(1/PRC_ACTFLO(R,V,P,C)));
$IF '%3'=='.M' %V%_ACT%3(R,V,T,P,S%5) $= SUM(RPC_PG(RP_FLO(NO_ACT(R,P)),C),%V%_FLO%3(R,V,T,P,C,S%5)*PRC_ACTFLO(R,V,P,C));
$IF '%3'=='.M' %V%_ACT%3(R,V,T,P,S%5) $= SUM(RPC_IRE(RPC_PG(NO_ACT(R,P),C),IE)$RP_AIRE(R,P,IE),%V%_IRE%3(R,V,T,P,C,S,IE%5)*PRC_ACTFLO(R,V,P,C));
*-------------------------------------------------------------------------------
* Marginals for substituted flows currently not supported
$IF '%3'=='.M' $EXIT
*-------------------------------------------------------------------------------
* FFUNC substituted flows
%1%2(RTP_VINTYR(R,V,T,P),C,S%5)$(RTPCS_VARF(R,T,P,C,S)%6$RPC_FFUNC(R,P,C)) =
  SUM((RPC_ACT(R,P,COM),RS_TREE(R,S,TS))$%V%_ACT%3(R,V,T,P,TS%5),
    %V%_ACT%3(R,V,T,P,TS%5) * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,COM,S,TS)) *
    ( ACT_FLO(R,V,P,C,S)%SHP1% ));

* Emission flows
%1%2(RTP_VINTYR(R,V,T,P),C,S%5)$(RTPCS_VARF(R,T,P,C,S)%6$RPC_EMIS(R,P,C)) =
   SUM((FS_EMIS(R,P,CG1,COM,C),RS_TREE(R,S,TS))$%1%2(R,V,T,P,COM,TS%5),
         %1%2(R,V,T,P,COM,TS%5) * RS_FR(R,S,TS)*(1+RTCS_FR(R,T,COM,S,TS)) *
         COEF_PTRAN(R,V,P,CG1,COM,C,TS)%SHP3%);
