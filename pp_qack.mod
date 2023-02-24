*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_QACK.MOD perform the individual quality control checks
*   %1 - mod or v# for the source code to be used
*=============================================================================*
*GaG Questions/Comments:
* - Provide control mechansim to turn-off (ALL, NOFATAL, NONE) tests
*------------------------------------------------------------------------------
* Pending Tests:
*   - check that each process consumes/produces a commodity
*   - check that each commodity is both produced/consumed
*   - TOP not violated by reference to COM not in TOP/T/X
*   - every process has PRC_ACTUNT/CAPUNT specified?
*   - not both COM_NETBND and COM_PRDBND (or does not matter?) + COM_PROJ
*   - check that any commodity/ts-index attribute OK according to COM_TS
*   - c=OCOM+NCAP_VALU+input to another process, otherwise warning
*   - check that FLO_FUNC/SHAR/SUM cg has all elements on the same side
*   - if PRC_ANN and non-ANNUAL attribute provided give warning
*   - check that all attributes s-index match up with RPS and the individual commodities
*   - warning that "NRG" used if no group matching the PG and PRC_SPG not provided
*   - No PRC_CAPUNIT/ACTUNIT assigned and > 1 input; fatal?
*   - PRC_CAPUNIT/ACTUNIT cg should be the same; serious?
*   - Check that anticipated mapping list members that may affect matrix generation are provided (e.g., FRE/LIMRENEW)
*   - check the TS associated with any attribute (as well as COM/PRC_TS) is OK
*   - check that if list of peak timeslices provided by the user then actual peak is in said list
*   - check that all FLO_* c/cg somehow relate to the PG/SPG (ouch)
*   - if TOP_IRE to/from an external check for IRE_BND/PRICE/XBND
*   - check that PRC_TSL=COM_TSL=COM_FR for DEM commodities
*   - check that TS-attributes are found in TS_GROUP/MAP for the region (during Aggr/Inher)
*     - or see what is around for TS_GROUP (TS_MAP if > 2 levels) and G_YRFR at the min!!!
*   - check that no 0/EPS for attributes that could turn-off a flow, or cause a 0 divide
*-----------------------------------------------------------------------------
*V0.5c 980904 - File opened in PPMAIN.MOD, setup to append in case any PP_MAIN messages output
*  FILE QLOG / QA_CHECK.LOG /;
  ALIAS(U2,U3,U4,*);
  PUT QLOG;
  IF(PUTOUT, QLOG.AP = 1);

* make 2 decimals points and allow for wider page
  QLOG.NW=10;QLOG.ND=2;QLOG.PW=150;

  PUTGRP = 0;
*-----------------------------------------------------------------------------
* Some important control sets are completed here
* Complete merely CAP dependent flow indicators
  RPC_CONLY(RTPC(R,T,P,C))$RPC_NOFLO(R,P,C) = YES;
* Complete flow variable indicators
  RTPCS_VARF(RPC_CONLY(R,T,P,C),S) = NO;
* Remove superfluous entries from RCS_COMBAL
  RCS_COMBAL(RHS_COMBAL,BDNEQ) = NO;
* Establish the RPG_RED control set
  TRACKPC(R,P,C)$(RPC_ACT(R,P,C)+RPC_FFUNC(R,P,C)+RPC_EMIS(R,P,C)) = YES;
  RPG_RED(R,P,CG,IO)$(NOT SUM(TOP(TRACKPC(R,P,C),IO)$COM_GMAP(R,CG,C),1)) = NO;
  OPTION CLEAR = TRACKPC;
$ IFI %VAR_UC%==YES OPTION UC_GMAP_U<=UC_UCN;
  RTP(NO_RVP) = NO;
*-----------------------------------------------------------------------------
* Year fractions
*-----------------------------------------------------------------------------
  LOOP(R, TS_ARRAY(S) = 0;
    LOOP(TS_MAP(R,TS,S)$(G_YRFR(R,S) EQ 0), TS_ARRAY(S) = 1;);
    LOOP(S$TS_ARRAY(S),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 99 'Year Fraction G_YRFR is ZERO!'
         PUT QLOG ' FATAL ERROR   -     R=',%RL%,' S=',S.TL;
  ));
  PUTGRP = 0;
