*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQCPT.MOD capacity transfer equation
*  - %1 = equation type when VALIDATE
*  - %2 = equation name adj (L) when VALIDATE (for DMDs in MARKAL)
*  - %3 = control qualifier
*  - %4 = RHS constant or VAR_CAP
*=============================================================================*
*GaG Questions/Comments:
*  - COEF_CPT established in COEF_CPT.MOD
*-----------------------------------------------------------------------------
*GG*V0.6a_3+ check whether used in UserConstraint
*$onlisting

  %EQ%%2_CPT(RTP(R,T,P) %SWT%)$(%3) ..

*  VAR_CAP(r,t,p %sow%) or CAP_BND(r,t,p,bd):
       %4

  =%1=

      SUM(V$COEF_CPT(R,V,T,P), COEF_CPT(R,V,T,P) *
          (%VARV%_NCAP(R,V,P %SWS%)$MILESTONYR(V) + NCAP_PASTI(R,V,P)$PASTYEAR(V)%RCAPSUB%))
  ;
*$offlisting
