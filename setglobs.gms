*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=========================================================================
* Setglobs initializes System Declarations and Global Controls
* %1 - optional variable label to jump
*=========================================================================
$ SETARGS X1 X2
* --- DATA Dump ---
$ IF NOT %DATAGDX%==YES $GOTO SYSD
$ IF NOT ERRORFREE $GOTO SYSD
$ GDXOUT _dd_.gdx
$ IF %G2X6%==YES
$ IF gamsversion 342 $UNLOAD XPT
$ UNLOAD
$ GDXOUT
$ IF NOT warnings $GOTO SYSD
$ IF NOT ERRORFREE $ABORT GAMS cannot filter domain violations
$ IF %G2X6%==YES $BATINCLUDE gdxfilter MAIN
*------------------
$ LABEL SYSD
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
  SET RDCUR(REG,CUR)              'Discounted currencies by region';
  SET OBJ_ICUR(REG,ALLYEAR,P,CUR) 'Capacity-related cost indicator';

* commodity types (basic)
  SET DEM(REG,COM)              'Demand commodities'                  //;
  SET ENV(REG,COM)              'Environmental indicator commodities' //;
  SET FIN(REG,COM)              'Financial flow commodities'          //;
  SET MAT(REG,COM)              'Material commodities'                //;
  SET NRG(REG,COM)              'Energy carrier commodities'          //;

* process
  SET RP(R,P)                   'Processes in each region'               //;
  SET RP_FLO(R,P)               'Processes with VAR_FLOs (not IRE)'      //;
  SET RP_STD(R,P)               'Standard processes with VAR_FLOs'       //;
  SET RP_STG(R,P)               'Storage processes'                      //;
  SET RP_IRE(ALL_REG,P)         'Processes involved in inter-regional trade'//;
  SET RP_NRG(R,P)               'Processes with an energy carrier PCG'   //;
  SET RP_INOUT(R,P,IO)          'Indicator if process input/output normalized (according to PG side)'//;
  SET RP_PG(REG,PRC,CG)         'Primary commodity group (PG)'           //;
  SET RP_PGTYPE(R,P,CG)         'Group type of the primary group'        //;
  SET RP_UPL(R,P,L)             'Processes with dispatching equations'   //;
  SET RP_UPR(R,P,L)             'Processes with ramping costs'           //;
  SET RP_UPS(R,P,TSLVL,L)       'Timeslice levels for startup accounting'//;
  SET RP_UPT(R,P,UPT,BD)        'Start-up types for unit commitment'     //;
  SET RP_DPL(R,P,TSLVL)         'Dispatching process timeslice levels'   //;
  SET RP_AIRE(R,P,IE)           'Exchange process activity directions'   //;
  SET RPC(R,P,C)                'Commodities in/out of a processes'      //;
  SET RPC_CAPFLO(R,ALLYEAR,P,C) 'Commodities involved in capacity'       //;
  SET RPC_CONLY(R,ALLYEAR,P,C)  'Commodities ONLY involved in capacity'  //;
  SET RPC_NOFLO(R,P,C)          'Commodities ONLY involved in capacity'  //;
  SET RPC_IRE(ALL_REG,P,C,IE)   'Process/commodities involved in inter-regional trade'//;
  SET RPC_EQIRE(R,P,C,IE)       'Indicator for EQIRE equation generation'//;
  SET RPC_MARKET(R,P,C,IE)      'Market exchange process indicator'      //;
  SET RPC_PG(R,P,C)             'Commodities in the primary group'       //;
  SET RPC_SPG(R,P,C)            'Commodities in the shadow primary group'//;
  SET RPCS_VAR(R,P,C,ALL_TS)    'The timeslices at which VAR_FLOs are to be created'//;
  SET RPS_S1(R,P,ALL_TS)        'All timeslices at the PRC_TSL/COM_TSLspg'//;
  SET RPS_S2(R,P,ALL_TS)        'All timeslices at/above PRC_TSL/COM_TSLspg'//;
  SET RPS_PRCTS(R,P,ALL_TS)     'All timeslices at/above the PRC_TSL'    //;
  SET RTC(R,ALLYEAR,C)          'Commodity/time'                         //;
  SET RTC_SHED(R,YEAR,C,BD,J)   'Elastic shape indexes'                  //;
  SET RTCS_VARC(R,ALLYEAR,C,ALL_TS) 'The VAR_COMNET/PRDs control set'    //;
  SET RTP(R,ALLYEAR,P)          'Process/time'                           //;
  SET RTPC(R,ALLYEAR,P,C)       'Commodities of process in period'       //;
  SET RTP_CPTYR(R,ALLYEAR,ALLYEAR,P) 'Capcity transfer v/t years'        //;
  SET RTP_OFF(R,ALLYEAR,P)      'Periods for which VAR_NCAP.UP = 0'      //;
  SET RTPCS_VARF(ALL_REG,ALLYEAR,P,C,ALL_TS) 'The VAR_FLOs control set'  //;
  SET RTP_VARA(R,ALLYEAR,P)     'The VAR_ACT control set'                //;
  SET RTP_VARP(R,T,P)           'RTPs that have a VAR_CAP'               //;
  SET RTP_VINTYR(ALL_REG,ALLYEAR,ALLYEAR,PRC) 'v/t years when vintaging involved'//;
  SET RTP_TT(R,YEAR,T,PRC)      'Retrofit control periods'               //;
  SET RVP(R,ALLYEAR,P)          'ALIAS(RTP) for Process/time'            //;
  SET RTP_CAPYR(R,YEAR,YEAR,P)  'Capacity vintage years'                 //;
  SET RTP_CGC(REG,YEAR,P,CG,CG) 'Multi-purpose work set'                //;
  SET RTPS_BD(R,ALLYEAR,P,S,BD) 'Multi-purpose work set'                //;
  SET CG_GRP(REG,PRC,CG,CG)     'Multi-purpose work set'                //;
  SET FSCK(REG,PRC,CG,C,CG)     'Multi-purpose work set'                //;
  SET FSCKS(REG,PRC,CG,C,CG,S)  'Multi-purpose work set'                //;
  SET RPC_IREIO(R,P,C,IE,IO)    'Types of trade flows'                  //;
  SET RPC_LS(R,P,C)             'Load sifting control'                  //;
