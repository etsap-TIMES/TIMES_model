*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQCUMFLO sets the cumulative upper limit on a flow or activity
*   %1 - equation declaration type
*=============================================================================*
*AL Questions/Comments:
* - scale both sides
* - support arbitrary year range
*-----------------------------------------------------------------------------
*$ONLISTING
    %EQ%_CUMFLO(RPC_CUMFLO(RP(R,P),C,ALLYEAR,LL) %SOW%) ..
$SETLOCAL SW1 '' SETLOCAL SW2 ""
$IF %STAGES%%SCUM%==YES $SET SOW ',WW' SET SWT ',SOW' SET SW1 'S_' SET SW2 ",'1',SOW"

* all commodity/activity flows within period range
                 SUM(TT(T)$
$IFI NOT %OBJ%==LIN  ((E(T) >= YEARVAL(ALLYEAR))$(B(T) <= YEARVAL(LL))),
$IFI %OBJ%==LIN      ((M(T)+LAGT(T) > YEARVAL(ALLYEAR))$(M(T)-LEAD(T) < YEARVAL(LL))),
                    SUM((RTP_VINTYR(R,V,T,P),RTPCS_VARF(R,T,P,C,TS)),
$IFI NOT %OBJ%==LIN   MAX(0,MIN(E(T),YEARVAL(LL))-MAX(B(T),YEARVAL(ALLYEAR))+1)
$IFI %OBJ%==LIN       SUM(TPULSEYR(T,YEAR)$((ORD(YEAR) >= ORD(ALLYEAR))$(ORD(YEAR) <= ORD(LL))),TPULSE(T,YEAR))
                      * (
$IF %STAGES%==YES     SUM(%SWSW% (
$                        BATINCLUDE %cal_red% C COM TS P T
                         $RP_STD(R,P) +
                         (SUM(RPC_IRE(R,P,C,IE),%VAR%_IRE(R,V,T,P,C,TS,IE%SOW%))$(NOT RPC_AIRE(R,P,C)) +
                          (%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C))$RP_IRE(R,P)
$IF %STAGES%==YES     ))
                    ))$RPC(R,P,C) +
                    SUM((RTP_VINTYR(R,V,T,P),RTP_VARA(R,T,P),PRC_TS(R,P,TS)),
$IFI NOT %OBJ%==LIN   MAX(0,MIN(E(T),YEARVAL(LL))-MAX(B(T),YEARVAL(ALLYEAR))+1)
$IFI %OBJ%==LIN       SUM(TPULSEYR(T,YEAR)$((ORD(YEAR) >= ORD(ALLYEAR))$(ORD(YEAR) <= ORD(LL))),TPULSE(T,YEAR))
                      * %VARTT%_ACT(R,V,T,P,TS %SWS%)
                    )$SAMEAS(%PGPRIM%,C)

                 ) / %CUFSCAL%

    =E=

* bound range working on
    %VAR%_CUMFLO(R,P,C,ALLYEAR,LL %SWT%)$(MAPVAL(%SW1%FLO_CUM(R,P,C,ALLYEAR,LL,'UP'%SW2%)) NE 8);
    ;

$OFFLISTING

