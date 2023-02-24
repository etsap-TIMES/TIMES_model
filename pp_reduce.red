*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*-----------------------------------------------------------------------------
* Reduction of model size
*-----------------------------------------------------------------------------
* when no reduction all processes have capacity variables and activity equations
  PRC_CAP(RP)     = YES;
  PRC_ACT(RP)     = RP_STD(RP)+RP_IRE(RP);
  OPTION RP_AFB < NCAP_AF;

$SETGLOBAL CAL_RED 'cal_nored.red'
* skip reduction algorithm by setting REDUCE to NO in run file
$IF %REDUCE% == NO $GOTO REDDONE

*-----------------------------------------------------------------------------
* limiting the number of capacity variables
*-----------------------------------------------------------------------------
* determining processes that need capacity variables
  PRC_CAP(RP) = NO;
  LOOP((R,UC_N,P)$UC_GMAP_P(R,UC_N,'CAP',P),  PRC_CAP(R,P) = YES);
  LOOP((R,UC_N,P)$UC_GMAP_P(R,UC_N,'NCAP',P), PRC_CAP(R,P) = YES);
  LOOP((RTP(R,PYR,P))$NCAP_PASTI(R,PYR,P),    PRC_CAP(R,P) = YES);
  LOOP((RTP(R,T,P),BD)$CAP_BND(R,T,P,BD),     PRC_CAP(R,P) = YES);
  LOOP((RTP(R,T,P),BD)$NCAP_BND(R,T,P,BD),    PRC_CAP(R,P) = YES);
  OBJ_ICUR(R,LL--ORD(LL),P,CUR)$DM_YEAR(LL) $= (NCAP_COST(R,LL,P,CUR) NE 0);
  OBJ_ICUR(R,LL--ORD(LL),P,CUR)$DM_YEAR(LL) $= (NCAP_FOM(R,LL,P,CUR) NE 0);
  OBJ_ICUR(R,LL--ORD(LL),P,CUR)$DM_YEAR(LL) $= (NCAP_ISUB(R,LL,P,CUR) NE 0);
  OBJ_ICUR(R,LL--ORD(LL),P,CUR)$DM_YEAR(LL) $= (NCAP_ITAX(R,LL,P,CUR) NE 0);
  OBJ_ICUR(R,LL--ORD(LL),P,CUR)$DM_YEAR(LL) $= (NCAP_FSUB(R,LL,P,CUR) NE 0);
  OBJ_ICUR(R,LL--ORD(LL),P,CUR)$DM_YEAR(LL) $= (NCAP_FTAX(R,LL,P,CUR) NE 0);
  OBJ_ICUR(R,LL--ORD(LL),P,CUR)$DM_YEAR(LL) $= (NCAP_DCOST(R,LL,P,CUR) NE 0);
  OBJ_ICUR(R,LL--ORD(LL),P,CUR)$DM_YEAR(LL) $= (NCAP_DLAGC(R,LL,P,CUR) NE 0);
  LOOP(OBJ_ICUR(R,LL,P,CUR), PRC_CAP(R,P) = YES);
*[UR]: added checks for fixed availabilities
  PRC_CAP(RP(R,P))                      $= RP_AFB(RP,'FX');
  RTPS_BD(R,T--ORD(T),P,S--ORD(S),'FX') $= NCAP_AFS(R,T,P,S,'FX');
  RTPS_BD(R,T--ORD(T),P,ANNUAL,'FX')    $= NCAP_AFA(R,T,P,'FX');
  LOOP(RTPS_BD(R,T,P,S,BD), PRC_CAP(R,P) = YES);
  OPTION CLEAR=OBJ_ICUR,CLEAR=RTPS_BD;
$IF '%ETL%'==YES PRC_CAP(R,P)$SEG(R,P) = YES;

*--------------------------------------------------------------------------------------------
* Occurence of emission flow variable can be replaced by term (source flow x emission factor)
*--------------------------------------------------------------------------------------------
  OPTION CLEAR=TRACKPC;
* Get emission commodity candidates:
  TRACKPC(RP_STD(R,P),C)$(TOP(R,P,C,'OUT')$ENV(R,C)) = YES;
  TRACKPC(RPC_PG) = NO;

* Select only those emissions that have been modeled with FLO_SUM on input flows
  OPTION FSCK <= FLO_SUM;
  FS_EMIS(FSCK(R,P,CG,C,COM))$((COM_GMAP(R,CG,C)$TOP(R,P,C,'IN'))$TRACKPC(R,P,COM)) = YES;
  LOOP(FS_EMIS(R,P,CG,C,COM), RPC_EMIS(R,P,COM) = YES);
*------------------------------------------------------------------------------------------
$IF NOT %REDUCE% == YES $GOTO REDDONE
$SETGLOBAL CAL_RED 'cal_red.red'
*--------------------------------------------------------------
* only 1 commodity in PCG
* => corresponding VAR_FLO can be replaced by VAR_ACT indicated
*    these cases are stored in RPC_ACT
*--------------------------------------------------------------
  RPC_ACT(RPC_PG(RP_PGACT(RP_STD),C)) = YES;

