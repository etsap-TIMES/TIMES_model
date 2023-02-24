*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* COEF_CPT.MOD coefficient calculations related to capacity transfer          *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
*GaG Questions/Comments:
*  - COEF_RPTI calculated in PPMAIN.MOD
*-----------------------------------------------------------------------------
* copy the period values into the years within the period
  LOOP(PERIODYR(T,V)$((NOT PHYR(V))$VNT(V,T)),
    B(V) = B(T); E(V) = E(T);
    M(V) = M(T); D(V) = D(T);
  );
* capacity transfer - set here only when no alternate objective
  OPTION CLEAR=FIL; FIL(V)=(NOT 0%CTST%);
  PASTSUM(RTP(R,FIL(V),P))$PRC_CAP(R,P) = B(V)+NCAP_ILED(RTP)+COEF_RPTI(RTP)*NCAP_TLIFE(RTP);
  COEF_CPT(RTP_CPTYR(R,FIL(V),T,P))$PASTSUM(R,V,P) =
    MAX(0, (MIN(E(T)+1,PASTSUM(R,V,P))-MAX(B(V)+NCAP_ILED(R,V,P),B(T))) / D(T));

$IF '%VALIDATE%'==YES COEF_CPT(RTP_CPTYR(R,T,T,P)) = 1;
  OPTION CLEAR=PASTSUM;

*-------------------------------------------------------------------------------
* Set NCAP_AF to be the minimum of NCAP_AF and NCAP_AFS, if both at same timeslice
  MY_TS(S)=NOT ANNUAL(S);
  NCAP_AF(RTP(R,V,P),MY_TS(S),BD)$(PRC_TS(R,P,S)$NCAP_AFS(RTP,S,BD)) = MIN(NCAP_AF(RTP,S,BD)+INF$(NOT NCAP_AF(RTP,S,BD)),NCAP_AFS(RTP,S,BD));
  NCAP_AF(RTP(R,V,P),S,BDNEQ)$(PRC_TS(R,P,S)$NCAP_AFS(RTP,S,'FX')) = 0;
* Remove NCAP_AFS from timeslices that are not above PRC_TS:
  NCAP_AFS(RTP(R,V,P),MY_TS(S),BD)$(PRC_TS(R,P,S) OR (NOT RPS_PRCTS(R,P,S))) = 0;

*-------------------------------------------------------------------------------
* have COEF_AF SHAPEd
* [AL] Rules for vintage-dependent availabilities:
* -- If P is Vintaged, both NCAP_AF and NCAP_AFS are vintage-dependent;
* -- If P is NOT Vintaged but NCAP_AFX is specified, then only NCAP_AF is vintage-dependent;
* -- If P is NOT Vintaged nor NCAP_AFX is specified, then neither is vintage-dependent (except AFS(ANNUAL));
* -- NCAP_AFA is always non-vintage-dependent, but NCAP_AFS(ANNUAL) overrides it and is always vintaged.

  NCAP_AFX(R,LL--ORD(LL),P) $= NCAP_AFM(R,LL,P);
  OPTION TRACKP < NCAP_AFX;
  TRACKP(RP)$(NOT PRC_CAP(RP)) = NO;
  TRACKP(RP)$RP_UPL(RP,'FX') = NO;
  TRACKP(PRC_CAP(PRC_VINT)) = YES;
  NCAP_AFBX(RTP(R,V,P),BD)$(RP_AFB(R,P,BD)>0) $= NCAP_AFX(RTP);
$ BATINCLUDE pp_shapr.%1 NCAP_AF (R,V,P,S,BD) "TRACKP(R,P)*PRC_TS(R,P,S)" COEF_AF(RTP_CPTYR(R,V,T,P),S,BD) NCAP_AFM(R,V,P) B

  TRACKP(PRC_CAP(R,P)) = (NOT TRACKP(R,P));
  COEF_AF(RTP_CPTYR(R,V,T,P),S,BD)$(PRC_TS(R,P,S)$TRACKP(R,P)) $= NCAP_AF(R,T,P,S,BD);
  COEF_AF(RTP_CPTYR(R,V,T,P),ANNUAL,BD)$PRC_CAP(R,P) $= NCAP_AFA(R,T,P,BD);

*V07_2 add seasonal AF in addition to process tslvl
  OPTION RP_PRC < NCAP_AFSM; NCAP_AFSM(R,V,P)$(NOT RP_PRC(R,P)) $= NCAP_AFM(R,V,P);
  NCAP_AFSX(RTP,BD)$NCAP_AFSM(RTP) = NCAP_AFSX(RTP,BD)+EPS;
  RTPS_BD(RTP(R,V,P),S,BD)$((PRC_VINT(R,P)+ANNUAL(S)+YES$NCAP_AFSX(RTP,BD))$NCAP_AFS(RTP,S,BD)) = YES;
  OPTION RP_PRC<NCAP_AFSX; NCAP_AFSX(R,V,P,BD)$SUM(RTPS_BD(R,V,P,S,BD),1) $= NCAP_AFX(R,V,P)$(NOT RP_PRC(R,P));
$ BATINCLUDE pp_shapr.%1 NCAP_AFS (R,V,P,S,BD) "RTPS_BD(R,V,P,S,BD)" COEF_AF(RTP_CPTYR(R,V,T,P),S,BD) NCAP_AFSM(R,V,P)

  COEF_AF(RTP_CPTYR(R,V,T,P),S,BD)$(NOT RTPS_BD(R,V,P,S,BD)) $= NCAP_AFS(R,T,P,S,BD)$PRC_CAP(R,P);
  COEF_AF(RTP_CPTYR(R,V,T,P),ANNUAL,BDNEQ)$NCAP_AFA(R,T,P,'FX') = 0;
  OPTION CLEAR=TRACKP,CLEAR=RTPS_BD,CLEAR=NCAP_AFBX;
