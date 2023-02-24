*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PREPRET.dsc oversees pre-processing for retirements
*=============================================================================*
* Questions/Comments:
*-----------------------------------------------------------------------------
$SET MIP %SOLMIP%==YES
$GOTO %1
*-----------------------------------------------------------------------------
$LABEL PREP
$SET TST %2
$IF DEFINED PRC_REFIT SET %2 //; PARAMETER %3 //;
$IFI '%RETIRE%'==NO $KILL %2
$IF DEFINED %2 PARAMETER %3 //; %3(R,'0',P,'N')$(%3(R,'0',P,'N')=0)$=%2(R,P);
$IFI '%RETIRE%'==YES $SHIFT
  PRC_REFIT(RP,P)$0=0;
$IF NOT DEFINED %2 $EXIT
* Declarations
  SET VNRET(YEAR,LL); PARAMETER RP_RTF(R,P);
* Interpolate RCAP_BND
$IF %TST%==%1 OPTION %TST% < %2;
$ BATINCLUDE fillparm RCAP_BLK R 'P' ",'','','','',''" V 'RTP(R,V,P)' 'GE 0'
$ BATINCLUDE prepparm RCAP_BND R 'P,L' ",'','',''" V 'RTP(R,V,P)' 1
$IF DEFINED NCAP_OLIFE $BATINCLUDE fillparm NCAP_OLIFE R P ",'','','','',''" V 'RTP(R,V,P)' 'GE 0'
$IF DEFINED NCAP_OLIFE OPTION PRC_CAP < NCAP_ELIFE; NCAP_ELIFE(R,V,P)$(NOT PRC_CAP(R,P)) $= NCAP_OLIFE(R,V,P); PRC_CAP(R,P)=0;
* Preprocess refits
  LOOP((RP(R,PRC),P)$(RP(R,P)$PRC_REFIT(RP,P)),
    NCAP_ILED(RTP(R,V,P)) = -ABS(NCAP_ILED(RTP));
    PRC_RCAP(RP)=YES; TRACKP(R,P)$(PRC_REFIT(RP,P)<0)=YES);
  RTP_VARP(RTP(R,T,P)) $= PRC_RCAP(R,P);
  PRC_RCAP(TRACKP)=YES; OPTION CLEAR=TRACKP;
* Activate MIP solution if requested
$IFI %DSC%==YES $SETGLOBAL SOLMIP %RETIRE%
$IFI %RETIRE%==MIP $SETGLOBAL SOLMIP YES
$EXIT
*-----------------------------------------------------------------------------
$LABEL DECL
$IF %MIP% INTEGER
  VARIABLE %VAR%_DRCAP(R,ALLYEAR,LL,P%SWD%,J);
  EQUATION %EQ%_DSCRET(R,ALLYEAR,ALLYEAR,P%SWTD%);
* Maps for refit vintages & types
  LOOP(PRC_RCAP(R,PRC), F=0; CNT=EPS;
   LOOP(P$PRC_REFIT(R,PRC,P),Z=PRC_REFIT(R,PRC,P);
    IF(ABS(Z)>1, F=F+1); CNT$CNT=CNT+1;
    IF(Z<0,RTP_TT(R,T,TT,PRC)$COEF_CPT(R,T,TT,P)=YES;
    ELSE RTP_TT(R,T,T,PRC)$RTP(R,T,P)=YES; CNT=0;));
   RP_RTF(R,PRC)$CNT = -1+2$(F=CNT);
   IF(F,RCAP_BND(RTP(R,T,PRC),'UP')$(NOT SUM(P$PRC_REFIT(R,PRC,P),RTP(R,T,P)$(ABS(PRC_REFIT(R,PRC,P))>1)))=EPS));
