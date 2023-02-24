*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQMAIN.MOD declarations & call for actual equations                         *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
*GaG Questions/Comments:
*   - any non-binding (=N=) accounting equations, or do it all with reports?
*   - what about scaling (by region)???
*   - declare all equations so that re-start changing models will work
*   - if UP then EQl_ is =L=, LO then EQl_ is =G=, FX then EQl_ is =E=
*-----------------------------------------------------------------------------
* Scaling constants
$IF NOT SET CUFSCAL $SETGLOBAL CUFSCAL 10
$IF NOT SET CUCSCAL $SETGLOBAL CUCSCAL 1000

*-----------------------------------------------------------------------------
*  EQUATIONS
*-----------------------------------------------------------------------------
$   BATINCLUDE eqdeclr.%1 %1
$   IFI %VDA%==YES $BATINCLUDE equ_ext.vda DECLR
*-----------------------------------------------------------------------------
* Objective Function
*-----------------------------------------------------------------------------
* Main OBJ
  PARAMETER SUM_OBJ(ITEM,ITEM) 'Objective component summation';

$IFI '%SPINES%'==YES $BATINCLUDE recurrin.stc SPINES
$IF  '%STAGES%'==YES $%WITSPINE% %SW_STVARS%

$IFI NOT %OBJ%==LIN   $SETLOCAL OBJ %1
$IFI NOT %MACRO%==YES $BATINCLUDE eqobj.%1 %1
$IFI %MACRO%    ==YES $BATINCLUDE eqobj.tm %1
*
$IFI '%SPINES%'==YES $%EWISPINE%
*-----------------------------------------------------------------------------
* Relationship between process activity & individual primary commodity flows
*-----------------------------------------------------------------------------
$   BATINCLUDE eqactflo.%1

*-----------------------------------------------------------------------------
* Bound of vintage process activity or TS-level above PRC_TS
*-----------------------------------------------------------------------------
*V0.5b 980902 - avoid equations if LO=0/UP=INF
$   BATINCLUDE eqactbnd.%1 G LO "(ACT_BND(R,T,P,S,'LO') NE 0)"
$   BATINCLUDE eqactbnd.%1 E FX YES
$   BATINCLUDE eqactbnd.%1 L UP "(ACT_BND(R,T,P,S,'UP') NE INF)"

*-----------------------------------------------------------------------------
* Bound on commodity Net/Production activity above COM_TS
*-----------------------------------------------------------------------------
$   BATINCLUDE eqbndcom.%1 G LO "(COM_BNDNET(R,T,C,S,'LO') NE 0)" NET
$   BATINCLUDE eqbndcom.%1 E FX YES NET
$   BATINCLUDE eqbndcom.%1 L UP "(COM_BNDNET(R,T,C,S,'UP') NE INF)" NET
$   BATINCLUDE eqbndcom.%1 G LO "(COM_BNDPRD(R,T,C,S,'LO') NE 0)" PRD
$   BATINCLUDE eqbndcom.%1 E FX YES PRD
$   BATINCLUDE eqbndcom.%1 L UP "(COM_BNDPRD(R,T,C,S,'UP') NE INF)" PRD

*-----------------------------------------------------------------------------
* Utilization equation ensure activity <= or = capacity
*-----------------------------------------------------------------------------
$   BATINCLUDE eqcapact.%1 E FX %MX%
$   BATINCLUDE eqcapact.%1 L UP %MX%
$   BATINCLUDE eqcapact.%1 G LO
$IF DEFINED PRC_SIMV $INCLUDE coef_csv.mod

*-----------------------------------------------------------------------------
* Capacity transfer constraint
*-----------------------------------------------------------------------------
$IFI '%SPINES%'==YES $%WITSPINE%
$IF '%VALIDATE%'==YES $GOTO M2T
$IFI %ETL% == YES RTP_VARP(RTP(R,T,P))$TEG(P) = YES;
$IFI %MACRO%==YES RTP_VARP(RTP(R,T,P))$((TM_QFAC(R) NE 0)$TM_CAPTB(R,P)) = YES;
$   BATINCLUDE eqcpt.%1 E E "RTP_VARP(R,T,P) OR YES$CAP_BND(R,T,P,'FX')"  "%VAR%_CAP(R,T,P %SOW%)"
$   BATINCLUDE eqcpt.%1 L L "((NOT RTP_VARP(R,T,P))$CAP_BND(R,T,P,'LO'))" "CAP_BND(R,T,P,'LO')"
$   BATINCLUDE eqcpt.%1 G G "((NOT RTP_VARP(R,T,P))$CAP_BND(R,T,P,'UP'))" "CAP_BND(R,T,P,'UP')"
$GOTO NOM2T
$LABEL M2T
$   BATINCLUDE eqcpt.%1 E E  "NOT PRC_MAP(R,'DMD',P)" "%VAR%_CAP(R,T,P %SOW%)"
$   BATINCLUDE eqcpt.%1 L L  "PRC_MAP(R,'DMD',P)" "%VAR%_CAP(R,T,P %SOW%)"
$   BATINCLUDE eqcpt.%1 G G NO 0
$LABEL NOM2T

