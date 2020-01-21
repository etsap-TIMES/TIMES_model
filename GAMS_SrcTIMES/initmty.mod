*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* INITMTY.MOD has all the EMPTY declarations for system & user data           *
*  %1..%6 - File extensions of code extensions to be included                 *
*=============================================================================*
* All the EMPTY declarations for user data                                    *
*=============================================================================*
*GaG Questions/Comments:
*   - all but LOCAL (in single BATINCLUDE and its immediate lower routines)
*   - consider PRC_MAP(PRC_GRP,PRC_SUBGRP,PRC) where PRC_SUBGRP = PRC_RSOURC + any user-provided sub-groupings
*   - SOW/COM/PRC/CUR master sets (merged) == entire list, that is not REG
*   - lists (eg, DEM_SECT) for _MAP sets not REG (but individual mappings are)
*   - HAVE THE USER *.SET/DD files OMIT the declarations to ease maintenance changes
*-----------------------------------------------------------------------------
* Version control
$IF NOT FUNTYPE rpower $ABORT TIMES Version 4.0 and above Requires GAMS 22.0 or above!
$IF NOT FUNTYPE gamsversion $GOTO DECL
$IF gamsversion 149 $SETGLOBAL G2X6 Yes
$IF gamsversion 230 $SETGLOBAL OBMAC YES
$IF gamsversion 236 $SETGLOBAL G2X6 YES
$LABEL DECL
$ONEMPTY
*-----------------------------------------------------------------------------
* SET SECTION
*-----------------------------------------------------------------------------
* Note: the *-out user SETs are declared in INITSYS.MOD

* commodities
*  SET COM_GRP                       'All CGs and each individal commodity';
*  SET COM(COM_GRP)                  'All Commodities'                       //;
  SET COM_DESC(REG,COM)              'Region-based commodity descriptions'   //;
*  SET COM_TYPE(COM_GRP)             'Primary grouping of commodities'       //;
  SET COM_GMAP(REG,COM_GRP,COM)      'User groups of individual commodities' //;
  SET COM_LIM(REG,COM,LIM)           'List of equation type for balance'     //;
  SET COM_OFF(REG,COM,*,*)           'Periods for which a commodity is unavailable' //;
  SET COM_TMAP(REG,COM_TYPE,COM)     'Primary grouping of commodities'       //;
  SET COM_TS(REG,COM,ALL_TS)         'List of commodity timeslices'          //;
  SET COM_TSL(REG,COM,TSLVL)         'Level at which a commodity tracked'    //;
  SET COM_UNIT(REG,COM,UNITS_COM)    'Units associated with each commodity'  //;

* currency
*  SET CUR                           'Currencies (c$)'              //;
  SET CUR_MAP(REG,CUR_GRP,CUR)       'Grouping of the currenies'    //;

* demands / emissions / financials
  SET DEM_SMAP(REG,DEM_SECT,COM)     'Grouping of DEMs (commodities) to their sector' //;
  SET ENV_MAP(REG,ENV_GRP,COM)       'Grouping of ENVs (commodities) to their emissions group' //;
  SET FIN_MAP(REG,FIN_GRP,COM)       'Grouping of FINs (commodities) to their financial group' //;

* materials
  SET MAT_GMAP(REG,MAT_GRP,COM)      'Grouping of materials'             //;
  SET MAT_TMAP(REG,MAT_TYPE,COM)     'Material by type'                  //;
  SET MAT_VOL(REG,COM)               'Material accounted for by volume'  //;
  SET MAT_WT(REG,COM)                'Material accounted for by weight'  //;

* energy
  SET NRG_FMAP(REG,NRG_FORM,COM)     'Grouping of NRG by Solid/Liquid/Gas' //;
  SET NRG_GMAP(REG,NRG_GRID,COM)     'Association with energy carriers to grids' //;
  SET NRG_TMAP(REG,NRG_TYPE,COM)     'Grouping of energy carriers by type' //;

* process
*  SET PRC                             'List of all processes'           //;
  SET PRC_AOFF(REG,PRC,*,*)            'Periods for which activity is unavailable' //;
  SET PRC_ACTUNT(REG,PRC,CG,UNITS_ACT) 'Primary commodity (or group) & activity unit' //;
  SET PRC_CAPUNT(REG,PRC,CG,UNITS_CAP) 'Unit of capacity'                //;
  SET PRC_CG(R,PRC,COM_GRP)            'Commodity groups for a process'  //;
  SET PRC_DESC(R,P)                    'Process descriptions by region'  //;
  SET PRC_FOFF(REG,PRC,COM,ALL_TS,*,*) 'Periods/timeslices for which flow is not possible' //;
  SET PRC_MAP(REG,PRC_GRP,PRC)         'Grouping of processes to nature' //;
  SET PRC_NOFF(REG,PRC,*,*)            'Periods for which new capacity can NOT be built' //;
  SET PRC_RMAP(REG,PRC_RSOURC,PRC)     'Grouping of XTRACT processes'    //;
  SET PRC_SPG(REG,PRC,COM_GRP)         'Shadow Primary Group'            //;
  SET PRC_TS(ALL_REG,PRC,ALL_TS)       'Timeslices for a process'        //;
  SET PRC_TSL(REG,PRC,TSLVL)           'Timeslice level for a process'   //;
  SET PRC_VINT(REG,PRC)                'Process is to be vintaged'       //;
  SET PRC_DSCNCAP(R,P)                 'Processes with discrete capacity additions';
  SET PRC_RCAP(REG,PRC)                'Process with early retirement';
  SET PRC_SIMV(REG,PRC)                'Process is to be vintage-simulated';

* region
*  SET REG(ALL_REG)                   'List of Regions'                  //;
  SET REG_GRP(*)                      'List of regional groups'          //;
  SET REG_RMAP(REG_GRP,ALL_REG)       'Grouping of regions in/out of area of study' //;

* time
*  SET TS(ALL_TS)                     'Time slices of the year               //;
      ALIAS(ALL_TS,TS,S,SL,S2);
  SET TS_OFF(REG,TS,BOHYEAR,EOHYEAR)  'Timeslices turned off';
  SET TS_GROUP(ALL_REG,TSLVL,ALL_TS)  'Timeslice Level assignment'           //;
  SET TS_MAP(ALL_REG,ALL_TS,ALL_TS)   'Timeslice hierarchy tree: node+below' //;
  SET MILESTONYR(ALLYEAR)             'Projection years for which model to be run' //;
      ALIAS(MILESTONYR,T,TT);
  SET DATAYEAR(ALLYEAR)               'Years for which user data is provided' //;
  SET PASTYEAR(ALLYEAR)               'The years before 1st MILESTONYR for which PASTI needs to be handled' //;
      ALIAS(PASTYEAR,PYR);

* topology
  SET TOP(REG,PRC,COM,IO)                  'Topology for all process'        //;
  SET TOP_IRE(ALL_REG,COM,ALL_REG,COM,PRC) 'Trade within area of study'      //;

* peaking
  SET COM_PEAK(REG,COM_GRP)           'Peaking required flag'                //;
  SET COM_PKTS(REG,COM_GRP,TS)        'Peaking time-slices'                  //;
  SET PRC_PKNO(ALL_REG,PRC)           'Processes which cannot be involved in peaking' //;
  SET PRC_PKAF(ALL_REG,PRC)           'Flag for default value of NCAP_PKCNT' //;

* storage
  SET PRC_NSTTS(REG,PRC,ALL_TS)       'Night storage process and time-slice for storaging' //;
  SET PRC_STGTSS(REG,PRC,COM)         'Storage process and stored commodity for time-slice storage' //;
  SET PRC_STGIPS(REG,PRC,COM)         'Storage process and stored commodity for inter-period storage' //;

