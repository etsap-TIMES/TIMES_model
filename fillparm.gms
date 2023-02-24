*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*******************************************************************************
* FILLPARM : Interpolation/extrapolation of user data
* Description: Default interpolation/extrapolation if no control option given
*              Non-default interpolation/extrapolation according to user option
*              DFUNC = -1-> no interpolation, 0-> default action, 
*              DFUNC = +1-> interp., 2->interp.+EPS, 3->interp.+extrap.
*              DFUNC >999 -> exponential interpolation beyond year DFUNC
* Parameters:
*      %1 - table name
*      %2 - control set 1
*      %3 - control set 2
*      %4 - UNCD7 residual dimension
*      %5 - MODLYEAR or MILESTONYR depending on parameter
*      %6 - RTP controlling the assignment to the MODLYEARs
*      %7 - Selective test for control option (normally GE 0)
*      %8 - Optional name for temporary write cache
*******************************************************************************
*$ONLISTING
$EOLCOM !
$SETLOCAL DATA '%1(%2,%5,%3)' SETLOCAL ITEM '%1(%2,%5,%3)' SETLOCAL ADD ''
$IF NOT '%8' == '' $SETLOCAL DATA '%8(%2,%3,%5)' SETLOCAL ITEM 'MY_FIL2(%5)' SETLOCAL ADD '+MY_FIL2(%5)'
$IF NOT '%8'=='%9' PARAMETER %8(%2,%3,ALLYEAR);
* conditional interpolation flag
 IF(NOT G_NOINTERP, OPTION CLEAR = UNCD7;
   LOOP(DATAYEAR, UNCD7(%2,%3%4)$%1(%2,DATAYEAR,%3) = YES;);
   LOOP(UNCD7(%2,%3%4), DFUNC = ROUND(%1(%2,'%DFLBL%',%3));
    IF(DFUNC %7, OPTION CLEAR=MY_FIL2; CNT = (DFUNC LE 999);
      MY_ARRAY(DM_YEAR) = %1(%2,DM_YEAR,%3); LAST_VAL=0; F = 0; Z = 0;
* do interpolate
	LOOP(DM_YEAR$MY_ARRAY(DM_YEAR),                    ! check for nonzero (including EPS)
           MY_F = MY_ARRAY(DM_YEAR); Z = YEARVAL(DM_YEAR);    
           IF(LAST_VAL,
             IF(CNT OR (Z LE DFUNC),             ! linear interpolation
                %ITEM%$((Z GT YEARVAL(%5))$(YEARVAL(%5) GT MY_FYEAR))
			= LAST_VAL + (MY_F-LAST_VAL)/(Z-MY_FYEAR)*(YEARVAL(%5)-MY_FYEAR); ! not the first one
             ELSE                                ! exponential function
                %ITEM%$((Z GT YEARVAL(%5))$(YEARVAL(%5) GT MY_FYEAR))
			= LAST_VAL*POWER(1+MY_F,YEARVAL(%5)-MY_FYEAR);
                MY_F = LAST_VAL*POWER(1+MY_F,Z-MY_FYEAR);
                %1(%2,DM_YEAR,%3) = MY_F;);      ! overwrite old data
           ELSE F = Z; FIRST_VAL = MY_F;);
           LAST_VAL = MY_F; MY_FYEAR=Z;);        ! remember the value and year
      IF(DFUNC GT 1,
        IF(CNT,DFUNC=MOD(DFUNC,10);
         IF(DFUNC EQ 2, FIRST_VAL = EPS; LAST_VAL = EPS; ELSEIF DFUNC EQ 4, Z = INF; ELSEIF DFUNC EQ 5, F = 0)));
      IF((DFUNC NE 1),
* Do back/forward extrapolate, or fill in with EPS
       %DATA%$%6 $= FIRST_VAL$(YEARVAL(%5) LT F) %ADD% + LAST_VAL$(YEARVAL(%5) GT Z);
$IF NOT '%8' == '' ELSE %DATA%$%6 $= %ITEM%;
   )));
* Reset OPT and add DATA
  %1(%2,'%DFLBL%',%3)$%1(%2,'%DFLBL%',%3) = MIN(%RESET%,%1(%2,'%DFLBL%',%3));
$IF NOT '%8' == '' %1(%2,%5,%3) $= %DATA%; OPTION KILL = %8;
 );
$OFFLISTING
