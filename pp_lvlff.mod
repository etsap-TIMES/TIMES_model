*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_LVLFF set the level of FLO_FUNC attribute using aggregation/inheritance
*   %1 - mod or v# for the source code to be used
*=============================================================================*
*GaG Questions/Comments:
* - Assumption is that values can be given at any levels
*-----------------------------------------------------------------------------
*$ONLISTING
  SET FFCKS(REG,PRC,CG,CG,S)  //;

* check all commodities in the groups of a process at other than PRC_TS level
  LOOP(V,FFCKS(R,P,CG,COM_GRP,S)$((NOT PRC_TS(R,P,S))$FLO_FUNC(R,V,P,CG,COM_GRP,S)) = YES);
  LOOP(FFCKS(R,P,CG,COM_GRP,S)$(NOT ANNUAL(S)),CG_GRP(R,P,CG,COM_GRP) = YES);
*-----------------------------------------------------------------------------
* Leveling by simultaneous aggregation/inheritance
*-----------------------------------------------------------------------------
  LOOP((CG_GRP(R,P,CG,COM_GRP),RTP(R,V,P)),
    TS_ARRAY(ALL_TS) = FLO_FUNC(R,V,P,CG,COM_GRP,ALL_TS);
    FLO_FUNC(R,V,P,CG,COM_GRP,TS)$PRC_TS(R,P,TS) =
      SUM(RS_TREE(FINEST(R,S),TS), G_YRFR(R,S) * (TS_ARRAY(S) +
           SUM(RS_BELOW(R,ALL_TS,S)$((NOT SUM(TS_MAP(R,SL,S)$RS_BELOW(R,ALL_TS,SL),TS_ARRAY(SL)))$TS_ARRAY(ALL_TS)),
               TS_ARRAY(ALL_TS))))/G_YRFR(R,TS));
*-----------------------------------------------------------------------------
* Leveling by direct inheritance
*-----------------------------------------------------------------------------
  FLO_FUNC(R,V,P,CG,COM_GRP,TS)$(NOT FLO_FUNC(R,V,P,CG,COM_GRP,TS)) $=
      SUM(FFCKS(R,P,CG,COM_GRP,ANNUAL)$PRC_TS(R,P,TS),FLO_FUNC(R,V,P,CG,COM_GRP,ANNUAL));
*-----------------------------------------------------------------------------

*UR* after inheritance aggregation delete all data that are not specified for elements of PRC_TS
* ? not a good idea since at least partially deleting the input of the user ?
*
*  FLO_FUNC(R,T,P,CG,COM_GRP,S)$(FFCKS(R,P,CG,COM_GRP,S)*(NOT PRC_TS(R,P,S))) = 0;

  OPTION CLEAR = FFCKS, CLEAR = CG_GRP;
*$OFFLISTING

