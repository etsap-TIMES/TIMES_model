*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================
* INIT DECLARATIONS FOR THE MACRO EXTENSION
*=============================================================================
$ SETGLOBAL SPOINT 3
* As in original IER implementation, disable warm start in MACRO
* This may be overridden in the RUN file after the INITMTY call
  OPTION BRATIO=1;
*--- Input parameters ---
PARAMETER TM_ARBM /1000/;
PARAMETER TM_SCALE_UTIL                'Scaling factor utility function'                            /0/;
PARAMETER TM_SCALE_NRG                 'Scaling factor demand units'                                /0/;
PARAMETER TM_SCALE_CST                 'Scaling factor cost units'                                  /0/;
PARAMETER TM_DEPR(R)                   'Depreciation rate'                                          //;
PARAMETER TM_DMTOL(R)                  'Demand lower bound factor'                                  //;
PARAMETER TM_ESUB(R)                   'Elasticity of substitution'                                 //;
PARAMETER TM_GDP0(R)                   'GDP in the first period'                                    //;
PARAMETER TM_GR(R,ALLYEAR)             'MACRO Projected Annual GDP Growth'                          //;
PARAMETER TM_IVETOL(R)                 'Investment and enery tolerance'                             //;
PARAMETER TM_KGDP(R)                   'Initial capital to GDP ratio'                               //;
PARAMETER TM_KPVS(R)                   'Capital value share'                                        //;
PARAMETER TM_QFAC(R)                   'Switch for market penetration penalty function'             //;
PARAMETER TM_EXPBND(R,ALLYEAR,P)       'Market Penetration Cutoff for Applying Cost Penalty'        //;
PARAMETER TM_EXPF(R,ALLYEAR)           'Annual percent expansion factor'                            //;
*--- Calibration parameters ---
PARAMETER TM_EC0(R)                    'Energy costs in the first period';
PARAMETER TM_GROWV(R,ALLYEAR)          'Labour growth rate'                                         //;
PARAMETER TM_DDATPREF(R,C)             'Reference marginal price for demand'                        //;
PARAMETER TM_DDF(R,ALLYEAR,C)          'Demand decoupling factor'                                   //;
*--- Internal parameters ---
PARAMETER TM_PWT(ALLYEAR)              'Period weight';
PARAMETER TM_AMP(R,ALLYEAR)            'Amortisation of past investments (from CSA only)'           //;
PARAMETER TM_AKL(R)                    'Production function constant'                               //;
PARAMETER TM_ASRV(R)                   'Annual capital survival factor'                             //;
PARAMETER TM_RHO(R)                    'Substitution constant'                                      //;
PARAMETER TM_B(R,C)                    'Demand coefficient'                                         //;
PARAMETER TM_D0(R,C)                   'Demand in first period'                                     //;
PARAMETER TM_L(R,YEAR)                 'Annual labor index'                                         //;
PARAMETER TM_TSRV(R,YEAR)              'Capital survival factor between two periods'                //;
PARAMETER TM_AEEIV(R,YEAR,C)           'Annual Autonomous energy efficiency and demand decoupling factor'     //;
PARAMETER TM_AEEIFAC(R,YEAR,C)         'Periodwise Autonomous energy efficiency and demand decoupling factor' //;
PARAMETER TM_ADDER(R,T,C)              'Demand decoupling adder'                                    //;
PARAMETER TM_C0(R)                     'Consume in the first period'                                //;
PARAMETER TM_K0(R)                     'Capital stock in first period'                              //;
PARAMETER TM_IV0(R)                    'Investment in the first period'                             //;
PARAMETER TM_Y0(R)                     'Annual production in first period'                          //;
PARAMETER TM_DFACT(R,YEAR)             'Utility discount factor'                                    //;
PARAMETER TM_DFACTCURR(R,YEAR)         'Intermediate parameter for the utility discount factor'     //;
PARAMETER TM_UDF(R,ALLYEAR)            'Utility discount factor'                                    //;
PARAMETER TM_CAP(R,P)                  'Base year capacity values for expanding technologies'       //;
PARAMETER TM_CAPTB(R,P)                'Cumulative quadratic capacity penalty level'                //;
PARAMETER TM_CSTINV(R,ALLYEAR,P)       'Annualized investment costs'                                //;
PARAMETER TM_YCHECK(R)                 'Check'                                                      //;