* process types
  SETS ELE(R,P)                 'Electric Power Plants'
       CHP(R,P)                 'Coupled Heat+Power Plants'
       HPL(R,P)                 'Heat and Steam Plants';

* region
  SET MREG(ALL_R)           'Set of active regions' //;
  SET RREG(ALL_REG,ALL_REG) 'Set of paired regions' //;

* cumulatives & UCs
  SET UC_ON(ALL_R,UC_N)                          'Active UCs by region' //;
  SET UC_GMAP_C(REG,UC_N,COM_VAR,COM,UC_GRPTYPE) 'Assigning commodities to UC_GRP';
  SET UC_GMAP_P(REG,UC_N,UC_GRPTYPE,PRC)         'Assigning processes to UC_GRP';
  SET UC_GMAP_U(ALL_R,UC_N,UC_N)                 'Assigning constraints to UC_GRP' //;
  SET UC_DYNBND(UC_N,LIM)                        'Dynamic process-wise UC bounds' //;
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
    EOHYEARS(ALLYEAR)        'Each year from 1st NCAP_PASTI-Y to last MILESTONYR' //;
  ALIAS(PASTYEAR,PYR);
  ALIAS(MODLYEAR,V);

* identifiers for beginning/end of model horizon
  SET MIYR_1(ALLYEAR) 'First T'   //;
  SET MIYR_L(ALLYEAR) 'Last year' //;

* miscellaneous
  SET IPS / IN, N /, LNX(L) / N, FX /;
  SET BDUPX(BD) / UP, FX /;
  SET BDLOX(BD) / LO, FX /;
  SET BDNEQ(BD) / LO, UP /;
  SET RP_PRC(R,P);
  SET RP_GRP(REG,PRC,CG);
  SET RP_CCG(REG,PRC,C,CG);
  SET RP_CGG(REG,PRC,C,CG,CG);
  SET TRACKC(R,C);
  SET TRACKP(R,P);
  SET TRACKPC(R,P,C);
  SET TRACKPG(R,P,CG);
  SET RVT(R,ALLYEAR,T);
  SET RTPX(R,T,P);
  SET RT_PP(R,T) //;
  PARAMETER NO_RT(ALL_R,T) //;

