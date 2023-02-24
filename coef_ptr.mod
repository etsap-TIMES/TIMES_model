*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* COEF_PTR is the coef and control with regard to which VAR_FLOs to create    *
*=============================================================================*
*GaG Questions/Comments:
*-----------------------------------------------------------------------------*
* hold on to the most granular specification for the p/c/s dealing with
* build intermediate test sets
    SET CGTEST(REG,ALLYEAR,PRC,CG,C,CG) //;
    SET CGTES2(REG,ALLYEAR,PRC,CG,C,CG) //;
* Add FLO_SUM tuples; Accept any RPC for the single commodity
    OPTION CGTEST <= FLO_SUM;
    CGTEST(R,V,P,COM_GRP,C,CG)$(NOT RPC(R,P,C)) = NO;
* Add reverse FLO_FUNCs for matching FLO_SUM (cg2=cg1)
    LOOP((CGTEST(R,V,P,COM_GRP,C,CG),S)$FLO_FUNC(R,V,P,CG,COM_GRP,S),CG_GRP(R,P,COM_GRP,CG) = YES);
    CGTES2(RTP(R,V,P),COM_GRP,C,CG)$((COM_GMAP(R,COM_GRP,C)*RPC(R,P,C))$CG_GRP(R,P,COM_GRP,CG)) = YES;
* Add forward FLO_FUNCs including all RPC in CG1
    LOOP((RTP(R,V,P),COM_GRP,CG,S)$FLO_FUNC(RTP,COM_GRP,CG,S),CGTES2(RTP,COM_GRP,C,CG)$(COM_GMAP(R,COM_GRP,C)*RPC(R,P,C)) = YES);
    CGTES2(CGTEST(RTP,C,COM,CG)) $= CGTES2(RTP,C,C,CG);
    OPTION CG_GRP <= CGTEST;

* Modified loop into direct assignment for speed-up
    COEF_PTRAN(CGTES2(R,V,P,COM_GRP,C,CG),S)$((YES$FLO_SUM(CGTES2,S)+(NOT CG_GRP(R,P,CG,COM_GRP)))$RPCS_VAR(R,P,C,S)) =
* a flo_sum for the c in cg1 or
* a flo_func for cg2 (as according to cgtest there must also be a flo_sum for some c in cg1), or
* a flo_func for cg1 without a flo_sum for cg2
      SUM((PRC_TSL(R,P,TSL),TS_GROUP(R,TSL,TS))$TS_MAP(R,TS,S),
        ((1+(1/FLO_FUNC(R,V,P,CG,COM_GRP,TS)-1)$FLO_FUNC(R,V,P,CG,COM_GRP,TS))$(NOT FLO_FUNC(R,V,P,COM_GRP,CG,TS)) +
         FLO_FUNC(R,V,P,COM_GRP,CG,TS)) * (1$(NOT FLO_SUM(CGTES2,S)) + FLO_SUM(CGTES2,S)));
    COEF_PTRAN(CGTEST(R,V,P,CG,C,CG2),S)$((NOT CGTES2(CGTEST))$RPCS_VAR(R,P,C,S)) $= FLO_SUM(CGTEST,S);

* Convert reduced flows
    KEEP_FLOF(RPC_AFLO(R,P,C)) = NO;
    ACT_FLO(RTP(R,V,P),C,S)$(RPCS_VAR(R,P,C,S)$KEEP_FLOF(R,P,C)) =
      SUM((RPCG_PTRAN(RPC_ACT(R,P,COM),C,CG,CG4),PRC_TS(R,P,TS))$TS_MAP(R,TS,S),PRC_ACTFLO(RTP,COM)*COEF_PTRAN(RTP,CG,COM,CG4,TS)) +
      SUM(RPCG_PTRAN(R,P,C,COM,CG,CG4)$COEF_PTRAN(RTP,CG,C,CG4,S),PRC_ACTFLO(RTP,COM)/COEF_PTRAN(RTP,CG,C,CG4,S));
    CGTEST(CGTES2) = YES;
    COEF_PTRAN(CGTEST(R,V,P,CG,C,COM),S)$RPCG_PTRAN(R,P,C,COM,CG,COM) = 0;

* Build the control set for EQ_PTRANS by removing REDUCEd tuples:
  OPTION CG_GRP <= CGTEST;
  CG_GRP(RPCC_FFUNC) = NO;
  OPTION RPCC_FFUNC <= CG_GRP;

* Remove derived commodities not in process topology, add QA PRC_CGs
  OPTION RP_GRP <= CG_GRP; PRC_CG(RP_GRP)=YES; OPTION RP_GRP < CG_GRP; PRC_CG(RP_GRP)=YES;
  RPCC_FFUNC(R,P,CG,C)$(RC(R,C)$(NOT RPC(R,P,C))) = NO;

* Free memory
  OPTION CLEAR=CG_GRP,CLEAR=RP_GRP,CLEAR=CGTEST,CLEAR=CGTES2;
