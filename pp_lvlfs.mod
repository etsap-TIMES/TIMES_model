*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_LVLFS set the level of FLO_SUM attribute using aggregation/inheritance
*   %1 - mod or v# for the source code to be used
*=============================================================================*
*GaG Questions/Comments:
*  - Assumption is that values can be at any level
*-----------------------------------------------------------------------------
*$ONLISTING
  SET FSTSL(TSLVL,R,P,CG,CG,CG,S) //;

* check all commodities in the groups of a process at other than PRC_TS level
  COEF_PTRAN(R,LL,P,CG,C,COM_GRP,S) $= FLO_SUM(R,LL,P,CG,C,COM_GRP,S)$(NOT RPCS_VAR(R,P,C,S));
  OPTION FSCKS <= COEF_PTRAN;
  FSCK(R,P,CG,C,COM_GRP) $= SUM(FSCKS(R,P,CG,C,COM_GRP,S)$(NOT RPS_PRCTS(R,P,S)),1);
  LOOP(ANNUAL(TS(TSLVL)),FSTSL(TSLVL+STOAL(R,S),FSCKS(R,P,CG,C,COM_GRP,S)) = YES);
*-----------------------------------------------------------------------------
* Leveling by simultaneous aggregation/inheritance
*-----------------------------------------------------------------------------
  LOOP((FSCK(R,P,CG,C,COM_GRP),RTP(R,V,P)),
    TS_ARRAY(ALL_TS) = FLO_SUM(R,V,P,CG,C,COM_GRP,ALL_TS);
    FLO_SUM(R,V,P,CG,C,COM_GRP,TS)$RPCS_VAR(R,P,C,TS) =
      SUM(RS_TREE(FINEST(R,S),TS), G_YRFR(R,S) * (TS_ARRAY(S) +
           SUM(RS_BELOW(R,ALL_TS,S)$((NOT SUM(TS_MAP(R,SL,S)$RS_BELOW(R,ALL_TS,SL),TS_ARRAY(SL)))$TS_ARRAY(ALL_TS)),
               TS_ARRAY(ALL_TS))))/G_YRFR(R,TS));
*-----------------------------------------------------------------------------
* Leveling by direct inheritance
*-----------------------------------------------------------------------------
* after mixed aggregation/inheritance delete all data that are not specified at PRC_TS
  FLO_SUM(R,LL,P,CG,C,COM_GRP,S)$COEF_PTRAN(R,LL,P,CG,C,COM_GRP,S) = 0;
  FLO_SUM(R,LL,P,CG,C,COM_GRP,S)$(NOT RTP(R,LL,P)) = 0;
  FOR(Z=CARD(TSLVL)-2 DOWNTO 0,
   LOOP(SAMEAS(TSLVL-Z,'ANNUAL'),
    FLO_SUM(RTP(R,V,P),CG,C,COM_GRP,TS)$((NOT FLO_SUM(R,V,P,CG,C,COM_GRP,TS))$RPCS_VAR(R,P,C,TS)) $=
       SUM(FSTSL(TSLVL,R,P,CG,C,COM_GRP,S)$RS_BELOW(R,S,TS),COEF_PTRAN(R,V,P,CG,C,COM_GRP,S));
  ));
*-----------------------------------------------------------------------------
  OPTION CLEAR=COEF_PTRAN, CLEAR = FSCK, CLEAR = FSCKS, CLEAR=FSTSL;
  FLO_SUM(R,LL,P,CG,C,CG,S)$FSCKS(R,P,CG,C,CG,S) = 0;
*$OFFLISTING
