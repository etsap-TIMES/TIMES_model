*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_LVLPK - levelization of NCAP_PKCNT
*   %1 - Default value for leveling
*=============================================================================*
* Questions/Comments:
*  -
*-----------------------------------------------------------------------------
SET RPC_PKC(R,P,C);
PARAMETER RPC_PKF(R,P,C) //;
*-----------------------------------------------------------------------------
* Collect PKTS for all COM_PEAK commodities
LOOP(COM_PKTS(R,CG,S), RCS(COM_TS(R,C,TS))$(RS_TREE(R,S,TS)$COM_GMAP(R,CG,C)) = YES);
TRACKC(R,C) $= SUM(RCS(R,C,S),1);
*-----------------------------------------------------------------------------
* Levelization of NCAP_PKCNT
LOOP((RTP(R,V,P),S)$NCAP_PKCNT(R,V,P,S),
  RTP_GRP(R,V,P,C,IO('OUT'))$(SUM(RCS(R,C,TS)$(NOT NCAP_PKCNT(R,V,P,TS)),1)$RPC(R,P,C)) = YES);
*-----------------------------------------------------------------------------
* Aggregation/inheritance to target timeslices
*-----------------------------------------------------------------------------
LOOP(RTP_GRP(R,V,P,C,IO), TS_ARRAY(S) = NCAP_PKCNT(R,V,P,S);
 IF((NOT SUM(RS_BELOW(R,'ANNUAL',S)$TS_ARRAY(S),1))$TS_ARRAY('ANNUAL'),
   NCAP_PKCNT(R,V,P,S)$RCS(R,C,S) = TS_ARRAY('ANNUAL');
 ELSE
* Set leveling default = %1;
  TS_ARRAY('ANNUAL')$(NOT TS_ARRAY('ANNUAL')) = %1;
* Simultaneous inheritance/aggregation; but only if target level value is not present
   LOOP(RCS(R,C,TS)$(NOT TS_ARRAY(TS)),
     NCAP_PKCNT(R,V,P,TS) $=
       SUM(TS_MAP(R,TS,S)$FINEST(R,S), G_YRFR(R,S)/G_YRFR(R,TS) * (TS_ARRAY(S) +
             SUM(RS_BELOW(R,ALL_TS,S)$((NOT SUM(SL$RS_BELOW(R,ALL_TS,SL),TS_MAP(R,SL,S)*TS_ARRAY(SL)))$TS_ARRAY(ALL_TS)),
                  TS_ARRAY(ALL_TS)))))));
*-----------------------------------------------------------------------------
* Peak contribution
 TRACKPC(R,P,C)$((TOP(R,P,C,'OUT')+RPC_IRE(R,P,C,'IMP'))$TRACKC(R,C)) = YES;
* If PRC_PKAF, apply PKCNT only for capacity
 TRACKP(PRC_PKAF(RP))=NOT PRC_PKNO(RP); RPC_PKF(TRACKPC(RP,C))=EPS**1$TRACKP(RP);
 TRACKPC(PRC_PKNO(RP),C)=NO;
* If no PKCNT provided, Copy NCAP_AF if PRC_PKAF; Otherwise set default 1
 LOOP(TRACKPC(R,P,C),PRC_TS2(R,P,S)$((NOT SUM(RTP(R,V,P),NCAP_PKCNT(RTP,S)))$RCS(R,C,S)) = YES);
 NCAP_PKCNT(RTP(R,V,P),S)$PRC_TS2(R,P,S) = 1$(NOT PRC_PKAF(R,P)) +
   SUM(PRC_TS(R,P,TS)$RS_TREE(R,S,TS),SMAX(BD,NCAP_AF(RTP,TS,BD))*(1+(G_YRFR(R,TS)/G_YRFR(R,S)-1)$RS_BELOW(R,S,TS)))$PRC_PKAF(R,P);
*-----------------------------------------------------------------------------
* RPC_PKC indicator for peak contribution by capacity
 RPC_PKC(TRACKPC(RPC_ACT(TRACKP(RP_STD),C)))=YES;
 TRACKPC(RP,C)$(NOT RPC_PG(RP,C)*RP_FLO(RP))=NO;
 RPC_PKC(TRACKPC(RP_PGACT(RP),C))$(RP_PG(RP,C)+TRACKP(RP))=YES;
 LOOP(NRG_TMAP(R,'ELC',C)$TRACKC(R,C),RPC_PKC(TRACKPC(TRACKP(R,P),C))=YES;TRACKP(R,P)$TRACKPC(R,P,C)=NO);
 OPTION CLEAR=TRACKP,CLEAR=TRACKC,CLEAR=TRACKPC,CLEAR=RTP_GRP,CLEAR=RCS,CLEAR=PRC_TS2;
