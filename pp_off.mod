*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_OFF sets to Start/End of the OFF period range
*   %1 - OFF Set name
*   %2 - 'C'ommodity/'P'rocess index indicator
*   %3 - control set
*   %4 - Table to set for each off-range with qualifier and one open (
*   %5 - The value for the off range (EPS/NO)
*=============================================================================*
* Comments: Depends on BOHYEAR/EOHYEAR being ordered 1 higher than ALLYEAR
*-----------------------------------------------------------------------------
*$ONLISTING
* Cope with multiple OFF-ranges
      OPTION CLEAR=FIL;
      LOOP(%1(R,%2,BOHYEAR,EOHYEAR)%3, STARTOFF=ORD(BOHYEAR)-2; ENDOFF=ORD(EOHYEAR);
* set the flags of the shutoff period
        FIL(EOHYEARS(LL))$((ORD(LL) > STARTOFF)$(ORD(LL) < ENDOFF)) = YES);
* open (
      %4(SUM(PERIODYR(T,FIL),1)/D(T) GE G_OFFTHD(T))$FIL(T)) = %5;
*$OFFLISTING
