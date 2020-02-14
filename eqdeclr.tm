*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* EQDECLR.MOD declarations for actual equations                               *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
*GaG Questions/Comments:
*   - declare all equations so that re-start changing models will work
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*  EQUATIONS
*-----------------------------------------------------------------------------
* Objective Function & Components
*-----------------------------------------------------------------------------
* Overall OBJ by regional objs (which are built from rest)
   EQ_OBJ(R,ALLYEAR)  'Overall Objective Function'

* Costs of elastic demands
   EQ_OBJELS(REG,CUR)

* Fixed Costs
   EQ_ANNFIX(REG,ALLYEAR,CUR)

* investment component
   EQ_ANNINV(REG,ALLYEAR,CUR)

* Variable operating costs
   EQ_ANNVAR(REG,ALLYEAR,CUR)

*-----------------------------------------------------------------------------
* MACRO equations
*-----------------------------------------------------------------------------
   EQ_UTIL              'Utility function'
   EQ_CONSO(R,T)        'Consumption equation'
   EQ_DD(R,T,C)         'Demand decoupling equation'
   EQ_MCAP(R,T)         'Capital dynamics equation'
   EQ_TMC(R,T)          'Terminal condition for investment in last period'
   EQ_IVECBND(R,T)      'Bound on the sum of investment and energy costs'
   EQ_ESCOST(R,T)       'Energy System costs'
   EQ_MPEN(R,T,P)       'Definition of variables for cost penalty function'
   EQ_XCAPDB(R,T,P)     'Quadratic approximation of market penetration cost penalty function'