*-----------------------------------------------------------------------------
* Topology
*-----------------------------------------------------------------------------
* Check PGPRIM
  LOOP(RPC(R,P,C(%PGPRIM%)),
$    BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 99 'Illegal system commodity in topology.'
     PUT QLOG ' FATAL ERROR   -     R=',%RL%,' P=',%PL%,' C=',C.TL;
  );
  PUTGRP = 0; Z = 1;
* see that components of any CG for a process in topology
  LOOP(PRC_CG(R,P,CG)$(NOT COM_TYPE(CG)),
      Z = NOT SUM(COM_GMAP(R,CG,C)$RPC(R,P,C),1);
      LOOP(COM_GMAP(R,CG,C)$((NOT RPC(R,P,C))$Z),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 10 'Commodity in CG of process P but not in topology'
         PUT QLOG ' SEVERE WARNING  -   R=',%RL%,' P=',%PL%,' C=',%CL%,' CG=',CG.TL ;
      )
    );
  PUTGRP = 0;
*-----------------------------------------------------------------------------
* Commodity description
*-----------------------------------------------------------------------------
$IF NOT %TIMESED%==YES $SETLOCAL TIMESED NO
  IF(%TIMESED%,
    LOOP(DEM(R,C)$SUM(BD$COM_STEP(R,C,BD),1),
* Check that elastic demands fully sprecifed
      IF((NOT SUM((T,S,CUR)$COM_BPRICE(R,T,C,S,CUR),1)) +
         (NOT SUM((T,BD)$COM_VOC(R,T,C,BD),1)) +
         (NOT SUM((T,S,BD)$COM_ELAST(R,T,C,S,BD),1)),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 10 'Elastic Demand but either COM_BPRICE/ELAST/VOC missing'
         PUT QLOG ' WARNING       -     R=',%RL%,' C=',%CL% ;
      )
    );
  );
  PUTGRP = 0;
  LOOP(RC(R,C(COM_TYPE)),
$          BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 99 'Commodity type is also a commodity'
           PUT QLOG ' FATAL ERROR   -     R=',%RL%,' C=',C.TL ;
  );
  PUTGRP = 0;
  LOOP(RC(R,C)$(SUM(COM_TMAP(R,COM_TYPE,C),1) NE 1),
$          BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 09 'Commodity has ambiguous base type'
    IF(SUM(COM_TMAP(R,COM_TYPE,C),1) GT 1,
           PUT QLOG ' FATAL ERROR   -  Several types: R=',%RL%,' C=',C.TL ;
    ELSE   PUT QLOG ' FATAL ERROR   -  Missing type : R=',%RL%,' C=',C.TL ;);
  );
  PUTGRP = 0;
*-----------------------------------------------------------------------------
* Demand description
*-----------------------------------------------------------------------------
  OPTION TRACKC < RD_SHAR;
  LOOP((R,T,C)$COM_PROJ(R,T,C),TRACKC(R,C) = YES);
  LOOP(COM_GMAP(DEM(R,C),C)$(NOT TRACKC(R,C)),
$          BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Demand: DEM commodity with missing COM_PROJ Projection'
           PUT QLOG ' WARNING       -     R=',%RL%,' C=',C.TL ;
  );
  PUTGRP = 0;
  LOOP(TRACKC(R,C)$(NOT DEM(R,C)),
$          BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Demand: COM_PROJ specified for non-DEM commodity'
           PUT QLOG ' WARNING       -     R=',%RL%,' C=',C.TL ;
  );
  OPTION CLEAR=TRACKC;
  PUTGRP = 0;
*-----------------------------------------------------------------------------
* Process description
*-----------------------------------------------------------------------------
  SET QASTAT(J) / 1 'Unreliable (see QA_Check.log)' /;
  OPTION TRACKPC<RPC; TRACKPC(RP(R,PRC(P)),C)$RC(R,C)=NO;
  LOOP(TRACKPC(RPC),
$   BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 33 'Phantom entries found in topology (process/commodity not in SET PRC/COM)'
    PUT QLOG ' FATAL ERROR   -     Phantom topology entry:   R.P.C= ',TRACKPC.TE(RPC));
  OPTION CLEAR=TRACKPC,CLEAR=PRC_CG;
  IF(ERRLEV=33,SOLVESTAT(J)$=QASTAT(J));
  PUTGRP = 0;
  PRC_YMAX(RP)=SUM(RP_PG(RP,CG),1)-1;
  LOOP(RP(R,P)$PRC_YMAX(R,P),
* Check that unambiguous PCG specified
$     BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 10 'Process with missing or mismatched CG/PRC_ACTUNIT'
      IF(PRC_YMAX(RP)<0,
         PUT QLOG ' FATAL ERROR   -  No way to identify PCG:   R=',%RL%,' P=',P.TL ;
      ELSE
         PUT QLOG ' FATAL ERROR   -  Several PCG groups:       R=',%RL%,' P=',P.TL ;
      );
  );