* VAR_IRE can be replaced by VAR_ACT if only 1 import or export commodity
  RPC_AIRE(RPC_PG(RP_IRE(RP_PGACT),C)) = YES;

* If activity is substituted for the primary flow, EQ_ACTFLO is not needed
  PRC_ACT(RP_PGACT) = NO;
*--------------------------------------------------------------------------------------------
* Process without capacity variable and without activity related parameters
* does not need activity variable
*--------------------------------------------------------------------------------------------
  NO_ACT(PRC_ACT(R,P))$(NOT PRC_CAP(R,P)) = YES;
  LOOP((RTP(R,T,P),S,BD)$((ACT_BND(RTP,S,BD)>-INF$BDUPX(BD))$ACT_BND(RTP,S,BD)), NO_ACT(R,P) = NO);
  LOOP((R,DM_YEAR,P,CUR)$ACT_COST(R,DM_YEAR,P,CUR), NO_ACT(R,P) = NO);
  LOOP((R,UC_N,P)$UC_GMAP_P(R,UC_N,'ACT',P), NO_ACT(R,P) = NO);
  NO_ACT(R,P)$SUM(RPC_CUMFLO(R,P,%PGPRIM%,YEAR,LL),1) = NO;

* Remove activity equation from processes that didn't have activity attributes
  PRC_ACT(NO_ACT) = NO;
* Keep RTP_VARA even when no VAR_ACT is needed
**RTP_VARA(R,T,P)$NO_ACT(R,P) = NO;

*--------------------------------------------------------------------------------------------
* If FLO_FUNC between two flow variables and one flow variable defines the activity,
* the other flow variable can be expressed by the activity variable
*--------------------------------------------------------------------------------------------
* check whether commodity defining activity is involved in FLO_FUNC

* Get all FLO_FUNCs between single-commodity groups
  OPTION CG_GRP <= FLO_FUNC; CG_GRP(R,P,CG,CG) = NO;
  CG_GRP(R,P,CG,CG2)$(SUM(RPC(R,P,C)$COM_GMAP(R,CG,C),1) NE 1) = NO;
  CG_GRP(R,P,CG1,CG)$(SUM(RPC(RP_PGACT(R,P),C)$COM_GMAP(R,CG,C),1) NE 1) = NO;
  RPCG_PTRAN(RPC(R,P,C),COM,CG1,CG2)$((COM_GMAP(R,CG1,C)*RPC(R,P,COM)*COM_GMAP(R,CG2,COM))$CG_GRP(R,P,CG1,CG2)) = YES;
* Ensure that possible reverse ordering due to FLO_SUM is taken into account
  LOOP(FSCK(R,P,CG1,C,CG2)$CG_GRP(R,P,CG2,CG1),RPCG_PTRAN(R,P,C,COM,CG1,CG2)$COM_GMAP(R,CG2,COM) = YES);
  RPCG_PTRAN(R,P,C,COM,CG1,CG2)$(NOT (RPC_ACT(R,P,C)+RPC_ACT(R,P,COM))) = NO;
  OPTION TRACKPC < RPCG_PTRAN;

* Check all processes for commodity-to-commodity FLO_SUM:
  OPTION RP_CGG < FSCK;
  RPCG_PTRAN(RP_CGG(RPC_ACT(R,P,COM),C,CG),C)$(RP_PG(R,P,CG)+RPC_ACT(R,P,CG)) = YES;
  RPCG_PTRAN(RP_CGG(RPC(R,P,COM),C,COM),C)$RPC_ACT(R,P,C) = YES;
* If shadow group has special level, don't substitute
  RPCG_PTRAN(RP_SGS,C,COM,CG,CG2) = NO;
  LOOP(RPCG_PTRAN(RP_FLO(R,P),C,COM,CG,CG2),
      IF(RPC_ACT(R,P,C), RPC_FFUNC(R,P,COM) = YES; ELSE RPC_FFUNC(R,P,C) = YES);
  );
* Remove activity flows and emission flows from RPC_FFUNC
  RPC_FFUNC(RPC)$(RPC_ACT(RPC)+RPC_EMIS(RPC)) = NO;
  RPC_FFUNC(RPC_AFLO(TRACKPC)) = NO;

* Add to RPCC_FFUNC all the CG1-CG2 PTRANS equations that are to be eliminated:
  RPCG_PTRAN(R,P,C,COM,CG,CG2)$(NOT (RPC_FFUNC(R,P,C)+RPC_FFUNC(R,P,COM))) = NO;
  LOOP(RPCG_PTRAN(R,P,C,COM,CG,CG2), RPCC_FFUNC(R,P,CG,CG2) = YES);

  OPTION CLEAR=CG_GRP,CLEAR=RP_CGG;
