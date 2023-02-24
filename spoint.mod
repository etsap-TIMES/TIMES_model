*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* SPOINT.mod is the code for handling solution point saving/loading
*   %1 - 1 or 0 (1: before solve, 0: renaming after solve)
* Note: Using Posix utility mv for renaming for portability
*=============================================================================*
$SETLOCAL PATH '%GDXPATH%' SETLOCAL PNT1 '_p' SETLOCAL PNT2 ''
$IF SET FIXBOH $SETLOCAL PNT1 '' SETLOCAL PNT2 '_p'
$IF NOT SET SPOINT $GOTO CHECK
$IFI %SPOINT%==YES $SET SPOINT 1
  IF(J('%SPOINT%'), Z = SUM(SAMEAS('%SPOINT%',J),ORD(J));
    IF(MOD(Z,2), OPTION SAVEPOINT=1;
* Reset GDX file to ensure it will always be written if SAVEPOINT=1
      IF(%1,execute_unload '%MODEL_NAME%_p.gdx',IMP;
      ELSE  execute 'mv -uf %MODEL_NAME%_p.gdx %PATH%%RUN_NAME%_p.gdx')));
$LABEL CHECK
$IF '%1'=='0' $EXIT
*-----------------------------------------------------------------------------
$IF %STAGES%==YES $BATINCLUDE clearsol.stc ALL
*-----------------------------------------------------------------------------
$LABEL LOADS
$IF %RPOINT%==NO $GOTO LLOAD
$IFI NOT %RPOINT%==YES $SET LPOINT %RPOINT%
$CLEAR EQ_IRE EQE_CPT EQ_PEAK EQE_UCRTP EQE_COMBAL EQG_COMBAL EQE_COMPRD VAR_UPS VAR_UPT VAR_UDP
$CLEAR EQE_UC EQE_UCR EQE_UCT EQE_UCRT EQE_UCTS EQE_UCRTS EQE_UCRS EQE_UCSU EQE_UCSUS EQE_UCRSU EQE_UCRSUS
$IF %VAR_UC%==YES $GOTO UCLEAR
$CLEAR EQG_UC EQG_UCR EQG_UCT EQG_UCRT EQG_UCTS EQG_UCRTS EQG_UCRS EQG_UCSU EQG_UCSUS EQG_UCRSU EQG_UCRSUS
$CLEAR EQL_UC EQL_UCR EQL_UCT EQL_UCRT EQL_UCTS EQL_UCRTS EQL_UCRS EQL_UCSU EQL_UCSUS EQL_UCRSU EQL_UCRSUS
$LABEL UCLEAR
$IF DEFINED EQ_CLITOT OPTION CLEAR=EQ_CLITOT,CLEAR=EQ_CLIMAX; VAR_CLIBOX.L(CM_VAR,LL)$NO=0;
  VAR_BLND.L(R,T,BLE,OPR)$NO = 0;
