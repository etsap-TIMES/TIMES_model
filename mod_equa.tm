*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* MOD_EQUA.MOD lists all the equations for each of the MODEL instances        *
*   a MODEL / <list of equaions> / block will appear for each model supported *
*=============================================================================*

  MODEL TIMES_MACRO /

$IFI %MERGE%==YES    ALL /;
$IFI %MERGE%==YES    $EXIT
*-----------------------------------------------------------------------------
* Objective Function & Components
*-----------------------------------------------------------------------------
* Overall OBJ linear combination of the regional objs (which are built from rest)
    EQ_OBJ

* Fixed Costs
    EQ_ANNFIX

* Investment component
    EQ_ANNINV

* Variable operating costs (including substitution loss in MLF)
    EQ_ANNVAR

*-----------------------------------------------------------------------------
* Core Equations
*-----------------------------------------------------------------------------
$ SET OBJANN NO
$ BATINCLUDE mod_equa.mod CORE
$ IF %MACRO%==Yes $GOTO MLF 
*---------------------------------------------------------------------
* MACRO equations
*---------------------------------------------------------------------
   EQ_UTIL
   EQ_CONSO
   EQ_DD
   EQ_MCAP
   EQ_TMC
   EQ_IVECBND
   EQ_ESCOST
   EQ_MPEN
   EQ_XCAPDB
$  EXIT
*---------------------------------------------------------------------
$ LABEL MLF
$ IF %NONLP%==NL $GOTO NONLP
*---------------------------------------------------------------------
* MACRO MLF equations
*---------------------------------------------------------------------
   EQ_UTILP
   EQ_CONSO
   EQ_CONDA
   EQ_LOGBD
   EQ_MACSH
   EQ_MACAG
   EQ_MACES
   EQ_KNCAP
   EQ_MCAP
   EQ_TMC
   EQ_IVECBND
   EQ_DD
   EQ_DEMSH
   EQ_DEMAG
   EQ_DEMCES
   EQ_ENSCST
   EQ_TRDBAL
*  EQ_MPEN
*  EQ_XCAPDB
$  EXIT
*---------------------------------------------------------------------
$ LABEL NONLP
*---------------------------------------------------------------------
* MACRO MLF NLP benchmark equations
*---------------------------------------------------------------------
   EQ_UTIL
   EQ_PROD_Y
   EQ_AKL
   EQ_LABOR
   EQ_KNCAP
   EQ_MCAP
   EQ_TMC
   EQ_DD
   EQ_IVECBND
   EQ_DNLCES
   EQ_ENSCST
   EQ_TRDBAL
* End of MODEL statement now in maindrv.mod
