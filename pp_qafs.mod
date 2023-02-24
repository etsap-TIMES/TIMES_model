*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================
* Other preprocessing stuff for FLO_SHAR: QA Checks
*=============================================================================
* Eliminate redundant / inconsistent shares due to careless modelling
 SET RTPGIG(R,ALLYEAR,P,CG,IO,CG) //;
 SET RTP_CG(R,ALLYEAR,P,CG,IO)    //;
 SET RTP_GRP(R,ALLYEAR,P,CG,IO)   //;
 SET RP_GIC(R,P,CG,IO,C)          //;
 SET RPG_RED(R,P,CG,IO)           //;
*-----------------------------------------------------------------------------
* Collect the Groups involved
 OPTION RP_CCG <= FLO_SHAR; PUTGRP=0;
 LOOP(RP_CCG(R,P,C,CG)$(NOT RPC(R,P,C)$COM_GMAP(R,CG,C)),
$    BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 07 'Unsupported FLO_SHARE: C not in RPC or CG'
     PUT QLOG ' SEVERE ERROR  -     R=',%RL%,' P=',%PL%,' C=',C.TL,' CG=',CG.TL;);
 IF(PUTGRP, RP_CCG(R,P,C,CG)$(NOT COM_GMAP(R,CG,C)) = NO);
 RTPGIG(R,'0',P,C,IO,CG)$(TOP(R,P,C,IO)$RP_CCG(R,P,C,CG)) = YES;
 LOOP(RTPGIG(R,'0',P,C,IO,CG),RPG_RED(R,P,CG,IO) = YES);
 RTP_CGC(R,V,P,C,CG) $= SUM(BD$FLO_SHAR(R,V,P,C,CG,'ANNUAL',BD),1);
 RP_GIC(RPG_RED(R,P,CG,IO),C)$(TOP(R,P,C,IO)$COM_GMAP(R,CG,C)) = YES;
 RTP_CG(RTP(R,V,P),CG,IO) $= SUM(RTP_CGC(R,V,P,C,CG)$RP_GIC(R,P,CG,IO,C),1);
 OPTION CLEAR=UNCD7; UNCD7(R,LL--ORD(LL),P,C,CG,S--ORD(S),BD) $= FLO_SHAR(R,LL,P,C,CG,S,BD)$(NOT ANNUAL(S));
 LOOP((UNCD7(R,LL,P,C,CG,S,BD),RP_GIC(R,P,CG,IO,C)), RTP_CG(R,V,P,CG,IO) = NO);
 OPTION CLEAR=RTP_CGC,CLEAR=RTPGIG,CLEAR=RP_CCG;
*------------------------------------------------------------------------------
* Check simultaneous FX+LO/UP
  RTP_CGC(R,V,P,C,CG) $= FLO_SHAR(R,V,P,C,CG,'ANNUAL','FX');
  PUTGRP = 0;
  LOOP(RTP_CGC(R,V,P,C,CG)$(FLO_SHAR(R,V,P,C,CG,'ANNUAL','LO')+FLO_SHAR(R,V,P,C,CG,'ANNUAL','UP')),
$     BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 01 'FLO_SHAR conflict: Both FX + LO/UP specified, latter ignored'
      PUT QLOG ' WARNING       -     R=',%RL%,' Y=',V.TL,' P=',%PL%,' CG=',CG.TL,' C=',C.TL ;
    RTPGIG(R,V,P,C,'OUT',CG) = YES;
  );
  FLO_SHAR(R,V,P,C,CG,S,BDNEQ)$RTPGIG(R,V,P,C,'OUT',CG) = 0;
  OPTION CLEAR=RTPGIG;
*-----------------------------------------------------------------------------
* Eliminate very small FLO_SHAR
$IF NOT SET SHARETOL $SETLOCAL SHARETOL 9E-5
 FLO_SHAR(RTP(R,V,P),C,CG,S(TSL),BD('UP'))$((FLO_SHAR(RTP,C,CG,S,BD)$COM_GMAP(R,CG,C) GE 1)$FLO_SHAR(RTP,C,CG,S,BD)) = 0;
 FLO_SHAR(R,V,P,C,CG,S,BDUPX(BD))$((FLO_SHAR(R,V,P,C,CG,S,BD) LT %SHARETOL%)$FLO_SHAR(R,V,P,C,CG,S,BD)) = EPS;
 FLO_SHAR(R,V,P,C,CG,S,BDLOX(BD))$((ABS(FLO_SHAR(R,V,P,C,CG,S,BD)-1) LT %SHARETOL%)$FLO_SHAR(R,V,P,C,CG,S,BD)) = 1;
