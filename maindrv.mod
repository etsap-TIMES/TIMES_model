*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* MAINDRV.EXT is the main driver hooking together the various core model code *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
*  Questions/Comments:
*   - BATINCLUDE calls should all be with lower case file names for UNIX
*   - Move the NO_EMTY to the *.RUN (user controlled) for dumpdata control
*     and make YES/NO the expected value in DUMPPUT
*   - [AL]: support for TIMES extension modules added
*-----------------------------------------------------------------------------
*$ONLISTING
* adjust GAMS language defaults to allow mixed mode $ tests and allow latest syntax
*-----------------------------------------------------------------------------
$   ONEMPTY
$   ONMIXED
$   USE999
$   SETLOCAL SRC %1
$   SETENV GDXCOMPRESS 1
$   BATINCLUDE setglobs 1
$   SET MODEL_NAME TIMES
$   IFI %MICRO%%TIMESED%==YES0 $SET TIMESED YES 
$   IFI %MACRO%==YES $SET MACRO 'YES' SET TIMESED 0
$   IF NOT %SYSTEM.FILESYS%==MSNT $SET MODEL_NAME times
$   IFI NOT %TIMESED%==NO
$   IF NOT %TIMESED%==0 $BATINCLUDE readbprice.mod
$   %MX% SETGLOBAL MX
$   IFI %MACRO%==YES  $SET MODEL_NAME 'TIMES_MACRO' SETLOCAL SRC tm
* Stochastic & sensitivity analysis controls
$   IFI %STAGES% == YES $SET STAGES YES
$   IFI %SENSIS% == YES $SET STAGES Yes
$   IFI %SPINES% == YES $SET STAGES YES
$   IF  %STAGES% == YES $SET SENSIS 'NO' SET OBJANN NO
* Stepped TIMES solution controls
$   IF SET TIMESTEP $SETGLOBAL STEPPED +
$   SET R_T 'R,T' SET TX 'T' SET R_V_T 'R,V,T' SET RTPX ''
$   IF SET STEPPED $SET R_T 'R,SUBT(T)' SET TX 'SUBT(T)' SET R_V_T 'R,V,SUBT(T)'
$   IF SET FIXBOH
$   IF DEFINED REG_FIXT $SET R_T 'RT_PP(%R_T%)' SET R_V_T 'RVT(%R_V_T%)' SET RTPX X
*-----------------------------------------------------------------------------
* do a check on user data
*-----------------------------------------------------------------------------
$   BATINCLUDE err_stat.mod '$IF NOT ERRORFREE' ABORT '*** ERRORS IN INPUT DATA/COMPILE ***'

*-----------------------------------------------------------------------------
* hook for GAMS-CGI WWW input
*-----------------------------------------------------------------------------
$   IF %GAMS_CGI% == WWW $BATINCLUDE www_in.cgi

*-----------------------------------------------------------------------------
* perform preprocessor tasks
*-----------------------------------------------------------------------------
$   IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod init_ext %EXTEND%
$   BATINCLUDE ppmain.%1 %1
$   IFI %INTEXT_ONLY% ==YES $GOTO SKIPTOEND
$   IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod ppm_ext %EXTEND%
*-----------------------------------------------------------------------------
* dump out the user/system data structures
*-----------------------------------------------------------------------------
$   IF %DEBUG% == YES       execute_unload "DATADUMP.gdx";
*-----------------------------------------------------------------------------
* Set the main controls for stochastic mode
$   IFI %STAGES%==YES $BATINCLUDE stages.stc
$   IF %STAGES%==YES $%SW_TAGS%
$   IF NOT %STAGES%==YES $%SW_NOTAGS%
*-----------------------------------------------------------------------------
* build the coefficients
*-----------------------------------------------------------------------------
$   IFI '%MID_YEAR%'==YES   $SET DISCSHIFT 0.5
$   BATINCLUDE coefmain.%1 %1
$   IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod coef_ext %EXTEND%
*-----------------------------------------------------------------------------
* establish model (use different .ext?)
*-----------------------------------------------------------------------------
$   BATINCLUDE mod_vars.%SRC%
$   IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod mod_vars %EXTEND%
$   BATINCLUDE eqmain.%1 %1
$   IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod equ_ext %EXTEND%
*-----------------------------------------------------------------------------
$   BATINCLUDE mod_equa.%SRC%
$   IFI %MERGE% == YES      $GOTO BNDSET
$   IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod mod_ext %EXTEND%
** End of MODEL statement is removed from mod_equa and added here:
/;

$LABEL BNDSET
*-----------------------------------------------------------------------------
* establish bounds
*-----------------------------------------------------------------------------
$   BATINCLUDE bndmain.%1 %1 0

*-----------------------------------------------------------------------------
* do quality assurance checks
*-----------------------------------------------------------------------------
$   BATINCLUDE pp_qack.%1 %1

*-----------------------------------------------------------------------------
* do an check on compile/execute errors
*-----------------------------------------------------------------------------
$   BATINCLUDE err_stat.%1 '$IF NOT ERRORFREE' ABORT '*** ERRORS IN GAMS COMPILE ***'
$   BATINCLUDE err_stat.%1 ABORT EXECERROR '*** ERRORS IN GAMS EXECUTION ***'
$   BATINCLUDE spoint.%1 1
$   IF NOT %RPOINT%==NO $GOTO REPORT
*-----------------------------------------------------------------------------
* solve the appropriate model & report solver status
*-----------------------------------------------------------------------------
$   SETLOCAL EXT %1
$   IFI %STAGES% == YES      $SETLOCAL EXT stc
$   IF SET STEPPED           $SETLOCAL EXT stp
$   IFI %MERGE% == YES       $SETLOCAL EXT mrg
$   BATINCLUDE solve.%EXT% %1
$   IF %SOLVE_NOW% == NO     $GOTO SKIPTOEND

*-----------------------------------------------------------------------------
* produce the reports
*-----------------------------------------------------------------------------
$   LABEL REPORT
$   BATINCLUDE rptmain.%1 %1 NO_EMTY
$   IF NOT %TIMESED%==0
$   IF NOT %TIMESED%==YES $BATINCLUDE wrtbprice.mod
$   IF SET SPOINT $BATINCLUDE spoint.%1 0

*-----------------------------------------------------------------------------
* do an check on compile/execute errors from reports
*-----------------------------------------------------------------------------
$   BATINCLUDE err_stat.mod '$IF NOT ERRORFREE' ABORT '*** ERRORS IN GAMS COMPILE ***'
$   BATINCLUDE err_stat.mod ABORT EXECERROR '*** ERRORS IN GAMS EXECUTION ***'
*-----------------------------------------------------------------------------

$LABEL SKIPTOEND
*$OFFLISTING
