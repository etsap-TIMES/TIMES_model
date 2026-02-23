*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2026 Energy Technology Systems Analysis Programme (ETSAP)
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
*V05b - need to apply seasonal fraction
             COEF_CPT(R,V,T,P) * NCAP_COM(R,V,P,C,'%1') * G_YRFR(R,S) * %3
             (%VARV%_NCAP%4(R,V,P%SWS%)$T(V) + NCAP_PASTI(R,V,P)$PYR(V) %RCAPSUB%) *
* Adjust for lagged commodity flows
             (1 + COEF_CIO(R,V,T,P,C,'%1'))
         ) +
* CAL_NCOM: the term associated with invest/decommission commodities in EQ(l)_COMxxx
         SUM(RPC_CAPFLO(R,V(LL),P,C)$COEF_%2COM(R,V,T,P,C), G_YRFR(R,S) * %3
	     (COEF_%2COM(R,V,T,P,C)*(%VARV%_NCAP%4(R,V,P%SWS%)$T(V)+NCAP_PASTI(R,V,P)$PYR(V)) +
	      SUM(VNTRT(V,T),COEF_%2COM(R,V,T,P,C)*SUM(TT(LL+MIN(VN2T(V,T),RVPRL(R,V,P))),-%VARTT%_SCAP%4(R,V,TT,P%SWS%)) +
	          %VART%_RCAP%4(R,V,T,P%SWS%)*COEF_RCOM(R,V,T,P,C))$((IPS('%1')->0)$RCAP_OCAP(R,V,P,C)))
         )
*$OFFLISTING
