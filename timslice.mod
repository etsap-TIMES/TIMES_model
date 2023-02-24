*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* Timslice.mod - Auxiliary timeslice preprocessing
*=============================================================================*
* complete timeslice declarations
*   - all below ANNUAL
*   - each individual to itself, including leaves
*   - all TS below a node
*-----------------------------------------------------------------------------
  SET RJLVL(J,R,TSLVL), RLUP(R,TSL,TSL);
  PARAMETERS RS_HR(R,S) //, MY_SUM /0/, NORTS(R,YEAR,S) //;
  SETS RS_UP(R,TS,J,TS), RJ_SL(R,J,TS,TS), JS(J,TS) /1.ANNUAL/;
*-----------------------------------------------------------------------------
  TS_GROUP(ALL_R,'ANNUAL',S) = ANNUAL(S);
  OPTION STOAL < TS_GROUP;
  TS_MAP(R,ANNUAL,S) = STOAL(R,S);
  TS_MAP(R,ALL_TS,TS)$SUM(TS_MAP(R,ALL_TS,S),TS_MAP(R,S,TS)) = YES;
  TS_MAP(R,S,S) = STOAL(R,S);
  STOAL(ALL_R,S)$STOAL(ALL_R,S) = STOAL(ALL_R,S)-1;
  IF(CARD(STOAL),ABORT "Error: Timeslice on several levels.");
* Set for timeslices strictly below
  RS_BELOW(TS_MAP(R,S,TS))$(NOT TS_MAP(R,TS,S)) = YES;
* Set for timeslices strictly ONE level below
  RS_BELOW1(RS_BELOW(R,S,TS))$(SUM(TS_MAP(R,S,ALL_TS)$RS_BELOW(R,ALL_TS,TS),1)=1) = YES;
*-----------------------------------------------------------------------------
* Prepare dynamic timeslice tree
$ SET MX '(MIYR_1)' SETGLOBAL RTS S
$ IFI %OBMAC%%DYNTS%==YESYES
$ IF DEFINED TS_OFF $SET MX '' SETGLOBAL RTS S+NORTS(R,T,S)
  SET TS_OFF //;
  LOOP(RS_BELOW1(R,ANNUAL,S)$SUM(TS_OFF(R,S,BOHYEAR,EOHYEAR),1),
$   BATINCLUDE pp_off.mod TS_OFF S "" "NORTS(R,T%MX%,S)$(" 1
    IF(PROD(T%MX%,FIL(T)),G_YRFR(R,TS)$TS_MAP(R,S,TS) = 0;
    ELSE NORTS(R,T(FIL%MX%),TS)$TS_MAP(R,S,TS) = -INF));
$ IF %OBMAC%==YES $MACRO RTS(S) %RTS%
$ IF NOT %OBMAC%==YES ALIAS(ALL_TS,RTS);
*-----------------------------------------------------------------------------
* Set the annual year fraction to 1
  G_YRFR(ALL_R,ANNUAL) = 1;
* Complete missing year fractions if non-zero fractions are given for timeslices right below:
  G_YRFR(R,S)$((G_YRFR(R,S)<=0)$TS_GROUP(R,'WEEKLY',S)) $= SUM(RS_BELOW1(R,S,TS),G_YRFR(R,TS));
  G_YRFR(R,S)$((G_YRFR(R,S)<=0)$TS_GROUP(R,'SEASON',S)) $= SUM(RS_BELOW1(R,S,TS),G_YRFR(R,TS));

*-----------------------------------------------------------------------------
* Remove timeslices that have a zero time fraction
  LOOP(TSL,FINEST(R,S)$((G_YRFR(R,S)<=0)$TS_GROUP(R,TSL,S)) = YES);
  TS_GROUP(R,TSL,S)$FINEST(R,S) = NO;
  TS_MAP(R,TS,S)$FINEST(R,S) = NO;
  RS_BELOW(R,TS,S)$FINEST(R,S) = NO;
  RS_BELOW1(R,TS,S)$FINEST(R,S) = NO;
  NORTS(R,T,S)$FINEST(R,S) = 0;
  OPTION CLEAR=FINEST;
* Build a set for all timeslices in the same subtree
  RS_TREE(R,S,TS)$(TS_MAP(R,TS,S) OR RS_BELOW(R,S,TS)) = YES;
* Define the set of the finest (highest) timeslices in use:
  FINEST(R,S)$(SUM(TS_MAP(R,S,TS),1)=1) = YES;
  LOOP(SAMEAS('5',J),RJLVL(J-ORD(TSL),R,TSL)=SUM(TS_GROUP(R,TSL,S),1));
* Define above-map for TSL levels
  LOOP((J,R,TSL)$RJLVL(J,R,TSL),Z=ORD(J);LOOP(RJLVL(JJ,R,TSLVL)$(ORD(JJ)>Z),RLUP(R,TSL,TSLVL)=1;Z=9));
*-----------------------------------------------------------------------------

* Target accuracy of fractions: 1 second
  Z = 8760*3600; PUTGRP=0;