* user constraints
  SET UC_N(*)                         'Names of all manual constraints'             //;
  SET UC_T_SUCC(ALL_R,UC_N,ALLYEAR)   'Specification of periods, if UC_DYN=SUCC'    //;
  SET UC_T_SUM(ALL_R,UC_N,ALLYEAR)    'Specification of periods, if UC_DYN=SEVERAL' //;
  SET UC_T_EACH(ALL_R,UC_N,ALLYEAR)   'Specification of periods, if UC_DYN=EACH'    //;
  SET UC_R_SUM(ALL_R,UC_N)            'Specification of regions, if UC_REG=SUM'     //;
  SET UC_R_EACH(ALL_R,UC_N)           'Specification of regions, if UC_REG=EACH'    //;
  SET UC_TS_SUM(ALL_R,UC_N,ALL_TS)    'Specification of time-slices, if UC_TS=SUM'  //;
  SET UC_TS_EACH(ALL_R,UC_N,ALL_TS)   'Specification of time-slices, if UC_TS=EACH' //;
  SET UC_ATTR(ALL_R,UC_N,SIDE,UC_GRPTYPE,UC_NAME) 'Mapping of parameter names to groups' //;
  SET UC_TSL(ALL_R,UC_N,SIDE,TSLVL)   'UC timeslice level' //;
  ALIAS(UC_N,UCN);

* miscellaneous
*  SET SOW                       'Stochastic State-of-the-World'         //;
  SET SW_T(ALLYEAR,ALLSOW)       'Stochastic state indexes by period'    //;
  SET G_UAMAT(U)                 'Unit for activity of material process' //;
  SET G_UANRG(U)                 'Unit for activity of energy process'   //;
  SET G_UCMAT(U)                 'Unit for capacity of material process' //;
  SET G_UCNRG(U)                 'Unit for capacity of energy process'   //;
  SET G_RCUR(REG,CUR)            'Main currency unit by region'          //;

*-----------------------------------------------------------------------------
* PARAMETERS SECTION
*-----------------------------------------------------------------------------

* Activity
  PARAMETER ACT_BND(REG,ALLYEAR,PRC,TS,BD)      'Bound on activity of a process' //;
  PARAMETER ACT_COST(REG,ALLYEAR,PRC,CUR)       'Variable costs associated with activity of a process' //;
  PARAMETER ACT_CSTUP(R,ALLYEAR,P,TSLVL,CUR)    'Variable costs associated with startup of a process' //;
  PARAMETER ACT_CSTSD(R,ALLYEAR,P,UPT,BD,CUR)   'Start-up (BD=UP) and shutdown costs (BD=LO) per unit of started-up capacity, by start-up type' //;
  PARAMETER ACT_CSTRMP(R,ALLYEAR,P,L,CUR)       'Ramp-up (L=UP) or ramp-down (L=LO) cost per unit of load change' //;
  PARAMETER ACT_TIME(R,ALLYEAR,P,L)             'Minimum online/offline hours' //;
  PARAMETER ACT_CUM(REG,PRC,ITEM,ITEM,LIM)      'Bound on cumulative activity' //;

* New Capacity
  PARAMETER NCAP_AF(REG,ALLYEAR,PRC,TS,BD)      'Availability of capacity'                //;
  PARAMETER NCAP_AFA(REG,ALLYEAR,PRC,BD)        'Annual Availability of capacity'         //;
  PARAMETER NCAP_AFS(REG,ALLYEAR,PRC,TS,BD)     'Seasonal Availability of capacity'       //;
  PARAMETER NCAP_AFX(R,ALLYEAR,P)               'Change in capacity availability'         //;
  PARAMETER NCAP_AFM(R,ALLYEAR,P)               'Pointer to availity change multiplier'   //;
  PARAMETER NCAP_BND(REG,ALLYEAR,PRC,LIM)       'Bound on overall capacity in a period'   //;
  PARAMETER NCAP_BPME(REG,ALLYEAR,PRC)          'Back pressure mode efficiency (or total eff.)' //;
  PARAMETER NCAP_CDME(REG,ALLYEAR,PRC)          'Condensing mode efficiency'              //;
  PARAMETER NCAP_CEH(REG,ALLYEAR,PRC)           'Coefficient of electricity to heat'      //;
  PARAMETER NCAP_CHPR(REG,ALLYEAR,PRC,LIM)      'Combined heat:power ratio'               //;
  PARAMETER NCAP_CLED(REG,ALLYEAR,PRC,COM)      'Leadtime of a commodity before new capacity ready' //;
  PARAMETER NCAP_CLAG(REG,ALLYEAR,PRC,COM,IO)   'Lagtime of a commodity after new capacity ready' //;
  PARAMETER NCAP_COM(REG,ALLYEAR,PRC,COM,IO)    'Use (but +) of commodity based upon capacity' //;
  PARAMETER NCAP_COST(REG,ALLYEAR,PRC,CUR)      'Investment cost for new capacity'        //;
  PARAMETER NCAP_CPX(REG,ALLYEAR,PRC)           'Pointer to capacity transfer multiplier' //;
  PARAMETER NCAP_DRATE(REG,ALLYEAR,PRC)         'Process specific discount (hurdle) rate' //;
  PARAMETER NCAP_FDR(REG,ALLYEAR,PRC)           'Functional depreciation rate of process' //;
  PARAMETER NCAP_ELIFE(REG,ALLYEAR,PRC)         'Economic (payback) lifetime'             //;
  PARAMETER NCAP_FOM(REG,ALLYEAR,PRC,CUR)       'Fixed annual O&M costs'                  //;
  PARAMETER NCAP_FOMX(REG,ALLYEAR,PRC)          'Change in fixed O&M'                     //;
  PARAMETER NCAP_FOMM(REG,ALLYEAR,PRC)          'Pointer to fixed O&M change multiplier'  //;
  PARAMETER NCAP_FSUB(REG,ALLYEAR,PRC,CUR)      'Fixed tax on installed capacity'         //;
  PARAMETER NCAP_FSUBX(REG,ALLYEAR,PRC)         'Change in fixed tax'                     //;
  PARAMETER NCAP_FSUBM(REG,ALLYEAR,PRC)         'Pointer to fixed subsidy change multiplier' //;
  PARAMETER NCAP_FTAX(REG,ALLYEAR,PRC,CUR)      'Fixed tax on installed capacity'         //;
  PARAMETER NCAP_FTAXX(REG,ALLYEAR,PRC)         'Change in fixed tax'                     //;
  PARAMETER NCAP_FTAXM(REG,ALLYEAR,PRC)         'Pointer to fixed tax change multiplier'  //;
  PARAMETER NCAP_ICOM(REG,ALLYEAR,PRC,COM)      'Input of commodity for install of new capacity' //;
  PARAMETER NCAP_ILED(REG,ALLYEAR,PRC)          'Lead-time required for building a new capacity' //;
  PARAMETER NCAP_ISUB(REG,ALLYEAR,PRC,CUR)      'Subsidy for a new investment in capacity' //;
  PARAMETER NCAP_ITAX(REG,ALLYEAR,PRC,CUR)      'Tax on a new investment in capacity'     //;
  PARAMETER NCAP_LCOST(REG,ALLYEAR,PRC)         '% labor cost of new investment'          //;
  PARAMETER NCAP_LFOM(REG,ALLYEAR,PRC)          '% labor cost of fixed O&M'               //;
  PARAMETER NCAP_PASTI(REG,ALLYEAR,PRC)         'Capacity install prior to study years'   //;
  PARAMETER NCAP_PASTY(REG,ALLYEAR,PRC)         'Buildup years for past investments'      //;
  PARAMETER NCAP_TLIFE(REG,ALLYEAR,PRC)         'Technical lifetime of a process'         //;
  PARAMETER NCAP_OLIFE(REG,ALLYEAR,PRC)         'Operating lifetime of a process';
  PARAMETER RCAP_BLK(REG,ALLYEAR,PRC)           'Retirement block size'                   //;
  PARAMETER RCAP_BND(REG,ALLYEAR,PRC,LIM)       'Retirement bounds';

