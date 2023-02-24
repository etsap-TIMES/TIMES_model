*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* COEF_SHP prepares the shapes for COEF_PTR and COEF_CPT
*=============================================================================*
* Shaping of COEF_PTRANS
*------------------------------------------------------------------------------
  PARAMETER RTP_FFCX(REG,ALLYEAR,ALLYEAR,PRC,CG,CG) //;
  SET AGEJ(J,AGE) / 1.1 /;
  Z=SMAX(T,MAX(IPD(T),D(T))); OPYEAR(LIFE,AGE)$((ORD(AGE)<=ORD(LIFE))$(ORD(LIFE)<=Z)) = YES;
  RTP_CGC(RTP(R,V,P),CG,CG2)$((FLO_FUNCX(RTP,CG,CG2)<=0)$FLO_FUNCX(RTP,CG,CG2))=PRC_VINT(R,P);

* Remove FLO_FUNCX indexes that won't have any effect
  Z=CARD(J)/2+1;
  FLO_FUNCX(RTP,CG,CG2)$(ABS(FLO_FUNCX(RTP,CG,CG2)-Z)>Z-1.5-INF$ACTCG(CG)) = 0;
  OPTION RP_GRP <= FLO_FUNCX,PRC_YMIN < RP_GRP,CLEAR=PRC_YMAX;
  TRACKP(RP)$PRC_YMIN(RP) $= PRC_VINT(RP)+RP_GRP(RP,'CAPFLO');
  RTP_CAPYR(RTP_CPTYR(R,V,T,P)) $= TRACKP(R,P);

  LOOP(AGEJ(J,AGE)$CARD(TRACKP),
    LOOP(V,
*   Set the starting and ending years taking into account NCAP_ILED:
      PRC_YMIN(TRACKP(R,P)) = B(V)+ROUND(NCAP_ILED(R,V,P));
      PRC_YMAX(TRACKP(R,P)) = PRC_YMIN(R,P)+ROUND(NCAP_TLIFE(R,V,P))-1;
*   Calculate average SHAPE for plants still operating in each period:
      RTP_FFCX(RTP_CAPYR(R,V,T,P),CG1,CG2)$FLO_FUNCX(R,V,P,CG1,CG2) =
        SUM(PERIODYR(T,EOHYEARS)$(YEARVAL(EOHYEARS) LE MAX(B(T),PRC_YMAX(R,P))),
          SHAPE(J+(FLO_FUNCX(R,V,P,CG1,CG2)-1),AGE+(MIN(YEARVAL(EOHYEARS),PRC_YMAX(R,P))-PRC_YMIN(R,P))))
        / (MAX(1,MIN(E(T),PRC_YMAX(R,P))-MAX(B(T),PRC_YMIN(R,P))+1)) -1;
    );
* For repeated investments, use the average SHAPE over lifetime:
    RVPRL(RTP(R,T,P))$((COEF_RPTI(RTP)>1)$TRACKP(R,P)) = ROUND(NCAP_TLIFE(RTP)-1)+EPS;
    RTP_FFCX(RTP_CAPYR(R,TT,T,P),CG1,CG2)$(RVPRL(R,TT,P)$FLO_FUNCX(R,TT,P,CG1,CG2)) =
        SUM(OPYEAR(AGE+RVPRL(R,TT,P),LIFE),SHAPE(J+(FLO_FUNCX(R,TT,P,CG1,CG2)-1),LIFE)) / (RVPRL(R,TT,P)+1) -1;
  );