$EXIT
*-----------------------------------------------------------------------------
$LABEL EQOBJ
$SETGLOBAL RCAPSUB -SUM(VNRET(V,T),%VART%_SCAP(R,V,T,P%SWS%))$PRC_RCAP(R,P)
$SETGLOBAL RCAPSBM -SUM(VNRET(MODLYEAR,T),%VART%_SCAP(R,MODLYEAR,T,P%SWS%))$PRC_RCAP(R,P)
* Force obj type 2a/2b
  VNRET(VNT(V,T))$(NOT SAMEAS(V,T)) = YES;
  RVPRL(RTP(R,V,P))$PRC_RCAP(R,P)=MAX(0,SMAX(RTP_CPTYR(R,VNRET(V,T),P),YEARVAL(T))-YEARVAL(V));
  RVP(RTP) $= RVPRL(RTP);
  NCAP_ILED(RVP) = NCAP_ILED(RVP)+EPS;
*-------------------

* Allow retirements in integer multiples of a user-defined block-size or the full residual capacity
  %EQ%_DSCRET(RTP_CPTYR(%R_V_T%,P)%SWT%)$(VNRET(V,T)$RCAP_BLK(R,V,P))..

   %VAR%_SCAP(R,V,T,P %SOW%) - RTFORC(R,V,T,P)  =E=
   RCAP_BLK(R,V,P) * %VAR%_DRCAP(R,V,T,P%SOW%,'2') + (NCAP_PASTI(R,V,P)-RTFORC(R,V,T,P)) * %VAR%_DRCAP(R,V,T,P%SOW%,'1');

* Cumulative retirements
  %EQ%_CUMRET(R,VNRET(V,K(T-1)),P%SWT%)$(RTP_CPTYR(R,V,T,P)$PRC_RCAP(R,P))..

   SUM(RTP_CPTYR(R,V,MODLYEAR(K),P),%VAR%_SCAP(R,V,T,P%SOW%)-%VAR%_RCAP(R,V,T,P%SOW%)-%VARM%_SCAP(R,V,K,P%SWS%))
   =E= 0;

* Maximum salvage capacity
  %EQ%L_SCAP(RTP(R,V(LL),P),IPS%SOW%)$(((OBJ_SUMS(RTP)+(NOT PRC_VINT(R,P))$T(V))$RVPRL(RTP)$LIM(IPS) OR NCAP_OLIFE(RTP)$IO(IPS))$PRC_RCAP(R,P))..

   SUM(IO(IPS),SUM((RTP_CPTYR(R,V,TT,P),PRC_TS(R,P,S)),%VARTT%_ACT(R,V,TT,P,S%SWS%)*FPD(TT))/PRC_CAPACT(R,P)/NCAP_OLIFE(RTP)) +
   SUM(VNRET(V,T(LL+RVPRL(RTP))),%VART%_SCAP(R,V,T,P%SWS%))$LIM(IPS)

   =L=  %VARV%_NCAP(R,V,P%SWS%)$T(V) + NCAP_PASTI(R,V,P) - %VAR%_SCAP(R,V,'0',P%SOW%)$OBJ_SUMS(R,V,P)$RVPRL(R,V,P);

* Retrofits and life-extensions
  %EQ%L_REFIT(RTP_TT(R,TT,T,PRC)%SWT%)$RT_PP(R,T)..
   SUM((V(TT),P)$((VNT(T,V) OR PRC_REFIT(R,PRC,P)<0)$PRC_REFIT(R,PRC,P)),COEF_CPT(R,V,T,P)*(%VARV%_NCAP(R,V,P%SWS%)%RCAPSUB%))+%VAR%_RCAP(R,T,TT,PRC%SOW%)
   =E=
   SUM(RTP_CPTYR(R,VNRET(V,TT),PRC),COEF_CPT(R,V,T,PRC) * (%VARTT%_SCAP(R,V,TT,PRC%SWS%)-SUM(MODLYEAR(K(TT-1))$VNRET(V,K),%VARM%_SCAP(R,V,K,PRC%SWS%)+MIN(INF$RP_RTF(R,PRC),RTFORC(R,V,TT,PRC)-RTFORC(R,V,K,PRC)))))+
   SUM(K(TT-1)$RTP_TT(R,K,T,PRC),%VAR%_RCAP(R,T,K,PRC%SOW%))$(RP_RTF(R,PRC)>0);