* decommissioning of Capacity
  PARAMETER NCAP_DCOST(REG,ALLYEAR,PRC,CUR)     'Cost of decomissioning'                  //;
  PARAMETER NCAP_DLAG(REG,ALLYEAR,PRC)          'Delay to begin decomissioning'           //;
  PARAMETER NCAP_DLAGC(REG,ALLYEAR,PRC,CUR)     'Cost of decomissioning delay'            //;
  PARAMETER NCAP_DELIF(REG,ALLYEAR,PRC)         'Economic lifetime to pay for decomissioning' //;
  PARAMETER NCAP_DLIFE(REG,ALLYEAR,PRC)         'Time for the actual decomissioning'      //;
  PARAMETER NCAP_OCOM(REG,ALLYEAR,PRC,COM)      'Commodity release during decomissioning' //;
  PARAMETER NCAP_VALU(REG,ALLYEAR,PRC,COM,CUR)  'Value of material released during decomissioning' //;

* capacity installed
  PARAMETER NCAP_START(REG,PRC)                 'Start year for new investments'  //;
  PARAMETER NCAP_SEMI(R,ALLYEAR,P)              'Semi-continuous capacity, lower bound';
  PARAMETER CAP_BND(REG,ALLYEAR,PRC,BD)         'Bound on total installed capacity in a period' //;

* general commodities
  PARAMETER COM_BNDNET(REG,ALLYEAR,COM,TS,LIM)      'Net bound on commodity (e.g., emissions)' //;
  PARAMETER COM_BNDPRD(REG,ALLYEAR,COM,TS,LIM)      'Limit on production of a commodity'       //;
  PARAMETER COM_CUMNET(REG,BOHYEAR,EOHYEAR,COM,LIM) 'Cumulative net bound on commodity (e.g. emissions)' //;
  PARAMETER COM_CUMPRD(REG,BOHYEAR,EOHYEAR,COM,LIM) 'Cumulative limit on production of a commodity' //;
  PARAMETER COM_CSTNET(REG,ALLYEAR,COM,TS,CUR)      'Cost on Net of commodity (e.g., emissions tax)' //;
  PARAMETER COM_CSTPRD(REG,ALLYEAR,COM,TS,CUR)      'Cost on production of a commodity'        //;
  PARAMETER COM_FR(REG,ALLYEAR,COM,TS)              'Seasonal distribution of a commodity'     //;
  PARAMETER COM_IE(REG,ALLYEAR,COM,TS)              'Seasonal efficiency of commodity'         //;
  PARAMETER COM_SUBNET(REG,ALLYEAR,COM,TS,CUR)      'Subsidy on a commodity net'               //;
  PARAMETER COM_SUBPRD(REG,ALLYEAR,COM,TS,CUR)      'Subsidy on production of a commodity net' //;
  PARAMETER COM_TAXNET(REG,ALLYEAR,COM,TS,CUR)      'Tax on a commodity net'                   //;
  PARAMETER COM_TAXPRD(REG,ALLYEAR,COM,TS,CUR)      'Tax on production of a commodity net'     //;
  PARAMETER COM_AGG(REG,ALLYEAR,COM,COM)            'Commodity aggregation parameter'          //;

* demands
  PARAMETER COM_BPRICE(REG,ALLYEAR,COM,TS,CUR)      'Base price of elastic demands'     //;
  PARAMETER COM_BQTY(REG,COM,TS)                    'Base quantity for elastic demands' //;
  PARAMETER COM_ELAST(REG,ALLYEAR,COM,TS,LIM)       'Elasticity of demand'              //;
  PARAMETER COM_ELASTX(REG,ALLYEAR,COM,BD)          'Elasticity shape of demand'        //;
  PARAMETER COM_PROJ(REG,ALLYEAR,COM)               'Demand baseline projection'        //;
  PARAMETER COM_STEP(REG,COM,LIM)                   'Step size for elastic demand'      //;
  PARAMETER COM_VOC(REG,ALLYEAR,COM,BD)             'Variance of elastic demand'        //;

* flow of commodities through processes
  PARAMETER FLO_BND(REG,ALLYEAR,PRC,CG,TS,BD)       'Bound on the flow variable'                           //;
  PARAMETER FLO_COST(REG,ALLYEAR,PRC,COM,TS,CUR)    'Added variable O&M of using a commodity'              //;
  PARAMETER FLO_DELIV(REG,ALLYEAR,PRC,COM,TS,CUR)   'Delivery cost for using a commodity'                  //;
  PARAMETER FLO_FEQ(REG,ALLYEAR,PRC,COM)            'Fossil equivalent of a commodity in a process'        //;
  PARAMETER FLO_FR(REG,ALLYEAR,PRC,COM,TS,LIM)      'Load-curve of availability of commodity to a process' //;
  PARAMETER FLO_FUNC(REG,ALLYEAR,PRC,CG,CG,TS)      'Relationship between 2 (group of) flows'              //;
  PARAMETER FLO_FUNCX(REG,ALLYEAR,PRC,CG,CG)        'Change in FLO_FUNC/FLO_SUM by age'                    //;
  PARAMETER FLO_SHAR(REG,ALLYEAR,PRC,C,CG,TS,BD)    'Relationship between members of the same flow group'  //;
  PARAMETER FLO_SUB(REG,ALLYEAR,PRC,COM,TS,CUR)     'Subsidy for the production/use of a commodity'        //;
  PARAMETER FLO_SUM(REG,ALLYEAR,PRC,CG,C,CG,TS)     'Multipier for commodity in cg1 where each is summed into cg2' //;
  PARAMETER FLO_TAX(REG,ALLYEAR,PRC,COM,TS,CUR)     'Tax on the production/use of a commodity'             //;
  PARAMETER FLO_CUM(REG,PRC,COM,ITEM,ITEM,LIM)      'Bound on cumulative flow'                             //;
  PARAMETER FLO_MARK(REG,ALLYEAR,PRC,COM,BD)        'Process-wise market share in total commodity production' //;
  PARAMETER PRC_MARK(REG,ALLYEAR,PRC,ITEM,C,LIM)    'Process group-wise market share' //;
  PARAMETER PRC_RESID(REG,ALLYEAR,PRC)              'Residual capacity available in each period' //;
  PARAMETER PRC_REFIT(REG,PRC,PRC)                  'Process with retrofit or life-extension';

* peak
  PARAMETER NCAP_PKCNT(REG,ALLYEAR,PRC,ALL_TS)      'Fraction of capacity contributing to peaking in time-slice TS' //;
  PARAMETER COM_PKRSV(REG,ALLYEAR,COM)              'Peaking reserve margin'   //;
  PARAMETER COM_PKFLX(REG,ALLYEAR,COM,TS)           'Peaking flux ratio'       //;
  PARAMETER FLO_PKCOI(REG,ALLYEAR,PRC,COM,ALL_TS)   'Factor increasing the average demand' //;

