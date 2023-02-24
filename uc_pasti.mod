*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* UC_PASTI code associated with first period capacity in GROWTH constraint
*     - %1 region summation index
*     - %2 period summation index (MIYR_1)
*     - %3 T index
*     - %4 'LHS' or 'RHS'
*=============================================================================*
*AL Questions/Comments:
*  - Possible bound attributes are for now ignored for PASTI
*-----------------------------------------------------------------------------
*"SUM(UC_R_SUM(R,UC_N)," or bracket "("
 %1

*[AL] Sum over RTP that have UC_CAP specified on current side
        SUM(RTP(R,%3,P)$UC_GMAP_P(R,UC_N,'CAP',P),

* Sum of PASTI inherited to first period is used as a capacity value for T-1 of MIYR_1(T)
* UC_CAP coefficient is taken from MIYR_1, because UC_CAP is interpolated on T only
            SUM(RTP_CPTYR(R,PASTYEAR,%3,P),COEF_CPT(R,PASTYEAR,%3,P)*NCAP_PASTI(R,PASTYEAR,P)) *
                UC_CAP(UC_N,%4,R,%3,P) *
* [AL] PROD operator is useful here, but needs to be 'initialized' due to a GAMS bug:
                PROD(SIDE(%4),PROD(UC_ATTR(R,UC_N,SIDE,'CAP','GROWTH'),
                     POWER(ABS(UC_CAP(UC_N,%4,R,%3,P)),M(%3)-B(%3))))

         )

*   closing bracket of %1 :
    )$SUM(%2(%3),1)