*--------------------------------------------------------------------------------------------
* If upper/fixed ACT_BND of zero at a higher TS-level than PRC_TS,
* do not generate EQL/E_ACTBND equation but add upper/fixed bound
* of zero to the VAR_ACT variables in bnd_act.mod
*--------------------------------------------------------------------------------------------
* (RTP_VARA(r,t,p) will be deleted if only all PRC_TS are fixed to zero in t)
  LOOP((R,T,P,S,BDUPX)$((ACT_BND(R,T,P,S,BDUPX) EQ 0)$ACT_BND(R,T,P,S,BDUPX)),
    RTPS_OFF(R,T,P,S)$RPS_PRCTS(R,P,S) = YES);

* Handle any earlier clearing of VARF
  LOOP((RTPCS_OUT(R,T,P,C,S),RPCS_VAR(RP_STD(R,P),C,S)),
    IF(RPC_FFUNC(R,P,C), RTPS_OFF(R,T,P,TS)$(PRC_TS(R,P,TS)*RS_TREE(R,S,TS)) = YES;
    ELSEIF RPC_ACT(R,P,C), RTPS_OFF(R,T,P,S) = YES));

*--------------------------------------------------------------------------------------------
* Process with upper/fixed activity of zero cannot be used in current period
*--------------------------------------------------------------------------------------------
  OPTION CLEAR=RXX;
* Track commodities turned off by some process, by T, timeslice and IO:
  LOOP(RTPS_OFF(R,T,P,S),IF(RP_STD(R,P),RTCS_SING(R,T,C,S,IO)$TOP(R,P,C,IO) = YES;
                                   ELSE RTCS_SING(R,T,C,S,'OUT')$RPC_IRE(R,P,C,'IMP') = YES));
* Track commodities turned off by some process, by IO only:
  LOOP(RTCS_SING(R,T,C,S,IO),RXX(R,C,IO) = YES);
  RXX(ENV,'IN') = NO; RXX(DEM,'IN') = NO; RXX(R,C,'IN')$RC_AGP(R,C,'LO') = NO;
  LOOP((R,T,COM,C)$(RXX(R,C,'OUT')$COM_AGG(R,T,COM,C)),TRACKC(R,C) = YES);
  RXX(TRACKC,'OUT') = NO;
  RC_IOP(RXX(R,C,IO),P)$TOP(R,P,C,IO) = YES;
  RC_IOP(RXX(R,C,'IN'),P)$RPC_IRE(R,P,C,'EXP') = YES;
  RC_IOP(RXX(R,C,'OUT'),P)$RPC_IRE(R,P,C,'IMP') = YES;
* Check whether commodity is produced by only one process (including STG, consider e.g. STG_CHRG)
  RXX(RXX(R,C,IO))$(SUM(RC_IOP(R,C,IO,P),1) NE 1) = NO;
  RTCS_SING(R,T,C,S,IO)$(NOT RXX(R,C,IO)) = NO;

* turning off all processes in linking to RTCS_SING
  LOOP(RTCS_SING(R,T,C,S,IO--1),
    LOOP(TOP(R,P,C,IO)$(SUM(COM$TOP(R,P,COM,IO),1)=1), RTPS_OFF(R,T,P,S)$RPS_PRCTS(R,P,S) = YES));
* turn off RHS_COMPRD if single producer is turned off
  RHS_COMPRD(R,T,C,S)$RTCS_SING(R,T,C,S,'OUT') = NO;
  OPTION CLEAR=TRACKC,CLEAR=RC_IOP;
*--------------------------------------------------------------------------------------------
  RTPS_OFF(RTPS_OFF(R,T,P,S))$PRC_MAP(R,'STG',P) = NO;
  RTPS_OFF(R,T,P,TS) $= SUM(RS_BELOW(R,S,TS)$RTPS_OFF(R,T,P,S),YES);
* Set EPS bounds for PRC_TS timeslices, removing the EPS bounds above
  ACT_BND(RTPS_OFF(RTP_VARA(R,T,P),S),'UP')$PRC_TS(R,P,S) = EPS;
  ACT_BND(RTPS_OFF(R,T,P,S),BD)$(NOT PRC_TS(R,P,S)) = 0;

* all flows of process with RTPS_OFF entry are forced to zero
* hence flow variable is not required
  RTPCS_OUT(RTPC(RTP(R,T,P),C),S)$RTPS_OFF(R,T,P,S) = YES;
  RTP_VARA(R,T,P)$(SUM(PRC_TS(R,P,TS)$(NOT RTPS_OFF(R,T,P,TS)),1) EQ 0) = NO;

*--------------------------------------------------------------------------------------------

$LABEL REDDONE

*--------------------------------------------------------------------------------------------
* Mark emissions to be handled by substitution
  LOOP(FS_EMIS(R,P,CG,C,COM), RPCC_FFUNC(R,P,CG,COM) = YES);
  OPTION CLEAR=TRACKPC,CLEAR=FSCK;
  PRC_TS2(PRC_TS(RP_PGACT(RP_STD),S)) = YES;
  RPC_PKF(RPC_PKC(PRC_CAP,C)) = 0;

* Remove timeslices turned off if DYNTS enabled
$IF NOT %RTS%==S $BATINCLUDE dynslite.vda REDUCE