*-----------------------------------------------------------------------------
* Cumulative Net/Production Commodity Limit
*-----------------------------------------------------------------------------
$   BATINCLUDE eqcumcom.%1 E NET
$   BATINCLUDE eqcumcom.%1 E PRD
* Cumulative process flow / activity
$   BATINCLUDE eqcumflo.%1 E
$IFI '%SPINES%'==YES $%EWISPINE%

*-----------------------------------------------------------------------------
* Basic commodity balance equations (by type) ensuring that production >=/= consumption
*-----------------------------------------------------------------------------
$   BATINCLUDE eqcombal.%1 %1 G LO BAL
$   BATINCLUDE eqcombal.%1 %1 E FX BAL
*  non-binding equation for FRERENEW/CONSRV commodities
*$   BATINCLUDE eqcombal.%1 %1 L UP BAL

*-----------------------------------------------------------------------------
* Limiting equation when total production is to be constrained
*-----------------------------------------------------------------------------
$   BATINCLUDE eqcombal.%1 %1 E FX PRD "* RHS_COMPRD(R,T,C,S)"

*-----------------------------------------------------------------------------
* Bound on the flow variable
*-----------------------------------------------------------------------------
$   BATINCLUDE eqflobnd.%1 G LO YES
$   BATINCLUDE eqflobnd.%1 E FX YES
$   BATINCLUDE eqflobnd.%1 L UP "(FLO_BND(R,T,P,CG,S,'UP') NE INF)"

*-----------------------------------------------------------------------------
* Fraction of a flow within a specific time slice
*-----------------------------------------------------------------------------
$   BATINCLUDE eqflofr.%1 L "'LO'"
$   BATINCLUDE eqflofr.%1 E  LNX
$   BATINCLUDE eqflofr.%1 G "'UP'"

*-----------------------------------------------------------------------------
* Market share equation allocating commodity percentages of a group
*-----------------------------------------------------------------------------
$   BATINCLUDE eqfloshr.%1 L LO IN
$   BATINCLUDE eqfloshr.%1 E FX IN
$   BATINCLUDE eqfloshr.%1 G UP IN

*-----------------------------------------------------------------------------
* Product share equation allocating commodity percentages of a group
*-----------------------------------------------------------------------------
$   BATINCLUDE eqfloshr.%1 L LO OUT
$   BATINCLUDE eqfloshr.%1 E FX OUT
$   BATINCLUDE eqfloshr.%1 G UP OUT

*-----------------------------------------------------------------------------
* Process market share constraint in total commodity production
*-----------------------------------------------------------------------------
$   BATINCLUDE eqflomrk.%1 G LO
$   BATINCLUDE eqflomrk.%1 E FX
$   BATINCLUDE eqflomrk.%1 L UP

*-----------------------------------------------------------------------------
* Inter-regional exchange
*-----------------------------------------------------------------------------
$   BATINCLUDE eqire.%1

*-----------------------------------------------------------------------------
* Bound on exchange between internal regions
*-----------------------------------------------------------------------------
*V0.5b 980902 - avoid equations if LO=0/UP=INF
$   BATINCLUDE eqirebnd.%1 G LO "(IRE_BND(R,T,C,S,ALL_REG,IE,'LO') NE 0)"
$   BATINCLUDE eqirebnd.%1 E FX YES
$   BATINCLUDE eqirebnd.%1 L UP "(IRE_BND(R,T,C,S,ALL_REG,IE,'UP') NE INF)"

*-----------------------------------------------------------------------------
* Commodity peaking
*-----------------------------------------------------------------------------
$   BATINCLUDE eqpeak.%1 %1

*-----------------------------------------------------------------------------
* Commodity-to-commodity transformation
*-----------------------------------------------------------------------------
$   BATINCLUDE eqptrans.%1

*-----------------------------------------------------------------------------
* Inter-period storage
*-----------------------------------------------------------------------------
$   BATINCLUDE eqstgips.%OBJ%
$   BATINCLUDE eqstgaux.%OBJ%

*-----------------------------------------------------------------------------
* Time-slice storage
*-----------------------------------------------------------------------------
$   BATINCLUDE eqstgtss.%1

*-----------------------------------------------------------------------------
* Bound on input/output flows of storage process
*-----------------------------------------------------------------------------
$   BATINCLUDE eqstgflo.%1 IN  G LO 0
$   BATINCLUDE eqstgflo.%1 IN  E FX NA
$   BATINCLUDE eqstgflo.%1 IN  L UP INF
$   BATINCLUDE eqstgflo.%1 OUT G LO 0
$   BATINCLUDE eqstgflo.%1 OUT E FX NA
$   BATINCLUDE eqstgflo.%1 OUT L UP INF

$IFI '%SPINES%'==YES $%WITSPINE%

