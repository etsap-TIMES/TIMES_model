*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQPEAK is the basic commodity balance and the production limit constraint
*   %1 - mod or v# for the source code to be used
*=============================================================================*
* Questions/Comments:
* - NCAP_PKCNT uses the vintage period !
* - Even annual level processes contribute to a seasonal peak according to PKCNT
*-----------------------------------------------------------------------------
*$ONLISTING
*
    %EQ%_PEAK(%R_T%,CG2,RTS(SL)%SWT%)$(SUM(COM_GMAP(R,CG2,C)$RTC(R,T,C),1)$COM_PKTS(R,CG2,SL)) ..

     SUM((COM_GMAP(R,CG2,C),COM_TS(R,C,S))$RS_FR(R,SL,S),
      RS_FR(R,SL,S) *

      (1/(1+MAX(SMAX(COM(CG2),COM_PKRSV(R,T,COM)),COM_PKRSV(R,T,C))))*COM_IE(R,T,C,S)*

      (SUM(RPC_PKC(PRC_CAP(R,P),C), G_YRFR(R,S) * PRC_CAPACT(R,P) *
           SUM(V$COEF_CPT(R,V,T,P),COEF_CPT(R,V,T,P)*PRC_ACTFLO(R,V,P,C)*NCAP_PKCNT(R,V,P,S)*
               (%VARV%_NCAP(R,V,P %SWS%)$MILESTONYR(V)+NCAP_PASTI(R,V,P)$PASTYEAR(V) %RCAPSUB%))
          ) +

*
* production
*
*   inter-regional trade to region; processes with PKNO+PKCNT contribute by net imports
$      BATINCLUDE cal_ire.%1 IMP OUT IE '*NCAP_PKCNT(R,V,P,S)' -
$      BATINCLUDE cal_ire.%1 EXP IN IE '*(-NCAP_PKCNT(R,V,P,S)/COM_IE(R,T,C,S))$(COM_IE(R,T,C,S)>0)' - PRC_PKNO( )

           (

*GG*PK no multiplier
*[UR] 25.04.2003 added NCAP_PKCNT multiplier to turn off contribution by setting NCAP_PKCNT to zero
*[AL] 25.01.2007 allow using PKNO to switch process to production-based peak contribution
*[AL] When PKNO=YES no default PKCNT is assigned -> process contributes only if PKCNT set by user

*   storage
$            BATINCLUDE cal_stgn.%1 OUT IN '*STG_EFF(R,V,P)' '' "(NOT PRC_NSTTS(R,P,TS))" '*(NCAP_PKCNT(R,V,P,S)**RPC_PKF(R,P,C))$RPC_PKF(R,P,C)'

*   individual flows
$            BATINCLUDE cal_fflo.%1 OUT O '*(NCAP_PKCNT(R,V,P,S)**RPC_PKF(R,P,C))$RPC_PKF(R,P,C)'

           0)

* [UR]: 04/22/2003: adjustment for extraction condensing CHP plants
$IF SET PEAKCHP $BATINCLUDE %PEAKCHP%
      ))

      =G=

     SUM((COM_GMAP(R,CG2,C),COM_TS(R,C,S))$RS_FR(R,SL,S),
         RS_FR(R,SL,S) *
* Apply the maximum of flexibilities among CG2 an C
         (1+MAX(SUM(COM(CG2),COM_PKFLX(R,T,COM,SL)),COM_PKFLX(R,T,C,S)))*
         (
              (
*
* consumption
*
*GG*PK pass TS as timeslice

*   individual flows
$              BATINCLUDE cal_fflo.%1 IN I  '*FLO_PKCOI(R,T,P,C,TS)'

*   inter-regional trade from region
$              BATINCLUDE cal_ire.%1 EXP IN IE '*FLO_PKCOI(R,T,P,C,TS)' -

* capacity related commodity flows
*   fixed commodity associated with installed capacity or investment
$              BATINCLUDE cal_cap.%1 IN I '1$(NOT PRC_PKNO(R,P))*'
              ) +
*   storage
$          BATINCLUDE cal_stgn.%1 IN OUT '' 'STG_EFF(R,V,P)*(NCAP_PKCNT(R,V,P,S)**RPC_PKF(R,P,C))*' "((NOT PRC_MAP(R,'NST',P))+PRC_NSTTS(R,P,TS))" "$(NOT RPC_PKC(R,P,C)*PRC_CAP(R,P))"

*   blending
           SUM(BLE_OPR(R,BLE,OPR)$(BLE_INP(R,BLE,C)*BLE_TP(R,T,BLE)),G_YRFR(R,S)*(1+RTCS_FR(R,T,C,S,'ANNUAL'))*BL_INP(R,BLE,C)*PEAKDA_BL(R,BLE,T)*%VAR%_BLND(R,T,BLE,OPR %SOW%)) +

*   demand projection
$IFI %STAGES% == YES $SETLOCAL SWS 'PROD(SW_MAP(T,SOW,J,WW)$S_COM_PROJ(R,T,C,J,WW),S_COM_PROJ(R,T,C,J,WW))*'
      ((%SWS% COM_PROJ(R,T,C)$(NOT RD_NLP(R,C)) +%VAR%_DEM(R,T,C%SOW%)$RD_NLP(R,C) +SUM(RD_AGG(R,COM),RD_SHAR(R,T,COM,C)*%VAR%_COMPRD(R,T,COM,'ANNUAL'%SOW%))) * COM_FR%MX%(R,T,C,S))$DEM(R,C) +

*   include the elasticity variables
$IF %TIMESED%==YES   SUM(RCJ(R,C,J,BDNEQ(BD))$COM_ELAST(R,T,C,S,BD),-BDSIG(BD)*%VAR%_ELAST(R,T,C,S,J,BD %SOW%)) +

       0)) ;
*$OFFLISTING
