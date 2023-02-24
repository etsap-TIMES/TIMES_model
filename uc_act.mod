*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* UC_ACT the code associated with the activity variable in the EQ_USERCON
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

*"SUM(UC_R_SUM(R,UC_N)," or bracket "("
 %1
*     "SUM(UC_T_SUM(UC_N,T)," or bracket "("
      %2
$IF %6==2 (1+(FPD(T)+(COEF_PVT(R,T)-FPD(T))$UC_ATTR(R,UC_N,'LHS','ACT','PERDISC')-1)$UC_DT(R,UC_N)) *
*          "SUM(UC_TS_SUM(UC_N,S)," or bracket "("
           %3
              SUM(RTP_VINTYR(R,V,%4,P)$UC_GMAP_P(R,UC_N,'ACT',P),
                          (
*V0.9a S reference should be TS
                           SUM(PRC_TS(R,P,TS)$(RS_FR(R,S,TS)*RTP_VARA(R,%4,P)),
                               %VAR%_ACT(R,V,%4,P,TS %SOW%)*UC_ACT(UC_N,%5,R,%7,P,TS)*

* [AL] PROD operator is useful here:
                               PROD(ANNUAL,RS_FR(R,S,TS)) *

$IF %6==1                      PROD(UC_ATTR(R,UC_N,%5,'ACT','GROWTH'),
$IF %6==1                        POWER(ABS(UC_ACT(UC_N,%5,R,%7,P,TS)),%8*UC_SIGN(%5)-1)) *
$IF %6==S                      (1/G_YRFR(R,S)) *
                               PROD(UC_ATTR(R,UC_N,%5,'ACT',UC_PERDS),FPD(%4) *
                                 PROD(UC_NEWFLO(UC_PERDS),1$(SAMEAS(V,%4)+RVPT(R,V,P,%4))/FPD(%4)))

                           )
                          )
                            *
                          PROD(UC_ATTR(R,UC_N,%5,'ACT','COST'),SUM(RDCUR(R,CUR),OBJ_ACOST(R,%4,P,CUR)))
              )
*          closing bracket of %3 :
           )

*       closing bracket of %2 :
        )

*   closing bracket of %1 :
    )

