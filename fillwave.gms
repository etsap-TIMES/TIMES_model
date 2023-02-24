*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*******************************************************************
* FILLWAVE : Fill parameters via weighted centered averaging
* %1 - table name
* %2 - index set (after year index)
*******************************************************************
$ SET TMP OBJ_DISC(R,LL,CUR)/COEF_PVT(R,T)
$ IF '%CTST%'=='' $SET TMP 1/D(T)
  SET REG_%2(REG,%2);
  IF(CARD(VDA_DISC)=0,VDA_DISC(R,MIYR_1)=1; LOOP((G_RCUR(R,CUR),T(TT+1)),VDA_DISC(R,Y_EOH(LL))$PERIODYR(T,LL)=%TMP%));
  OPTION REG_%2 <= %1; DONE=SMAX(T,M(T));
  LOOP(REG_%2(R,%2), OPTION CLEAR=FIL2;
    MY_ARRAY(DM_YEAR)=%1(R,DM_YEAR,%2); MY_F=0; Z=0;
* interpolate densely
    LOOP(DM_YEAR(LL)$MY_ARRAY(LL),
      LAST_VAL=MY_F; F=Z; MY_F=MY_ARRAY(LL); Z=YEARVAL(LL);    
      IF(LAST_VAL, FOR(CNT=F-Z+1 TO -1, FIL2(LL+CNT)=MY_F+(MY_F-LAST_VAL)/(Z-F)*CNT)));
    IF(DONE=Z$%3,FIL2(Y_EOH)$(YEARVAL(Y_EOH)>Z)=MY_F);
* weighted centered average
    %1(R,T,%2) = SUM(PERIODYR(T,Y_EOH(LL)),(MY_ARRAY(LL)+FIL2(LL))*VDA_DISC(R,LL)));
