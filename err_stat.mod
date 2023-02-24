*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* ERR_STAT.MOD checks/displays GAMS/Solver Errors
*   %1 - Condition to be checked or 'SOLVE'  used
*   %2 - Action or Condition to be checked
*   %3 - Error Message if Not SOLVE
*=============================================================================*
*GaG Questions/Comments:
*  - for %system.filesys% == UNIX file /dev/tty
*  - does not affect stopping BAT
*------------------------------------------------------------------------------
*$ONLISTING
$ IFI NOT %SHELL%==ANSWER $SET TMP END_GAMS
$ IFI %SHELL%==ANSWER     $SET TMP END_GAMS.STA
$ IF "%1" == SOLVE        $GOTO SOLVE
$ IF DEFINED SOLVESTAT    $GOTO ACTION
*------------------------------------------------------------------------------
SET SOLVESTAT(J) /
  1 "Optimal"
  2 "Locally optimal"
  3 "Unbounded"
  4 "Infeasible"
  5 "Locally infeasible"
  6 "Intermediate infeasible"
  7 "Intermediate nonoptimal"
  8 "Integer solution"
  9 "Intermediate non-integer"
 10 "Integer infeasible"
 12 "Error unknown"
 13 "Error no solution"
/;
FILE SCREEN / '' /;
FILE END_GAMS / %TMP% /;
*------------------------------------------------------------------------------
$LABEL ACTION

$ IF %ERR_ABORT%==NO  $GOTO DONE
%4;
* compile or GAMS execute error
$IF NOT ERRORFREE $ECHO %3%5 > %TMP%
 IF(execerror,PUT END_GAMS "%3%5"; PUTCLOSE);
%1 $%2  "%3"
$GOTO DONE

$LABEL SOLVE
 Z = MIN(14,%MODEL_NAME%.MODELSTAT)-1; IF(Z > 12, Z=11);
 IF(Z>=0,PUT SCREEN /"--- TIMES Solve status: ";
   LOOP(SAMEAS(J,'1'), PUT SOLVESTAT.TE(J+Z));
   PUTCLOSE;
   PUT END_GAMS "Solve status: ";
   LOOP(SAMEAS(J,'1'), PUT SOLVESTAT.TE(J+Z) /);
   PUTCLOSE;
   Z = ABS(ABS(2*%MODEL_NAME%.MODELSTAT-9)-6));
 IF(Z>1.5 OR %MODEL_NAME%.MODELSTAT=7,execerror=1);
$IF %ERR_ABORT%==NO  Z=0;
* [UR] allow solution "optimal with unscaled infeasibilities"
* -- allow even "intermediate non-optimal" for investigation
*ABORT$((%MODEL_NAME%.MODELSTAT GT 1) OR (%MODEL_NAME%.SOLVESTAT GT 1)) '*** ERRORS IN OPTIMIZATION ***'
 ABORT$(Z>1.5) '%2';
 IF(execerror,execerror=0);
$LABEL DONE
*$OFFLISTING
;