* Add PTRANS control for ACT_FLO
  PRC_CG(RP_PG(R,P,CG))$=SUM(RPC_AFLO(R,P,C)$(NOT RPC_FFUNC(R,P,C)),1);
  PUTGRP = 0;
* Make a QA Complaint about invalid FS_EMIS substitution
  LOOP(FS_EMIS(R,P,CG,C,COM)$RPC_EMIS(R,P,C),
$   BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 01 'Illegal dependency of substituted auxiliary commodities C1 and C2 in FLO_SUM'
    PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' C1=',%CL%,' C2=',COM.TL;
  );
  PUTGRP = 0;
  OPTION  PRC_YMAX < PRC_REFIT; PRC_YMAX(RP)$(PRC_YMAX(RP)=1)=0;
  LOOP(RP(R,P)$PRC_YMAX(RP),
$   BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 01 'Multiple host processes for REFIT option - Not supported'
    PUT QLOG ' WARNING       -     REG=',R.TL,' PRC='P.TL);
  PUTGRP = 0;
  IF(CARD(RP_UPL),OPTION TRACKP<NCAP_AFX; TRACKP(PRC_VINT)=NO;
  LOOP(RP_UPL(TRACKP(R,P),'FX'),
$   BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 00 'NCAP_AFX defined for NON-vintaged dispatchable process with ACT_MINLD'
    PUT QLOG ' NOTICE        -     AFX ignored on PRC_TSL:  R=',%RL%,' P=',%PL%;
  );
  OPTION CLEAR=TRACKP,CLEAR=PRC_YMAX; PUTGRP = 0);
*-----------------------------------------------------------------------------
* Possible reasons for execerror in retrospect
  IF(EXECERROR,
    OPTION CLEAR=RXX; LOOP(RDCUR(R,CUR),RXX(R,CUR,R)=YES); RXX(R,CUR,R)=NO;
    LOOP(RXX(R,ITEM,R),
$   BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 99 'Active currency but not member of set CUR'
    PUT QLOG ' FATAL ERROR   -     R=',%RL%,' CUR=',ITEM.TL); PUTGRP=0;
    LOOP(R$PROD(G_RCUR(R,CUR),0),IF(SUM(RP(R,P),1),
$   BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 99 'Internal Region without Discount Rate'
    PUT QLOG ' FATAL ERROR   -     R=',%RL%)); PUTGRP=0;
    OPTION CLEAR=RXX; LOOP(OBJ_ICUR(R,V,P,CUR)$(NOT RDCUR(R,CUR)),RXX(R,R,CUR)=YES);
    LOOP(RXX(R,R,CUR),
$   BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 99 'Active Currency without Discount Rate'
    PUT QLOG ' FATAL ERROR   -     R=',%RL%,' CUR =',CUR.TL);
    LOOP(RTPC(R,T,P,C)$((PRC_ACTFLO(R,T,P,C) EQ 0)$RPC_PG(R,P,C)),TRACKPC(R,P,C)=YES);
    LOOP(TRACKPC(R,P,C),
$   BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 99 'Process with zero PRC_ACTFLO for C in PG'
    PUT QLOG ' FATAL ERROR   -     R=',%RL%,' P=',%PL%,' C=',%CL%);
    OPTION CLEAR=TRACKPC; PUTGRP = 0);
*-----------------------------------------------------------------------------
* Extended QA chacks - Activated when either DEBUG=YES or XTQA is set
*-----------------------------------------------------------------------------
$IFI '%DEBUG%'==YES $SET XTQA YES
$IFI NOT '%VDA%%XTQA%'==YESYES $GOTO FINISH
* Not same commodity TOP IN/OUT
   LOOP(RPC(R,P,C)$(TOP(R,P,C,'IN')*TOP(R,P,C,'OUT')),
     IF(NOT PRC_MAP(R,'STG',P),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Same Commodity IN and OUT of non-STG process'
         PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' C=',C.TL;
     ));
   PUTGRP = 0;