* Normalize year fractions if they do not sum up
  LOOP(TS_GROUP(R,TSL,S)$(NOT FINEST(R,S)),
   IF(ANNUAL(S)$CARD(NORTS), F=0;
     LOOP(T,MY_F=1-SUM(RS_BELOW1(R,S,TS)$(RS_HR(R,TS)$(NORTS(R,T,TS)=0)),RS_HR(R,TS));
       MY_SUM = SUM(RS_BELOW1(R,S,TS)$((NOT RS_HR(R,TS))$(NORTS(R,T,TS)=0)),G_YRFR(R,TS));
       IF(MY_SUM*MY_F>0,RS_HR(R,TS)$((NORTS(R,T,TS)=0)$(NOT RS_HR(R,TS))$RS_BELOW1(R,S,TS))=MY_F/MY_SUM*G_YRFR(R,TS);
       ELSEIF ABS(MY_F)>99/Z,ABORT 'Invalid dynamic Timeslice configuration'); F=MAX(F,ABS(MY_F-MY_SUM)));
     G_YRFR(R,TS) $= RS_HR(R,TS);
*  Get the year fraction of current timeslice and sum of those below
   ELSE MY_F=G_YRFR(R,S); MY_SUM=SUM(RS_BELOW1(R,S,TS),G_YRFR(R,TS));
     F=ABS(MY_F-MY_SUM); IF(F*Z>1,G_YRFR(R,TS)$RS_BELOW1(R,S,TS)=MY_F/MY_SUM*G_YRFR(R,TS)));
*  If the sum differs from the lump sum by over a second, do normalize:
   IF(F*Z > 1,
$    BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 01 'User-provided G_YRFR values are not valid year fractions'
     PUT QLOG ' WARNING       - TS fractions normalized,  (R.TSL.S)=',TS_GROUP.TE(TS_GROUP);
  ));
*-----------------------------------------------------------------------------
* Calculate the number of storage periods for each timeslice
  G_CYCLE(TSL('WEEKLY'))$(G_CYCLE(TSL)=0)=8760/(24*7); TS_CYCLE(FINEST)=0;
  LOOP(RLUP(R,TSLVL,TSL),TS_CYCLE(R,S)$((TS_CYCLE(R,S)<1)$TS_GROUP(R,TSL,S)) = 365/G_CYCLE(TSLVL));
  LOOP(TSL,RS_STGPRD(R,S)$TS_GROUP(R,TSL,S) = MAX(1,SUM(RS_BELOW1(R,TS,S),G_YRFR(R,TS)*365/TS_CYCLE(R,TS))));

* Timeslice level for all timeslices
  LOOP(TSL, RS_TSLVL(R,S)$TS_GROUP(R,TSL,S) = TSLVLNUM(TSL));
* Calculate the lead from previous storage timeslice for each timeslice
  LOOP(TS_MAP(R,ANNUAL,S), F=0;
   LOOP(RS_BELOW1(R,S,TS), IF(F, RS_STG(R,TS)=ORD(TS)-Z; Z=ORD(TS); ELSE Z=ORD(TS); F=Z));
   RS_STG(R,S+(F-ORD(S)))$F = F-Z;);
* Calculate average residence time for storage activity in each timeslice
  LOOP((R,S,TS(S--RS_STG(R,S)))$RS_STGPRD(R,S),RS_STGAV(R,S) = (G_YRFR(R,S)+G_YRFR(R,TS))/2/RS_STGPRD(R,S));
  RS_STGAV(R,ANNUAL) = 1;

  OPTION STOAL<RS_BELOW1,CLEAR=RS_HR; STOAL(R,S)$(STOAL(R,S)=1)=0;
  IF(CARD(STOAL),PUTGRP=0;
    LOOP((R,S)$STOAL(R,S),
$   BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 99 'Duplicate parent timeslices - Fatal'
    PUT QLOG ' FATAL ERROR   -    REG=',R.TL,' TS='S.TL));
* Define the lags to the ANNUAL timeslice for all S
  LOOP(ANNUAL(TS), STOA(S) = ORD(TS)-ORD(S));
  LOOP(TSL,STOAL(R,S)$TS_GROUP(R,TSL,S) = ORD(TSL)-1);
*----------------------------------------------------------------------
* Define TS hours and map for TS within same cycle
  IF(CARD(RP_UPR)+CARD(RP_UPT),LOOP(TS_MAP(R,ANNUAL,TS),F=0;Z=0;LOOP(RS_BELOW1(R,TS,S),F=G_YRFR(R,S)/RS_STGPRD(R,S);RS_HR(R,S)=MOD(Z+F/2,1);Z=Z+F));
  LOOP(JS(J,ANNUAL),
    RJ_SL(R,J+(MOD(ROUND((RS_HR(R,TS)*8760)/146,0),60)*2),S,TS)$RS_BELOW1(R,S,TS) = YES;
    RJ_SL(R,J+(MOD(ROUND((RS_HR(R,TS)*8760-73)/146+60,0),60)*2+1),S,TS)$RS_BELOW1(R,S,TS) = YES;
    OPTION RS_UP < RJ_SL;
  ));
  IF(CARD(RS_UP),
*   Remove hours too far
    RS_UP(R,TS,J,S)$((MOD(RS_HR(R,TS)-(ORD(J)-2)*73/8760+1,1)<48/8760) OR (MOD(ORD(J)*73/8760-RS_HR(R,TS)+1,1)<25/8760)) = NO;
    OPTION JS < RS_UP; RJ_SL(R,J,S,TS)$(NOT JS(J,S)) = NO;
*   Cycles
    JS_CCL(R,JS(J,S)) = MAX(1/G_YRFR(R,S),365/TS_CYCLE(R,S));
  );
