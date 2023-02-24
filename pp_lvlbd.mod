*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_LVLBD aggregate the bound attributes if finer than level
*  %1 - bound attribute name (ACT_BND,FLO_FR,COM_BND,IRE_BND)
*  %2 - 'C'ommodity/'P'rocess index
*  %3 - 'C,' or none
*  %4 - other indexes between S and BD
*  %5 - temp residual indexes
*  %6 - COM/PRC_TS-level shooting for
*  %7 - valid bound levels
*  %8 - temp set name
*  %9 - treat negative bouds as 0/EPS?
*=============================================================================*
* Questions/Comments: 
*  - New implementation (Jul-2011)
*  - As originally, based on summing of UP/FX and LO/FX bounds from finer levels
*-----------------------------------------------------------------------------
*$ONLISTING
  SET BDVAL(BD);
  PARAMETER TS_BD(S,BD);
  %8(RT%2(R,T,%2),%3S--ORD(S),%4'FX'%5) $= SUM(BD$%1(RT%2,%3S,%4BD),1)$(NOT %7(R,%2,%3S));

* Aggregation only if target level value is not present
  LOOP((%8(R,T,%2,%3ALL_TS,%4'FX'%5),%6(R,%2,%3TS)),
    TS_BD(S,BD) = %1(R,T,%2,%3S,%4BD)$TS_MAP(R,TS,S); 
    TS_BD(S,BDNEQ) $= TS_BD(S,'FX'); Z=SUM(BD$TS_BD(TS,BD),1); F=CARD(TS_BD)-Z;
    IF(Z>1,Z=F; ELSE Z=SUM((RS_BELOW(R,TS,S),BDNEQ(BD))$(TS_BD(S,BD)$TS_BD(TS,BD)),1)$F);
    IF(Z, F=(F>Z);
$     BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 01 '%1 Bounds conflict: Value at %6 level and below, latter ignored'
      PUT QLOG ' WARNING       -     %1:  R=',%RL%,' Y=',T.TL,' %2=',%2.TL,' S=',TS.TL);
    IF(F, BDVAL(BD)=(NOT TS_BD(TS,BD))$BDNEQ(BD);
*   Clear neg bounds and those below the topmost ones
$IF NOT %9=='' TS_BD(S,BDNEQ)$(TS_BD(S,BDNEQ)<0) = %9;
      TS_BD(S,BDVAL(BD))$SUM(RS_BELOW(R,SL,S)$TS_BD(SL,BD),1)=0;
*   Check the INF default for UP bounds before summing
      BDVAL(BDVAL('UP')) = (G_YRFR(R,TS)-SUM(RS_BELOW(R,TS,S)$TS_BD(S,'UP'),G_YRFR(R,S))) < 1E-5;
      TS_BD(TS,BDVAL)=SUM(RS_BELOW(R,TS,S),TS_BD(S,BDVAL));
      IF((TS_BD(TS,'UP')-TS_BD(TS,'LO') < 1E-7)$(SUM(BD$TS_BD(TS,BD),1)=2),
         %1(R,T,%2,%3TS,%4'FX') = TS_BD(TS,'LO');
      ELSE %1(R,T,%2,%3TS,%4BDVAL) $= TS_BD(TS,BDVAL))));

  %1(R,T,%2,%3S,%4BDNEQ)$%1(R,T,%2,%3S,%4'FX') = 0;
  OPTION CLEAR=%8;
*$OFFLISTING