* Storage
  PARAMETER STG_EFF(REG,ALLYEAR,PRC)                'Storage efficiency'       //;
  PARAMETER STG_LOSS(REG,ALLYEAR,PRC,S)             'Annual energy loss from a storage technology' //;
  PARAMETER STG_CHRG(REG,ALLYEAR,PRC,S)             'Exogeneous charging of a storage technology ' //;
  PARAMETER STG_SIFT(R,ALLYEAR,P,C,S)               'Max load sifting in proportion to total load' //;
  PARAMETER STGOUT_BND(REG,ALLYEAR,PRC,C,S,BD)      'Bound on output-flow of storage process'      //;
  PARAMETER STGIN_BND(REG,ALLYEAR,PRC,C,S,BD)       'Bound on output-flow of storage process'      //;

* Process units
  PARAMETER PRC_ACTFLO(REG,ALLYEAR,PRC,CG)          'Convert from process activity to particular commodity flow' //;
  PARAMETER PRC_CAPACT(REG,PRC)                     'Factor for going from capacity to activity' //;

* globals
  PARAMETER G_CHNGMONY(REG,ALLYEAR,CUR)             'Exchange rate for currency'    //;
  PARAMETER G_DRATE(REG,ALLYEAR,CUR)                'Discount rate for a currency'  //;
  PARAMETER G_YRFR(ALL_REG,TS)                      'Seasonal fraction of the year' //;
  PARAMETER TS_CYCLE(REG,TS)                        'Length of cycles below timeslice, in days' //;
  PARAMETER G_OFFTHD(ALLYEAR)                       'Threshold for OFF ranges';
  PARAMETER G_OVERLAP                               'Overlap of stepped solutions (in years)' / 0 /;
  PARAMETER REG_FIXT(ALL_R)                         'Year up to which periods are fixed';
  PARAMETER G_CUREX(CUR,CUR)                        'Global currency conversions';
  PARAMETER R_CUREX(ALL_REG,CUR,CUR)                'Regional currency conversions';

* trade of commodities
  PARAMETERS
    IRE_BND(ALL_R,ALLYEAR,COM,TS,ALL_REG,IE,BD)     'Limit on inter-reg exchange of commodity' //
    IRE_FLO(ALL_R,ALLYEAR,PRC,COM,ALL_R,COM,TS)     'Efficiency of exchange for inter-regional trade' //
    IRE_FLOSUM(REG,ALLYEAR,PRC,COM,TS,IE,COM,IO)    'Aux. consumption/emissions from inter-regional trade'//
    IRE_PRICE(REG,ALLYEAR,PRC,COM,TS,ALL_R,IE,CUR)  'Exogenous price of import/export' //
    IRE_XBND(ALL_REG,ALLYEAR,COM,TS,IE,BD)          'Limit on all (external and inter-regional) exchange of commodity' //
    IRE_CCVT(ALL_REG,COM,ALL_REG,COM)               'Commodity unit conversion factor between regions' //
    IRE_TSCVT(ALL_REG,ALL_TS,ALL_REG,ALL_TS)        'Identification and TS-conversion factor between regions' //;

* Shape and Multi
  PARAMETER SHAPE(J,AGE)                            'Shaping table'       //;
  PARAMETER MULTI(J,ALLYEAR)                        'Multiplier table'    //;

* Regional Cost bounds
  PARAMETERS
    REG_BNDCST(REG,ALLYEAR,COSTAGG,CUR,BD)          'Bound on regional costs by type'    //
    REG_CUMCST(REG,ALLYEAR,ALLYEAR,COSTAGG,CUR,BD)  'Cumulative bound on regional costs' //;

* User Constraints

  PARAMETER UC_RHS(UC_N,LIM)                        'Constant in user constraint'  //;
  PARAMETER UC_RHST(UC_N,ALLYEAR,LIM)               'Constant in user constraint'  //;
  PARAMETER UC_RHSR(ALL_REG,UC_N,LIM)               'Constant in user constraint'  //;
  PARAMETER UC_RHSS(UC_N,TS,LIM)                    'Constant in user constraint'  //;
  PARAMETER UC_RHSRT(ALL_REG,UC_N,ALLYEAR,LIM)      'Constant in user constraint'  //;
  PARAMETER UC_RHSRS(ALL_REG,UC_N,TS,LIM)           'Constant in user constraint'  //;
  PARAMETER UC_RHSRTS(ALL_REG,UC_N,ALLYEAR,TS,LIM)  'Constant in user constraint'  //;
  PARAMETER UC_RHSTS(UC_N,ALLYEAR,TS,LIM)           'Constant in user constraint'  //;

  PARAMETERS
    UC_FLO(UC_N,SIDE,ALL_REG,ALLYEAR,PRC,COM,TS)    'Multiplier of flow variables' //
    UC_ACT(UC_N,SIDE,ALL_REG,ALLYEAR,PRC,ALL_TS)    'Multiplier of activity variables' //
    UC_CAP(UC_N,SIDE,ALL_REG,ALLYEAR,PRC)           'Multiplier of capacity variables' //
    UC_NCAP(UC_N,SIDE,ALL_REG,ALLYEAR,PRC)          'Multiplier of VAR_NCAP variables' //
    UC_COMCON(UC_N,SIDE,ALL_REG,ALLYEAR,COM,TS)     'Multiplier of VAR_COMCON variables' //
    UC_COMPRD(UC_N,SIDE,ALL_REG,ALLYEAR,COM,TS)     'Multiplier of VAR_COMPRD variables' //
    UC_COMNET(UC_N,SIDE,ALL_REG,ALLYEAR,COM,TS)     'Multiplier of VAR_COMNET variables' //
    UC_IRE(UC_N,SIDE,ALL_REG,ALLYEAR,PRC,COM,TS,IE) 'Multiplier of inter-regional exchange variables' //
    UC_CUMACT(UC_N,ALL_REG,PRC,ITEM,ITEM)           'Multiplier of cumulative process activity variable' //
    UC_CUMFLO(UC_N,ALL_REG,PRC,COM,ITEM,ITEM)       'Multiplier of cumulative process flow variable' //
    UC_CUMCOM(UC_N,ALL_REG,COM_VAR,COM,ITEM,ITEM)   'Multiplier of cumulative commodity variable' //
    UC_UCN(UC_N,SIDE,ALL_R,ALLYEAR,UC_N)            'Multiplier of user constraint variable' //
    UC_TIME(UC_N,ALL_REG,ALLYEAR)                   'Multiplier of time in model periods (years)' //;

*-----------------------------------------------------------------------------
* Extensions
*-----------------------------------------------------------------------------
* Damage input parameters
  PARAMETER DAM_COST(REG,ALLYEAR,COM,CUR) 'Marginal damage cost of emissions';
  PARAMETER DAM_BQTY(REG,COM)             'Base quantity of emissions'           //;
  PARAMETER DAM_ELAST(REG,COM,LIM)        'Elasticity of damage cost';
  PARAMETER DAM_STEP(REG,COM,LIM)         'Step number for emissions up to base' //;
  PARAMETER DAM_VOC(REG,COM,LIM)          'Variance of emissions'                //;
* Experimental parameters
  PARAMETER DAM_TQTY(REG,ALLYEAR,COM)     'Base quantity of emissions by year'   //;
  PARAMETER DAM_TVOC(REG,ALLYEAR,COM,LIM) 'Variance of emissions by year'        //;
  PARAMETER DAM_COEF(REG,ALLYEAR,COM,S)   'Coefficient from commodity to damage' //;

*----------------------------------------------------------------------------------------------
* SYSTEM (Internal) Declarations
*----------------------------------------------------------------------------------------------
* SET SECTION
*----------------------------------------------------------------------------------------------

