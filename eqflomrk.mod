*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*==================================================================================================*
* EQx_FLMRK is a market share constraint for a commodity flow of a process
*   %1 - equation declaration type
*   %2 - BOUND type for %1
*==================================================================================================*
* Comments:
*---------------------------------------------------------------------------------------------------
*$ONLISTING
$IF NOT '%2' == '' $GOTO EQUDEF
*---------------------------------------------------------------------------------------------------
 SET RTX_MARK(R,T,ITEM,C,BD,S) //;
 SET RX_MARK(R,YEAR,ITEM,C,BD) //;
 SET RMKC(R,ITEM,C) //;

* Remove superfluous data points
 PRC_MARK(R,LL,P,ITEM,C,BDNEQ)$PRC_MARK(R,LL,P,ITEM,C,'FX') = NO;
 PRC_MARK(R,LL,P,ITEM,C,BD)$((NOT RTP_VARA(R,LL,P))$(NOT SAMEAS(P,ITEM))$PRC_MARK(R,LL,P,ITEM,C,BD)) = NO;

* Partitioning
 LOOP(T,RX_MARK(R,'0',P,C,BD)$((PRC_MARK(R,T,P,P,C,BD)$RP_STD(R,P) GE 0)$PRC_MARK(R,T,P,P,C,BD)) = YES);
 RX_MARK(R,T--ORD(T),P,C,BD) $= PRC_MARK(R,T,P,P,C,BD)$(NOT RX_MARK(R,'0',P,C,BD));
* Eliminate zero values; For standard processes set flow bound
 OPTION CLEAR=UNCD7,CLEAR=YK1;
 UNCD7(RTP_VARA(R,T,P),ITEM,C,BD,'')$((PRC_MARK(R,T,P,ITEM,C,BD) EQ 0)$PRC_MARK(R,T,P,ITEM,C,BD)) = YES;
 UNCD7(RTP_VARA(R,T,P),PRC,C,BD,'')$(PRC_MARK(R,T,PRC,PRC,C,BD)$RX_MARK(R,'0',PRC,C,BD)) = NO;
 LOOP(UNCD7(R,T,P,ITEM,C,BDUPX(BD),'')$RP_STD(R,P),FLO_BND(R,T,P,C,ANNUAL,BD) = EPS);
 PRC_MARK(R,T,P,ITEM,C,BD)$UNCD7(R,T,P,ITEM,C,BD,'') = 0;
* Make sure that data for all PRC in group are forward extrapolated
 LOOP((RTP_VARA(R,T,P),ITEM,C,BD)$PRC_MARK(R,T,P,ITEM,C,BD),RTX_MARK(R,T,ITEM,C,BD,'ANNUAL') = YES);
 YK1(TT,T(TT+1)) = YES;
 LOOP(YK1(TT,T),PRC_MARK(RTP_VARA(R,T,P),ITEM,C,BD)$(NOT PRC_MARK(R,T,P,ITEM,C,BD)) $= PRC_MARK(R,TT,P,ITEM,C,BD));
 PRC_MARK(R,T,P,ITEM,C,BD)$(NOT RTX_MARK(R,T,ITEM,C,BD,'ANNUAL')) = 0;
 OPTION CLEAR=UNCD7,CLEAR=RXX,CLEAR=YK1;

* Add ANNUAL level for PRC_MARK group commodities not in TOP
 LOOP((R,T,P,ITEM,C,BD)$PRC_MARK(R,T,P,ITEM,C,BD),RMKC(R,ITEM,C) = YES); OPTION TRACKC <= RMKC;
 TRACKC(RC) = NO; COM_TSL(TRACKC,'ANNUAL')$(NOT SUM(COM_TSL(TRACKC,TSLVL),1)) = YES;
* Prepare the COMPRD variables for all PRC_MARK parameters:
 OPTION CLEAR=TRACKC; LOOP(RMKC(R,ITEM,C),TRACKC(RC(R,COM))$COM_GMAP(R,C,COM) = YES);
 RHS_COMPRD(RTCS_VARC(R,T,C,S))$TRACKC(R,C) = YES;
 OPTION CLEAR=TRACKC,CLEAR=RXX;
