*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
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
$IF NOT SET FIXBOH $GOTO LOADS
$IF NOT %STAGES%==YES $GOTO LOADS
$BATINCLUDE clearsol.stc ALL
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
$IF %LOAD%==2 $EXIT
$IF EXIST %PATH%%LPOINT%%PNT2%.gdx $SET LOAD 2
$IF %LOAD%==2 execute_loadpoint '%PATH%%LPOINT%%PNT2%.gdx';
$IF %LOAD%==2 $EXIT
$IF SET FIXBOH $ABORT Could not load gdx file %LPOINT%
*-----------------------------------------------------------------------------
$LABEL RUNNAME
$IF NOT SET SPOINT $EXIT
$IFI %LPOINT%==%RUN_NAME% $EXIT
$IF %SPOINT%==2 $SET LOAD 1
$IF %SPOINT%==3 $SET LOAD 1
$IF %LOAD%==0 $EXIT
$IF EXIST %PATH%%RUN_NAME%_P.gdx $SET LOAD 2
$IF %LOAD%==2 execute_loadpoint '%PATH%%RUN_NAME%_p.gdx';
$IF %LOAD%==2 $EXIT
$IF EXIST %PATH%%RUN_NAME%.gdx $SET LOAD 2
$IF %LOAD%==2 execute_loadpoint '%PATH%%RUN_NAME%.gdx';
$IF %LOAD%==2 $EXIT
*-----------------------------------------------------------------------------