* commodities
  SET RC(R,C)                       'Commodities in each region';
  SET RCJ(R,C,J,BD)                 '# of steps for elastic demands';
  SET RC_AGP(REG,COM,LIM)           'Commodity aggregation of production';
  SET RTC_NET(R,ALLYEAR,C)          'VAR_COMNETs within CUM constraint range';
  SET RTC_PRD(R,ALLYEAR,C)          'VAR_COMPRDs within CUM constraint range';
  SET RHS_COMBAL(R,ALLYEAR,C,S)     'VAR_COMNET needed on balance';
  SET RHS_COMPRD(R,ALLYEAR,C,S)     'VAR_COMPRD needed on production';
  SET RCS_COMBAL(R,ALLYEAR,C,S,LIM) 'TS for balance given RHS requirements';
  SET RCS_COMPRD(R,ALLYEAR,C,S,LIM) 'TS for production given RHS requirements';
  SET RCS_COMTS(R,C,ALL_TS)         'All timeslices at/above the COM_TSL';
  SET RD_AGG(REG,COM)               'Micro aggregated demands' //;
  SET MI_DMAS(REG,COM,COM)          'Micro aggregation map' //;

* currency
  SET RDCUR(REG,CUR)       'Discounted currencies by region';

* commodity types (basic)
  SET DEM(REG,COM)         'Demand commodities'                  //;
  SET ENV(REG,COM)         'Environmental indicator commodities' //;
  SET FIN(REG,COM)         'Financial flow commodities'          //;
  SET MAT(REG,COM)         'Material commodities'                //;
  SET NRG(REG,COM)         'Energy carrier commodities'          //;

* process
  SET RP(R,P)                   'Processes in each region'               //;
  SET RP_FLO(R,P)               'Processes with VAR_FLOs (not IRE)'      //;
  SET RP_STD(R,P)               'Standard processes with VAR_FLOs'       //;
  SET RP_STG(R,P)               'Storage processes'                      //;
  SET RP_IRE(ALL_REG,P)         'Processes involved in inter-regional trade' //;
  SET RP_NRG(R,P)               'Processes with an energy carrier PCG'   //;
  SET RP_INOUT(R,P,IO)          'Indicator if process input/output normalized (according to PG side)' //;
  SET RP_PG(REG,PRC,CG)         'Primary commodity group (PG)'           //;
  SET RP_PGTYPE(R,P,CG)         'Group type of the primary group'        //;
  SET RP_UPL(R,P,L)             'Processes with dispatching equations'   //;
  SET RP_UPR(R,P,L)             'Processes with ramping costs'           //;
  SET RP_UPS(R,P,TSLVL,L)       'Timeslice levels for startup accounting'//;
  SET RP_UPT(R,P,UPT,BD)        'Start-up types for unit commitment'     //;
  SET RP_DPL(R,P,TSLVL)         'Dispatching process timeslice levels'   //;
  SET RPC(R,P,C)                'Commodities in/out of a processes'      //;
  SET RPC_CAPFLO(R,ALLYEAR,P,C) 'Commodities involved in capacity'       //;
  SET RPC_CONLY(R,ALLYEAR,P,C)  'Commodities ONLY involved in capacity'  //;
  SET RPC_NOFLO(R,P,C)          'Commodities ONLY involved in capacity'  //;
  SET RPC_IRE(ALL_REG,P,C,IE)   'Process/commodities involved in inter-regional trade'//;
  SET RPC_PG(R,P,C)             'Commodities in the primary group'       //;
  SET RPC_SPG(R,P,C)            'Commodities in the shadow primary group' //;
  SET RPCS_VAR(R,P,C,ALL_TS)    'The timeslices at which VAR_FLOs are to be created' //;
  SET RPS_S1(R,P,ALL_TS)        'All timeslices at the PRC_TSL/COM_TSLspg' //;
  SET RPS_S2(R,P,ALL_TS)        'All timeslices at/above PRC_TSL/COM_TSLspg'//;
  SET RPS_PRCTS(R,P,ALL_TS)     'All timeslices at/above the PRC_TSL'    //;
  SET RTC(R,ALLYEAR,C)          'Commodity/time'                         //;
  SET RTCS_VARC(R,ALLYEAR,C,ALL_TS) 'The VAR_COMNET/PRDs control set'    //;
  SET RTP(R,ALLYEAR,P)          'Process/time'                           //;
  SET RTPC(R,ALLYEAR,P,C)       'Commodities of process in period'       //;
  SET RTP_CPTYR(R,ALLYEAR,ALLYEAR,P) 'Capcity transfer v/t years'        //;
  SET RTP_OFF(R,ALLYEAR,P)      'Periods for which VAR_NCAP.UP = 0'      //;
  SET RTPCS_VARF(ALL_REG,ALLYEAR,P,C,ALL_TS) 'The VAR_FLOs control set'  //;
  SET RTP_VARA(R,ALLYEAR,P)     'The VAR_ACT control set'                //;
  SET RTP_VARP(R,T,P)           'RTPs that have a VAR_CAP'               //;
  SET RTP_VINTYR(ALL_REG,ALLYEAR,ALLYEAR,PRC) 'v/t years when vintaging involved' //;
  SET RTP_TT(R,T,YEAR,PRC)      'Retrofit control periods'               //;
  SET RVP(R,ALLYEAR,P)          'ALIAS(RTP) for Process/time'            //;
  SET RTP_CAPYR(R,YEAR,YEAR,P)  'Capacity vintage years'                 //;
  SET CG_GRP(REG,PRC,CG,CG)     'Multi-purpose work set'               //;
  SET FSCK(REG,PRC,CG,C,CG)     'Multi-purpose work set'               //;
  SET FSCKS(REG,PRC,CG,C,CG,S)  'Multi-purpose work set'               //;
  SET RPC_IREIO(R,P,C,IE,IO)    'Types of trade flows'                 //;
  SET RPC_LS(R,P,C)             'Load sifting control'                 //;

* region
  SET RREG(ALL_REG,ALL_REG) 'The set of paired regions' //;

* cumulatives & UCs
  SET UC_ON(ALL_R,UC_N)                          'Active UCs by region' //;
  SET UC_GMAP_C(REG,UC_N,COM_VAR,COM,UC_GRPTYPE) 'Assigning commodities to UC_GRP';
  SET UC_GMAP_P(REG,UC_N,UC_GRPTYPE,PRC)         'Assigning processes to UC_GRP';
  SET UC_GMAP_U(ALL_R,UC_N,UC_N)                 'Assigning constraints to UC_GRP' //;
  SET RC_CUMCOM(REG,COM_VAR,ALLYEAR,ALLYEAR,COM) 'Cumulative commodity PRD/NET';
  SET RPC_CUMFLO(REG,PRC,COM,ALLYEAR,ALLYEAR)    'Cumulative process flows';

* time
  SETS
    RS_BELOW(ALL_REG,TS,TS)  'Timeslices stictly below a node'     //
    RS_BELOW1(ALL_REG,TS,TS) 'Timeslices strictly one level below' //
    RS_TREE(ALL_REG,TS,TS)   'Timeslice subtree'                   //
    FINEST(R,ALL_TS)         'Set of the finest timeslices in use' //
    PASTMILE(ALLYEAR)        'PAST years that are not MILESYONYR'  //
    EACHYEAR(ALLYEAR)        'Each year from 1st NCAP_PASTI-Y to last MILESTONYR + DUR_MAX' //
    EOHYEARS(ALLYEAR)        'Each year from 1st NCAP_PASTI-Y to last MILESTONYR' //
    MODLYEAR(ALLYEAR)        'Years for which the model is to be run (MILESTONYR+PASTYEAR)' //;
  ALIAS(MODLYEAR,V);

