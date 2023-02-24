*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* BND_UCV.MOD set the actual bounds for UC constraint slacks                  *
*=============================================================================*
* %1 - UC variable name
* %2 - "," or ""
* %3 - "R" or ""
* %4 - period
* %5 - UCRHS attribute name
* %6 - control sets (region, period EACH/SUM/SUCC)
* %7 - optional LOOP
* %8 - optional LOOP close
* %9 - timeslice
* %10 - multi-stage indicator
* %11 - SPAR_UCSL residual dimension
*------------------------------------------------------------------------------
$IF '%10'=='M' $GOTO MULTIPHASE
*------------------------------------------------------------------------------
* Clear the bounds for the variables
$IF DEFINED %1
   %1.LO(UC_N%2%3%4%9%SWD%)%12 = -INF;
   %1.UP(UC_N%2%3%4%9%SWD%)    =  INF;
*------------------------------------------------------------------------------
* Set the bounds for the variables
%7
   %1.LO(UC_N%2%3%4%13%9%SOW%)%6 $= %5(%3%2UC_N%4%9,'LO');
   %1.UP(UC_N%2%3%4%13%9%SOW%)%6 $= %5(%3%2UC_N%4%9,'UP');
   %1.FX(UC_N%2%3%4%13%9%SOW%)%6 $= %5(%3%2UC_N%4%9,'FX');
%8
*------------------------------------------------------------------------------
* Set INF upper bound for N type constraints to activate them (DYN too!)
   %5(%3%2UC_N%4%9,'UP')$((NOT %5(%3%2UC_N%4%9,'UP'))$%5(%3%2UC_N%4%9,'N')) = INF;
*------------------------------------------------------------------------------
$IFI NOT %STAGES%==YES $EXIT
*------------------------------------------------------------------------------
* Deviation bounds: Check if any specified
 IF(SW_PHASE EQ -9,
   CNT=CNT+SUM((%3%2UC_N%4%9)$((%5(%3%2UC_N%4%9,'N') GE 0)$%5(%3%2UC_N%4%9,'N')),1);
   CNT=CNT+SUM((%3%2UC_N%4%9,W)$((S_%5(%3%2UC_N%4%9,'N','1',W) GE 0)$S_%5(%3%2UC_N%4%9,'N','1',W)),1);
 );
*------------------------------------------------------------------------------
$IF%10 NOT %STAGES%==YES $EXIT
*------------------------------------------------------------------------------
* Handle uncertain RHS if stochastic mode: Set uncertain bounds for variables
  IF(SW_PHASE NE -2,
%7
   %1.LO(UC_N%2%3%4%13%9%SOW%)%6 $= S_%5(%3%2UC_N%4%9,'LO','1',SOW);
   %1.UP(UC_N%2%3%4%13%9%SOW%)%6 $= S_%5(%3%2UC_N%4%9,'UP','1',SOW);
   %1.FX(UC_N%2%3%4%13%9%SOW%)%6 $= S_%5(%3%2UC_N%4%9,'FX','1',SOW);
%8
  );
*------------------------------------------------------------------------------
$IF NOT '%10'=='I' $EXIT
*------------------------------------------------------------------------------
  IF(SW_PHASE EQ 2,
*------------------------------------------------------------------------------
* Copy UC slack levels for missing first phase runs if necessary
$IF %STAGES%==YES LOOP((SOW(WW),W(WW-1))$(S_UCOBJ('OBJ1',SOW) EQ 4),%1.L(UC_N%2%3%4%9,SOW) $= %1.L(UC_N%2%3%4%9,W));
$IF NOT %STAGES%==YES %1.L(UC_N%2%3%4%9%SOW%) $= SPAR_UCSL(SOW,UC_N%2%3%4%9%11);
*------------------------------------------------------------------------------
%7
* Set the deviation bounds for the variables - copy defaults to SOW if not specified
   S_%5(%3%2UC_N%4%9,'N','1',SOW)$(NOT S_%5(%3%2UC_N%4%9,'N','1',SOW)) $= %5(%3%2UC_N%4%9,'N');
*------------------------------------------------------------------------------
* Set deviation uncertain bounds for variables - for SOW that have bound specified
   %1.LO(UC_N%2%3%4%13%9%SOW%)$(((S_%5(%3%2UC_N%4%9,'N','1',SOW) GE 0)%6)$S_%5(%3%2UC_N%4%9,'N','1',SOW)) =
      %1.L(UC_N%2%3%4%9%SOW%)-ABS(%1.L(UC_N%2%3%4%9%SOW%)*S_%5(%3%2UC_N%4%9,'N','1',SOW));
   %1.UP(UC_N%2%3%4%13%9%SOW%)$(((S_%5(%3%2UC_N%4%9,'N','1',SOW) GE 0)%6)$S_%5(%3%2UC_N%4%9,'N','1',SOW)) =
      %1.L(UC_N%2%3%4%9%SOW%)+ABS(%1.L(UC_N%2%3%4%9%SOW%)*S_%5(%3%2UC_N%4%9,'N','1',SOW));
%8
*------------------------------------------------------------------------------
  );
$EXIT
$LABEL MULTIPHASE
*------------------------------------------------------------------------------
  OPTION CLEAR=UNCD1; UNCD1(UC_N)=YES; UNCD1('OBJ1') = NO;
* Initally clear any deterministic N RHS bounds
 LOOP(SOW(WW), IF(ORD(WW)=1, %5(%3%2UC_N%4%9,'N')=0);
%7
* Copy old deviation bounds forward unless cleared
   %5(%3%2UC_N%4%9,'N')$S_%5(%3%2UC_N%4%9,'N','1',SOW) = 0;
   %1.LO(UC_N(UNCD1)%2%3%4%9,ALLSOW)$%5(%3%2UC_N%4%9,'N') = %1.LO(UC_N%2%3%4%9,SOW);
   %1.UP(UC_N(UNCD1)%2%3%4%9,ALLSOW)$%5(%3%2UC_N%4%9,'N') = %1.UP(UC_N%2%3%4%9,SOW);
*------------------------------------------------------------------------------
* Add flags indicating the new deviation bounds in force
   %5(%3%2UC_N%4%9,'N')$((S_%5(%3%2UC_N%4%9,'N','1',SOW) GE 0)$S_%5(%3%2UC_N%4%9,'N','1',SOW)) = -1;
* Set deviation uncertain bounds for variables - for SOW that have bound specified
   %1.LO(UC_N(UNCD1)%2%3%4%9,ALLSOW)$((S_%5(%3%2UC_N%4%9,'N','1',SOW) GE 0)$S_%5(%3%2UC_N%4%9,'N','1',SOW)) =
      %1.L(UC_N%2%3%4%9%SOW%)-ABS(%1.L(UC_N%2%3%4%9%SOW%)*S_%5(%3%2UC_N%4%9,'N','1',SOW));
   %1.UP(UC_N(UNCD1)%2%3%4%9,ALLSOW)$((S_%5(%3%2UC_N%4%9,'N','1',SOW) GE 0)$S_%5(%3%2UC_N%4%9,'N','1',SOW)) =
      %1.L(UC_N%2%3%4%9%SOW%)+ABS(%1.L(UC_N%2%3%4%9%SOW%)*S_%5(%3%2UC_N%4%9,'N','1',SOW));
%8
 );
*------------------------------------------------------------------------------
