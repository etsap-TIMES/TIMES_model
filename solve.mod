*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* SOLVE.MOD solver and solve controls
*=============================================================================*
*GaG Questions/Comments:
*-----------------------------------------------------------------------------
*$ONLISTING
* Release some memory
$  BATINCLUDE pp_clean.mod
*  get the optimizer directive file
%MODEL_NAME%.OPTFILE = OPTFILEID;
%MODEL_NAME%.PRIOROPT=(OPTFILEID=2);
* set the model solver status
%MODEL_NAME%.MODELSTAT = 0;

* MACRO: Loading solution from GDX file replaced by activating the SPOINT utility

$  IF '%SOLVE_NOW%'==NO  $GOTO NO_SOLVE
* solve TIMES with appropriate METHOD
$  IF NOT SET MIXLP $SETLOCAL MIXLP ''
$  IF NOT SET NONLP $SETLOCAL NONLP ''
* if ETL or DSC with binary variables use MIP
$  IF    '%DAMAGE%'==NLP    $SETLOCAL NONLP NL
$  IF    '%MICRO%'==YES     $SETLOCAL NONLP NL
$  IF    '%ETL%' == YES     $SETLOCAL MIXLP MI
$  IF    '%SOLMIP%'==YES    $SETLOCAL MIXLP MI
$  SETLOCAL METHOD '%MIXLP%%NONLP%P'
$  IF     %METHOD% == P     $SETLOCAL METHOD LP
$  IF     %MACRO% == YES    SOLVE %MODEL_NAME% MAXIMIZING VAR_UTIL USING NLP;
$  IF     %MACRO% == YES    $GOTO CHECK
* solve TIMES as an LP/MIP
SOLVE %MODEL_NAME% MINIMIZING objZ USING %METHOD%;

$LABEL CHECK
* do an check on solution errors
$  BATINCLUDE err_stat.mod SOLVE '*** ERRORS DURING SOLUTION ***'

* hook for GAMS-CGI WWW output
$  IF %GAMS_CGI% == WWW  $BATINCLUDE www_out.cgi

$LABEL NO_SOLVE
*$OFFLISTING