* If ITEM is also P (ala FLO_MARK), or C is not in TOP, use commodity timeslices; else use ANNUAL
 LOOP(RX_MARK(R,LL,P,C,BD),RXX(R,P,C)=YES); RXX(RMKC(R,ITEM,C))$(NOT RC(R,C))=YES;
 RXX(R,ITEM,C)$COM_TSL(R,C,'ANNUAL') = NO;
 UNCD7(RTX_MARK(R,T,ITEM,C,BD,S),'')$RXX(R,ITEM,C) = YES; RTX_MARK(R,T,ITEM,C,BD,S)$UNCD7(R,T,ITEM,C,BD,S,'') = NO;
 LOOP((RXX(R,ITEM,C),COM_TSL(R,C,TSLVL)),RTX_MARK(R,T,ITEM,C,BD,S)$(TS_GROUP(R,TSLVL,S)$UNCD7(R,T,ITEM,C,BD,'ANNUAL','')) = YES);

$EXIT
*===================================================================================================
$LABEL EQUDEF
$SETLOCAL IRED ""
$IF %REDUCE% == YES $SETLOCAL IRED "$(NOT RPC_AIRE(R,P,C))+%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,C)$RPC_AIRE(R,P,C)"
* For IRE/STG: Output flow from process if PRC_MARK >= 0, Input flow if PRC_MARK <= 0
$SETLOCAL SIGO "(PRC_MARK(R,T,P,ITEM,COM,'%2') GE 0)" SETLOCAL SIGI "(PRC_MARK(R,T,P,ITEM,COM,'%2') LE 0)"
*===================================================================================================

%EQ%%1_FLOMRK(%R_T%,ITEM,COM,S %SWT%)$RTX_MARK(R,T,ITEM,COM,'%2',S) ..

* Sum over all processes with PRC_MARK(COM) (not just capacity-related)
  SUM(P$PRC_MARK(R,T,P,ITEM,COM,'%2'),
      POWER(PRC_MARK(R,T,P,ITEM,COM,'%2'),1$RX_MARK(R,'0',ITEM,COM,'%2')-1) *

* Sum over all COMPRD balance variables related to timeslice S
    SUM((RHS_COMPRD(R,T,C,SL),RS_TREE(R,S,SL))$COM_GMAP(R,COM,C),

* Sum over all flow variables related to balance timeslice
         (SUM(RTPCS_VARF(R,T,P,C,TS)$RS_FR(R,SL,TS),
              SUM(RTP_VINTYR(R,V,T,P),
$               BATINCLUDE %cal_red% C COM1 TS P T
                 ) *
* Balance coarser than variable or balance finer than variable
              RS_FR(R,SL,TS)*(1+RTCS_FR(R,T,C,SL,TS))
         )*(1+(COM_IE(R,T,C,SL)-1)$TOP(R,P,C,'OUT')))$RP_STD(R,P)

* Inter-regional trade contribution
       + SUM(RTPCS_VARF(R,T,P,C,TS)$RS_FR(R,SL,TS),
           SUM(RTP_VINTYR(R,V,T,P),
             ((%VAR%_IRE(R,V,T,P,C,TS,'IMP'%SOW%)%IRED%)*(1+IRE_FLOSUM(R,T,P,C,S,'IMP',C,'OUT'))*COM_IE(R,T,C,SL))$(%SIGO%$RPC_IRE(R,P,C,'IMP'))-
             ((%VAR%_IRE(R,V,T,P,C,TS,'EXP'%SOW%)%IRED%)*(1+IRE_FLOSUM(R,T,P,C,S,'EXP',C,'IN')))$(%SIGI%$RPC_IRE(R,P,C,'EXP'))) *
* Balance coarser than variable or balance finer than variable
           RS_FR(R,SL,TS)*(1+RTCS_FR(R,T,C,SL,TS)))$RP_IRE(R,P)

* Storage contribution
       + SUM(RPCS_VAR(RPC_STG(R,P,C),TS)$RS_FR(R,SL,TS),
             SUM(RTP_VINTYR(R,V,T,P),
               ((%VAR%_SOUT(R,V,T,P,C,TS %SOW%)*STG_EFF(R,V,P)*COM_IE(R,T,C,SL))$%SIGO%-%VAR%_SIN(R,V,T,P,C,TS %SOW%)$%SIGI%)) *
* Balance coarser than variable or balance finer than variable
             RS_FR(R,SL,TS)*(1+RTCS_FR(R,T,C,SL,TS)))$PRC_MAP(R,'STG',P)

       ))

      =%1=

* Reference is the COMPRD variable
  SUM((RHS_COMPRD(R,T,C,SL),RS_TREE(R,S,SL))$COM_GMAP(R,COM,C),%VAR%_COMPRD(R,T,C,SL %SOW%)) *
  PROD(RX_MARK(R,LL,P(ITEM),COM,'%2'),PRC_MARK(R,T,P,P,COM,'%2')$LASTLL(LL))

;

*$OFFLISTING
