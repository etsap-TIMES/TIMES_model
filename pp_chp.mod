*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*==============================================================================*
* PP_CHP.MOD derives the FLO_SUM/SHARs/ACTFLOs for modeling CHPs from the inputs
*   Upon completion all attributes are in place for handling by regular code
*==============================================================================*
  SET CHP_ELC(R,P,C);

* Back-pressure point should correspond to the maximum HEAT/POWER ratio
  NCAP_CHPR(RTP,BDNEQ)$NCAP_CHPR(RTP,'FX') = 0;
  COEF_RTP(RTP(R,V,P))$CHP(R,P) = MAX(0,SMAX(BD,NCAP_CHPR(RTP,BD)));
*-----------------------------------------------------------------------------
* calculate the slope: (CDEF/BPEF*(1+CHPR)-1)/CHPR
  NCAP_CEH(RTP)$((COEF_RTP(RTP)>0)$NCAP_CDME(RTP)) = MAX(.001,(NCAP_CDME(RTP)/NCAP_BPME(RTP)*(1+COEF_RTP(RTP))-1)/COEF_RTP(RTP));
* EQ_PTRANS control - overall efficiency
  FLO_SUM(RTP(R,V,P),C,COM,C,ANNUAL)$(RPC_SPG(R,P,COM)$RPC_PG(R,P,C)$NRG_TMAP(R,'ELC',C)) $= NCAP_CDME(RTP);
*-----------------------------------------------------------------------------
* Identify CHP processes using NCAP_CHPR
  IF(CARD(CHP),
* Get the ELC / HEAT outputs
   OPTION PRC_ACT < NCAP_CHPR;
   CHP_ELC(RPC_PG(CHP(PRC_ACT(R,P)),C))$NRG_TMAP(R,'ELC',C) = YES;
   OPTION TRACKP < CHP_ELC; TRACKP(RP_PGACT) = NO;
   RVP(R,V,P)$(COEF_RTP(R,V,P)$TRACKP(R,P)) = YES;
   RP_GRP(RPC_PG(TRACKP(RP),C))$(NOT CHP_ELC(RP,C)) = YES;
   RP_GRP(RP_PGACT(CHP),C)$(TOP(CHP,C,'OUT')$(NOT CHP_ELC(CHP,C))) = YES;
   TRACKPG(RP_GRP(RPC_PG(R,P,C)))$COM_LIM(R,C,'N')=YES; OPTION RP_PRC<TRACKPG;
   NCAP_CEH(RVP(R,V,P))$(NCAP_CEH(RVP)=0) = -0.5$RP_PRC(R,P);
   NCAP_BPME(RVP) = MIN(0,SMIN(BD$NCAP_CHPR(RVP,BD),NCAP_CHPR(RVP,BD))*((NCAP_CEH(RVP)+1)$NCAP_CEH(RVP)-1));
   NCAP_CEH(RVP)$(NCAP_CEH(RVP)<0) = -NCAP_CEH(RVP);
* If slope is different from 1, we should always have a maximum heat share:
   NCAP_CHPR(RVP,'FX')$((ABS(NCAP_CEH(RVP)-1)>.01)$(NOT NCAP_CHPR(RVP,'UP'))) = COEF_RTP(RVP)+EPS;
  );
*-----------------------------------------------------------------------------
* Calculate ACTFLOs for pg and elc
  PRC_ACTFLO(RVP(R,V,P),C)$((NCAP_CEH(RVP) LE 1)$RPC_PG(R,P,C)) =
     POWER(NCAP_CEH(RVP),(1$CHP_ELC(R,P,C)-1)$NCAP_CEH(RVP)) * (1-NCAP_BPME(RVP));
  PRC_ACTFLO(RVP(R,V,P),C)$(((NCAP_CEH(RVP) GT 1)*NCAP_CEH(RVP))$RPC_PG(R,P,C)) =
     (1+(1/NCAP_CEH(RVP)-1)/(1+1/COEF_RTP(RVP))) * POWER(NCAP_CEH(RVP),1-1$CHP_ELC(R,P,C));
  PRC_ACTFLO(RVP(R,V,P),C)$TRACKPG(R,P,C) = PRC_ACTFLO(RVP,C)*(1/COEF_RTP(RVP)+1)/MAX(1E-3,EXP(ABS(LOG(NCAP_CEH(RVP))))-1);
