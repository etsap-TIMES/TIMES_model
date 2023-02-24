*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* RPTMAIN.MOD is the main driver for the report writer                        *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
*GaG Questions/Comments:
*  -  COM, PRC descriptions need to be taken from the COM_GMAP/PRC_MAP Sets
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* dump solution if requested
$IF NOT %STAGES%  ==  YES
$IF %DUMPSOL%  == 'YES'  $BATINCLUDE dumpsol.%1 %1
*-----------------------------------------------------------------------------
$IFI %VDA% == YES        $SETLOCAL SOLVEDA 1
$IFI %SENSIS%  == YES    $GOTO FINISH
$IF NOT '%SOLVEDA%'==NO  $BATINCLUDE solsetv.v3
$IFI %MACRO%   == YES    $GOTO OTHER_REP
$IF DEFINED VAR_NTX      $GOTO FINISH
$IF  %STAGES%  == YES    $GOTO OTHER_REP
*-----------------------------------------------------------------------------
* produce standard VEDA report
$IFI %SOLVEDA% == 'YES'  $BATINCLUDE rptmain.rpt
$IFI %SOLVEDA% == '1'    $BATINCLUDE rptlite.rpt S WW, "'1',"

$LABEL OTHER_REP
$IF  %MACRO%  == YES     $BATINCLUDE rptmain.tm

* If running stochastics, streamline reports
$IF  %STAGES% == YES     $BATINCLUDE rptmain.stc SOW %SWS% "'1'" ",'1')"

* output ETL info
$IFI %ETL%     == 'YES'  $BATINCLUDE atlearn.etl

* produce damage report
$IF DEFINED DAM_COST     $BATINCLUDE rpt_dam.%1
*-----------------------------------------------------------------------------
$LABEL FINISH

* Extensions
$IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod rpt_ext %EXTEND%

* Back-end software dependent reporting routines
* produce ANSWER-TIMES report
$IFI %SOLANS% == YES     $BATINCLUDE solputta.ans S WW, SOW,
$IFI %VDA%==YES          $BATINCLUDE solsetv.v3 FINISHUP