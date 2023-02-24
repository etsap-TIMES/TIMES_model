*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*******************************************************************************
* FILLCOST : Fill cost parameters
* Description: Dense interpolation/extrapolation of cost parameters
* Parameters:
*      %1 - table name
*      %2 - control set 1 (before year index)
*      %3 - control set 2 (after year index)
*      %4 - UNCD7 residual dimension
*      %5 - CKEYERS2 or EOHYEARS depending on cost parameter
*      %6 - Validity Qualifier restricting interpolation
*      %7 - Qualifier restricting backward extrapolation
*      %8 - Qualifier restricting forward extrapolation
*      %9 - Original data table
*     %10 - Write cache
*******************************************************************************
*$ONLISTING
$ EOLCOM !
$SETLOCAL SRC '%9' SETLOCAL DATA '%10(%2,%3,%5)' SETLOCAL TAKE '$%6' SETLOCAL TMP %3%4
$IF DIMENSION 8 %9 $SETLOCAL TMP %4
 PARAMETER %10(%2,%3,ALLYEAR);
 IF(YES,OPTION CLEAR=UNCD7; 
$IF '%11'==1 %1(%2,DATAYEAR,%3) $= %9(%2,DATAYEAR,%3)%TAKE%;
$IF '%11'==1 $SETLOCAL TAKE '' SETLOCAL SRC %1
 UNCD7(%2,LL--ORD(LL),%TMP%)%TAKE% $= %SRC%(%2,LL,%3);
 LOOP(UNCD7(%2,YEAR,%TMP%), F=0; LAST_VAL=0;
    OPTION CLEAR=MY_FIL2; MY_ARRAY(DM_YEAR)= %SRC%(%2,DM_YEAR,%3);
* do linear interpolation
	LOOP(DM_YEAR(LL)$MY_ARRAY(DM_YEAR),  ! check for nonzero
	  MY_F = MY_ARRAY(LL); Z = YEARVAL(LL);
	  IF(LAST_VAL, LAST_VAL=(MY_F-LAST_VAL)/(Z-MY_FYEAR);
	     FOR(CNT=MY_FYEAR-Z+1 TO -1, MY_FIL2(%5(LL+CNT)) = MY_F+LAST_VAL*CNT;);
	  ELSE F = Z; FIRST_VAL = MY_F;);
	  LAST_VAL = MY_F; MY_FYEAR=Z);      ! remember the value and year
* Do back/forward extrapolate
$IF '%11'==2 MY_FIL2(%5) $= MY_ARRAY(%5);
    %DATA% $= FIRST_VAL$(%7(YEARVAL(%5) LT F)) + MY_FIL2(%5) + LAST_VAL$(%8(YEARVAL(%5) GT Z));
  );
);
$IF NOT '%11'==2 %1(%2,%5,%3) $= %DATA%; OPTION CLEAR=%10;
$IF '%11'==2    %10('EMPTY',%3,'EMPTY')=0;
$OFFLISTING