* ---------------------------------------------------------------------------------------------
* PARAMETERS SECTION
* ---------------------------------------------------------------------------------------------
* Years and splits of timeslices based upon level
  PARAMETER LEAD(ALLYEAR) //;
  PARAMETER LAGT(ALLYEAR) //;
  PARAMETER FPD(ALLYEAR)  //;
  PARAMETER IPD(ALLYEAR)  //;
  PARAMETER RS_FR(R,S,S)  //;
  PARAMETER JS_CCL(R,J,S) //;

* integrated parameters (created in PREPPM.mod)
  PARAMETER UC_COM(UC_N,COM_VAR,SIDE,REG,ALLYEAR,COM,S,UC_GRPTYPE) 'Multiplier of VAR_COM variables' //;
  PARAMETER COM_CUM(REG,COM_VAR,ALLYEAR,ALLYEAR,COM,LIM) 'Cumulative bound on commodity' //;

* derived coefficient components (created in COEF*.MOD)
  PARAMETER COEF_AF(R,ALLYEAR,T,PRC,S,BD)      'Capacity/Activity relationship'         //;
  PARAMETER COEF_CPT(R,ALLYEAR,T,PRC)          'Fraction of capacity available'         //;
  PARAMETER COEF_ICOM(R,ALLYEAR,T,PRC,C)       'Commodity flow at investment time'      //;
  PARAMETER COEF_OCOM(R,ALLYEAR,T,PRC,C)       'Commodity flow at decommissioning time' //;
  PARAMETER COEF_CIO(R,ALLYEAR,T,P,C,IO)       'Capacity-related commodity in/out flows'//;
  PARAMETER COEF_PTRAN(REG,ALLYEAR,PRC,CG,C,CG,S) 'Multiplier for EQ_PTRANS'            //;
  PARAMETER COEF_RPTI(R,ALLYEAR,P)             'Repeated investment cycles'             //;
  PARAMETER COEF_ILED(R,ALLYEAR,P)             'Investment lead time'                   //;
  PARAMETER COEF_PVT(R,T)                      'Present value of time in periods'       //;
  PARAMETER COEF_CAP(R,ALLYEAR,LL,P)           'Generic re-usable work parameter';
  PARAMETER COEF_RTP(R,ALLYEAR,P)              'Generic re-usable work parameter';
  PARAMETER COEF_RVPT(R,ALLYEAR,PRC,T)         'Generic re-usable work parameter';
  PARAMETER RTP_CPX(R,ALLYEAR,P,LL)            'Shape multipliers for capacity transfer'//;
  PARAMETER NCAP_AFBX(R,ALLYEAR,P,BD)          'Shape multipliers for NCAP_AF factors'  //;
  PARAMETER NCAP_AFSM(R,ALLYEAR,P) //;
  PARAMETER RVPRL(R,YEAR,P) //;

* OBJ function yearly values established in COEF_OBJ and used in OBJ_*
  PARAMETER OBJ_RFR(R,YEAR,CUR)            'Risk-free rates'          //;
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
  PARAMETER OBJ_COMNT(R,ALLYEAR,C,S,COSTYPE,CUR) 'CSTNET for each year'//;
  PARAMETER OBJ_COMPD(R,ALLYEAR,C,S,COSTYPE,CUR) 'CSTPRD for each year'//;
  PARAMETER OBJ_IPRIC(R,ALLYEAR,P,C,S,IE,CUR) 'IRE_PRICE for each year'//;

* Miscellanea
  PARAMETERS
    PRC_YMIN(REG,PRC)   'Generic process parameter' //
    PRC_YMAX(REG,PRC)   'Generic process parameter' //
    PRC_SC(REG,PRC)     'Process storage cycles'    //
    PRC_SGL(REG,PRC)    'Process shadow level (< DAYNITE)' //
    PRC_SEMI(R,P)       'Semi-continuous indicator' //
    RD_NLP(R,C)         'NLP demand indicator' //
    RD_SHAR(R,T,C,C)    'Demand aggregation share' //
    RP_AFB(REG,PRC,BD)  'Processes with NCAP_AF by bound type' //
    RS_STG(R,ALL_TS)    'Lead from previous storage timeslice'
    RS_UCS(R,S,SIDE)    'Lead for TS-dynamic UC'
    RS_STGPRD(R,ALL_TS) 'Number of storage periods for each timeslice'
    RS_STGAV(R,ALL_TS)  'Average residence time for storage activity'
    RS_TSLVL(R,ALL_TS)  'Timeslice levels'
    TS_ARRAY(ALL_TS)    'Array for leveling parameter values across timeslices'
    STOA(ALL_TS)        'ORD Lag from each timeslice to ANNUAL'
    STOAL(ALL_REG,TS)   'ORD Lag from the LVL of each timeslice to ANNUAL';


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

