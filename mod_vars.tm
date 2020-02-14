*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* MOD_VARS.MOD lists the individual variables of all instances of the MODEL
*=============================================================================*
* Questions/Comments:
*  - no need to add SOW-index to variables under MACRO
*-----------------------------------------------------------------------------

* Include declarations for all variables in standard TIMES
$ INCLUDE mod_vars.mod

  SET OBVANN(OBV) / OBJINV, OBJFIX, OBJVAR /;

* Activate demand variables
  RD_NLP(DEM) = 1;

  POSITIVE VARIABLES

*-----------------------------------------------------------------------------*
* MACRO Interface Variables
* - Annual Cost Components: investment, fixed, variable costs
* - Annual Demands
*-----------------------------------------------------------------------------*
  VAR_ANNCST(OBVANN,R,ALLYEAR,CUR)  Annualized costs
  VAR_DEM(R,MILESTONYR,C)           Annual useful demand

*-----------------------------------------------------------------------------*
* MACRO variables
*-----------------------------------------------------------------------------*
  VAR_EC(R,ALLYEAR)       'Annual energy costs in MACRO'
  VAR_C(R,T)              'Annual consumption in MACRO'
  VAR_D(R,T,C)            'Annual useful demand in MACRO'
  VAR_Y(R,T)              'Annual production in MACRO'
  VAR_INV(R,T)            'Annual investments in MACRO'
  VAR_OBJCOST(R,ALLYEAR)  'Annual energy costs in TIMES'
  VAR_K(R,T)              'Total capital'
  VAR_SP(R,T,C)           'Artificial variable for scaling shadow price'
  VAR_XCAP(R,YEAR,P)      'Market penetration bounds - additional capacity'
  VAR_XCAPP(R,YEAR,P,J)   'Market penetration bounds - additional capacity'
  ;


  VARIABLES

*-----------------------------------------------------------------------------*
* MACRO variables
*-----------------------------------------------------------------------------*
  VAR_UTIL                Total utility
  ;