* identifiers for beginning/end of model horizon
  SET MIYR_1(ALLYEAR) 'First T'   //;
  SET MIYR_L(ALLYEAR) 'Last year' //;

* miscellaneous
  SET RP_PRC(R,P);
  SET RP_GRP(REG,PRC,CG);
  SET RP_CCG(REG,PRC,C,CG);
  SET TRACKC(R,C);
  SET TRACKP(R,P);
  SET TRACKPC(R,P,C);
  SET TRACKPG(R,P,CG);

* ---------------------------------------------------------------------------------------------
* PARAMETERS SECTION
* ---------------------------------------------------------------------------------------------
* time
  PARAMETER B(ALLYEAR)      'Beginning year of each model period' //;
  PARAMETER E(ALLYEAR)      'Ending year of each model period'    //;
  PARAMETER M(ALLYEAR)      'Middle year of each Period'          //;
  PARAMETER D(ALLYEAR)      'Length of each period'               //;

  SCALARS MIYR_V1 /0/, MIYR_VL /0/, PYR_V1 /0/;

* maximum NCAP_ILED+NCAP_TLIFE+NCAP_DLAG+NCAP_DLIFE+NCAP_DELIF
  SCALAR  DUR_MAX / 0 /;

* Split of timeslice based upon level
  PARAMETER RS_FR(R,S,S) //;
  PARAMETER JS_CCL(R,J,S)//;

* integrated parameters (created in PREPPM.mod)
  PARAMETER UC_COM(UC_N,COM_VAR,SIDE,REG,ALLYEAR,COM,S,UC_GRPTYPE) 'Multiplier of VAR_COM variables' //;
  PARAMETER COM_CUM(REG,COM_VAR,ALLYEAR,ALLYEAR,COM,LIM) 'Cumulative bound on commodity' //;

* derived coefficient components (created in COEF*.MOD)
  PARAMETER COEF_AF(R,ALLYEAR,T,PRC,S,BD)      'Capacity/Activity relationship'         //;
  PARAMETER COEF_CPT(R,ALLYEAR,T,PRC)          'Fraction of capacity available'         //;
  PARAMETER COEF_ICOM(R,ALLYEAR,T,PRC,C)       'Commodity flow at investment time'      //;
  PARAMETER COEF_OCOM(R,ALLYEAR,T,PRC,C)       'Commodity flow at decommissioning time' //;
  PARAMETER COEF_PTRAN(REG,ALLYEAR,PRC,CG,C,CG,S) 'Multiplier for EQ_PTRANS'            //;
  PARAMETER COEF_RPTI(R,ALLYEAR,P)             'Repeated investment cycles'             //;
  PARAMETER COEF_ILED(R,ALLYEAR,P)             'Investment lead time'                   //;
  PARAMETER COEF_PVT(R,T)                      'Present value of time in periods'       //;
  PARAMETER COEF_CAP(R,ALLYEAR,LL,P)           'Generic re-usable work parameter';
  PARAMETER COEF_RTP(R,ALLYEAR,P)              'Generic re-usable work parameter';
  PARAMETER COEF_RVPT(R,ALLYEAR,PRC,T)         'Generic re-usable work parameter';
  PARAMETER RTP_CPX(R,ALLYEAR,P,LL)            'Shape multipliers for capacity transfer'//;
  PARAMETER NCAP_AFSX(R,ALLYEAR,P) //;
  PARAMETER NCAP_AFSM(R,ALLYEAR,P) //;
  PARAMETER RVPRL(R,YEAR,P) //;

* OBJ function yearly values established in COEF_OBJ and used in OBJ_*
  PARAMETER OBJ_PVT(R,YEAR,CUR)            'Present value of period'  //;
  PARAMETER OBJ_CRF(R,ALLYEAR,P,CUR)       'Capital recovery factor'  //;
  PARAMETER OBJ_CRFD(R,ALLYEAR,P,CUR)      'Capital recovery factor for Decommissioning' //;
  PARAMETER OBJ_DISC(R,ALLYEAR,CUR)        'Discounting factor'       //;
$IF %OBMAC%==YES $GOTO RESTOBJ
  PARAMETER OBJ_ICOST(R,ALLYEAR,P,CUR)     'NCAP_COST for each year'  //;
  PARAMETER OBJ_ISUB(R,ALLYEAR,P,CUR)      'NCAP_ISUB for each year'  //;
  PARAMETER OBJ_ITAX(R,ALLYEAR,P,CUR)      'NCAP_ITAX for each year'  //;
  PARAMETER OBJ_FOM(R,ALLYEAR,P,CUR)       'NCAP_FOM for each year'   //;
  PARAMETER OBJ_FSB(R,ALLYEAR,P,CUR)       'NCAP_FSUB for each year'  //;
  PARAMETER OBJ_FTX(R,ALLYEAR,P,CUR)       'NCAP_FTX for each year'   //;
  PARAMETER OBJ_DCOST(R,ALLYEAR,P,CUR)     'NCAP_DCOST for each year' //;
  PARAMETER OBJ_DLAGC(R,ALLYEAR,P,CUR)     'NCAP_DLAGC for each year' //;
  PARAMETER OBJ_ACOST(R,ALLYEAR,P,CUR)     'ACT_COST for each year'   //;
  PARAMETER OBJ_FCOST(R,ALLYEAR,P,C,S,CUR) 'FLO_COST for each year'   //;
  PARAMETER OBJ_FDELV(R,ALLYEAR,P,C,S,CUR) 'FLO_DELIV for each year'  //;
  PARAMETER OBJ_FTAX(R,ALLYEAR,P,C,S,CUR)  'FLO_TAX for each year'    //;
$LABEL RESTOBJ
  PARAMETER OBJ_FSUB(R,ALLYEAR,P,C,S,CUR)  'FLO_SUB for each year'    //;
  PARAMETER OBJ_COMNT(R,ALLYEAR,C,S,COSTYPE,CUR) 'COM_CNET for each year' //;
  PARAMETER OBJ_COMPD(R,ALLYEAR,C,S,COSTYPE,CUR) 'COM_CPRD for each year' //;
  PARAMETER OBJ_IPRIC(R,ALLYEAR,P,C,S,IE,CUR) 'IRE_PRICE for each year' //;

* Miscellanea
  PARAMETERS
    PRC_YMIN(REG,PRC)   'Generic process parameter' //
    PRC_YMAX(REG,PRC)   'Generic process parameter' //
    PRC_SC(REG,PRC)     'Process storage cycles'    //
    PRC_SGL(REG,PRC)    'Process shadow level (< DAYNITE)' //
    PRC_SEMI(R,P)       'Semi-continuous indicator' //
    RD_NLP(R,C)         'NLP demand indicator' //
    RD_SHAR(R,T,C,C)    'Demand aggregation share' //
    RS_STG(R,ALL_TS)    'Lead from previous storage timeslice'
    RS_UCS(R,S,SIDE)    'Lead for TS-dynamic UC'
    RS_STGPRD(R,ALL_TS) 'Number of storage periods for each timeslice'
    RS_STGAV(R,ALL_TS)  'Average residence time for storage activity'
    RS_TSLVL(R,ALL_TS)  'Timeslice levels'
    TS_ARRAY(ALL_TS)    'Array for leveling parameter values across timeslices'
    STOA(ALL_TS)        'ORD Lag from each timeslice to ANNUAL'
    STOAL(ALL_REG,TS)   'ORD Lag from the LVL of each timeslice to ANNUAL';