*-----------------------------------------------------------------------------
$IF %STAGES%==YES $%SW_TAGS%
* Set bounds for continuous retirements
  RCAP_BND(R,T,P,BDNEQ) $= RCAP_BND(R,T,P,'FX');
  PASTSUM(RVP(R,V,P))$RCAP_BND(RVP,'N') = -(B(V)+NCAP_ILED(RVP)+ABS(RCAP_BND(RVP,'N')));
  PASTSUM(RVP)$((RCAP_BND(RVP,'N')<0)+MAPVAL(RCAP_BLK(RVP))) = MAX(1,ABS(PASTSUM(RVP)));
  LOOP(TT(T--1),Z=ORD(T)-1;
  %VAR%_RCAP.LO(RTP_CPTYR(R,VNRET(V,T),P)%SOW%)$RVP(R,V,P) = RCAP_BND(R,T,P,'LO')$(NOT MAPVAL(RCAP_BLK(R,V,P)))+MIN(0,RTFORC(R,V,T,P)-RTFORC(R,V,TT,P)$Z);
  %VAR%_RCAP.UP(RTP_CPTYR(R,VNRET(V,T),P)%SOW%)$RCAP_BND(R,T,P,'UP') =
    MIN(SMIN(PASTMILE(V),NCAP_PASTI(R,V,P)),RCAP_BND(R,T,P,'UP')+MAX(0,RTFORC(R,V,T,P)-RTFORC(R,V,TT,P)$Z)));
  %VAR%_SCAP.LO(RTP_CPTYR(R,V,T,P)%SOW%)$RVP(R,V,P) = MAX(RCAP_BND(R,T,P,'LO'),RTFORC(R,V,T,P));
  %VAR%_SCAP.UP(RTP_CPTYR(R,PASTMILE(V),T,P)%SOW%)$RVP(R,V,P) = MAX(RTFORC(R,V,T,P),NCAP_PASTI(R,V,P));
  LOOP(RVP(R,V,P),Z=1;LOOP(RTP_CPTYR(R,VNRET(V,T),P)$Z,Z=0; %VAR%_SCAP.UP(R,V,T,P%SOW%)=MIN(%VAR%_RCAP.UP(R,V,T,P%SOW%),%VAR%_SCAP.UP(R,V,T,P%SOW%))));
  %VAR%_SCAP.FX(RTP_CPTYR(R,V,T,P)%SOW%)$(((M(T) LT ABS(PASTSUM(R,V,P)))+((M(T)-LEAD(T))/PASTSUM(R,V,P) GE 1))$PASTSUM(R,V,P)) = RTFORC(R,V,T,P);
* Force refits = retirements on request
  PRC_YMAX(PRC_RCAP(RP)) = MIN(0,SUM(P$PRC_REFIT(RP,P),MAX(EPS,2-ABS(PRC_REFIT(RP,P)))));
  RVPRL(R,'0',P) $= PRC_YMAX(R,P);
  %VAR%_RCAP.UP(RTP_TT(R,T(TT++1),T,P)%SOW%)$PRC_YMAX(R,P)=MAX(0,SUM(RTP(R,PYR_S(V),P),RTFORC(R,V,T,P)-RTFORC(R,V,TT,P))$VNT(TT,T)$(NOT RP_RTF(R,P)));
