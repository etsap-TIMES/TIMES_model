*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*******************************************************************************
* FILPARAM : Fill parameter
* Description: Dense interpolation/extrapolation of parameters
* Parameters:
*      %1 - table name
*      %2 - control set 1 (before year index)
*      %3 - control set 2 (after year index)
*      %4 - UNCD7 residual dimension
*      %5 - Source data years (e.g. ALLYEAR, DM_YEAR)
*      %6 - Target data years (e.g. ALLYEAR, MILESTONYR)
*      %7 - Qualifier restricting backward extrapolation
*      %8 - Qualifier restricting forward extrapolation
*      %9 - Default interpolation option
*******************************************************************************
*$ONLISTING
$ EOLCOM !
$SETLOCAL SRC '%1' SETLOCAL TAIL1 '%3' SETLOCAL TAIL2 ',%3'
$IF '%3' == '' $SETLOCAL TAIL1 "''" SETLOCAL TAIL2 ''
$IF '%10'=='' IF(YES, OPTION CLEAR = UNCD7; LOOP((%2%5%TAIL2%)$%SRC%(%2%5%TAIL2%), UNCD7(%2%TAIL1%%4) = YES));
$IF NOT '%10'=='' IF(YES, OPTION CLEAR = UNCD7; UNCD7(%2LL--ORD(LL),%TAIL1%%4)$%SRC%(%2LL%TAIL2%) = YES);
 LOOP(UNCD7(%2%10%TAIL1%%4), F=0; Z=INF; MY_FYEAR=9999;
   DFUNC = ROUND(%SRC%(%2'%DFLBL%'%TAIL2%));
$IF NOT %9=='' IF(NOT DFUNC, DFUNC = %9);
   IF(DFUNC GE 0,
    MY_ARRAY(%5) = %SRC%(%2%5%TAIL2%); MY_ARRAY('%DFLBL%')=0;
* do interpolate
	LOOP(%5$MY_ARRAY(%5),              ! check for nonzero (including EPS)
	  MY_F = MY_ARRAY(%5); Z = YEARVAL(%5);
	  IF(Z > MY_FYEAR+1,               ! linear interpolation
	     %1(%2%6%TAIL2%)$((Z GT YEARVAL(%6))$(YEARVAL(%6) GT MY_FYEAR))
			= LAST_VAL + (MY_F-LAST_VAL)/(Z-MY_FYEAR)*(YEARVAL(%6)-MY_FYEAR); ! not the first one
	  ELSEIF Z LT MY_FYEAR, F=Z; FIRST_VAL = MY_F);
	  LAST_VAL = MY_F; MY_FYEAR=Z);    ! remember the value and year
* Do back/forward extrapolate
    IF(DFUNC GT 1, DFUNC=MOD(DFUNC,10);
      IF(DFUNC EQ 2, FIRST_VAL=EPS; LAST_VAL=EPS; ELSEIF DFUNC EQ 4, Z=INF; ELSEIF DFUNC EQ 5, F=0));
    IF(DFUNC NE 1,
      %1(%2%6%TAIL2%) $= FIRST_VAL$(%7(YEARVAL(%6) LT F)) + LAST_VAL$(%8(YEARVAL(%6) GT Z));
    ));
  );
$OFFLISTING