*---------------------------------------------------------------------
* Bounds on undiscounted costs by region, category and currency
*---------------------------------------------------------------------
$   BATINCLUDE eqbndcst.%1

*-----------------------------------------------------------------------------
* User-constraints
*-----------------------------------------------------------------------------
* Commissioning periods
  SET RVPT(R,ALLYEAR,P,T);
  LOOP(OBJ_2A(R,T,P)$(NOT RTP_OFF(R,T,P)),F=B(T)+NCAP_ILED(R,T,P); Z=SUM(VNT(T,TT)$(F GT E(TT)+0.5),1);
    RVPT(R,T,P,T+Z) = YES);
  RTP_OFF(OBJ_2A(R,T,P))$(NOT SUM(RVPT(R,T,P,TT),1)) = YES;
*-----------------------------------------------------------------------------
* Define a map for region and milestone year specific user constraints to be generated
$IF '%VAR_UC%'==YES $SETLOCAL UCBD '' SETLOCAL UCLIM ',LIM'
$IF NOT '%VAR_UC%'==YES $SETLOCAL UCBD ',BD' SETLOCAL UCLIM ',BD'
 SET UC_RHSMAP(UC_N,UC_NUMBER,UC_NUMBER,REG,T,S%UCBD%);
 SET UC_TMAP(YEAR,YEAR,T,SIDE,UC_DYNT);
 UC_TMAP(T,TT(T-DIAG(SIDE,'RHS')),TT,SIDE,'N') = YES;
 UC_TMAP(T,TT(T-DIAG(SIDE,'RHS')),MILESTONYR,SIDE,'CUMSUM')$(ORD(T) > ORD(MILESTONYR)+DIAG(SIDE,'RHS')) = YES;
 UC_TMAP(T,T,T,'RHS','SYNC') = YES;
 UC_TMAP(T,T,TT,'RHS','CUM+')$UC_TMAP(T,T,TT,'LHS','CUMSUM') = YES;
 LOOP((UC_R_EACH(R,UC_N),T%UCLIM%)$UC_RHSRT(R,UC_N,T%UCLIM%),
  IF(    SUM(UC_TS_SUM(R,UC_N,S),1)$UC_T_EACH(R,UC_N,T),UC_RHSMAP(UC_N,'EACH','SEVERAL',R,T,ANNUAL%UCBD%) = YES;
  ELSEIF SUM(UC_TS_SUM(R,UC_N,S),1)$UC_T_SUCC(R,UC_N,T),UC_RHSMAP(UC_N,'SUCC','SEVERAL',R,T,ANNUAL%UCBD%) = YES;
 ));
 LOOP((UC_R_EACH(R,UC_N),T,S%UCLIM%)$UC_RHSRTS(R,UC_N,T,S%UCLIM%),
  IF(    UC_TS_EACH(R,UC_N,S)$UC_T_EACH(R,UC_N,T),UC_RHSMAP(UC_N,'EACH','EACH',R,T,S%UCBD%) = YES;
  ELSEIF UC_TS_EACH(R,UC_N,S)$UC_T_SUCC(R,UC_N,T),UC_RHSMAP(UC_N,'SUCC','EACH',R,T,S%UCBD%) = YES;
 ));
*-----------------------------------------------------------------------------
$   BATINCLUDE equcwrap.%1 E BD '' SUM(BD$ ,1) NOT
$   BATINCLUDE equcwrap.%1 E "'FX'" ",'FX'"
$   BATINCLUDE equcwrap.%1 G "'LO'" ",'LO'"
$   BATINCLUDE equcwrap.%1 L "'UP'" ",'UP'"

$IFI '%SPINES%'==YES $%EWISPINE%

*-----------------------------------------------------------------------------
* Bound on total inter-regional exchange, including external+internal regions
*-----------------------------------------------------------------------------

*V0.5b avoid equations if LO=0/UP=INF
$   BATINCLUDE eqxbnd.%1 G LO "(IRE_XBND(ALL_REG,T,C,S,IE,'LO') NE 0)"
$   BATINCLUDE eqxbnd.%1 E FX YES
$   BATINCLUDE eqxbnd.%1 L UP "(IRE_XBND(ALL_REG,T,C,S,IE,'UP') NE INF)"

*---------------------------------------------------------------------
*GG* V07_2 Refinery blending
* Blending constraint to a specification characteristic
*---------------------------------------------------------------------
$   BATINCLUDE eqblnd.mod L 1
$   BATINCLUDE eqblnd.mod G 2
$   BATINCLUDE eqblnd.mod E 3
$   BATINCLUDE eqblnd.mod N 4

*---------------------------------------------------------------------
* MACRO equations
*---------------------------------------------------------------------
$IF %MACRO%  == YES  $BATINCLUDE eqmacro.tm

*---------------------------------------------------------------------
* damages
*---------------------------------------------------------------------
$IF DEFINED DAM_COST $BATINCLUDE eqdamage.%1
