*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* COEF_NIO.MOD coefficient calculations for the flow equations I/OCOM on new  *
*              capacity                                                       *
*=============================================================================*
*GaG Questions/Comments:
*  - COEF_RPTI calculated in PPMAIN.MOD
*[AL] Corrected bugs in the end of commodity flows in the OCOM case
*-----------------------------------------------------------------------------
* commodity flows tied to new capacity
*V0.5b 980828 re-adjust v,t handling to capture enclosed periods & condition to
*             handle period of length 1
     RPC_CAPFLO(R,V,P,C)$(NOT RTP(R,V,P)) = 0;
     FIL(V) = YEARVAL(V) GE MIYR_V1;
*V05c 980923 - use the capacity flow control set
     LOOP(RPC_CAPFLO(R,FIL(V),P,C)$NCAP_ICOM(R,V,P,C), DFUNC = COEF_RPTI(R,V,P);
       MY_F = NCAP_ILED(R,V,P); F = COEF_ILED(R,V,P); CNT = ABS(NCAP_CLED(R,V,P,C));
       Z = B(V)+MAX(1$(CNT$MY_F=0),MY_F); F = Z-MAX(1,MIN(CNT,F));
       IF(DFUNC GT 1,
* repeated investment
          COEF_ICOM(R,T(V),T,P,C) = (DFUNC * NCAP_ICOM(R,V,P,C) / FPD(T))
       ELSE
         LOOP(T$((E(T) >= F) * (B(T) < Z)),
          COEF_ICOM(R,V,T,P,C) =
* some part of consumption in T
*V0.5 980718 - beginning of commodity flow is NCAP_ILED - NCAP_CLED!
            MAX(0,((MIN(Z-1,E(T))-MAX(F,B(T)) + 1) / FPD(T))) * NCAP_ICOM(R,V,P,C) / (Z-F)
       );
      );
     );

* commodity flows tied to decommissioning of capacity
*V05c 980921 - include the PASTInvestments, was looping over MILESTONYR
*V05c 980923 - use the capacity flow control set
     LOOP(RPC_CAPFLO(R,V,P,C)$NCAP_OCOM(R,V,P,C),
       F = NCAP_ILED(R,V,P); MY_F = NCAP_TLIFE(R,V,P);
       Z = MAX(1,NCAP_DLIFE(R,V,P)); DFUNC = COEF_RPTI(R,V,P);
       IF(DFUNC GT 1,
         FOR(CNT = 1 TO CEIL(DFUNC),
           COEF_OCOM(R,V,T,P,C)$(YEARVAL(T) >= YEARVAL(V)) =
                                 COEF_OCOM(R,V,T,P,C) + MIN(1,DFUNC-CNT+1) *
                                 (MAX(0,(MIN(B(V)+F+(CNT*MY_F)+NCAP_DLAG(R,V,P)+Z,E(T)+1) -
                                         MAX(B(V)+F+(CNT*MY_F)+NCAP_DLAG(R,V,P),B(T))
                                        ) / FPD(T)
                                     ) * (NCAP_OCOM(R,V,P,C) / Z)
                                 )
            )
       ELSE
          COEF_OCOM(R,V,T,P,C)$(YEARVAL(T) >= YEARVAL(V)) =
* some part of release in T
            MAX(0,(MIN(B(V)+F+MY_F+NCAP_DLAG(R,V,P)+Z,E(T)+1) -
                   MAX(B(V)+F+MY_F+NCAP_DLAG(R,V,P),B(T))
                  ) / FPD(T)
               ) * (NCAP_OCOM(R,V,P,C) / Z)
       );
     );
  OPTION CLEAR = CNT;
*display coef_icom, coef_ocom;

* Modification: Convert negative ICOM to OCOM so that NCAP-related outputs can also be modeled
* Modification: Convert negative OCOM to ICOM so that DECOM-related inputs can also be modeled
  COEF_OCOM(R,V,T,P,C)$((COEF_ICOM(R,V,T,P,C) LT 0)$COEF_ICOM(R,V,T,P,C)) = COEF_OCOM(R,V,T,P,C)-COEF_ICOM(R,V,T,P,C);
  COEF_ICOM(R,V,T,P,C)$((COEF_ICOM(R,V,T,P,C) LT 0)$COEF_ICOM(R,V,T,P,C)) = 0;
  COEF_ICOM(R,V,T,P,C)$((COEF_OCOM(R,V,T,P,C) LT 0)$COEF_OCOM(R,V,T,P,C)) = COEF_ICOM(R,V,T,P,C)-COEF_OCOM(R,V,T,P,C);
  COEF_OCOM(R,V,T,P,C)$((COEF_OCOM(R,V,T,P,C) LT 0)$COEF_OCOM(R,V,T,P,C)) = 0;

* Allow using NCAP_CLED as NCAP_CLAG, if no NCAP_ICOM
  NCAP_CLAG(RTP,C,IO)$((NOT NCAP_ICOM(RTP,C))$NCAP_COM(RTP,C,IO)) $= NCAP_CLED(RTP,C);
  NCAP_CLED(R,V,P,C)$(NOT NCAP_ICOM(R,V,P,C)) = 0;
