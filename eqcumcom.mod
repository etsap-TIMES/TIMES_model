*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQCUMCOM sets the cumulative limit on a commodity
*   %1 - equation declaration type
*   %2 - NET/PRD indicator
*=============================================================================*
*GaG Questions/Comments:
* - scale both sides!!!
* [AL] Changed to support arbitrary year range
*-----------------------------------------------------------------------------
*$ONLISTING
    %EQ%_CUM%2(RC(R,C),ALLYEAR,LL %SOW%)$RC_CUMCOM(R,'%2',ALLYEAR,LL,C)..

* all commodity flows within period range
               SUM(RTC_%2(R,TT(T),C)$
$IFI NOT %OBJ%==LIN  ((E(T) >= YEARVAL(ALLYEAR))$(B(T) <= YEARVAL(LL))),
$IFI %OBJ%==LIN      ((M(T)+LAGT(T) > YEARVAL(ALLYEAR))$(M(T)-LEAD(T) < YEARVAL(LL))),
                   SUM(RTCS_VARC(R,T,C,S),
$IFI NOT %OBJ%==LIN  MAX(0,MIN(E(T),YEARVAL(LL))-MAX(B(T),YEARVAL(ALLYEAR))+1)
$IFI %OBJ%==LIN      SUM(TPULSEYR(T,YEAR)$((ORD(YEAR) >= ORD(ALLYEAR))$(ORD(YEAR) <= ORD(LL))),TPULSE(T,YEAR))
                     * %VARTT%_COM%2(R,T,C,S %SWS%)
                   )
               ) / %CUCSCAL%

    =%1=

* bound range working on
    %VAR%_CUMCOM(R,C,'%2',ALLYEAR,LL %SOW%)
    ;

$OFFLISTING
