*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* EQSTGTSS TIME-Slice Storage (TSS) and general storage (STS)
*=============================================================================*
*UR Questions/Comments:
*   - the storage level in one TS has to be fixed by ACT_BND to an initial storage level
*AL Comment:
*   - fixing by ACT_BND is no longer needed
*-----------------------------------------------------------------------------*
*$ONLISTING

    %EQ%_STGTSS(RTP_VINTYR(%R_V_T%,P),RTS(S)%SWT%)$(RPS_STG(R,P,S)$RP_STG(R,P))..

* storage level in time-slice s
          %VAR%_ACT(R,V,T,P,S %SOW%)

    =E=

          SUM(RPS_STG(R,P,ALL_TS(S--RS_STG(R,S))),
* storage level in time-slice s
               %VAR%_ACT(R,V,T,P,ALL_TS%SOW%)
               +
* for day-night storage; allow flow variable at or above ALL_TS
               (
                 SUM((RPCS_VAR(RPC_STG(R,P,C),TS),TS_MAP(R,TS,ALL_TS)),
                   (%VAR%_SIN(R,V,T,P,C,TS%SOW%)$(TOP(R,P,C,'IN')$PRC_NSTTS(R,P,TS)) -
                    %VAR%_SOUT(R,V,T,P,C,TS %SOW%)$(TOP(R,P,C,'OUT')$(NOT PRC_NSTTS(R,P,TS)))) *
                   RS_FR(R,ALL_TS,TS) * (1+RTCS_FR(R,T,C,ALL_TS,TS)) / PRC_ACTFLO(R,V,P,C))
               )$PRC_MAP(R,'NST',P)
               +
* for storage processes without charging restriction
               SUM(TOP(PRC_STGTSS(R,P,C),'IN'),%VAR%_SIN(R,V,T,P,C,ALL_TS%SOW%)/PRC_ACTFLO(R,V,P,C)) -
               SUM(TOP(PRC_STGTSS(R,P,C),'OUT'),%VAR%_SOUT(R,V,T,P,C,ALL_TS%SOW%)/PRC_ACTFLO(R,V,P,C))
               -
* optional balancer flow
               SUM(PRC_TS(R,P,TS)$RS_BELOW1(R,TS,S),%VAR%_SOUT(R,V,T,P,%PGPRIM%,TS%SOW%)*RS_FR(R,ALL_TS,TS))$RP_STS(R,P) -

* storage losses: average storage level per cycle * loss fraction by cycle * cycles
               (%VAR%_ACT(R,V,T,P,ALL_TS%SOW%)+%VAR%_ACT(R,V,T,P,S %SOW%)) / 2 *
               ((1-EXP(MIN(0,STG_LOSS(R,V,P,ALL_TS))*G_YRFR(R,ALL_TS)/RS_STGPRD(R,S))) +
                       MAX(0,STG_LOSS(R,V,P,ALL_TS))*G_YRFR(R,ALL_TS)/RS_STGPRD(R,S))
             )
* storage charge
    + STG_CHRG(R,T,P,S--RS_STG(R,S))

    ;


*--- Balancer Equation ---

    %EQ%_STSBAL(RTP_VINTYR(%R_V_T%,P),RTS(S)%SWT%)$((NOT RPS_STG(R,P,S))$PRC_TS(R,P,S)$RP_STS(R,P))..

* storage level in time-slice s
         SUM(RS_BELOW(R,ANNUAL,S),%VAR%_ACT(R,V,T,P,S %SOW%))

    =E=

         SUM(RS_BELOW(R,ANNUAL,ALL_TS(S--RS_STG(R,S))),
* storage level in time-slice s
             %VAR%_ACT(R,V,T,P,ALL_TS%SOW%)
             +
* balancer flows
             %VAR%_SOUT(R,V,T,P,%PGPRIM%,ALL_TS%SOW%) -
             SUM(PRC_TS(R,P,TS)$RS_BELOW1(R,TS,S),%VAR%_SOUT(R,V,T,P,%PGPRIM%,TS%SOW%)*RS_FR(R,ALL_TS,TS))
             -
* storage losses: average storage level * year fraction * loss fraction
             (%VAR%_ACT(R,V,T,P,ALL_TS%SOW%)+%VAR%_ACT(R,V,T,P,S%SOW%)) / 2 *
             ((1-EXP(MIN(0,STG_LOSS(R,V,P,ALL_TS))*G_YRFR(R,ALL_TS)/RS_STGPRD(R,S))) +
                     MAX(0,STG_LOSS(R,V,P,ALL_TS))*G_YRFR(R,ALL_TS)/RS_STGPRD(R,S))
            )
         +
         SUM(ANNUAL(S),
* net charging into IPS
             SUM(TOP(PRC_STGIPS(R,P,C),IO), 1 / PRC_ACTFLO(R,V,P,C) *
                %VAR%_SIN(R,V,T,P,C,S %SOW%)$IPS(IO) - %VAR%_SOUT(R,V,T,P,C,S %SOW%)$(NOT IPS(IO))) -
* balancer flow
             %VAR%_SOUT(R,V,T,P,%PGPRIM%,S%SOW%))

    ;


*$OFFLISTING
