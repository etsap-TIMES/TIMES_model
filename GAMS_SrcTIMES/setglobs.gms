*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2020 IEA-ETSAP.  Licensed under GPLv3 (see file LICENSE.txt).
*=========================================================================
* Globals.gms - Safe Set of TIMES Critical Global control variables
* %1 - optional variable label to jump
*=========================================================================
$SET ControlAbort "Abort Internal Control variable being set by user, aborted"
$SETARGS X1 X2
$LABEL START
$IF NOT '%X2%'=='' $GOTO %X2%
*-------------------------------------------------------------------------
* Normal Tags for standard TIMES (changed under stochastic mode)
$SETGLOBAL SW_NOTAGS %X1%
$IF NOT %SW_NOTAGS%=="%X1%" $%ControlAbort%: SW_NOTAGS
$IF "%X1%"==''
$SETGLOBAL SW_NOTAGS SET EQ 'EQ' SET VAR 'VAR' SET SWS '' SET SOW '' SET SWT '' SET SWD '' SET SWTD '' SET SWSW '' SET VART 'VAR' SET VARV 'VAR' SET VARM 'VAR' SET VARTT VAR

* Helper for process tranformation shape controls
$SETGLOBAL SHFF '%X1%' SETGLOBAL RCAPSUB '%X1%' SETGLOBAL RCAPSBM %X1%
$IF NOT "%SHFF%%RCAPSUB%%RCAPSBM%"=='%X1%%X1%%X1%' $%ControlAbort%: SHFF / RCAPSUB
$SETGLOBAL SHFF 1+RTP_FFC

* Additional tags for stochastic
$SETGLOBAL MX '%X1%' SETGLOBAL SCUM '%X1%' SETGLOBAL SW_STVARS %X1%
$IF NOT "%MX%%SCUM%%SW_STVARS%"=='%X1%%X1%%X1%' $%ControlAbort%: MX / SW_STVARS / SCUM

* Objective function variants
$SETGLOBAL CAPJD '%X1%' SETGLOBAL CAPWD %X1%
$IF NOT '%CAPJD%%CAPWD%'=='%X1%%X1%' $%ControlAbort%: CAPxD
*
$SETGLOBAL SWX '%X1%' SETGLOBAL SWTX %X1%
$IF NOT "%SWX%%SWTX%"=='%X1%%X1%' $%ControlAbort%: SWX
$SETGLOBAL SWX ,'1'
*
$SET TMP '%CTST%' SETGLOBAL CTST %X1%
$IF NOT "%CTST%"=='%X1%' $%ControlAbort%: CTST
$SETGLOBAL CTST %TMP%
*
* Tags for stochastic TIMES (set in stages.stc)
$SETGLOBAL SW_TAGS %X1%
$IF NOT "%SW_TAGS%"=='%X1%' $%ControlAbort%: SW_TAGS
$IF NOT '%X1%'=='' $SETLOCAL X1 '' GOTO START
*---------
* DATA Dump
$IF NOT %DATAGDX%==YES $GOTO EOF
$GDXOUT _dd_.gdx
$UNLOAD
$GDXOUT
$IF NOT warnings $GOTO EOF
$IF NOT %G2X6%==YES $GOTO EOF
  DISPLAY 'GAMS Warnings detected; Data have been Filterd via GDX';
$hiddencall gdxdump _dd_.gdx NODATA > _dd_.dmp
$hiddencall sed "/\(^Scalar\|(\*)\)/{N;d;}; /^\([^$].*$\|$\)/d; s/\$LOAD.. /$LOADR /" _dd_.dmp > _dd_.dd
$INCLUDE _dd_.dd
$hiddencall rm -f _dd_.dmp
$GDXIN
*---------
$LABEL EOF
$SETGLOBAL TIMESED 0
