*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* UC_IRE the code associated with the IRE variable in the EQ_USERCON
*     - %1 region summation index
*     - %2 period summation index
*     - %3 time-slice summation index
*     - %4 'T' or 'T+1' index
*     - %5 'LHS' or 'RHS'
*=============================================================================*
*UR Questions/Comments:
*  -
*-----------------------------------------------------------------------------

*"SUM(UC_R_SUM(R,UC_N)," or bracket "("
 %1
*     "SUM(UC_T_SUM(R,UC_N,T)," or bracket "("
      %2
$IF %6==2 (1+(FPD(T)+(COEF_PVT(R,T)-FPD(T))$UC_ATTR(R,UC_N,'LHS','IRE','PERDISC')-1)$UC_DT(R,UC_N)) *
*          "SUM(UC_TS_SUM(R,UC_N,S)," or bracket "("
           %3
*[UR]: RPC_IRE comtrol may be redundant, only necessary if UC_IRE givrn for non-exchange processes by mistake
                 SUM((RTP_VINTYR(R,V,%4,P),UC_MAP_IRE(UC_N,R,P,C,IE),RTPCS_VARF(R,%4,P,C,TS))$RS_FR(R,S,TS),
                     (

* [UR] model reduction %REDUCE% is set in *.run
                             (%VAR%_IRE(R,V,%4,P,C,TS,IE %SOW%)$(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,%4,P,TS %SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C))
                             * UC_IRE(UC_N,%5,R,%7,P,C,TS,IE) *
*GG* use the derived multipier
* [AL] PROD operator is useful here, but must be activated due to a GAMS bug:
                               PROD(ANNUAL,1)*PROD(RS_BELOW(R,TS,S),RS_FR(R,S,TS)*(1+RTCS_FR(R,%4,C,S,TS))) *

$IF %6==1                      PROD(UC_ATTR(R,UC_N,%5,'IRE','GROWTH'),
$IF %6==1                           POWER(ABS(UC_IRE(UC_N,%5,R,%7,P,C,TS,IE)),%8*UC_SIGN(%5)-1)) *
$IF %6==S                      (1/G_YRFR(R,S)) *
                               PROD(UC_ATTR(R,UC_N,%5,'IRE',UC_PERDS),FPD(%4) *
                                    PROD(UC_NEWFLO(UC_PERDS),1$(SAMEAS(V,%4)+RVPT(R,V,P,%4))/FPD(%4))) *

                               PROD(REG(R)$SUM(UC_ATTR(R,UC_N,%5,'IRE',UC_COST),1),
                                SUM((RDCUR(R,CUR),TS_ANN(TS,SL)),
                                  OBJ_FCOST(R,%4,P,C,SL,CUR)$UC_ATTR(R,UC_N,%5,'IRE','COST') 
                                 +OBJ_FDELV(R,%4,P,C,SL,CUR)$UC_ATTR(R,UC_N,%5,'IRE','DELIV') 
                                 +MIN(0,OBJ_FTAX(R,%4,P,C,SL,CUR))$UC_ATTR(R,UC_N,%5,'IRE','SUB')
                                 +MAX(0,OBJ_FTAX(R,%4,P,C,SL,CUR))$UC_ATTR(R,UC_N,%5,'IRE','TAX')))
                     )
                    )

*          closing bracket of %3 :
           )

*       closing bracket of %2 :
        )

*   closing bracket of %1 :
    )

