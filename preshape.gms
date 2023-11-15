*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*******************************************************************************
* PRESHAPE : Prepare SHAPE parameters for preprocessing
* Description: Interpolation of X parameter on user request
* Parameters:
*      %1 - table name
*      %2 - control set 1
*      %3 - control set 2
*      %4 - residual dimension for control tuple
*      %5 - MODLYEAR or MILESTONYR depending on parameter
*      %6 - temporary table of control tuples
*      %7 - P/C
*******************************************************************************
*$ONLISTING
$EOLCOM !
$SETLOCAL TAIL ",%3" SETLOCAL DEF 10
$IF '%3'=='' $SETLOCAL TAIL
$IF NOT '%8'=='' $SETLOCAL DEF %8
OPTION CLEAR = %6;
%6(%2,LL--ORD(LL)%TAIL%%4) $= %1(%2,LL%TAIL%);
LOOP(%6(%2,'%DFLBL%'%TAIL%%4),
  DFUNC=%DEF%; DFUNC $= MOD(ROUND(%1(%2,'%DFLBL%'%TAIL%)),1000);
  MY_ARRAY(DM_YEAR) = %1(%2,DM_YEAR%TAIL%);
  IF(DFUNC NE 10, F=0; LAST_VAL=0;
* do interpolate
   LOOP(DM_YEAR$MY_ARRAY(DM_YEAR),          ! check for nonzero (including EPS)
     MY_F = MY_ARRAY(DM_YEAR); Z = YEARVAL(DM_YEAR);
     IF(LAST_VAL, %1(%2,%5%TAIL%)$((Z>YEARVAL(%5))$(YEARVAL(%5)>MY_FYEAR)) = LAST_VAL;
     ELSE F = Z; FIRST_VAL = MY_F);
     LAST_VAL = ROUND(MY_F); MY_FYEAR=Z;);  ! remember the value and year
  ELSE FIRST_VAL = 0; MY_FYEAR = 0;         ! intra-period I/E
   LOOP(MY_FIL(LL)$MY_ARRAY(MY_FIL),        ! check for data values
     MY_F = MY_ARRAY(LL); Z = YEARVAL(MY_FIL); F = FIL2(MY_FIL);
     IF(MY_FYEAR<F, IF(F>MIN(FIRST_VAL,Z), LAST_VAL = MY_F; FIRST_VAL = F;);
     %1(%2,%5(LL+(F-YEARVAL(LL)))%TAIL%)$(NOT MY_ARRAY(%5)) = LAST_VAL);
     LAST_VAL = MY_F; MY_FYEAR=Z;);         ! remember the value and year
     DFUNC=0;
   );
   IF(ROUND(DFUNC-5,-1)=10,
     %1(%2,%5%TAIL%)$%7 $= FIRST_VAL$(YEARVAL(%5)<F)$(E(%5) GE F) + LAST_VAL$(YEARVAL(%5)>Z)$(B(%5) LE Z);
     DFUNC=DFUNC-10);
   IF(DFUNC GE 2,
* Do back/forward extrapolate
     IF(DFUNC=4, Z = INF; ELSEIF DFUNC=5, F = 0);
     %1(%2,%5%TAIL%)$%7 $= FIRST_VAL$(YEARVAL(%5)<F) + LAST_VAL$(YEARVAL(%5)>Z);
   );
  );
$OFFLISTING
