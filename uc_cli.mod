*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* UC_CLI the UC code associated with climate variables
*     - %1 region summation index
*     - %2 period summation index
*     - %3 time-slice summation index
*     - %4 'T' or 'T+1' index
*     - %5 'LHS' or 'RHS'
*     - %6 Type of constraint (0=EACH, 1=SUCC or 2=SEVERAL)
*=============================================================================*
*[AL] Questions/Comments:
*  -
*-----------------------------------------------------------------------------
$IF NOT DEFINED UC_CLI $EXIT
* "SUM(UC_R_SUM(R,UC_N)," or bracket (
+ %1
*     "SUM(UC_T_SUM(UC_N,T)," or bracket (
      %2
*         "SUM(UC_TS_SUM(UC_N,S)," or bracket (
          %3
              SUM(CM_VAR$UC_CLI(UC_N,%5,R,%7,CM_VAR), UC_CLI(UC_N,%5,R,%7,CM_VAR) *
                (%VAR%_CLITOT(CM_VAR,%4 %SOW%)$CM_KIND(CM_VAR) +
                 SUM(CM_BOXMAP(CM_KIND,CM_VAR,CM_BOX),%VAR%_CLIBOX(CM_VAR,%4 %SOW%))) *

* [AL] PROD operator is useful here, but requires 'initialization' due to GAMS bug
                      PROD(ANNUAL,1) *
$IF %6==1             PROD(UC_ATTR(R,UC_N,%5,'CLI','GROWTH'),
$IF %6==1                  POWER(ABS(UC_CLI(UC_N,%5,R,%7,CM_VAR)),%8*UC_SIGN(%5)-1)) *
                      PROD(UC_ATTR(R,UC_N,%5,'CLI','PERIOD'),FPD(%4))
              )

*          closing bracket of %3 :
           )

*       closing bracket of %2 :
       )

*   closing bracket of %1 :
   )