$IF %TIMESED%==YES VAR_OBJELS.L(R,BD,CUR)$NO = 0;
$IFI %MERGE%==YES $BATINCLUDE clears.mrg
$IF SET TIMESTEP $BATINCLUDE eqobsalv.mod STP EXIT
$ BATINCLUDE pp_clean.mod
*-----------------------------------------------------------------------------
$LABEL LLOAD
$SET LOAD 0
$IF NOT SET LPOINT $GOTO RUNNAME
$IF EXIST %PATH%%LPOINT%%PNT1%.gdx $SET LOAD 2
$IF %LOAD%==2 execute_loadpoint '%PATH%%LPOINT%%PNT1%.gdx';
$IF %LOAD%==2 $GOTO FINISH
$IF EXIST %PATH%%LPOINT%%PNT2%.gdx $SET LOAD 2
$IF %LOAD%==2 execute_loadpoint '%PATH%%LPOINT%%PNT2%.gdx';
$IF %LOAD%==2 $GOTO FINISH
$IF SET FIXBOH $ABORT Could not load gdx file %LPOINT%
*-----------------------------------------------------------------------------
$LABEL RUNNAME
$IF NOT SET SPOINT $GOTO FINISH
$IFI %LPOINT%==%RUN_NAME% $GOTO FINISH
$IF %SPOINT%==2 $SET LOAD 1
$IF %SPOINT%==3 $SET LOAD 1
$IF %LOAD%==0 $GOTO FINISH
$IF EXIST %PATH%%RUN_NAME%_P.gdx $SET LOAD 2
$IF %LOAD%==2 execute_loadpoint '%PATH%%RUN_NAME%_p.gdx';
$IF %LOAD%==2 $GOTO FINISH
$IF EXIST %PATH%%RUN_NAME%.gdx $SET LOAD 2
$IF %LOAD%==2 execute_loadpoint '%PATH%%RUN_NAME%.gdx';
*-----------------------------------------------------------------------------
$LABEL FINISH
$IF NOT DEFINED REG_BDNCAP $SET LOAD 0 
$IF NOT %LOAD%==2 $CLEAR REG_BDNCAP
$IF NOT %LOAD%==2 $EXIT
* Fix new capacities to previous solution if requested
  SET RT_NO(R,T), RTCS(R,ALLYEAR,C,S);
  REG_BDNCAP(R,BDNEQ)$REG_BDNCAP(R,'FX')=MAX(REG_BDNCAP(R,BDNEQ),REG_BDNCAP(R,'FX'))$SUM(BD,REG_BDNCAP(R,BD)$BDSIG(BD));
  REG_BDNCAP(R,'FX')$SUM(BDNEQ$REG_BDNCAP(R,BDNEQ),1)=0;
  LOOP((R,BD)$REG_BDNCAP(R,BD),Z=REG_BDNCAP(R,BD); RT_NO(R,T)$(M(T)<=Z)=YES);
* Determine which milestones available
  RTCS(RTC,S--ORD(S))$=EQG_COMBAL.M(RTC,S);
  RTCS(RTC,S--ORD(S))$=EQE_COMBAL.M(RTC,S);
  OPTION FIL < RTCS;
  PASTSUM(RTP(RT_NO(R,T(FIL)),P))$PRC_CAP(R,P)=EPS;
  PASTSUM(RTP(RT_NO,P)) $= VAR_NCAP.L(RTP);
  RTPS_BD(RTP(RT_NO(R,T),P),ANNUAL,BD)$((M(T)<=REG_BDNCAP(R,BD))$PASTSUM(RTP)) = YES;
  RTPS_BD(RTP(RT_NO(R,T),P),ANNUAL(S),BDNEQ)$(RTPS_BD(RTP,S,'LO')$RTPS_BD(RTP,S,'UP')) = BDSIG(BDNEQ)-NCAP_BND(R,'0',P,'N');
  NCAP_BND(RTP(RT_NO(R,T),P),BD)$RTPS_BD(RTP,'ANNUAL',BD) = MAX(EPS,PASTSUM(RTP),NCAP_BND(RTP,BD)$BDLOX(BD));
  NCAP_BND(RTP(RT_NO,P),'UP')$(NCAP_BND(RTP,'LO')$NCAP_BND(RTP,'UP')) = SMAX(BDNEQ,NCAP_BND(RTP,BDNEQ));
$ IF %STAGES%==YES $SETLOCAL SWT '$SW_T(T%SOW%)'
  %VAR%_NCAP.LO(RTP(RT_NO(R,T),P)%SOW%)%SWT%  $= NCAP_BND(RTP,'LO');
  %VAR%_NCAP.UP(RTP(RT_NO(R,T),P)%SOW%)%SWT%  $= NCAP_BND(RTP,'UP');
  %VAR%_NCAP.FX(RTP(RT_NO(R,T),P)%SOW%)%SWT%  $= NCAP_BND(RTP,'FX');
  VAR_NCAP.L(RTP(RT_NO,P)) $= PASTSUM(RTP);
  OPTION CLEAR=PASTSUM,CLEAR=RTCS,CLEAR=FIL,CLEAR=RTPS_BD,CLEAR=RT_NO;