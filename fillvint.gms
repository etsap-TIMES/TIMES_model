*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*******************************************************************************
* FILLVINT : Optional weighting of vintaged attributes
*   %1 - table name
*   %2 - Control set 1
*   %3 - Control set 2
*   %4 - Name for temporary cache
*******************************************************************************
*$ONLISTING
$ IF NOT '%4'=='' $GOTO FILL
*------------------------------------------------------------------------------
* Initialization
  OPTION CLEAR=PRC_YMIN,CLEAR=PASTSUM;
$IF %VINTOPT%==2 PRC_SIMV(PRC_VINT(R,P)) = NOT PRC_MAP(R,'STG',P);
$IF DEFINED PRC_SIMV PRC_SIMV(R,P)$PRC_MAP(R,'STG',P) = NO; PRC_VINT(PRC_SIMV) = YES;
* Make sure that all PRC_VINT have first leading V in RTP:
  LOOP(T(LL),RVP(R,V(LL-LEAD(T)),P)$((NOT RVP(R,V,P))$RVP(R,T,P)$PRC_VINT(R,P)) = YES);
$IF DEFINED PRC_SIMV RTP(RVP(R,V,P)) $=PRC_SIMV(R,P);
$EXIT
*------------------------------------------------------------------------------
$ LABEL FILL
  PARAMETER %4(%2,%3,ALLYEAR);
  IF(CARD(PASTSUM)=0,
    PASTSUM(RTP(R,T,P))$PRC_VINT(R,P) = 
      MIN(1,(MAX(YEARVAL(T)-(LEAD(T)-1)/2,B(T)+MAX(NCAP_ILED(RTP),(D(T)+NCAP_ILED(RTP)-NCAP_TLIFE(RTP))/2)) -
             (YEARVAL(T)-LEAD(T))) / LEAD(T)));
  TRACKP(PRC_VINT) = YES;
$IF DEFINED PRC_SIMV TRACKP(PRC_SIMV) = NO;
* Weighted average of vintages T and T-1
  LOOP((T(LL),V(LL-LEAD(LL))),
    %4(%2,%3,T)$(%1(%2,T,%3)$TRACKP(R,P)) = %1(%2,T,%3)*PASTSUM(R,T,P)+%1(%2,V,%3)*(1-PASTSUM(R,T,P)));
  %1(%2,T,%3) $= %4(%2,%3,T);
  OPTION CLEAR=%4,CLEAR=TRACKP;
$OFFLISTING