*-----------------------------------------------------------------------------
* Check for redundant fixed shares
* RTP_CGC(R,V,P,C,CG) $= FLO_SHAR(R,V,P,C,CG,'ANNUAL','FX');
* Get the good Groups by including those that have not been fixed
 RTPGIG(RTP_CG(R,V,P,CG,IO),C)$((NOT RTP_CGC(R,V,P,C,CG))$RP_GIC(R,P,CG,IO,C)) = YES;
 LOOP(RTPGIG(R,V,P,CG,IO,C), RTP_GRP(R,V,P,CG,IO) = YES);
 OPTION CLEAR=RTPGIG; PUTGRP=0;
 LOOP(RTP_CG(R,V,P,CG,IO)$(NOT RTP_GRP(R,V,P,CG,IO)),
   Z = SUM(RP_GIC(R,P,CG,IO,C),FLO_SHAR(R,V,P,C,CG,'ANNUAL','FX')+8);
   F = MOD(Z,8);
   IF(ABS(F-1) GT .001,
$    BATINCLUDE pp_qaput.mod PUTOUT PUTGRP 07 'Inconsistent sum of fixed FLO_SHAREs in Group'
     PUT QLOG ' SEVERE ERROR  -     R=',%RL%,' P=',%PL%,' V=',V.TL,' CG=',CG.TL,' SUM=',F:0:5;);
   F = MAX(F-1,F/Z*8-%SHARETOL%);
$IF NOT %SHARELAX%==NO
   LOOP(RP_GIC(R,P,CG,IO,C)$Z, IF(FLO_SHAR(R,V,P,C,CG,'ANNUAL','FX') GT F, Z=0; RTPGIG(R,V,P,CG,IO,C) = YES));
 );
 IF(CARD(RTPGIG),
   LOOP(IO,FLO_SHAR(R,V,P,C,CG,S,BD)$RTPGIG(R,V,P,CG,IO,C) = 0);
   F=CARD(RTPGIG); DISPLAY 'Redundant Veda FLO_SHAR bounds removed:',F);
 OPTION CLEAR=RTP_GRP;
*------------------------------------------------------------------------------
* Check for defective FX/UP shares
  RTP_CGC(R,V,P,C,CG) $= FLO_SHAR(R,V,P,C,CG,'ANNUAL','UP');
* Get the good Groups by including those that have not been fixed
  RTPGIG(RTP_CG(R,V,P,CG,IO),C)$((NOT RTP_CGC(R,V,P,C,CG))$RP_GIC(R,P,CG,IO,C)) = YES;
  LOOP(RTPGIG(R,V,P,CG,IO,C), RTP_GRP(R,V,P,CG,IO) = YES);
  OPTION CLEAR=RTPGIG; PUTGRP=0;
  LOOP(RTP_CG(R,V,P,CG,IO)$(NOT RTP_GRP(R,V,P,CG,IO)),
    F = SUM((RP_GIC(R,P,CG,IO,C),BDUPX),FLO_SHAR(R,V,P,C,CG,'ANNUAL',BDUPX));
    IF(F LT 1+%SHARETOL%, Z = 1;
$IF NOT %SHARELAX%==NO LOOP(RP_GIC(R,P,CG,IO,C)$Z, MY_F=FLO_SHAR(R,V,P,C,CG,'ANNUAL','UP'); IF((MY_F GT F-1)$MY_F, Z=0; RTPGIG(R,V,P,CG,'OUT',C)=YES));
     IF(F LT 1-%SHARETOL%$(NOT Z),
$     BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 07 'Defective sum of FX and UP FLO_SHAREs in Group'
      PUT QLOG ' SEVERE ERROR  -     R=',%RL%,' P=',%PL%,' V=',V.TL,' CG=',CG.TL,' SUM=',F:0:5;
      IF(NOT Z,PUT QLOG ' (Auto-relaxed)'))));
  OPTION CLEAR=RTP_GRP,CLEAR=RTP_CGC;
  LOOP(IO,LOOP(RTPGIG(R,V,P,CG,'OUT',C)$RP_GIC(R,P,CG,IO,C),RTP_GRP(R,V,P,CG,IO) = YES);
    RTP_CGC(R,V,P,CG,C)$(RP_GIC(R,P,CG,IO,C)$RTP_GRP(R,V,P,CG,IO)) = YES);
  FLO_SHAR(R,V,P,C,CG,'ANNUAL','FX')$(NOT RTPGIG(R,V,P,CG,'OUT',C)) $=
    FLO_SHAR(R,V,P,C,CG,'ANNUAL','UP')$RTP_CGC(R,V,P,CG,C);
  FLO_SHAR(R,V,P,C,CG,'ANNUAL',BDNEQ)$RTP_CGC(R,V,P,CG,C) = 0;
  OPTION CLEAR=RTP_GRP, CLEAR=RTP_CGC;