*-----------------------------------------------------------------------------
* IRE process parameter check
  OPTION CLEAR=UNCD7;
  UNCD7(R,LL+(1-ORD(LL)),P,CG1,CG2,S--ORD(S),'0') $= FLO_FUNC(R,LL,P,CG1,CG2,S)$RP_IRE(R,P);
  UNCD7(R,LL+(2-ORD(LL)),P,CG1,C,CG2,S--ORD(S))   $= FLO_SUM(R,LL,P,CG1,C,CG2,S)$RP_IRE(R,P);
  UNCD7(R,LL+(3-ORD(LL)),P,C,CG,S--ORD(S),BD)     $= FLO_SHAR(R,LL,P,C,CG,S,BD)$RP_IRE(R,P);
  UNCD7(R,LL+(4-ORD(LL)),P,CG,S--ORD(S),'0','0')  $= ACT_EFF(R,LL,P,CG,S)$RP_IRE(R,P);
  LOOP(UNCD7(R,LL,P,CG,U2,U3,U4), Z = ORD(LL);
$      BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'IRE Process with invalid Parameters'
       IF(Z = 1, PUT QLOG ' WARNING       - IRE with FLO_FUNC: R=',%RL%,' P=',%PL%,' CG=',CG.TL);
       IF(Z = 2, PUT QLOG ' WARNING       - IRE with FLO_SUM:  R=',%RL%,' P=',%PL%,' CG=',CG.TL);
       IF(Z = 3, PUT QLOG ' WARNING       - IRE with FLO_SHAR: R=',%RL%,' P=',%PL%,' C=',CG.TL);
       IF(Z = 4, PUT QLOG ' WARNING       - IRE with ACT_EFF:  R=',%RL%,' P=',%PL%,' CG=',CG.TL);
  );
  OPTION CLEAR=UNCD7;
  UNCD7(UC_N,SIDE--ORD(SIDE),R,LL--ORD(LL),P,C,S--ORD(S)) $= UC_FLO(UC_N,SIDE,R,LL,P,C,S)$RP_IRE(R,P);
  LOOP(UNCD7(UC_N,SIDE,R,LL,P,C,S),
$      BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'IRE Process with invalid Parameters'
       PUT QLOG ' WARNING       - IRE with UC_FLO:   R=',%RL%,' P=',%PL%,' UC_N=',UC_N.TL;
  );
*-----------------------------------------------------------------------------
  PUTGRP = 0;
* ACT_EFF quality tests
  IF(CARD(ACT_EFF),
  OPTION RP_GRP < ACT_EFF;
  RP_GRP(RPC_ACE)=NO; RP_GRP(RPC_PG)=NO;
  RP_GRP(R,P,CG)$SUM(RPG_ACE(R,P,CG,IO),1)=NO;
  RP_GRP(R,P,CG)$SUM(RPG_1ACE(R,P,CG,C),1)=NO;
  RP_GRP(R,P,C)$SUM(RPG_1ACE(R,P,CG,C),1)=NO;
  LOOP(RP_GRP(R,P,CG),
   IF(NOT SUM((TOP(R,P,C(CG),IO),COM_GMAP(R,CG2,C))$RPG_ACE(R,P,CG2,IO),1),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Invalid Commodity / Group used in ACT_EFF - parameter ignored'
         PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' CG=',CG.TL;
   )));
  PUTGRP = 0;
* FLO_SUM quality tests
  OPTION CLEAR=FSCK, CLEAR=UNCD7;
  OPTION FSCK <= FLO_SUM;
  FSCK(RPC_EMIS(R,P,CG),C,CG)$RPC(R,P,C) = NO;
  LOOP(FSCK(R,P,CG,C,CG2)$(NOT RPC(R,P,C)),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'FLO_SUM Commodity Not in RPC - parameter ignored'
         PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' CG=',CG.TL,' C=',C.TL;
   );
  PUTGRP = 0;
