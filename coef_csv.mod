*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* COEF_CSV.mod oversees building simulated vintaging coefficients
*=============================================================================*
* Questions/Comments:
* Load after all COEF*.mod
*-----------------------------------------------------------------------------
  SET VTV(LL,LL,T), AFSV(R,T,P,S,BD);
  SET RPS_CAFLAC(R,P,S,L) //;
  PARAMETER COEF_CSV(R,ALLYEAR,LL,P,ALLYEAR);
  PARAMETER NCAP_AFCS(R,LL,P,CG,S) //;
*-----------------------------------------------------------------------------
  EQUATIONS
  EQL_CAPVAC(R,ALLYEAR,T,P,S,ALLSOW)  'Capacity Utilization (=L=)'
  EQE_CAPVAC(R,ALLYEAR,T,P,S,ALLSOW)  'Capacity Utilization (=E=)'
  EQG_CAPVAC(R,ALLYEAR,T,P,S,ALLSOW)  'Capacity Utilization (=G=)';

$IF NOT SET TRIVINT $SET TRIVINT 6
*-----------------------------------------------------------------------------
* Average vintage year for each MODLYEAR:
MY_ARRAY(T) = YEARVAL(T)-LEAD(T);
* Set vintages for simplified vintaging processes:
OPTION CLEAR=PRC_YMIN;
PRC_SIMV(RP)$RP_UPL(RP,'FX')=NO;
LOOP(T(LL), MY_F = YEARVAL(T); Z = MIN(B(T),YEARVAL(T)-FLOOR(LEAD(T)/2));
* Look up the first valid vintages for period T
  PRC_YMIN(PRC_SIMV(R,P))$RTP_VARA(R,T,P) = SMIN(RTP_CPTYR(R,TT,T,P)$(MY_ARRAY(TT)+NCAP_TLIFE(R,TT,P)>Z),MY_ARRAY(TT));
  LOOP(PRC_SIMV(R,P)$RTP_VARA(R,T,P), MY_FYEAR = PRC_YMIN(R,P);
   IF(MY_FYEAR NE INF, F = MY_FYEAR-0.5; Z = MY_F-0.5;
     FIRST_VAL = (%TRIVINT%-0.5)*(%TRIVINT%+0.5);
* Find the vintage maximizing the distance to first and last
     MY_FIL2(TT)= (YEARVAL(TT)-F)*(Z-YEARVAL(TT))$RTP(R,TT,P); Z = SMAX(TT,MY_FIL2(TT));
     IF(Z > FIRST_VAL, Z = SMIN(TT$(MY_FIL2(TT) EQ Z),YEARVAL(TT));
          COEF_CAP(R,LL+(Z-MY_F),T,P) = -1;
          COEF_CAP(R,LL+(MY_FYEAR-MY_F),T,P) =  1;
     ELSE COEF_CAP(R,LL+(MY_FYEAR-MY_F),T,P) = -1;))));
*-----------------------------------------------------------------------------
* Set still missing vintage indicators for year T:
COEF_CAP(R,T,T,P)$(RTP_VARA(R,T,P)$PRC_SIMV(R,P)) = 1;
* Initialize capacity transfer of simulated vintages for each TT
COEF_CSV(RTP_CPTYR(R,TT,T,P),TT)$COEF_CAP(R,TT,T,P) = 1;
*-----------------------------------------------------------------------------
OPTION CLEAR=YK1;
IF(CARD(PRC_SIMV),
 LOOP(MIYR_1(LL), Z = LEAD(LL); OPTION FIL < T; FIL(LL-Z) = YES;
* Add PASTI vintages
  COEF_CSV(RTP_CPTYR(R,PASTMILE,T,P),LL-Z)$(PRC_SIMV(R,P)*NCAP_PASTI(R,PASTMILE,P)) = 1);
* Average effective vintage year for each MODLYEAR:
 YK1(FIL,V)$((NOT SAMEAS(FIL,V))$FIL(V)) = YES;
 VTV(YK1(FIL,V),T)$((YEARVAL(T)-YEARVAL(FIL)-.5)*(YEARVAL(V)-YEARVAL(T)+.5) > 0) = YES;
* Calculate effective average vintage year
 PASTSUM(RTP(R,T,P))$PRC_SIMV(R,P) =
   MIN(M(T),FLOOR(MAX(YEARVAL(T)-(LEAD(T)-1)/2,B(T)+MAX(NCAP_ILED(RTP),(D(T)+NCAP_ILED(RTP)-NCAP_TLIFE(RTP))/2))+0.5));
);
*-----------------------------------------------------------------------------
* Calculate capacity transfer for each simulated vintage:
LOOP(YK1(LL,FIL), Z = YEARVAL(LL); F = YEARVAL(FIL);
 COEF_CSV(RTP_CPTYR(R,TT,T,P),FIL)$((COEF_CAP(R,LL,T,P)*COEF_CAP(R,FIL,T,P) < 0)$VTV(LL,FIL,TT))
	= (PASTSUM(R,TT,P)-Z)/(F-Z)
);
* Embed COEF_CPT in the coefficients
COEF_CSV(RTP_CPTYR(R,V,T,P),FIL)$PRC_SIMV(R,P) = COEF_CSV(R,V,T,P,FIL)*COEF_CPT(R,V,T,P);
*-----------------------------------------------------------------------------
* Clear unused vintages and ReSet RTP_VINTYR
  OPTION CLEAR=YK1,CLEAR=VTV,CLEAR=PASTSUM;
  OPTION COEF_CAP < COEF_CSV;
  RTP_VINTYR(R,V,T,P)$PRC_SIMV(R,P) = NO;
  RTP_VINTYR(R,V,T,P)$COEF_CAP(R,V,T,P) = YES;
  OPTION CLEAR=COEF_CAP;
*-----------------------------------------------------------------------------
  AFSV(AFS(R,T,P,S,BD))$=PRC_SIMV(R,P); AFS(AFSV)=NO;
$ BATINCLUDE eqcapvac.mod E FX N
$ BATINCLUDE eqcapvac.mod L UP N
$ BATINCLUDE eqcapvac.mod G LO LO
