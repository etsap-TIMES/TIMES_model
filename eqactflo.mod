*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQACTFLO.MOD relationship between process activity & individual primary     *
*              commodity flows                                                *
*=============================================================================*
*GaG Questions/Comments:
*  - always created at the PRC_TS level as tied to the PCG
*-----------------------------------------------------------------------------
*$ONLISTING
* adjust so VAR_FLO only when not IRE (or STG)
*  EQ_ACTFLO(RTP_VINTYR(R,V,T,P),S)$((RP_FLO(R,P) + RP_IRE(R,P)) * PRC_TS(R,P,S)
   %EQ%_ACTFLO(RTP_VINTYR(%R_V_T%,P),S %SWT%)$(PRC_TS(R,P,S) *
$IF %REDUCE% == 'YES'                               (NOT RTPS_OFF(R,T,P,S)) *
                                                    PRC_ACT(R,P)) ..

      %VAR%_ACT(R,V,T,P,S %SOW%)$RTP_VARA(R,T,P)

  =E=

* handle both regular and IRE processes
* need to ensure that said commodity handled in current timeslice
       SUM(RPC_PG(R,P,C)$RTPCS_VARF(R,T,P,C,S),
                         (%VAR%_FLO(R,V,T,P,C,S %SOW%)$RP_FLO(R,P) +
                          SUM(RPC_IRE(R,P,C,IE)$RP_AIRE(R,P,IE),
                            %VAR%_IRE(R,V,T,P,C,S,IE %SOW%))$RP_IRE(R,P)
                         ) / PRC_ACTFLO(R,V,P,C)
       );
*$OFFLISTING