* FLO_SUM commodity-in-group test
  FSCK(RPC(R,P,COM),C,COM)$RPCC_FFUNC(R,P,COM,COM) = NO;
  LOOP(FSCK(R,P,CG,C,CG2)$(NOT COM_GMAP(R,CG,C)),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'FLO_SUM Commodity Not in CG1 - parameter ignored'
         PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' CG1=',CG.TL,' C=',C.TL;
   );
  PUTGRP = 0;
* Two-way PTRANS equations chack
   OPTION CLEAR=CG_GRP; FSCK(RP,C,COM,C)=NO;
   LOOP(FSCK(R,P,CG1,C,CG2),CG_GRP(R,P,CG1,CG2) = YES);
   LOOP((R,V,P,CG1,CG2,S)$(FLO_FUNC(R,V,P,CG2,CG1,S)$FLO_FUNC(R,V,P,CG1,CG2,S)),CG_GRP(R,P,CG1,CG2) = YES);
   LOOP(CG_GRP(R,P,CG1,CG2)$CG_GRP(R,P,CG2,CG1),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 10 'PTRANS between CG1 and CG2 in both directions'
         PUT QLOG ' FATAL ERROR   -     R=',%RL%,' P=',%PL%,' CG1=',CG1.TL,' CG2=',CG2.TL;
   );
  OPTION CLEAR=FSCK;
  PUTGRP = 0;
* All TOPc are in some ACTFLO/FLO_SHAR/FLO_FUNC
  OPTION CLEAR=CG_GRP;
  OPTION RP_CCG < COEF_PTRAN;
  CG_GRP(RP_CCG) = YES;
  OPTION RP_CCG < FLO_SHAR;
  CG_GRP(RP_CCG) = YES;
  OPTION RP_GRP < CG_GRP;
  CG_GRP(R,P,C,COM)$((NOT ENV(R,C))$ENV(R,COM)) = NO;
  TRACKPC(R,P,C) $= SUM(CG_GRP(R,P,C,CG2),1);
  RP_GRP(TRACKPC(R,P,C))$(NOT RPC(R,P,C)) = YES;
  TRACKPC(RP_GRP(RPC(R,P,C))) = YES; RP_GRP(RPC) = NO;
  LOOP(RP_GRP(R,P,CG),TRACKPC(RPC(R,P,C))$COM_GMAP(R,CG,C) = YES);
$IF DEFINED RPG_ACE LOOP(RPG_ACE(R,P,CG,IO),TRACKPC(RPC_ACE(R,P,C)) = YES);
  TRACKPC(RPC_PG) = YES;
  TRACKPC(RPC(R,P,C))$RP_IRE(R,P) = YES;
  TRACKPC(RPC_SPG(RPC_STG)) = YES;
  TRACKPC(RPC_NOFLO) = YES;
  TRACKPC(RPC_FFUNC) = YES;
  LOOP(T, TRACKP(RP_STD(R,P))$RTP_VARA(R,T,P) = YES);
  LOOP(TOP(TRACKP(R,P),C,IO)$(NOT TRACKPC(R,P,C)),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'RPC in TOP not found in any ACTFLO/FLO_SHAR/FLO_FUNC/FLO_SUM'
         PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' C=',%CL%,' IO=',IO.TL;
  );
  OPTION CLEAR=TRACKP,CLEAR=TRACKPC,CLEAR=CG_GRP,CLEAR=RP_CCG;
  PUTGRP = 0;
* Empty groups check
  RP_GRP(RP_PG(R,P,CG))$(NOT SUM(RPC_PG(R,P,C),1)) = YES;
$IF SET PGPRIM RP_GRP(R,P,%PGPRIM%) = NO;
  LOOP(RP_GRP(RP(R,P),CG)$(NOT SUM(RPC(R,P,C)$COM_GMAP(R,CG,C),1)),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Empty Group in FLO_SUM/FLO_FUNC/FLO_SHAR'
         PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' CG=',CG.TL;
  );
  PUTGRP = 0;
  OPTION CLEAR=RXX,CLEAR=RP_GRP;
* Simultaneous NCAP_AF/NCAP_AFA availability check
  LOOP((R,V,P,BD)$(PRC_TS(R,P,'ANNUAL')*NCAP_AFA(R,V,P,BD)), RXX(R,V,P) = YES;);
  LOOP((RXX(R,V,P),BD)$((NCAP_AF(R,V,P,'ANNUAL',BD) NE 1)$NCAP_AF(R,V,P,'ANNUAL',BD)),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Both NCAP_AF and NCAP_AFA specified for same process'
         PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' V=',V.TL;
  );
  PUTGRP = 0;