* EQ_PTRANS control - low-temperature heat
  FLO_SUM(RTP(R,V,P),C,COM,C,ANNUAL)$(RP_GRP(R,P,COM)$CHP_ELC(R,P,C)$NCAP_CDME(RTP)) = -1/PRC_ACTFLO(RTP,COM);
*-----------------------------------------------------------------------------
* EQ_OUTSHR controls: Set bound for the electricity output
* Define the share over PG if there is more than just ELC, otherwise NRG
  RP_GRP(TRACKPG)=NO; TRACKP(RP_PRC)=NO; RP_GRP(TRACKP,C)=NO;
  OPTION CLEAR=TRACKPG; TRACKPG(RP_PG(TRACKP,CG))=YES;
  TRACKPG(RP_PGACT(RP),'NRG') $= SUM(CHP_ELC(RP,C),1);
  LOOP((CHP_ELC(R,P,C),TRACKPG(R,P,CG)),
   FLO_SHAR(RTP(R,V,P),C,CG,S,'LO')$(PRC_TS(R,P,S) * NCAP_CHPR(RTP,'UP')) = 1 / (1+NCAP_CHPR(RTP,'UP'));
   FLO_SHAR(RTP(R,V,P),C,CG,S,'FX')$(PRC_TS(R,P,S) * NCAP_CHPR(RTP,'FX')) = 1 / (1+NCAP_CHPR(RTP,'FX'));
   FLO_SHAR(RTP(R,V,P),C,CG,S,'UP')$(PRC_TS(R,P,S) * NCAP_CHPR(RTP,'LO')) = 1 / (1+NCAP_CHPR(RTP,'LO'));
  );
* Heat share
  FLO_SHAR(RTP(R,V,P),C,CG,S,BD)$(PRC_TS(R,P,S)$RP_PG(R,P,CG)$RP_GRP(R,P,C)) = NCAP_CHPR(RTP,BD)/(NCAP_CHPR(RTP,BD)+1);
* ACT emission
  FLO_SUM(RVP,COM,C,COM,S)$((NCAP_BPME(RVP)$NCAP_CEH(RVP)$PRC_ACTFLO(RVP,C)<0)$FLO_EFF(RVP,COM,C,S)) = FLO_EFF(RVP,COM,C,S)/PRC_ACTFLO(RVP,C);
*-----------------------------------------------------------------------------
* Adjust PKCNT
  LOOP(RPC_PKC(CHP_ELC(R,P,C)),NCAP_PKCNT(RVP(R,V,P),S)$COM_TS(R,C,S)=NCAP_PKCNT(RVP,S)/MAX(1,PRC_ACTFLO(RVP,C)));
  RVP(RVP)$(NCAP_CEH(RVP)+1$NCAP_CHPR(RVP,'FX')+NCAP_CHPR(RVP,'LO')>0) = NO;
  PUTGRP = 0;
  LOOP(RVP(R,V,P)$(T(V)+PRC_VINT(R,P)),
$    BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 01 'CHP process with zero CEH but only upper bound on CHPR.'
     PUT QLOG ' WARNING       - Unusual CHP operation: R=',%RL%,' P=',%PL%,' V=',V.TL;
  );
  OPTION CLEAR=PRC_ACT,CLEAR=RVP,CLEAR=TRACKP,CLEAR=TRACKPG,CLEAR=RP_PRC,CLEAR=RP_GRP,CLEAR=COEF_RTP;