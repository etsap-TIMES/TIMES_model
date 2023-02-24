$TITLE  TIMES -- VERSION 4.7.0
*==========================================================================================*
* INITSYS.MOD has all the fixed system declarations for ETSAP TIMES                        *
*==========================================================================================*
$ onlisting ontext
*===========================================================================================
*  Copyright (C) 2000-2023 IEA Energy Technology Systems Analysis Programme (IEA-ETSAP).
*  This software (ETSAP TIMES) is open source: you can redistribute it and/or modify it
*  under the terms of the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*  For further information, visit: <https://www.gnu.org/licenses/gpl-3.0.html>.
*
*  This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
*  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*===========================================================================================
$ offtext
$ offlisting
$ SET TMP Restart
$ IF %SYSTEM.LICENSELEVEL%==2 $SET TMP Runtime
$ IF SET RunTimes $TITLE %SYSTEM.TITLE% -- %TMP% (v%RunTimes%)
$ PHANTOM EMPTY
$ ONEMPTY
$ ONMULTI
* TIME - SET ALL_TS ordering is crucial, since the order of time-slices within a TSLVL is used in EQ_STGTSS.
*        Therefore, declare ALL_TS first, before the call to INITSYS.MOD.  Example:
*
*        SET ALL_TS 'Time-slices '
*         / ANNUAL  'Annual      '
*           I       'Intermediate'
*           S       'Summer      '
*           W       'Winter      '
*         / ;

  ALIAS(*,ITEM);
* Defaults for the some total spans available in the model:
$IF NOT SET BOTIME $SETGLOBAL BOTIME 1850
$IF NOT SET EOTIME $SETGLOBAL EOTIME 2200
$IF NOT %SHELL%==ANSWER
$IF SET MAXSOW SET ITEM /BOH, 1*%EOTIME%/;

  SET BOHYEAR                        'BOH + years'                  / BOH, %BOTIME%*%EOTIME% /
  SET ALLYEAR                        'All Years'                    / %BOTIME%*%EOTIME% /
  PARAMETER YEARVAL(ALLYEAR)         'Value of each year';
            YEARVAL(ALLYEAR) = %BOTIME% + ORD(ALLYEAR)-1;
  SET EOHYEAR                        "'BOH/EOH' + years"            / SET.BOHYEAR, EOH /
  Parameter BEOH(*)                  'BOH / EOH offset'             / BOH +1, EOH -1 /;
  SET PERIODYR(ALLYEAR,ALLYEAR)      'All years in each period'     //;
  SET ALL_TS                         'The universe for time-slices' / ANNUAL /
  SET ANNUAL(ALL_TS)                 'Annual identifier'            / ANNUAL /
  SET TSLVL                          'Timeslice levels'             / ANNUAL, SEASON, WEEKLY, DAYNITE /;
  PARAMETER TSLVLNUM(TSLVL)          'Timeslice level values'
          / ANNUAL  1
            SEASON  2
            WEEKLY  3
            DAYNITE 4 /;
*  SET SEASON(REG,ALL_TS)             'Seasons'                     //;
*  SET WEEK(REG,ALL_TS)               'Week Sub-divisions '         //;
*  SET DAYNITE(REG,ALL_TS)            'Daily Sub-divisions'         //;

  ALIAS(ALLYEAR,YEAR,LL);

* topology
  SET IMPEXP       'Imports/Exports'                                / IMP, EXP /
  SET IMP          'Imports'                                        / IMP /
  SET XPT          'Exports'                                        / EXP /
  SET IN_OUT       'Input/Output'                                   / IN, OUT /
  ALIAS(IMPEXP,IE);
  ALIAS(IN_OUT,IO);

* limits
  SET LIM           'Limit Types'                                   / LO, FX, UP, N /
  SET BND_TYPE(LIM) 'Bound Types'                                   / LO, FX, UP /
  ALIAS(LIM,L,LIM_TYPE);
  ALIAS(BND_TYPE,BD);

* Start-up types
  SET UPT          'Start-up types'                                 / COLD, WARM, HOT /

* Numbered sets
  SET ALLYEAR                                                       / 0 /;
  SET AGE          'Age for SHAPEing'                               / 1*200 /
  SET J            'Supply/demand steps 1*COM_STEP and SHAPE/MULTI' / 1*999 /
  ALIAS(J,JJ);