* ---------------------------------------------------------------------------------------------
*GG* V07_2 Initializations for BLENDing
* ---------------------------------------------------------------------------------------------
* user provided Sets & Scalars
         SET BLE(COM)       //;
         SET OPR(COM)       //;
         SET SPE(*)         //;
         SET REF(R,PRC)     //;
         PARAMETER REFUNIT(R) //;

* internal Sets
         SET CVT  / DENS, WCV, VCV, SLF /;

* user provided Parameters
         PARAMETER CONVERT(OPR,CVT)              //;
         PARAMETER BL_START(R,COM,SPE)           //;
         PARAMETER BL_UNIT(R,COM,SPE)            //;
         PARAMETER BL_TYPE(R,COM,SPE)            //;
         PARAMETER BL_SPEC(R,COM,SPE)            //;
*         PARAMETER TBL_SPEC(COM,SPE,YEAR)       //;
         PARAMETER BL_COM(R,COM,OPR,SPE)         //;
*         PARAMETER TBL_COM(COM,SPE,OPR,YEAR)    //;
         PARAMETER BL_INP(R,COM,COM)             //;
*         PARAMETER TBL_INP(COM,SPE,COM,YEAR)    //;
         PARAMETER BL_VAROM(R,COM)               //;
         PARAMETER BL_VAROMC(R,COM,CUR)          //;
*         PARAMETER TBL_VAROM(COM,SPE,YEAR)      //;
         PARAMETER BL_DELIV(R,COM,COM)           //;
         PARAMETER BL_DELIVC(R,COM,COM,CUR)      //;
*         PARAMETER TBL_DELIV(COM,SPE,COM,YEAR)  //;
         PARAMETER ENV_BL(R,COM,COM,OPR,YEAR)    //;
         PARAMETER PEAKDA_BL(R,COM,YEAR)         //;

* internal Parameters
         PARAMETER RU_CVT(R,BLE,SPE,OPR)         //;
         PARAMETER RU_FEQ(R,COM,YEAR)            //;

  PARAMETER OBJ_BLNDV(R,YEAR,C,C,CUR) 'annual variable costs for blending' //;

*-----------------------------------------------------------------------------
* Initialization interpolation/extrapolation
*-----------------------------------------------------------------------------
  SET        FIL(ALLYEAR);
  SET        MY_FIL(ALLYEAR) //;
  SET        VNT(ALLYEAR,ALLYEAR);
  SET        YK1(ALLYEAR,ALLYEAR);
  PARAMETER  FIL2(ALLYEAR);
  PARAMETER  MY_FIL2(ALLYEAR) //;
  PARAMETER  MY_ARRAY(ALLYEAR)//;
  PARAMETER  YKVAL(ALLYEAR,ALLYEAR);
  SCALAR     MY_F /0/, F /0/, Z /0/, CNT /0/, DFUNC /0/, DONE /0/, IFQ /1/;

* first and last given data value to be extrapolated
  SCALAR FIRST_VAL /0/, LAST_VAL /0/, MY_FYEAR /0/;

* flags used in extrapolation
  SET BACKWARD(ALLYEAR) //;
  SET FORWARD(ALLYEAR)  //;
* DM_YEAR is the union of the sets MODLYEAR and DATAYEAR (used in IE routines)
  SET DM_YEAR(ALLYEAR)  //;

* Interpolation defaults
  SET INT_DEFAULT(*) //;
  PARAMETER IE_DEFAULT(*) //;
* Placeholder for interpolation control option
$ SETGLOBAL DFLBL '0'
  YEARVAL('%DFLBL%') = 0;
  SET LASTLL(LL) /%DFLBL%/; Z=SUM(LASTLL(LL),ORD(LL)); ABORT$(Z NE CARD(LL)) 'FATAL';

*------------------------------------------------------------------------------
* Additional system declarations
*------------------------------------------------------------------------------
* One predefined system CG and COM:
$IF NOT SET PGPRIM $SETGLOBAL PGPRIM "'ACT'"
  SET COM_GRP   / %PGPRIM% /;
  SET ACTCG(CG) / %PGPRIM% /;
  SET COM       / %PGPRIM% /;
* Internal Sets:
  SETS
    PYR_S(ALLYEAR)       'Residual vintage' //
    MY_TS(ALL_TS)        'Temporary set for timeslices' //
    R_UC(ALL_R,UC_N)     'Temporary set for UCs by region' //
    UC_T(UC_N,T)         'Temporary set for UCs by period' //
    RXX(ALL_R,*,*)       'General triples related to a region'
    UNCD1(*)             'Non-domain-controlled set'
    UNCD7(*,*,*,*,*,*,*) 'Non-domain-controlled set of 7-tuples';
  ALIAS (TSLVL,TSL);
  ALIAS (LIFE,AGE);
* Label lengths exceeding default
  PARAMETER LABL(ITEM);
$IF NOT SETGLOBAL G2X6 $SETGLOBAL RL 'R.TL:(12+LABL(R))' SETGLOBAL PL 'P.TL:(12+LABL(P))' SETGLOBAL CL 'C.TL:(12+LABL(C))'
$IF SETGLOBAL G2X6 $SETGLOBAL RL 'R.TL:MAX(12,R.LEN)' SETGLOBAL PL 'P.TL:MAX(12,P.LEN)' SETGLOBAL CL 'C.TL:MAX(12,C.LEN)'

*------------------------------------------------------------------------------
* Sets and parameters used in reduction algorithm
*------------------------------------------------------------------------------
SET    NO_ACT(R,P)                    'Process not requiring activity variable'             //;
SET    RP_PGACT(R,P)                  'Process with PCG consisting of 1 commodity'          //;
SET    RP_PGFLO(R,P)                  'Process with PCG having COM_FR'                      //;
SET    RPC_ACT(REG,PRC,CG)            'PG commodity of Process with PCG consisting of 1'    //;
SET    RPC_AIRE(ALL_REG,PRC,COM)      'Exchange process with only one commodity exchanged'  //;
SET    RPC_EMIS(R,P,COM_GRP)          'Process with emission COM_GRP'                       //;
SET    FS_EMIS(R,P,COM_GRP,C,COM)     'Indicator for emission related FLO_SUM'              //;
SET    RC_IOP(R,C,IO,P)               'Processes associated with commodity'                 //;
SET    RTCS_SING(R,T,C,S,IO)          'Commodity not being consumed'                        //;
SET    RTPS_OFF(R,T,P,S)              'Process being turned off'                            //;
SET    RPC_FFUNC(REG,PRC,COM)         'RPC_ACT Commodity in FFUNC'                          //;
SET    RPCC_FFUNC(REG,PRC,CG,CG)      'Pair of FFUNC commodities with RPC_ACT commodity'    //;
SET    PRC_CAP(REG,PRC)               'Process requiring capacity variable'                 //;
SET    PRC_ACT(REG,PRC)               'Process requiring activity equation'                 //;
SET    PRC_TS2(REG,PRC,TS)            'Alias for PRC_TS of processes with RPC_ACT'          //;
ALIAS (CG3,CG4,COM_GRP);