* flags used in extrapolation
  SET BACKWARD(ALLYEAR) //;
  SET FORWARD(ALLYEAR)  //;
* DM_YEAR is the union of the sets MODLYEAR and DATAYEAR
  SET DM_YEAR(ALLYEAR)  //;

*------------------------------------------------------------------------------
* Additional system declarations
*------------------------------------------------------------------------------
* Internal Sets:
  SETS
    PYR_S(ALLYEAR)       'Residual vintage' //
    MY_TS(ALL_TS)        'Temporary set for timeslices' //
    R_UC(ALL_R,UC_N)     'Temporary set for UCs by region' //
    UC_T(UC_N,T)         'Temporary set for UCs by period' //
    RXX(ALL_R,*,*)       'General triples related to a region'
    UNCD1(*)             'Non-domain-controlled set'
    UNCD7(*,*,*,*,*,*,*) 'Non-domain-controlled set of 7-tuples';
  ALIAS(LIFE,AGE);
  SET OPYEAR(AGE,LIFE) //;

*------------------------------------------------------------------------------
* Sets and parameters used in reduction algorithm
*------------------------------------------------------------------------------
  SET  NO_ACT(R,P)                    'Process not requiring activity variable'             //;
  SET  RP_PGACT(R,P)                  'Process with PCG consisting of 1 commodity'          //;
  SET  RP_PGFLO(R,P)                  'Process with PCG having COM_FR'                      //;
  SET  RPC_ACT(REG,PRC,CG)            'PG commodity of Process with PCG consisting of 1'    //;
  SET  RPC_AFLO(REG,PRC,CG)           'ACT_FLO residual groups to be handled specially'     //;
  SET  RPC_AIRE(ALL_REG,PRC,COM)      'Exchange process with only one commodity exchanged'  //;
  SET  RPC_EMIS(R,P,COM_GRP)          'Process with emission COM_GRP'                       //;
  SET  FS_EMIS(R,P,COM_GRP,C,COM)     'Indicator for emission related FLO_SUM'              //;
  SET  RC_IOP(R,C,IO,P)               'Processes associated with commodity'                 //;
  SET  RTCS_SING(R,T,C,S,IO)          'Commodity not being consumed'                        //;
  SET  RTPS_OFF(R,T,P,S)              'Process being turned off'                            //;
  SET  RTPCS_OUT(R,ALLYEAR,P,C,S)     'Process flows being turned off'                      //;
  SET  RPC_FFUNC(R,P,C)               'RPC_ACT Commodity in FFUNC'                          //;
  SET  RPCC_FFUNC(REG,PRC,CG,CG)      'Pair of FFUNC commodities with RPC_ACT commodity'    //;
  SET  PRC_CAP(REG,PRC)               'Process requiring capacity variable'                 //;
  SET  PRC_ACT(REG,PRC)               'Process requiring activity equation'                 //;
  SET  PRC_TS2(REG,PRC,TS)            'Alias for PRC_TS of processes with RPC_ACT'          //;
  SET  RPCG_PTRAN(R,P,COM,C,CG,CG)    'Set for FLO_FUNC/FLO_SUM based substitution'         //;
  SET  KEEP_FLOF(R,P,C)               'Set for FFUNC-defined flows retained';
  ALIAS(CG3,CG4,COM_GRP);