* Commodity fraction check
  LOOP(RTC(R,T,C)$(ABS(SUM(COM_TS(R,C,S),COM_FR(R,T,C,S))-1) GT 3E-3),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Commodity fractions do not sum up to 1'
         PUT QLOG ' WARNING       -     R=',%RL%,' C=',%CL%,' T=',T.TL;
  );
  PUTGRP = 0;
* NCAP_CLED duration check
   LOOP((R,V,P,C)$NCAP_CLED(R,V,P,C),
     IF(NCAP_CLED(R,V,P,C) > COEF_ILED(R,V,P),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Too Long Commodity Lead Time'
         PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%,' C=',C.TL;
     ));
  PUTGRP = 0;
* CHP parameter check
  OPTION CLEAR=UNCD7;
  UNCD7('1',R,V,P,'','','')$(NOT CHP(R,P)) $=NCAP_BPME(R,V,P);
  UNCD7('2',R,V,P,BDUPX,'','')$(NOT CHP(R,P)) $=NCAP_CHPR(R,V,P,BDUPX);
  UNCD7('3',R,V,P,'','','')$(NOT CHP(R,P)) $=NCAP_CEH(R,V,P);
  LOOP(UNCD7(J,R,V,P,U2,U3,U4), Z=ORD(J);
$   BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'CHP parameter specified for Non-CHP process'
    PUT QLOG ' WARNING       -     NCAP_';
    IF(Z=1,PUT QLOG,'BPME';ELSEIF Z=2,PUT QLOG,'CHPR';ELSE PUT QLOG,'CEH ');
    PUT QLOG ': R=',%RL%,' P=',%PL%,' V=',V.TL;
  );
  PUTGRP = 0;
* CHP primary group check
  LOOP(CHP(RP_PGACT(R,P)),
   IF(SUM((T,BD)$NCAP_CHPR(R,T,P,BD),1),
$        BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'PG of CHP process consists of single commodity yet has a CHP-ratio'
         PUT QLOG ' SEVERE ERROR  -     R=',%RL%,' P=',%PL%;);
  );
  PUTGRP = 0;
* CHP ratio check, if some ratios defined
  TRACKP(CHP(R,P))=SUM(RTP(R,T,P)$(NOT SUM(BD$NCAP_CHPR(R,T,P,BD),1)),1);
  LOOP(R, Z=SUM(TRACKP(R,P)$(NOT RP_PGACT(R,P)),1);
   IF(Z,
$      BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Found CHP processes without CHP-ratio defined'
       PUT QLOG ' WARNING       -     R=',%RL%,' Number of PRCs without ratio: ',Z:0:0;);
  ); OPTION CLEAR=TRACKP;
  PUTGRP = 0;
* CHP efficiency check
  LOOP((CHP_ELC(R,P,C),RPG_PACE(R,P,CG)),
$      BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Found CHP processes with PG commodity efficiencies - unsupported'
       PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%;);
  PUTGRP = 0;
* CHP electricity check
  LOOP(CHP(R,P)$(NOT SUM(RPC_PG(R,P,C)$NRG_TMAP(R,'ELC',C),1)),
$      BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 01 'Found CHP processes without electricity in the PG'
       PUT QLOG ' WARNING       -     R=',%RL%,' P=',%PL%;);
*-----------------------------------------------------------------------------
$LABEL FINISH
*-----------------------------------------------------------------------------
* Abort if truly MAJOR ERROR
  IF(ERRLEV >= 33,
    IF(ERRLEV=33, PUTGRP=0;
$      BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 33 'Found severe modeling errors (see error code 33 above) ***'
       PUT QLOG ' ERROR ALERT   -     Model Solution is Unreliable         ';
    ELSE ABORT '*** FATAL QA ERROR - Check the QA_CHECK.LOG file for details ***'
  ));

$   BATINCLUDE pp_qaput.%1 PUTOUT$PUTOUT PUTOUT * 'ALL QUALITY CHECKS PASSED ***'
  OPTION CLEAR = PUTOUT, CLEAR = PUTGRP, CLEAR = ERRLEV;
  PUTCLOSE QLOG;
