*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* BND_FLO.MOD set the actual bounds for non-vintage VAR_FLOs                  *
*=============================================================================*
*UR Questions/Comments:
*-----------------------------------------------------------------------------
*$ONLISTING
* reset any existing bounds
  %VAR%_FLO.LO(R,V,T,P,C,S%SWD%) = 0;
  %VAR%_FLO.UP(R,V,T,P,C,S%SWD%) = INF;

* assign from user data
  FLO_BND(R,T,P,C,S,'LO')$((NOT RPC_EMIS(R,P,C))$(FLO_BND(R,T,P,C,S,'LO')=0)$RP_FLO(R,P))=0;
  LOOP((RTPC(R,T,P,C),S,BD)$FLO_BND(RTPC,S,BD),TRACKPC(RP_FLO(R,P),C)=YES);
  TRACKPC(PRC_VINT(R,P),C) = NO;
  TRACKPC(RPC_FFUNC(R,P,C))= NO;
  TRACKPC(RPC_EMIS(R,P,C)) = NO;
* Mark all tuples that definitely cannot be handled by VAR bounds
  LOOP(T,FLO_BND(R,'%DFLBL%',P,C,S,BD)$FLO_BND(R,T,P,C,S,BD) = EPS$(NOT TRACKPC(R,P,C));
         FLO_BND(R,'%DFLBL%',P,CG,S,BD)$((NOT C(CG))$FLO_BND(R,T,P,CG,S,BD)) = EPS);
  TRACKPC(RPC_ACT(R,P,C)) = NO;

$IF %STAGES% == YES LOOP(SW_T(T%SWD%),
  %VAR%_FLO.LO(RTP_VINTYR(R,T,T,P),C,S%SWD%)$((RTPCS_VARF(R,T,P,C,S)*TRACKPC(R,P,C))$FLO_BND(R,T,P,C,S,'LO')) = FLO_BND(R,T,P,C,S,'LO');
  %VAR%_FLO.UP(RTP_VINTYR(R,T,T,P),C,S%SWD%)$((RTPCS_VARF(R,T,P,C,S)*TRACKPC(R,P,C))$FLO_BND(R,T,P,C,S,'UP')) = FLO_BND(R,T,P,C,S,'UP');
  %VAR%_FLO.FX(RTP_VINTYR(R,T,T,P),C,S%SWD%)$((RTPCS_VARF(R,T,P,C,S)*TRACKPC(R,P,C))$FLO_BND(R,T,P,C,S,'FX')) = FLO_BND(R,T,P,C,S,'FX');
$IF %STAGES% == YES );
  OPTION CLEAR=TRACKPC;

*$OFFLISTING
$IF NOT '%REDUCE%' == 'YES' $EXIT
$IF %STAGES% == YES $SETLOCAL SWT "%SWD%)$SW_T(T%SWD%"
* As BND_ACT has been set before this, MAX/MIN can be used; FX bound consistency cannot be guaranteed
 LOOP(RTPCS_VARF(R,T,P,C,S)$(((NOT PRC_VINT(R,P))*RPC_ACT(R,P,C))$FLO_BND(R,T,P,C,S,'LO')),%VAR%_ACT.LO(R,T,T,P,S%SWT%) = MAX(%VAR%_ACT.LO(R,T,T,P,S%SWT%),FLO_BND(R,T,P,C,S,'LO')/PRC_ACTFLO(R,T,P,C)));
 LOOP(RTPCS_VARF(R,T,P,C,S)$(((NOT PRC_VINT(R,P))*RPC_ACT(R,P,C))$FLO_BND(R,T,P,C,S,'UP')),%VAR%_ACT.UP(R,T,T,P,S%SWT%) = MIN(%VAR%_ACT.UP(R,T,T,P,S%SWT%),FLO_BND(R,T,P,C,S,'UP')/PRC_ACTFLO(R,T,P,C)));
 LOOP(RTPCS_VARF(R,T,P,C,S)$(((NOT PRC_VINT(R,P))*RPC_ACT(R,P,C))$FLO_BND(R,T,P,C,S,'FX')),%VAR%_ACT.FX(R,T,T,P,S%SWT%) = FLO_BND(R,T,P,C,S,'FX')/PRC_ACTFLO(R,T,P,C));

