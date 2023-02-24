*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* MAIN_EXT.mod is the extension driver
*=============================================================================*
* %1 is the name of the extension module to be called, e.g. 'rpt_ext' for reporting extensions
* Different extensions are identified by file extensions given in %2, %3, %4....%9
* Example: $BATINCLUDE rpt_ext ETL RP1 RP2
*          This would include the reporting extensions for ETL and two custom 
*          reporting routines rpt_ext.RP1 and rpt_ext.RP2
*-----------------------------------------------------------------------------
$SETNAMES %SYSTEM.INCPARENT% . TMP .
$SETLOCAL WHCALL %1
$LABEL MORE
$SHIFT
$IF %1. == . $GOTO DONE
$IF NOT SETLOCAL %1
$IF EXIST %WHCALL%.%1 $BATINCLUDE %WHCALL%.%1 %1 %TMP%
$SETLOCAL %1 YES
$GOTO MORE
$LABEL DONE
