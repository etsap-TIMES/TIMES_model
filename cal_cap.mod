*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* CAL_CAP the code for capacity dependent commodity flows in EQ_COMxxx
*   %1 - IN/OUT indicator
*   %2 - I/O indicator
*   %3 - cost expression for EQOBJVAR
*=============================================================================*
*GaG Questions/Comments:
*  - COEF_CPT derived in COEF_CPT.MOD
*-----------------------------------------------------------------------------
*$ONLISTING
         SUM(RTP_CPTYR(R,V,T,P)$NCAP_COM(R,V,P,C,'%1'),
*V05b 980902 - need to apply seasonal fraction
             COEF_CPT(R,V,T,P) * NCAP_COM(R,V,P,C,'%1') * G_YRFR(R,S) *
             %3
             (%VARV%_NCAP%4(R,V,P %SWS%)$T(V) + NCAP_PASTI(R,V,P)$PASTYEAR(V) %RCAPSUB%) *
* Adjust for lagged commodity flows
             (1 + COEF_CIO(R,V,T,P,C,'%1'))
         ) +
* CAL_NCOM: the term associated with invest/decommission commodities in the EQ_COMxxx
         SUM(RPC_CAPFLO(R,V,P,C)$COEF_%2COM(R,V,T,P,C), COEF_%2COM(R,V,T,P,C) *
             %3
             G_YRFR(R,S) * (%VARV%_NCAP%4(R,V,P %SWS%)$T(V)
$ IF '%2'=='O'            + NCAP_PASTI(R,V,P)$PASTYEAR(V)
             )
         )
*$OFFLISTING