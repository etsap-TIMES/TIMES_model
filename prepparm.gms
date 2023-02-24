*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*******************************************************************************
* PREPPAR : Prepare parameters for preprocessing
* Description: Non-default interpolation/extrapolation according to user option
*              DFUNC = -1-> no interpolation, 0-> default action, 10->intra-period
*              DFUNC = +1-> interp., 2->interp.+EPS, 3->interp.+extrap.
*              DFUNC >999 -> exponential interpolation beyond year DFUNC
* Parameters:
*      %1 - table name
*      %2 - control set 1
*      %3 - control set 2
*      %4 - UNCD7 residual dimension
*      %5 - MODLYEAR or MILESTONYR depending on parameter
*      %6 - RTP controlling the assignment to the MODLYEARs
*      %7 - Option to prohibit extrapolation (1 for other than cost parameters)
*******************************************************************************
*$ONLISTING
$EOLCOM !
$SETLOCAL DATA 'MY_FIL2(%5)' SETLOCAL OPT '*' SETLOCAL LL
$IF NOT %7 == 0 $SETLOCAL LL ",'%DFLBL%'" SETLOCAL OPT
$IF NOT %8.== . $SETLOCAL DEF_IEBD %8
* conditional interpolation flag
IF(G_NOINTERP, INT_DEFAULT('%1')=NO;
  ELSE OPTION CLEAR=UNCD7; CNT = (%DEF_IEBD%+(3-%DEF_IEBD%)$IE_DEFAULT('%1'))$%7;
   IF(CNT=0, UNCD7(%2%LL%,%3%4)$(%1(%2,'%DFLBL%',%3)>0) = YES;
%OPT%  ELSE UNCD7(%2,LL--ORD(LL),%3%4) $= %1(%2,LL,%3);
%OPT%  UNCD7(%2,LL,%3%4)$((%9(%1(%2,'%DFLBL%',%3)) LE -.5)$%1(%2,'%DFLBL%',%3)) = NO;
   );
   LOOP(UNCD7(%2%LL%,%3%4), DFUNC = CNT; DFUNC $= ROUND(%1(%2,'%DFLBL%',%3));
      MY_ARRAY(DM_YEAR) = %1(%2,DM_YEAR,%3); OPTION CLEAR=MY_FIL2;
* do interpolate
      IF(DFUNC NE 10, LAST_VAL=0; F = 0; Z = 0;
        LOOP(DM_YEAR$MY_ARRAY(DM_YEAR),          ! check for nonzero (including EPS)
           MY_F = MY_ARRAY(DM_YEAR); Z = YEARVAL(DM_YEAR);
           IF(LAST_VAL,
             IF((Z GT DFUNC)$(DFUNC GT 999),     ! exponential function
                %DATA%$((Z>YEARVAL(%5))$(YEARVAL(%5)>MY_FYEAR))
			= LAST_VAL*POWER(1+MY_F,YEARVAL(%5)-MY_FYEAR)+EPS;
                MY_F = LAST_VAL*POWER(1+MY_F,Z-MY_FYEAR)+EPS;
                MY_FIL2(DM_YEAR) = MY_F;         ! overwrite old data
             ELSE                                ! linear interpolation
                %DATA%$((Z>YEARVAL(%5))$(YEARVAL(%5)>MY_FYEAR))
			= LAST_VAL + (MY_F-LAST_VAL)/(Z-MY_FYEAR)*(YEARVAL(%5)-MY_FYEAR);
             );
           ELSE F = Z; FIRST_VAL = MY_F);
           LAST_VAL = MY_F; MY_FYEAR=Z;);        ! remember the value and year
%OPT% ELSE FIRST_VAL = 0; MY_FYEAR = 0;          ! intra-period I/E
%OPT%   LOOP(MY_FIL(LL)$MY_ARRAY(MY_FIL),        ! check for data values
%OPT%     MY_F = MY_ARRAY(LL); Z = YEARVAL(LL); F = FIL2(LL);
%OPT%     IF(MY_FYEAR < F, IF(F > MIN(FIRST_VAL,Z), LAST_VAL = MY_F; FIRST_VAL = F);
%OPT%       MY_FIL2(%5(LL+(F-YEARVAL(LL))))$(NOT MY_ARRAY(%5)) = LAST_VAL+(MY_F-LAST_VAL)/(Z-MY_FYEAR)*(F-MY_FYEAR));
%OPT%       LAST_VAL = MY_F; MY_FYEAR=Z;);       ! remember the value and year
%OPT%   DFUNC = %7;
      );
%OPT% IF(FLOOR(DFUNC/10)=1,
%OPT%   LOOP(MIYR_1(LL), MY_FYEAR=YEARVAL(LL);
%OPT%    MY_F = FIL2(LL+(F-MY_FYEAR)); IF(MY_F<F$MY_F,MY_FIL2(%5(LL+(MY_F-MY_FYEAR))) = FIRST_VAL);
%OPT%    MY_F = FIL2(LL+(Z-MY_FYEAR)); IF(MY_F>Z,MY_FIL2(%5(LL+(MY_F-MY_FYEAR))) = LAST_VAL));
%OPT%   DFUNC=DFUNC-10);
      IF(DFUNC NE %7,
* Do back/forward extrapolate, or fill in with EPS
       IF(DFUNC LE 2, %DATA%$(%6$(NOT %DATA%+MY_ARRAY(%5))) = EPS; ELSE
         IF(DFUNC EQ 4, Z = INF; ELSEIF DFUNC EQ 5, F = 0);
         %DATA%$(%6) $= FIRST_VAL$(YEARVAL(%5)<F) + LAST_VAL$(YEARVAL(%5)>Z);
         IF((NOT %7)$LAST_VAL, %DATA%$(%6$(NOT %DATA%+MY_ARRAY(%5)))=EPS);
      )); %1(%2,%5,%3) $= %DATA%;
  ));
* and reset OPT
$IF NOT %9==+ %1(%2,'%DFLBL%',%3)$((%1(%2,'%DFLBL%',%3)-%7)$%1(%2,'%DFLBL%',%3)) = MIN(%RESET%,%1(%2,'%DFLBL%',%3));
$OFFLISTING
