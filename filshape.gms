*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*******************************************************************************
* FILSHAPE : Fill shape parameters 
* Description: Dense interpolation/extrapolation of shape values
* Parameters: 
* %1 - Limit for forward extrapolation (MAXLIFE)
*******************************************************************************
*$ONLISTING
$ EOLCOM !
 SET AGEFIL(AGE);
 LOOP(J, Z = 0; MY_FYEAR = 9999;
* do interpolate
     AGEFIL(AGE) = YES$SHAPE(J,AGE);
     LOOP(AGE$AGEFIL(AGE),                ! check for nonzero (including EPS)
	  MY_F = SHAPE(J,AGE); Z = ORD(AGE);    
          IF(Z > MY_FYEAR+1,                      ! linear interpolation
               SHAPE(J,LIFE)$((ORD(LIFE) GT MY_FYEAR)$(Z GT ORD(LIFE)))
			= LAST_VAL + (MY_F-LAST_VAL)/(Z-MY_FYEAR)*(ORD(LIFE)-MY_FYEAR);
	  ELSEIF Z LT MY_FYEAR, F = Z;);
	  LAST_VAL = MY_F; MY_FYEAR=Z;);   ! remember the value and year
* Do back/forward extrapolate
     IF(Z, SHAPE(J,LIFE)$(ORD(LIFE) LT F) = 1;
           SHAPE(J,LIFE)$((ORD(LIFE) GT Z)$(ORD(LIFE) LE %1)) = LAST_VAL;);
 );
$OFFLISTING
