*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* CAL_CAPS the code for capacity dependent commodity flows regardless of IO
*   %1 - Milestone year
*   %2 - coefficient expression for EQOBJVAR / UC_FLO
*   %3 - TS control index for RPCS_VAR summing
*=============================================================================*
* Questions/Comments:
*  - COEF_CPT derived in COEF_CPT.MOD
*-----------------------------------------------------------------------------
*$ONLISTING
*V05c 980923 - use the capacity flow control set
   SUM((VNT(V,%1),RPC_CAPFLO(R,V,P,C)),
*V05b 980902 - need to apply seasonal fraction
* Flows related to investment / decommissioning
      ((COEF_ICOM(R,V,%1,P,C)+COEF_OCOM(R,V,%1,P,C)) * G_YRFR(R,S) *
        (%VARV%_NCAP%4(R,V,P %SWS%)$MILESTONYR(V) + NCAP_PASTI(R,V,P)) *
        SUM(RPCS_VAR(R,P,C,%3), RS_FR(R,TS,S) * %2))$(COEF_ICOM(R,V,%1,P,C)+COEF_OCOM(R,V,%1,P,C)) +
* Flows related to existing capacity over lifetime
      SUM((RTP_CPTYR(R,V,%1,P),IO)$NCAP_COM(R,V,P,C,IO),
        COEF_CPT(R,V,%1,P) * NCAP_COM(R,V,P,C,IO) * G_YRFR(R,S) *
        (%VARV%_NCAP%4(R,V,P %SWS%)$T(V) + NCAP_PASTI(R,V,P)
$IF DEFINED VNRET -SUM(VNRET(V,MODLYEAR(%1)),%VARM%_SCAP%4(R,V,%1,P%SWS%))$PRC_RCAP(R,P)
        ) * SUM(RPCS_VAR(R,P,C,%3), RS_FR(R,TS,S) * %2) * (1+COEF_CIO(R,V,%1,P,C,IO)))
     )
*$OFFLISTING
