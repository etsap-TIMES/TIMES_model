*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* BNDMAIN.MOD establishes bounds on variables
*   %1 - mod or v# for the source code to be used
*   %2 - flag indicating calling phase
*=============================================================================*
*GaG Questions/Comments:
*  - FXs take precedence as are set last!!!
*  - TS-based bounds:
*    - individual TS vs at/above limit via s-index
*-----------------------------------------------------------------------------
$ IF %2==0 $CLEAR %VAR%_IRE %VAR%_UPS %VAR%_UDP %VAR%_UPT %VAR%_SCAP

*-----------------------------------------------------------------------------
* elastic demands step curve
*-----------------------------------------------------------------------------
    %VAR%_ELAST.UP(R,T,C,S,J,BD %SWD%) = INF;
$ IF %TIMESED%==YES  $BATINCLUDE bnd_elas.%1

*-----------------------------------------------------------------------------
* limit on total activity capacity when not vintaged
*-----------------------------------------------------------------------------
$   BATINCLUDE bnd_act.%1

*-----------------------------------------------------------------------------
* limit on the flow variable when not vintaged
*-----------------------------------------------------------------------------
$   BATINCLUDE bnd_flo.%1

*-----------------------------------------------------------------------------
* limit on storage
*-----------------------------------------------------------------------------
$   BATINCLUDE bnd_stg.%1 SIN  STGIN  0
$   BATINCLUDE bnd_stg.%1 SOUT STGOUT -INF

*-----------------------------------------------------------------------------
* limit on total installation of new capacity
*-----------------------------------------------------------------------------
$ IF %STAGES%==YES  $SETLOCAL SWT '$SW_T(T%SOW%)'
* prevent new investment if turned off explicitly by the user
    NCAP_BND(RTP_OFF,'UP') = EPS;
    NCAP_BND(RTP(R,T,P),'LO')$(NCAP_BND(RTP,'UP')$NCAP_BND(RTP,'LO')) = SMIN(BDNEQ,NCAP_BND(RTP,BDNEQ));
$   BATINCLUDE bnd_set.%1 %VAR%_NCAP 'R,T,P' NCAP_BND '%R_T%,P' $(RP(R,P)%SWT%)

*-----------------------------------------------------------------------------
* limit on total installed capacity
*-----------------------------------------------------------------------------
    CAP_BND(RTP(RTP_VARP),'LO')$CAP_BND(RTP,'UP') = SMIN(BDNEQ,CAP_BND(RTP,BDNEQ));
$   BATINCLUDE bnd_set.%1 %VAR%_CAP 'R,T,P' CAP_BND RTP(R,T,P) %SWT%

*-----------------------------------------------------------------------------
* limit on commdities
*-----------------------------------------------------------------------------
$   BATINCLUDE bnd_set.%1 %VAR%_COMNET 'R,T,C,S' COM_BNDNET RTCS_VARC(%R_T%,C,S) %SWT%
$   BATINCLUDE bnd_set.%1 %VAR%_COMPRD 'R,T,C,S' COM_BNDPRD RTCS_VARC(%R_T%,C,S) %SWT%
    %VAR%_COMPRD.FX(RTCS_VARC(R,T,C,S)%SOW%)$((NOT RHS_COMPRD(R,T,C,S))$RCS_COMPRD(R,T,C,S,'FX')) = EPS;

*-----------------------------------------------------------------------------
* bounds for cumulative variables
*-----------------------------------------------------------------------------
$ IF %2==0 $BATINCLUDE bnd_cum.%1 COM_VAR

*-----------------------------------------------------------------------------
* bounds for user constraint slacks
*-----------------------------------------------------------------------------
$IF %VAR_UC%==YES $BATINCLUDE bnd_ucw.%1 %SWT%
*-----------------------------------------------------------------------------
$IF %MACRO%==YES $GOTO MACRO
* Bounds for OBJ components
   UC_TS_SUM(R,UC_N(OBV),S) = NO;
   %VAR%_OBJ.LO(R,OBV(UC_N),CUR %SOW%)$UC_RHS(UC_N,'N') = -INF;
   %VAR%_OBJ.LO(R,OBV(UC_N),CUR %SOW%) $= UC_RHS(UC_N,'LO');
   %VAR%_OBJ.UP(R,OBV(UC_N),CUR %SOW%) $= UC_RHS(UC_N,'UP');
   %VAR%_OBJ.LO(R,OBV(UC_N),CUR %SOW%)$UC_RHSR(R,UC_N,'N') = -INF;
   %VAR%_OBJ.LO(R,OBV(UC_N),CUR %SOW%) $= UC_RHSR(R,UC_N,'LO');
   %VAR%_OBJ.UP(R,OBV(UC_N),CUR %SOW%) $= UC_RHSR(R,UC_N,'UP');
*-----------------------------------------------------------------------------
* bounds for TIMES-MACRO
*-----------------------------------------------------------------------------
$LABEL MACRO
$ IF %MACRO% == YES  $BATINCLUDE bnd_macro.tm
*-----------------------------------------------------------------------------
* Fix timeslices turned off in projected periods
$IF NOT %RTS%==S $BATINCLUDE dynslite.vda BOUNDS