* Shapes for capacity-related commodity flows
  COEF_CIO(RTP_CAPYR(R,V,T,P),C,IO)$NCAP_COM(R,V,P,C,IO) $= RTP_FFCX(R,V,T,P,'CAPFLO',C);
  COEF_CIO(RTP_CPTYR(R,V,T,P),C,IO)$NCAP_CLAG(R,V,P,C,IO) = SIGN(NCAP_CLAG(R,V,P,C,IO)) *
      (MAX(0, E(T)+1-MAX(B(V)+NCAP_ILED(R,V,P)+ABS(NCAP_CLAG(R,V,P,C,IO)),B(T))) /
       MAX(.1,E(T)+1-MAX(B(V)+NCAP_ILED(R,V,P),B(T)))-1)-1$(NCAP_CLAG(R,V,P,C,IO)<0);
  RTP_FFCX(RTP_CAPYR,'CAPFLO',CG) = 0;
* Option for non-vintaged FLO_FUNC multipliers
  RTP_FFCX(RTP_VINTYR(R,V,T,P),CG,CG2)$((FLO_FUNC(R,V,P,CG,CG2,'ANNUAL')>0)$RTP_CGC(R,V,P,CG,CG2))=FLO_FUNC(R,T,P,CG,CG2,'ANNUAL')/FLO_FUNC(R,V,P,CG,CG2,'ANNUAL')-1;
  OPTION CLEAR=RTP_CGC,CLEAR=TRACKP,CLEAR=RVPRL,CLEAR=RP_GRP;
*------------------------------------------------------------------------------
* Shaping of COEF_CPT
*------------------------------------------------------------------------------
* Remove NCAP_CPX indexes that won't have any effect
  Z=CARD(J)/2+1;
  NCAP_CPX(RTP)$(ABS(NCAP_CPX(RTP)-Z)>Z-1.5) = 0;
  OPTION PRC_YMIN < NCAP_CPX,CLEAR=PRC_YMAX;

  LOOP(AGEJ(J,AGE)$CARD(NCAP_CPX),
    TRACKP(RP) $= PRC_YMIN(RP);
    LOOP(V,
*   Set the starting and ending years taking into account NCAP_ILED:
      PRC_YMIN(TRACKP(R,P)) = B(V)+ROUND(NCAP_ILED(R,V,P));
      PRC_YMAX(TRACKP(R,P)) = PRC_YMIN(R,P)+NCAP_TLIFE(R,V,P);
*   Calculate weighted average SHAPE for plants still operating in each period:
      LOOP(G_RCUR(R,CUR),
      COEF_CAP(RTP_CPTYR(R,V,T,P))$NCAP_CPX(R,V,P) =
        SUM(PERIODYR(T,Y_EOH)$(YEARVAL(Y_EOH)<PRC_YMAX(R,P)),MIN(1,PRC_YMAX(R,P)-YEARVAL(Y_EOH))*OBJ_DISC(R,Y_EOH,CUR)*
          SHAPE(J+(NCAP_CPX(R,V,P)-1),AGE+(YEARVAL(Y_EOH)-PRC_YMIN(R,P)))) / COEF_PVT(R,T)
    ));
* For repeated investments, use the average SHAPE over lifetime:
    RVPRL(RTP)$((COEF_RPTI(RTP)>1)$NCAP_CPX(RTP)) = ROUND(NCAP_TLIFE(RTP)-1)+EPS;
    COEF_CAP(RTP_CPTYR(R,V(TT),T,P))$RVPRL(R,V,P) =
        SUM(OPYEAR(AGE+RVPRL(R,V,P),LIFE),SHAPE(J+(NCAP_CPX(R,V,P)-1),LIFE)) / (RVPRL(R,V,P)+1);
    COEF_CAP(R,V,T,P)$COEF_CAP(R,V,T,P) = 1/MAX(1,COEF_CPT(R,V,T,P)/COEF_CAP(R,V,T,P))-1;
  );
  OPTION RTP_CPX <= COEF_CAP;
  COEF_CPT(R,V,T,P)$COEF_CAP(R,V,T,P) = COEF_CPT(R,V,T,P)*(COEF_CAP(R,V,T,P)+1);
  OPTION CLEAR=PRC_YMIN,CLEAR=PRC_YMAX,CLEAR=TRACKP,CLEAR=COEF_CAP,CLEAR=RVPRL;