*------------------------------------------------------------------------------
* Check for excessive FX/LO shares
  RTP_CGC(R,V,P,C,CG) $= SUM(BDLOX$FLO_SHAR(R,V,P,C,CG,'ANNUAL',BDLOX),1);
  LOOP((RP_GIC(R,P,CG,IO,C),RTP_CGC(R,V,P,C,CG)),RTP_GRP(R,V,P,CG,IO) = YES);
  OPTION CLEAR=RTPGIG; PUTGRP=0;
  LOOP(RTP_GRP(RTP_CG(R,V,P,CG,IO)),
    F = SUM((RP_GIC(R,P,CG,IO,C),BDLOX),FLO_SHAR(R,V,P,C,CG,'ANNUAL',BDLOX));
    IF(F GT 1-%SHARETOL%, Z = 1; MY_F = 0;
     IF(F GT 1+%SHARETOL%, MY_F = 1;
$     BATINCLUDE pp_qaput.%1 PUTOUT PUTGRP 07 'Excessive sum of FX and LO FLO_SHAREs in Group'
      PUT QLOG ' SEVERE ERROR  -     R=',%RL%,' P=',%PL%,' V=',V.TL,' CG=',CG.TL,' SUM=',F:0:5;);
      F = MAX(0,F-1); LOOP((RP_GIC(R,P,CG,IO,C),BDLOX)$Z, IF(FLO_SHAR(R,V,P,C,CG,'ANNUAL',BDLOX) GT F, Z=0;
$IF NOT %SHARELAX%==NO  RTPGIG(R,V,P,CG,'OUT',C) = YES; IF(MY_F,PUT QLOG ' (Auto-relaxed)';);
   ))));
  OPTION CLEAR=RTP_GRP,CLEAR=RTP_CGC;
  LOOP(IO,LOOP(RTPGIG(R,V,P,CG,'OUT',C)$RP_GIC(R,P,CG,IO,C),RTP_GRP(R,V,P,CG,IO) = YES);
    RTP_CGC(R,V,P,CG,C)$(RP_GIC(R,P,CG,IO,C)$RTP_GRP(R,V,P,CG,IO)) = YES);
  FLO_SHAR(R,V,P,C,CG,'ANNUAL','FX')$RTP_CGC(R,V,P,CG,C) =
    FLO_SHAR(R,V,P,C,CG,'ANNUAL','LO')+FLO_SHAR(R,V,P,C,CG,'ANNUAL','FX')+EPS;
  FLO_SHAR(R,V,P,C,CG,'ANNUAL',BD)$((BDNEQ(BD)+RTPGIG(R,V,P,CG,'OUT',C))$RTP_CGC(R,V,P,CG,C)) = 0;
  OPTION CLEAR=RP_GIC, CLEAR=RTP_CGC, CLEAR=RTPGIG, CLEAR=RTP_CG, CLEAR=RTP_GRP;
  PUTGRP=0;
*-----------------------------------------------------------------------------