*------------------------------------------------------------------------------
* Parameters used in report routine
*------------------------------------------------------------------------------
  PARAMETERS
   PAR_FLO(R,ALLYEAR,ALLYEAR,P,C,S)            'Flow parameter'                                    //
   PAR_FLOM(R,ALLYEAR,ALLYEAR,P,C,S)           'Reduced cost of flow variable'                     //
   PAR_IRE(R,ALLYEAR,ALLYEAR,P,C,S,IMPEXP)     'Parameter for im/export flow'                      //
   PAR_IREM(R,ALLYEAR,ALLYEAR,P,C,S,IMPEXP)    'Reduced cost of import/export flow'                //
   PAR_OBJINV(R,ALLYEAR,ALLYEAR,P,CUR)         'Annual discounted investment costs'                //
   PAR_OBJDEC(R,ALLYEAR,ALLYEAR,P,CUR)         'Annual discounted decommissioning costs'           //
   PAR_OBJFIX(R,ALLYEAR,ALLYEAR,P,CUR)         'Annual discounted FOM cost'                        //
   PAR_OBJSAL(R,ALLYEAR,P,CUR)                 'Annual discounted salvage value'                   //
   PAR_OBJLAT(R,ALLYEAR,P,CUR)                 'Annual discounted late costs'                      //
   PAR_OBJACT(R,ALLYEAR,ALLYEAR,P,TS,CUR)      'Annual discounted variable costs'                  //
   PAR_OBJFLO(R,ALLYEAR,ALLYEAR,P,COM,TS,CUR)  'Annual discounted flow costs (incl import/export)' //
   PAR_OBJCOM(R,ALLYEAR,COM,TS,CUR)            'Annual discounted commodity costs '                //
   PAR_OBJBLE(R,ALLYEAR,COM,CUR)               'Annual discounted blending costs'                  //
   PAR_OBJELS(R,ALLYEAR,COM,CUR)               'Annual discounted elastic demand cost term'        //;
*-----------------------------------------------------------------------------
* Reporting parameters for extensions
  PARAMETER CST_DAM(REG,T,COM)                 'Damage costs'                      //;
  PARAMETER CM_RESULT(ITEM,ALLYEAR)            'Climate module results'            //;
  PARAMETER CM_MAXC_M(ITEM,ALLYEAR)            'Shadow price of climate constraint'//;
  PARAMETER TM_RESULT(ITEM,R,ALLYEAR)          'MACRO results'                     //;


*------------------------------------------------------------------------------
* CONTROL section
*------------------------------------------------------------------------------
$ SETGLOBAL GDXPATH ''
$ IFI EXIST gamssave\nul $SETGLOBAL GDXPATH 'gamssave\'
$ SETGLOBAL SYSPREFIX '' SETGLOBAL PRF FILE=1
*------------------------------------------------------------------------------
* Alternative objective controls
  SCALAR ALTOBJ / 1 /;
$IFI %OBJ%==STD ALTOBJ=0;
$IFI %OBJ%==ALT ALTOBJ=2;
$IFI %OBJ%==LIN ALTOBJ=3;
$IFI %MACRO%==YES IF(ALTOBJ>1, ABORT 'MACRO Cannot be used with Alternative Objective'); ALTOBJ=0);
$IFI %VALIDATE%==YES IF(ALTOBJ>1, ABORT 'Cannot use VALIDATE with Alternative Objective'); ALTOBJ=0);
$SETGLOBAL CTST ''
$IFI %OBJ%==MOD $SETGLOBAL OBLONG YES
$IFI %OBJ%==ALT $SETGLOBAL CTST **EPS
$IFI %OBLONG%==YES $SETGLOBAL CTST **0
$IFI %OBJ%==LIN $SETGLOBAL CTST **EPS
$IFI '%OBLONG%%OBJ%'==YESALT $SETGLOBAL VARCOST LIN
$IFI '%OBLONG%%OBJ%'==YESALT ALTOBJ = -2;
*------------------------------------------------------------------------------
* Stochastic extension
$IFI %SENSIS%==YES $SETLOCAL STAGES yes
$IFI %SPINES%==YES $SETLOCAL STAGES YES
$IFI %STAGES%==YES $BATINCLUDE initmty.stc
*------------------------------------------------------------------------------
* Stepped extensions etc.
  SET ITEM / "%FIXBOH%", "%TIMESTEP%", "%SPOINT%" /;
$SETGLOBAL RPOINT NO
$IF SET SPOINT IF((NOT J('%SPOINT%'))$(NOT SAMEAS('%SPOINT%','YES')), ABORT 'Invalid Control: SPOINT');
$IF SET TIMESTEP IF(NOT AGE('%TIMESTEP%'), ABORT 'Invalid Control: TIMESTEP');
$IF SET FIXBOH IF(NOT ALLYEAR('%FIXBOH%'), ABORT 'Invalid Control: FIXBOH');
$IF SET FIXBOH $SETGLOBAL STEPPED -
$IF SET TIMESTEP $SETGLOBAL STEPPED +
$IF SET STEPPED $SETGLOBAL VAR_UC YES
  SET RVT(R,ALLYEAR,T); SET RTPX(R,T,P);
  PARAMETER NO_RT(ALL_R,T) //;
  SET RT_PP(R,T) //;
$IF %SYSTEM.LICENSELEVEL%==2 $SETGLOBAL VAR_UC YES
*------------------------------------------------------------------------------
* Other extensions to TIMES code
*------------------------------------------------------------------------------
* Auto-activation of discrete capacity extensions
$IF %DSCAUTO%==YES $SETGLOBAL DSC YES
$IF %PGPRIM%==ACT  $SETGLOBAL RETIRE 'YES' SETGLOBAL DSCAUTO Yes
$IFI %DSC%==YES    $KILL RCAP_BLK

* Initialize list of standard extensions to be loaded
$SETGLOBAL EXTEND ''

* Add recognized extensions if defined
$IFI '%MACRO%'==CSA $SETGLOBAL EXTEND '%EXTEND% MSA'
$IFI '%MACRO%'==MSA $SETGLOBAL EXTEND '%EXTEND% MSA'
$IFI '%ETL%' == YES $SETGLOBAL EXTEND '%EXTEND% ETL'
$IFI '%CLI%' == YES $SETGLOBAL EXTEND '%EXTEND% CLI'
$IFI '%DSC%' == YES $SETGLOBAL EXTEND '%EXTEND% DSC'
$IFI '%VDA%' == YES $SETGLOBAL EXTEND '%EXTEND% VDA'
$IFI '%ABS%' == YES $SETGLOBAL EXTEND '%EXTEND% ABS'
$IFI '%MCA%' == YES $SETGLOBAL EXTEND '%EXTEND% MCA'

* Finally, add args %1...%6 to list of extensions:
$SETGLOBAL EXTEND %EXTEND% %1 %2 %3 %4 %5 %6

* Load all extension declarations
$IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod initmty %EXTEND%

$IF ERRORFREE
$BATINCLUDE err_stat.mod '$IF NOT ERRORFREE' ABORT 'Errors in Compile' 'VARIABLE OBJz' ': Required _TIMES.g00 Restart File Missing'

*------------------------------------------------------------------------------
* Call MACRO initmty.tm
*------------------------------------------------------------------------------
$IF NOT SET MACRO $SETGLOBAL MACRO N
$IF %MACRO%==YES $INCLUDE initmty.tm

*------------------------------------------------------------------------------
* Load data from GDX if DATAGDX set and %RUN_NAME%~DATA exists
$ IF NOT SET DATAGDX $GOTO RUN
$ IF NOT %G2X6%==YES $GOTO RUN
$ IF NOT SET RUN_NAME $SETNAMES %SYSTEM.INCPARENT% . RUN_NAME .
$ IF NOT EXIST %RUN_NAME%~data.gdx $GOTO RUN
$ hiddencall gdxdump %RUN_NAME%~data.gdx NODATA > _dd_.dmp
$ hiddencall sed "/\(^\|(\*) \)Alias/{N;d;}; /^\([^$].*$\|$\)/d; s/\$LOAD.. /$LOADR /" _dd_.dmp > _dd_.dd
$ INCLUDE _dd_.dd
$ hiddencall rm -f _dd_.dmp
$ TITLE %SYSTEM.TITLE%#
$ GDXIN
$ LABEL RUN