*------------------------------------------------------------------------------
* Parameters used in report routine
*------------------------------------------------------------------------------
* Label lengths exceeding default
$SETGLOBAL RL 'R.TL:MAX(12,R.LEN)' SETGLOBAL PL 'P.TL:MAX(12,P.LEN)' SETGLOBAL CL C.TL:MAX(12,C.LEN)
$IFI NOT %G2X6%==YES $SETGLOBAL RL 'R.TL:MAX(12,CARD(R.TL))' SETGLOBAL PL 'P.TL:MAX(12,CARD(P.TL))' SETGLOBAL CL C.TL:MAX(12,CARD(C.TL))

  PARAMETERS
   PAR_FLO(R,ALLYEAR,ALLYEAR,P,C,S)          'Flow parameter'                                    //
   PAR_FLOM(R,ALLYEAR,ALLYEAR,P,C,S)         'Reduced cost of flow variable'                     //
   PAR_IRE(R,ALLYEAR,ALLYEAR,P,C,S,IMPEXP)   'Parameter for im/export flow'                      //
   PAR_IREM(R,ALLYEAR,ALLYEAR,P,C,S,IMPEXP)  'Reduced cost of import/export flow'                //
   PAR_OBJINV(R,ALLYEAR,ALLYEAR,P,CUR)       'Annual discounted investment costs'                //
   PAR_OBJDEC(R,ALLYEAR,ALLYEAR,P,CUR)       'Annual discounted decommissioning costs'           //
   PAR_OBJFIX(R,ALLYEAR,ALLYEAR,P,CUR)       'Annual discounted FOM cost'                        //
   PAR_OBJSAL(R,ALLYEAR,P,CUR)               'Annual discounted salvage value'                   //
   PAR_OBJLAT(R,ALLYEAR,P,CUR)               'Annual discounted late costs'                      //
   PAR_OBJACT(R,ALLYEAR,ALLYEAR,P,TS,CUR)    'Annual discounted variable costs'                  //
   PAR_OBJFLO(R,ALLYEAR,ALLYEAR,P,C,TS,CUR)  'Annual discounted flow costs (incl import/export)' //
   PAR_OBJCOM(R,ALLYEAR,COM,TS,CUR)          'Annual discounted commodity costs '                //
   PAR_OBJBLE(R,ALLYEAR,COM,CUR)             'Annual discounted blending costs'                  //
   PAR_OBJELS(R,ALLYEAR,COM,CUR)             'Annual discounted elastic demand cost term'        //;


*----------------------------------------------------------------------------------------------
* GLOBALS SECTION - Safe Set of TIMES Critical Global control variables
*----------------------------------------------------------------------------------------------
$SETGLOBAL TIMESED 0
$SET ControlAbort "Abort Internal Control variable being set by user, aborted"
$LABEL RESET
$IF NOT '%X2%'=='' $EXIT
*-------------------------------------------------------------------------
* Normal Tags for standard TIMES (changed under stochastic mode)
$SETGLOBAL SW_NOTAGS %X1%
$IF NOT %SW_NOTAGS%=="%X1%" $%ControlAbort%: SW_NOTAGS
$IF "%X1%"==''
$SETGLOBAL SW_NOTAGS SET EQ 'EQ' SET VAR 'VAR' SET SWS '' SET SOW '' SET SWT '' SET SWD '' SET SWTD '' SET SWSW '' SET VART 'VAR' SET VARV 'VAR' SET VARM 'VAR' SET VARTT VAR

* Helper for process tranformation shape controls
$SETGLOBAL SHFF '%X1%' SETGLOBAL RCAPSUB '%X1%' SETGLOBAL RCAPSBM %X1%
$IF NOT "%SHFF%%RCAPSUB%%RCAPSBM%"=='%X1%%X1%%X1%' $%ControlAbort%: SHFF / RCAPSUB
$SETGLOBAL SHFF 1+RTP_FFC

* Additional tags for stochastic
$SETGLOBAL MX '%X1%' SETGLOBAL SCUM '%X1%' SETGLOBAL SW_STVARS %X1%
$IF NOT "%MX%%SCUM%%SW_STVARS%"=='%X1%%X1%%X1%' $%ControlAbort%: MX / SW_STVARS / SCUM

* Objective function variants
$SETGLOBAL CAPJD '%X1%' SETGLOBAL CAPWD %X1%
$IF NOT '%CAPJD%%CAPWD%'=='%X1%%X1%' $%ControlAbort%: CAPxD
*
$SETGLOBAL SWX '%X1%' SETGLOBAL SWTX %X1%
$IF NOT "%SWX%%SWTX%"=='%X1%%X1%' $%ControlAbort%: SWX
$SETGLOBAL SWX ,'1'
*
$SET TMP '%CTST%' SETGLOBAL CTST %X1%
$IF NOT "%CTST%"=='%X1%' $%ControlAbort%: CTST
$SETGLOBAL CTST %TMP%
*
* Tags for stochastic TIMES (set in stages.stc)
$SETGLOBAL SW_TAGS %X1%
$IF NOT "%SW_TAGS%"=='%X1%' $%ControlAbort%: SW_TAGS
$IF NOT '%X1%'=='' $SETLOCAL X1 '' GOTO RESET
*-------------------------------------------------------------------------
