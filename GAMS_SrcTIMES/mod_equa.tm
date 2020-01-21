*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* MOD_EQUA.MOD lists all the equations for each of the MODEL instances        *
*   a MODEL / <list of equaions> / block will appear for each model supported *
*=============================================================================*
*GaG Questions/Comments:
*   - need a mechanism to enable limiting of CUR (c$)
*   - any non-binding (=N=) accounting equations, or do it all with reports?
*-----------------------------------------------------------------------------

  MODEL TIMES_MACRO / 

$IFI %MERGE%==YES    ALL /;
$IFI %MERGE%==YES    $EXIT
*-----------------------------------------------------------------------------
* Objective Function & Components
*-----------------------------------------------------------------------------
* Overall OBJ linear combination of the regional objs (which are built from rest)
    EQ_OBJ

* Resource depletion costs
*    EQ_OBJDPL

* Costs of elastic demands - not in MACRO
*$IF %TIMESED% == 'YES'    EQ_OBJELS

* Fixed Costs
    EQ_ANNFIX

* investment component
    EQ_ANNINV

* Variable operating costs
    EQ_ANNVAR

*-----------------------------------------------------------------------------
* Core Equations
*-----------------------------------------------------------------------------
$ SET OBJANN NO
$ BATINCLUDE mod_equa.mod CORE

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

* [AL] Commented out the end of MODEL statement - now in maindrv.mod
*/;

