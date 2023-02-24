*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQSTGTSS TIME-Slice Storage (TSS) and general storage (STS)
*=============================================================================*
* Questions/Comments:
*   - the storage level does NOT need to be fixed to an initial storage level in some TS
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
                    %VAR%_SOUT(R,V,T,P,C,TS%SOW%)$(TOP(R,P,C,'OUT')$(PRC_NSTTS(R,P,TS) EQV RPC_STGN(R,P,C,'OUT')))) *
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
               %VAR%_ACT(R,V,T,P,ALL_TS%SOW%) * MAX(STG_LOSS(R,V,P,ALL_TS)/2,
* equilibrium loss (STG_LOSS<0): Act0 * (1-Loss/(1/EXP(-Loss)-1))
                 (1+(STG_LOSS(R,V,P,ALL_TS))/(1/EXP(STG_LOSS(R,V,P,ALL_TS))-1)))$STG_LOSS(R,V,P,ALL_TS) -
               %VAR%_ACT(R,V,T,P,S%SOW%) * MAX(STG_LOSS(R,V,P,ALL_TS)/2,
* equilibrium loss (STG_LOSS<0): Act1 * (-Loss/(EXP(-Loss)-1)-1)
                 ((STG_LOSS(R,V,P,ALL_TS))/(EXP(STG_LOSS(R,V,P,ALL_TS))-1)-1))$STG_LOSS(R,V,P,ALL_TS)
             )
* storage charge
    + STG_CHRG(R,T,P,S--RS_STG(R,S))

    ;


*--- Balancer Equation ---

    %EQ%_STSBAL(RTP_VINTYR(%R_V_T%,P),TSL,RTS(S),L%SWT%)$(TS_GROUP(R,TSL,S)$PRC_TS(R,P,S)$RP_STL(R,P,TSL,L))..

* storage level in time-slice s
         SUM(RS_BELOW(R,ANNUAL,S),%VAR%_ACT(R,V,T,P,S%SOW%)+(%VAR%_SIN(R,V,T,P,%PGPRIM%,S%SOW%)+VAR_STS(R,V,T,P,S,'N'))$RP_STL(R,P,TSL,'UP'))

    =E=

         SUM(RS_BELOW(R,ANNUAL,SL(S--RS_STG(R,S))),
* storage level in time-slice s
             %VAR%_ACT(R,V,T,P,SL%SOW%)$IPS(L) + %VAR%_UDP(R,V,T,P,SL,'LO'%SOW%)$BD(L) +
             (%VAR%_SIN(R,V,T,P,%PGPRIM%,SL%SOW%)+VAR_STS(R,V,T,P,SL,L))$RP_STL(R,P,TSL,'UP')
             +
* balancer flows
             (%VAR%_SOUT(R,V,T,P,%PGPRIM%,SL%SOW%) -
              SUM(PRC_TS(R,P,TS)$RS_BELOW1(R,TS,S),%VAR%_SOUT(R,V,T,P,%PGPRIM%,TS%SOW%)*RS_FR(R,SL,TS))
              -
* storage losses: average storage level * year fraction * loss fraction
              (%VAR%_ACT(R,V,T,P,SL%SOW%)$RS_STG(R,S)) * MAX(STG_LOSS(R,V,P,SL)/2,
* equilibrium loss (STG_LOSS<0): Act0 * (1-Loss/(1/EXP(-Loss)-1))
                (1+STG_LOSS(R,V,P,SL)/(1/EXP(STG_LOSS(R,V,P,SL))-1)))$STG_LOSS(R,V,P,SL) -
              (%VAR%_ACT(R,V,T,P,S%SOW%)$RS_STG(R,S)+(%VAR%_SIN(R,V,T,P,%PGPRIM%,S%SOW%)-%VAR%_SIN(R,V,T,P,%PGPRIM%,SL%SOW%))$RP_STL(R,P,TSL,'UP')) *
* equilibrium loss (STG_LOSS<0): Act1 * (-Loss/(EXP(-Loss)-1)-1)
              MAX(STG_LOSS(R,V,P,SL)/2, (STG_LOSS(R,V,P,SL)/(EXP(STG_LOSS(R,V,P,SL))-1)-1))$STG_LOSS(R,V,P,SL)
            )$IPS(L))
         +
         SUM(ANNUAL(S),
* net charging into IPS
             SUM(TOP(PRC_STGIPS(R,P,C),IO), 1 / PRC_ACTFLO(R,V,P,C) *
                %VAR%_SIN(R,V,T,P,C,S %SOW%)$IPS(IO) - %VAR%_SOUT(R,V,T,P,C,S %SOW%)$(NOT IPS(IO))) -
* balancer flow
             %VAR%_SOUT(R,V,T,P,%PGPRIM%,S%SOW%))

    ;


*--- Levelizer Equation ---

    EQ_STSLEV(RTP_VINTYR(%R_V_T%,P),TSL,RTS(S)%SWX%)$((STOAL(R,S)=PRC_SGL(R,P))$TS_GROUP(R,TSL,S)$RP_STL(R,P,TSL,'UP'))..

* Sum of levelizers must be less than average variation over S
        SUM(TS_MAP(R,TS,S)$STOA(TS),(%VAR%_SIN(R,V,T,P,%PGPRIM%,TS%SOW%)+%VAR%_UDP(R,V,T,P,TS,'LO'%SOW%)+VAR_STS(R,V,T,P,TS,'N'))/RS_STGPRD(R,TS))
        =L=
        SUM(RS_BELOW1(R,S,TS)$RS_FR(R,TS,S),%VAR%_ACT(R,V,T,P,TS%SOW%)/RS_STGPRD(R,TS)*RS_FR(R,TS,S));

*$OFFLISTING