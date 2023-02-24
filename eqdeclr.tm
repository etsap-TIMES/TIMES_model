*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQDECLR.MOD declarations for actual equations                               *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
*  EQUATIONS
*-----------------------------------------------------------------------------
* Objective Function & Components
*-----------------------------------------------------------------------------
* Overall OBJ by regional objs (which are built from rest)
   EQ_OBJ(R,ALLYEAR)  'Overall Objective Function'

* Costs of elastic demands
   EQ_OBJELS(REG,BD,CUR)

* Fixed Costs
   EQ_ANNFIX(REG,ALLYEAR,CUR)

* Investment component
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

*-----------------------------------------------------------------------------
* MACRO MLF calibration equations
*-----------------------------------------------------------------------------
* Calibration
*  EQ_UTIL              'Utility function'
   EQ_PROD_Y(R,T)       'Production unction'
   EQ_AKL(R,T)          'Aggregate Kapital Labor'
   EQ_LABOR(R,T)        'Labor dummy definition'
   EQ_KNCAP(R,T)        'Capital dummy definition'
*  EQ_MCAP(R,T)         'Capital dynamics equation'
*  EQ_TMC(R,T)          'Terminal condition for investment in last period'
*  EQ_IVECBND(R,T)      'Bound on the sum of investment and energy costs'
*  EQ_DD(R,T,C)         'Demand decoupling equation'
*  EQ_ESCOST(R,T)       'Energy System costs'
   EQ_TRDBAL(T)         'Trade balance'
   EQ_DNLCES(R,T)       'Demand CES function'
*-----------------------------------------------------------------------------
* Full MLF model formulation
*-----------------------------------------------------------------------------
   EQ_UTILP             'Utility function'
*  EQ_CONSO(R,T)        'Consumption equation'
   EQ_CONDA(R,T)        'Consumption disaggregation'
   EQ_LOGBD(R,T)        'Linearized log bound'
   EQ_MACSH(R,T,CG,CG)  'Macro shares in aggergate'
   EQ_MACAG(R,T,CG)     'Macro aggergations'
   EQ_MACES(R,T,CG,CG)  'Macro CES functions'
*  EQ_LABOR(R,T)        'Labor dummy definition'
*  EQ_KNCAP(R,T)        'Capital dummy definition'
*  EQ_MCAP(R,T)         'Capital dynamics equation'
*  EQ_TMC(R,T)          'Terminal condition for investment in last period'
*  EQ_IVECBND(R,T)      'Bound on the sum of investment and energy costs'
*  EQ_DD(R,T,C)         'Demand decoupling equation'
   EQ_DEMSH(R,T,C)      'Demand shares in aggergate'
   EQ_DEMAG(R,T)        'Demand aggregation'
   EQ_DEMCES(R,T,C)     'Demand CES function'
   EQ_ENSCST(R,T)       'Energy System costs'
*  EQ_TRDBAL(T,TRD)     'Trade balance'
