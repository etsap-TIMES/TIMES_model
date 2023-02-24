*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* BND_STG.MOD set the actual bounds for non-vintage VAR_SIN/OUT
*   %1 - which variable
*   %2 - which bound
*=============================================================================*
* reset any existing bounds

  %VAR%_%1.LO(R,V,T,P,C,S%SWD%)$PRC_MAP(R,'STG',P) = 0;
  %VAR%_%1.UP(R,V,T,P,C,S%SWD%)$PRC_MAP(R,'STG',P) = INF;
  %VAR%_%1.LO(RTP_VINTYR(R,V,T,P),%PGPRIM%,S%SWD%)$((RPS_STG(R,P,S)->0)$RP_STS(R,P)) = %3;

* set bounds at process activity level
  TRACKP(RP(R,P))$((NOT PRC_VINT(R,P))$PRC_MAP(R,'STG',P)) = YES;

$IF %STAGES% == YES LOOP(SW_T(T%SWD%),

  %VAR%_%1.LO(RTP_VINTYR(R,T,T,P),C,S%SWD%)$(RPCS_VAR(R,P,C,S)$TRACKP(R,P)) $= %2_BND(R,T,P,C,S,'LO');
  %VAR%_%1.UP(RTP_VINTYR(R,T,T,P),C,S%SWD%)$(RPCS_VAR(R,P,C,S)$TRACKP(R,P)) $= %2_BND(R,T,P,C,S,'UP');
  %VAR%_%1.FX(RTP_VINTYR(R,T,T,P),C,S%SWD%)$(RPCS_VAR(R,P,C,S)$TRACKP(R,P)) $= %2_BND(R,T,P,C,S,'FX');

$IF %STAGES% == YES );
  OPTION CLEAR=TRACKP;