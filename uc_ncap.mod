*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* UC_NCAP the code associated with the flow variable in the EQ_USERCON
*     - %1 region summation index
*     - %2 period summation index
*     - %3 'T' or 'T+1' index
*     - %4 'LHS' or 'RHS'
*     - %5 Type of constraint (0=EACH, 1=SUCC or 2=SEVERAL)
*=============================================================================*
*UR Questions/Comments:
*  -
*-----------------------------------------------------------------------------
*"SUM(UC_R_SUM(R,UC_N)," or bracket "("
 %1

* UR 05/15/00
*    SUM(UC_GRP$( UC_GMAP(R,UC_N,'NCAP',UC_GRP)*%4   ),

*       "SUM(UC_T_SUM(UC_N,T)," or bracket "("
        %2
* [AL] VAR_NCAP(R,%3,P) can be active even if there is no RTP_CPTYR(R,V,T,P) (due to ILED)!
* [AL] Therefore, changed to check for RTP(R,%3,P) without RTP_OFF(R,%3,P)
*              SUM((P,CUR)$(UC_GMAP_P(R,UC_N,'NCAP',P)*SUM(V,RTP_CPTYR(R,V,T,P))),
              SUM(UC_GMAP_P(R,UC_N,'NCAP',P)$RTP(R,%3,P), UC_NCAP(UC_N,%4,R,%6,P) *
                  (%VAR%_NCAP(R,%3,P %SOW%)$(NOT RTP_OFF(R,%3,P)) +
                   (SUM(RVPT(R,V,P,%3),%VARV%_NCAP(R,V,P %SWS%)) + %VAR%_NCAP(R,%3,P %SOW%) *
                    (COEF_RPTI(R,%3,P)-PROD(RVPT(R,%3,P,MILESTONYR),2)))$UC_ATTR(R,UC_N,%4,'NCAP','PERIOD')) *

* [AL] PROD operator is useful here, but needs to be 'tweaked' due to a bug in GAMS 21.3-21.4:
$IF %5==1         PROD(UC_ATTR(R,UC_N,%4,'NCAP','GROWTH'),
$IF %5==1              POWER(ABS(UC_NCAP(UC_N,%4,R,%6,P)),%7*UC_SIGN(%4)-1)) *
                  PROD(UC_ATTR(R,UC_N,%4,'NCAP','BUILDUP'),1/LEAD(%3)) *

                  PROD(L('N'),PROD(REG(R)$SUM(UC_ATTR(R,UC_N,%4,'NCAP',UC_COST),1),
                    SUM(RDCUR(R,CUR),
$IF NOT %3==%6         SUM(UC_ATTR(R,UC_N,%4,'NCAP',UC_ANNUL),CST_ANNC(R,%3,P,%6,UC_ANNUL,CUR))+
                       OBJ_ICOST(R,%3,P,CUR)$UC_ATTR(R,UC_N,%4,'NCAP','COST')
                       +OBJ_ITAX(R,%3,P,CUR)$UC_ATTR(R,UC_N,%4,'NCAP','TAX')
                       -OBJ_ISUB(R,%3,P,CUR)$UC_ATTR(R,UC_N,%4,'NCAP','SUB'))))

              )

*       closing bracket of %2 :
        )

*   closing bracket of %1	:
    )

