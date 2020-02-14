*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* COEF_SHP prepares the shapes for COEF_PTR and COEF_CPT
*=============================================================================*
* Shaping of COEF_PTRANS
*------------------------------------------------------------------------------
  PARAMETER RTP_FFCX(R,ALLYEAR,ALLYEAR,P,CG,CG) //;
  SET AGEJ(J,AGE) / 1.1 /;
  OPTION CLEAR=PRC_YMAX;

* Remove FLO_FUNCX indexes that won't have any effect
  Z=CARD(J)/2+1;
  FLO_FUNCX(RTP,CG1,CG2)$(ABS(FLO_FUNCX(RTP,CG1,CG2)-Z)>Z-1.5) = 0;
  LOOP((RTP(R,V,P),CG1,CG2)$FLO_FUNCX(RTP,CG1,CG2),TRACKP(R,P) = YES);
  TRACKP(RP)$(NOT PRC_VINT(RP)) = NO;

  LOOP(AGEJ(J,AGE)$CARD(TRACKP),
    LOOP(V,
*   Set the starting and ending years taking into account NCAP_ILED:
      PRC_YMIN(TRACKP(R,P)) = B(V)+ROUND(NCAP_ILED(R,V,P));
      PRC_YMAX(TRACKP(R,P)) = PRC_YMIN(R,P)+ROUND(NCAP_TLIFE(R,V,P))-1;
*   Calculate average SHAPE for plants still operating in each period:
      RTP_FFCX(RTP_VINTYR(R,V,T,P),CG1,CG2)$FLO_FUNCX(R,V,P,CG1,CG2) =
        SUM(PERIODYR(T,EOHYEARS)$(YEARVAL(EOHYEARS) LE MAX(B(T),PRC_YMAX(R,P))),
          SHAPE(J+(FLO_FUNCX(R,V,P,CG1,CG2)-1),AGE+(MIN(YEARVAL(EOHYEARS),PRC_YMAX(R,P))-PRC_YMIN(R,P))))
        / (MAX(1,MIN(E(T),PRC_YMAX(R,P))-MAX(B(T),PRC_YMIN(R,P))+1)) -1;
    );
* For repeated investments, use the average SHAPE over lifetime:
    LOOP(TT, PRC_YMAX(TRACKP(R,P)) = ROUND(NCAP_TLIFE(R,TT,P))$(COEF_RPTI(R,TT,P)>1);
      RTP_FFCX(RTP_VINTYR(R,TT,T,P),CG1,CG2)$(PRC_YMAX(R,P)*FLO_FUNCX(R,TT,P,CG1,CG2)) =
        SUM(LIFE$(ORD(LIFE) LE PRC_YMAX(R,P)),SHAPE(J+(FLO_FUNCX(R,TT,P,CG1,CG2)-1),LIFE))
        / PRC_YMAX(R,P) -1);
  );
  OPTION CLEAR=PRC_YMIN,CLEAR=PRC_YMAX,CLEAR=TRACKP;
*------------------------------------------------------------------------------
* Shaping of COEF_CPT
*------------------------------------------------------------------------------
* Remove NCAP_CPX indexes that won't have any effect
  Z=CARD(J)/2+1;
  NCAP_CPX(RTP)$(ABS(NCAP_CPX(RTP)-Z)>Z-1.5) = 0;
  LOOP(RTP(R,V,P)$NCAP_CPX(RTP), TRACKP(R,P) = YES);

  LOOP(AGEJ(J,AGE)$CARD(TRACKP),
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
    LOOP(TT, PRC_YMAX(TRACKP(R,P)) = ROUND(NCAP_TLIFE(R,TT,P))$(COEF_RPTI(R,TT,P)>1);
      COEF_CAP(RTP_CPTYR(R,TT,T,P))$(PRC_YMAX(R,P)*NCAP_CPX(R,TT,P)) =
        SUM(LIFE$(ORD(LIFE) LE PRC_YMAX(R,P)),SHAPE(J+(NCAP_CPX(R,TT,P)-1),LIFE)) / PRC_YMAX(R,P));
    COEF_CAP(R,V,T,P)$COEF_CAP(R,V,T,P) = 1/MAX(1,COEF_CPT(R,V,T,P)/COEF_CAP(R,V,T,P))-1;
  );
  OPTION RTP_CPX <= COEF_CAP;
  COEF_CPT(R,V,T,P)$COEF_CAP(R,V,T,P) = COEF_CPT(R,V,T,P)*(COEF_CAP(R,V,T,P)+1);
  OPTION CLEAR=PRC_YMIN,CLEAR=PRC_YMAX,CLEAR=TRACKP,CLEAR=COEF_CAP;
