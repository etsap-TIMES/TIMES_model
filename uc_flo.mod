*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* UC_FLO the code associated with the flow variable in the EQ_USERCON
*     - %1 region summation index
*     - %2 period summation index
*     - %3 time-slice summation index
*     - %4 'T' or 'T+1' index
*     - %5 'LHS' or 'RHS'
*     - %6 Type of constraint (0=EACH, 1=SUCC or 2=SEVERAL)
*=============================================================================*
*UR Questions/Comments:
*  -
*-----------------------------------------------------------------------------
$IF %6==1 $SET VAR '%9' SET SOW %10
*"SUM(UC_R_SUM(R,UC_N)," or bracket "("
 %1
*     "SUM(UC_T_SUM(R,UC_N,T)," or bracket "("
      %2
$IF %6==2  (1+(FPD(T)+(COEF_PVT(R,T)-FPD(T))$UC_ATTR(R,UC_N,'LHS','FLO','PERDISC')-1)$UC_DT(R,UC_N)) *
$IF %6==S  (1/G_YRFR(R,S)) *
*          "SUM(UC_TS_SUM(R,UC_N,S)," or bracket "("
           %3
                 SUM((RTP_VINTYR(R,V,%4,P),UC_MAP_FLO(UC_N,%5,R,P,C),RTPCS_VARF(R,%4,P,C,TS))$RS_FR(R,S,TS),
                          %11(%12
*V0.9a S reference should be TS
* [UR] model reduction %REDUCE% is set in *.run
$                               BATINCLUDE %cal_red% C COM TS P %4
                              * UC_FLO(UC_N,%5,R,%7,P,C,TS) *
*GG* use the derived multipier
* [AL] PROD operator is useful here, but must be activated due to a GAMS bug:
                               PROD(ANNUAL,1)*PROD(RS_BELOW(R,TS,S),RS_FR(R,S,TS)*(1+RTCS_FR(R,%4,C,S,TS))) *

$IF %6==1                      PROD(UC_ATTR(R,UC_N,%5,'FLO','GROWTH'),
$IF %6==1                           POWER(ABS(UC_FLO(UC_N,%5,R,%7,P,C,TS)),%8*UC_SIGN(%5)-1)) *
                               PROD(UC_ATTR(R,UC_N,%5,'FLO',UC_PERDS),FPD(%4) *
                                    PROD(UC_NEWFLO(UC_PERDS),1$(SAMEAS(V,%4)+RVPT(R,V,P,%4))/FPD(%4))) *

                               PROD(REG(R)$SUM(UC_ATTR(R,UC_N,%5,'FLO',UC_COST),1),
                                SUM((RDCUR(R,CUR),TS_ANN(TS,SL)),
                                  OBJ_FCOST(R,%4,P,C,SL,CUR)$UC_ATTR(R,UC_N,%5,'FLO','COST')
                                 +OBJ_FDELV(R,%4,P,C,SL,CUR)$UC_ATTR(R,UC_N,%5,'FLO','DELIV')
                                 +MIN(0,OBJ_FTAX(R,%4,P,C,SL,CUR))$UC_ATTR(R,UC_N,%5,'FLO','SUB')
                                 +MAX(0,OBJ_FTAX(R,%4,P,C,SL,CUR))$UC_ATTR(R,UC_N,%5,'FLO','TAX')))
                             )
                    ) +

                 SUM(UC_CAPFLO(UC_N,%5,R,P,C),
$                    BATINCLUDE cal_caps.mod %4 "UC_FLO(UC_N,%5,R,%7,P,C,TS)" TS
                      *
$IF %6==1            PROD(UC_ATTR(R,UC_N,%5,'FLO','GROWTH'),
$IF %6==1              SUM(RPCS_VAR(R,P,C,TS),RS_FR(R,TS,S)*POWER(ABS(UC_FLO(UC_N,%5,R,%7,P,C,TS)),%8*UC_SIGN(%5)-1))) *
                     PROD(UC_ATTR(R,UC_N,%5,'FLO',UC_PERDS),FPD(%4)$(NOT UC_NEWFLO(UC_PERDS))) *

                     PROD(REG(R)$SUM(UC_ATTR(R,UC_N,%5,'FLO',UC_COST),1),
                      SUM(RPCS_VAR(R,P,C,TS),RS_FR(R,TS,S) *
                       SUM((RDCUR(R,CUR),TS_ANN(TS,SL)),
                         OBJ_FCOST(R,%4,P,C,SL,CUR)$UC_ATTR(R,UC_N,%5,'FLO','COST')
                        +OBJ_FDELV(R,%4,P,C,SL,CUR)$UC_ATTR(R,UC_N,%5,'FLO','DELIV')
                        +MIN(0,OBJ_FTAX(R,%4,P,C,SL,CUR))$UC_ATTR(R,UC_N,%5,'FLO','SUB')
                        +MAX(0,OBJ_FTAX(R,%4,P,C,SL,CUR))$UC_ATTR(R,UC_N,%5,'FLO','TAX'))))
                    )


*          closing bracket of %3 :
           )

*       closing bracket of %2 :
        )

*   closing bracket of %1 :
    )

* Add Cumflos
$IF %6==2  +SUM((%8RPC_CUMFLO(R,P,C,ALLYEAR,LL))$UC_CUMFLO(UC_N,R,P,C,ALLYEAR,LL),UC_CUMFLO(UC_N,R,P,C,ALLYEAR,LL)*%VAR%_CUMFLO(R,P,C,ALLYEAR,LL %SWT%)*%CUFSCAL%)