$IF NOT %MIP% OPTION CLEAR=RCAP_BLK;
* Set bounds for integer retirements
  IF(CARD(RCAP_BLK), RCAP_BLK(RTP)$(RCAP_BLK(RTP) LE 0) = 0;
*  Define upper bound of 1 for binary variable if past investments
   COEF_CAP(RTP_CPTYR(R,V,T,P))$RCAP_BLK(R,V,P) = (NCAP_PASTI(R,V,P)-RTFORC(R,V,T,P))/RCAP_BLK(R,V,P);
   %VAR%_DRCAP.UP(RTP_CPTYR(R,V,T,P)%SOW%,'1')$PRC_RCAP(R,P) = 1$(ABS(COEF_CAP(R,V,T,P)-MIN(10,ROUND(COEF_CAP(R,V,T,P)))) >1E-9);
*  Define upper bound for integer multiples
   %VAR%_DRCAP.UP(RTP_CPTYR(R,V,T,P)%SOW%,'2')$RCAP_BLK(R,V,P) = MIN(10,FLOOR(%VAR%_SCAP.UP(R,V,T,P%SOW%)/RCAP_BLK(R,V,P)+1E-8));
  );
  RVPRL(R,PYR_S,P)$PRC_RESID(R,'0',P)=NO; NCAP_OLIFE(R,T,P)$(NOT PRC_VINT(R,P))=NO;
  OPTION CLEAR=COEF_CAP,CLEAR=PASTSUM,CLEAR=RVP;
$EXIT
*-----------------------------------------------------------------------------
$LABEL OBJFIX
* Credit retired capacity for the avoided fixed costs
   SUM((OBJ_SUMIV(K_EOH,R,V,P,JOT,LIFE),VNRET(V,T))$RVPRL(R,V,P),
     SUM((INVSPRED(K_EOH,JOT,LL,K),KTYAGE(LL,T,Y_EOH,AGE))$OPYEAR(LIFE,AGE),
          -OBJ_DISC(R,Y_EOH,CUR) * (1+RTP_CPX(R,V,P,T)$NCAP_CPX(R,V,P)) * %CAPWD%
             (
                OBJ_FOM(R,K,P,CUR) * (1+SUM(RTP_SHAPE(R,V,P,'1',J,JJ),SHAPE(J,AGE)*MULTI(JJ,Y_EOH)-1)) +
                OBJ_FTX(R,K,P,CUR) * (1+SUM(RTP_SHAPE(R,V,P,'2',J,JJ),SHAPE(J,AGE)*MULTI(JJ,Y_EOH)-1)) -
                OBJ_FSB(R,K,P,CUR) * (1+SUM(RTP_SHAPE(R,V,P,'3',J,JJ),SHAPE(J,AGE)*MULTI(JJ,Y_EOH)-1))
             )
        ) *
        %VART%_SCAP(R,V,T,P %SWS%) / OBJ_DIVIV(R,V,P)) +

* RESIDS require special handling
   SUM(RTP_CPTYR(R,PYR_S(V(K)),T,P)$((NOT RVPRL(R,V,P))$PRC_RCAP(R,P)),
        SUM(PERIODYR(T,Y_EOH), -OBJ_DISC(R,Y_EOH,CUR) *
             (
                OBJ_FOM(R,K,P,CUR) * (1+SUM(RTP_SHAPE(R,V,P,'1',J,JJ),MULTI(JJ,Y_EOH)-1)) +
                OBJ_FTX(R,K,P,CUR) * (1+SUM(RTP_SHAPE(R,V,P,'2',J,JJ),MULTI(JJ,Y_EOH)-1)) -
                OBJ_FSB(R,K,P,CUR) * (1+SUM(RTP_SHAPE(R,V,P,'3',J,JJ),MULTI(JJ,Y_EOH)-1))
             )) *
        %VART%_SCAP(R,V,T,P %SWS%)) +
$EXIT
*-----------------------------------------------------------------------------
$LABEL OBSALV
* Discredit salvage value for retired capacity
   SUM(OBJ_SUMS(R,V,P)$((NOT NCAP_FDR(R,V,P)$RVPRL(R,'0',P))$RVPRL(R,V,P)),
     OBJSCC(R,V,P,CUR) * OBJ_DCEOH(R,CUR) *
     (%VAR%_SCAP(R,V,'0',P%SOW%)-%VARV%_NCAP(R,V,P%SWS%)$T(V)-NCAP_PASTI(R,V,P))) +
