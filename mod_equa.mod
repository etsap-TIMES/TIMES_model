*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* MOD_EQUA.MOD lists all the equations for each of the MODEL instances        *
*  a MODEL / <list of equations> / block will appear for each model supported *
*=============================================================================*
*GaG Questions/Comments:
*   - any non-binding (=N=) accounting equations, or do it all with reports?
*   - Investment component = investment cost + tax/sub + decom, not split?
*   - Fixed component = O&M cost + tax/sub, not split?
*-----------------------------------------------------------------------------
$IF %1==CORE $GOTO CORE

  MODEL TIMES /
*-----------------------------------------------------------------------------
* Objective Function & Components
*-----------------------------------------------------------------------------
* Overall OBJ linear combination of the regional objs (which are built from rest)
    EQ_OBJ

$IFI %STAGES%==YES
    EQ_EXPOBJ, EQ_UPDEV, %EQ%_SOBJ, %EQ%_ROBJ

* Resource depletion costs
*   EQ_OBJDPL

* Costs of elastic demands
$IF %TIMESED% == YES   %EQ%_OBJELS
$IFI %OBJANN% == YES   $GOTO CORE

* Fixed Costs including tax/subsidy
    %EQ%_OBJFIX

* investment component including tax/subsidy
    %EQ%_OBJINV

* Salvage
    %EQ%_OBJSALV

* Variable operating costs
    %EQ%_OBJVAR

$LABEL CORE
*-----------------------------------------------------------------------------
* MACRO calibration
*-----------------------------------------------------------------------------
$IFI %OBJANN%==YES EQ_OBJANN, EQ_ANNFIX, EQ_ANNINV, EQ_ANNVAR

*-----------------------------------------------------------------------------
* Core Equations
*-----------------------------------------------------------------------------
* Relationship between process activity & individual commodity flows
    %EQ%_ACTFLO

* Bound of vintage process activity or TS-level above PRC_TS
    %EQ%G_ACTBND
    %EQ%E_ACTBND
    %EQ%L_ACTBND

* Bound on commodities
    %EQ%G_BNDNET
    %EQ%E_BNDNET
    %EQ%L_BNDNET
    %EQ%G_BNDPRD
    %EQ%E_BNDPRD
    %EQ%L_BNDPRD

* Utilization of capacity, or the relationship between process capacity and activity
    %EQ%L_CAPACT
    %EQ%E_CAPACT
    %EQ%G_CAPACT
$IF DEFINED PRC_SIMV EQL_CAPVAC, EQE_CAPVAC, EQG_CAPVAC

* Basic commodity balance equations (by type) ensuring that production >=/= consumption
    %EQ%G_COMBAL
    %EQ%E_COMBAL
    %EQ%E_COMPRD
$IF %TIMESED%==YES  %EQ%L_COMCES

* Transfer of installed capacity between periods
    %EQ%E_CPT
    %EQ%G_CPT
    %EQ%L_CPT

* Bound on the flow variable
    %EQ%G_FLOBND
    %EQ%E_FLOBND
    %EQ%L_FLOBND

* Bound on the fraction of a flow within a time slice
    %EQ%G_FLOFR
    %EQ%E_FLOFR
    %EQ%L_FLOFR

* Market share equation allocating commodity percentages of a group
    %EQ%G_INSHR
    %EQ%E_INSHR
    %EQ%L_INSHR

* Inter-regional exchange balance
    %EQ%_IRE

* Bound on inter-regional exchange of a commodity
    %EQ%G_IREBND
    %EQ%E_IREBND
    %EQ%L_IREBND

* Bound on total exchange of a commodity to/from all regions
    %EQ%G_XBND
    %EQ%E_XBND
    %EQ%L_XBND

* Product share equation allocating commodity percentages of a group
    %EQ%G_OUTSHR
    %EQ%E_OUTSHR
    %EQ%L_OUTSHR

* Market share equation for process in total commodity production
    %EQ%G_FLOMRK
    %EQ%E_FLOMRK
    %EQ%L_FLOMRK

* Peaking Equation
    %EQ%_PEAK

* Commodity-to-commodity transformation
    %EQ%_PTRANS

* Cumulative commodity NET/PRD and flow constraint
    %EQ%_CUMNET
    %EQ%_CUMPRD
    %EQ%_CUMFLO

* Time-slice storage
    %EQ%_STGTSS
    %EQ%_STSBAL
    EQ_STSLEV

* Bounds on in/output flows of storage process
    %EQ%G_STGIN
    %EQ%E_STGIN
    %EQ%L_STGIN
    %EQ%G_STGOUT
    %EQ%E_STGOUT
    %EQ%L_STGOUT

* Inter-period storage
    %EQ%_STGIPS
    %EQ%_STGAUX

* User-constraint

    %EQ%E_UC
    %EQ%E_UCR
    %EQ%E_UCT
    %EQ%E_UCRS
    %EQ%E_UCRT
    %EQ%E_UCTS
    %EQ%E_UCRTS
    %EQ%E_UCSU
    %EQ%E_UCRSU
    %EQ%E_UCSUS
    %EQ%E_UCRSUS

$IF '%VAR_UC%' == YES $GOTO UCDONE

    EQG_UC
    EQG_UCR
    EQG_UCT
    EQG_UCRS
    EQG_UCRT
    EQG_UCTS
    EQG_UCRTS
    EQG_UCSU
    EQG_UCRSU
    EQG_UCSUS
    EQG_UCRSUS

    EQL_UC
    EQL_UCR
    EQL_UCT
    EQL_UCRS
    EQL_UCRT
    EQL_UCTS
    EQL_UCRTS
    EQL_UCSU
    EQL_UCRSU
    EQL_UCSUS
    EQL_UCRSUS

$LABEL UCDONE

* Bounds on costs by region, category and currency
    %EQ%_BNDCST

*---------------------------------------------------------------------
*GG* V07_2 Refinery blending
*---------------------------------------------------------------------
    EQL_BLND
    EQG_BLND
    EQE_BLND
    EQN_BLND

*-----------------------------------------------------------------------------
* damages
*-----------------------------------------------------------------------------
$IF DEFINED DAM_COST
$IF NOT %DAMAGE%==NO  %EQ%_DAMAGE, %EQ%_OBJDAM

$IF DEFINED VNRET     %EQ%_DSCRET, %EQ%_CUMRET, %EQ%L_SCAP, %EQ%L_REFIT
$IFI %SPINES%==YES    %EQ%_OBW1

* [AL] Commented out the end of MODEL statement - now in maindrvx.mod
*/;