* Master Set declarations
  SET ALL_REG(*)   'External + Internal Regions'                    //
  SET REG(ALL_REG) 'Region'                                         //
  ALIAS(ALL_REG,ALL_R);
  ALIAS(REG,R);

  SET COM_GRP      'Commodities & Groups'
    / DEM          'Demands',
      NRG          'Energy',
      MAT          'Material',
      ENV          'Environmental Indicators',
      FIN          'Financial' /;
  ALIAS(COM_GRP,CG,CG1,CG2);

  SET COM(COM_GRP) 'Commodities'                                    //
  ALIAS(COM,C,COM1,COM2);

  SET PRC(*)       'Processes'                                      //
  ALIAS(PRC,P);
  SET CUR(*)       'Currencies = c$'                                //
  ALIAS(CUR,CURR);

* Stochastics
$ SETGLOBAL MAXSOW 96
  SET ALLSOW       'State-of-the-World'                             / 1*%MAXSOW% /
  SET SOW(ALLSOW)  'State-of-the-World'                             //
  ALIAS(SOW,W);

*-------------------------------------------------------------------------------
* UC facility - fixed sets and controls for user-constraints
*-------------------------------------------------------------------------------
  SET SIDE                 'LHS and RHS of an equation'        / LHS, RHS /
  PARAMETER UC_SIGN(SIDE)  'Sign of LHS and RHS expression'    / LHS 1, RHS -1 /;
  SETS COM_VAR / NET, PRD /, COV_MAP / NET.COMNET, PRD.COMPRD /;

* List of parameters that can be used in user-constraints
  SET UC_NAME   'Allowed parameters in user-constraints'
    / COST, DELIV, TAX, SUB
      EFF, NET, N
      GROWTH, PERIOD, PERDISC, BUILDUP
      CUMSUM, CUM+, SYNC, YES
      CAPACT, CAPFLO, NEWFLO, ONLINE
      ANNUL, INVCOST, INVTAX, INVSUB
      FLO_COST, FLO_DELIV, FLO_SUB, FLO_TAX
      NCAP_COST, NCAP_ITAX, NCAP_ISUB
    /;

  SET UC_COST(UC_NAME) 'UC cost attributes'
    / COST, DELIV, TAX, SUB, ANNUL /;

  SET UC_MAPCOST(UC_COST,UC_NAME) 'Compatibility map for cost attributes'
    / COST.(FLO_COST,NCAP_COST)
      DELIV.FLO_DELIV
      ANNUL.(INVCOST,INVTAX,INVSUB)
      TAX.(FLO_TAX,NCAP_ITAX)
      SUB.(FLO_SUB,NCAP_ISUB) /;

  SET UC_ANNUL(UC_NAME) / INVCOST, INVTAX, INVSUB /;
  SET UC_DYNT(UC_NAME) / N, CUMSUM, CUM+, SYNC /;

  SET UC_NUMBER 'Determines way of handling of REG,T and TS'
    / SEVERAL, SUCC, EACH /;

  SET UC_PERDS(UC_NAME) / PERIOD, NEWFLO /;
  SET UC_NEWFLO(UC_NAME) / NEWFLO /;

  SET UC_GRPTYPE 'Type of components within UC_GRP'
    / ACT, FLO, IRE, CAP, NCAP, COMNET, COMPRD, COMCON, UCN /;

  SET COSTAGG 'Types of cost aggregations'
    / INV, INVTAX, INVSUB, FOM, FOMTAX, FOMSUB, COMTAX, COMSUB, FLOTAX, FLOSUB,
      INVTAXSUB, INVALL, FOMTAXSUB, FOMALL, FIX, FIXTAX, FIXSUB, FIXTAXSUB, FIXALL,
      COMTAXSUB, FLOTAXSUB, ALLTAX, ALLSUB, ALLTAXSUB /;
  ALIAS (COSTAGG,COSTCAT)
  ALIAS (UC_COST,COSTYPE)
*-------------------------------------------------------------------------------
* control sets
*  - expected in *.RUN file
*  - throw switch other way in *.RUN to change
*-------------------------------------------------------------------------------
* user should provide name in *.RUN
$ SET MODEL_NAME    TIMES
$ SET RUN_NAME      TEST
* control of whether all 0 lines are dumped in *.PUT files; user provides 0 to NOT print lines with all 0s (or empty)
  SCALAR DUMP0 /1/, OPTFILEID /1/;
* user set to 'YES' to activate
$ SET DEBUG          NO
$ SET DUMPSOL        NO
$ SET SOLANS         NO
* user set to 'NO' to not abort when error condition fails
$ SET ERR_ABORT      YES
* user sets to 'WWW' to activate
$ SET GAMS_CGI       NO
* user sets to 'NO' if only want to compile
$ SET SOLVE_NOW      YES

* get list of default units
$ BATINCLUDE units.def

* get list of default mapping group lists
$ BATINCLUDE maplists.def

* get defalut global scalars and parameters
$ BATINCLUDE globals.def
