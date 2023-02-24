*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQOBJVAR the objective functions variable costs, variable O&M and commodity
*          direct costs
*   %1 - mod or v# for the source code to be used
*=============================================================================*
* Questions/Comments:
* - Top-level SUM over Y_EOH moved to individual components
* - This version works for the alternative objective formulations ALT/LIN
*-----------------------------------------------------------------------------
$SET TPULSE PERIODYR(T,Y_EOH),OBJ_DISC(R,Y_EOH,CUR)
$IFI %OBJ%==ALT     $SET TPULSE PERIODYR(T,Y_EOH),OBJ_ALTV(R,T)*OBJ_DISC(R,Y_EOH,CUR)
$IFI %OBJ%==LIN     $SET TPULSE TPULSEYR(T,Y_EOH),TPULSE(T,Y_EOH)*OBJ_DISC(R,Y_EOH,CUR)
$IFI %VARCOST%==LIN $SET TPULSE Y_EOH$OBJ_LINT(R,T,Y_EOH,CUR),OBJ_LINT(R,T,Y_EOH,CUR)
*===============================================================================
* Generate Variable cost equation summing over all active indexes by region and currency
*===============================================================================

%2   %EQ%_OBJVAR(RDCUR(R,CUR) %SOW%) ..

$IF %STAGES% == YES $SETLOCAL SWTD 'SUM(SW_TSW(SOW,T,WW),' SET SOW ',WW'
      (%SWTD%
*------------------------------------------------------------------------------
* Costs on Overall activity of a process
*------------------------------------------------------------------------------
* multiply storage activity by average residence time
          SUM(RTP_VARA(R,T,P)$OBJ_ACOST(R,T,P,CUR),
            SUM(%TPULSE% * OBJ_ACOST(R,Y_EOH,P,CUR)) *
            SUM((RTP_VINTYR(R,V,T,P),PRC_TS(R,P,S)),%VAR%_ACT(R,V,T,P,S %SOW%) *
                POWER(RS_STGAV(R,S),1$RP_STG(R,P)))
             ) +
* modal costs if modeled
          SUM(RTP_VINTYR(R,V,T,P)$RPC_CUR(R,P,%PGPRIM%,CUR), 
            SUM(RP_UPS(R,P,TSL,L('UP')),ACT_CSTUP(R,V,P,TSL,CUR)*OBJ_PVT(R,T,CUR)*SUM(TS_GROUP(R,TSL,S),RS_STGPRD(R,S)*%VAR%_UPS(R,V,T,P,S,L%SOW%))) +
            SUM(RP_UPT(R,P,UPT,'UP'),ACT_CSTSD(R,V,P,UPT,'FX',CUR)*OBJ_PVT(R,T,CUR)*SUM(TS_GROUP(R,TSL,S)$RP_DPL(R,P,TSL),RS_STGPRD(R,S)*%VAR%_UPT(R,V,T,P,S,UPT%SOW%))) +
            SUM(RP_UPR(R,P,BDNEQ(BD)),ACT_CSTRMP(R,V,P,BD,CUR)*OBJ_PVT(R,T,CUR)*SUM(PRC_TS(R,P,S),RS_STGPRD(R,S)*%VAR%_UDP(R,V,T,P,S,BD%SOW%)))) +

*------------------------------------------------------------------------------
* Commodity added costs and sub/tax
*------------------------------------------------------------------------------
     SUM(RHS_COMBAL(R,T,C,S), %VAR%_COMNET(R,T,C,S %SOW%) *
       SUM(%TPULSE% * SUM(COSTYPE,OBJ_COMNT(R,Y_EOH,C,S,COSTYPE,CUR)))) +
     SUM(RHS_COMPRD(R,T,C,S), %VAR%_COMPRD(R,T,C,S %SOW%) *
       SUM(%TPULSE% * SUM(COSTYPE,OBJ_COMPD(R,Y_EOH,C,S,COSTYPE,CUR)))) +
$IFI %STAGES%==YES SUM((RTCS_VARC(R,T,C,S),COM_VAR,W(WW))$S_COM_TAX(R,T,C,S,COM_VAR,CUR,'1',W),SUM(Y_EOH(Y)$OBJ_LINT(R,T,Y,CUR),OBJ_LINT(R,T,Y,CUR)*S_COM_TAX(R,Y,C,S,COM_VAR,CUR,'1',W))*(%VAR%_COMPRD(R,T,C,S%SOW%)$(ORD(COM_VAR)=2)+%VAR%_COMNET(R,T,C,S%SOW%)$UC_NAME(COM_VAR))) +

*------------------------------------------------------------------------------
* Commodity costs/tax/sub associated with imports/exports from outside study area
* - note that price only applied when actually an external region
*------------------------------------------------------------------------------
     SUM((RTPCS_VARF(R,T,P,C,S),RPC_IREIO(R,P,C,IE,'OUT')),
       SUM(%TPULSE% * OBJ_IPRIC(R,Y_EOH,P,C,S,IE,CUR)) *
       SUM(RTP_VINTYR(R,V,T,P),
         (%VAR%_IRE(R,V,T,P,C,S,IE %SOW%)$(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,T,P,S %SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C))
          )
        ) +

*------------------------------------------------------------------------------
* Flow level costs/tax/sub
*------------------------------------------------------------------------------
*GG* need to add VAR_NCAP if I/O/COM and FLO_COST/DELIV/SUB/TAX for commodity
*    based upon RPC_CAPFLOr,t,p,c
     SUM(RTPCS_VARF(R,T,P,C,S)$SUM(OBJ_VFLO(RP_FLO(R,P),C,CUR,UC_COST),1),
        SUM(TS_ANN(S,TS),
          SUM(%TPULSE% * (OBJ_FCOST(R,Y_EOH,P,C,TS,CUR)+OBJ_FDELV(R,Y_EOH,P,C,TS,CUR)+OBJ_FTAX(R,Y_EOH,P,C,TS,CUR)))) *
        SUM(RTP_VINTYR(R,V,T,P),
$            BATINCLUDE %cal_red% C COM S P T
          )) +

* same for IRE processes
     SUM(RTPCS_VARF(R,T,P,C,S)$SUM(OBJ_VFLO(RP_IRE(R,P),C,CUR,UC_COST),1),
        SUM(TS_ANN(S,TS),
          SUM(%TPULSE% * (OBJ_FCOST(R,Y_EOH,P,C,TS,CUR)+OBJ_FDELV(R,Y_EOH,P,C,TS,CUR)+OBJ_FTAX(R,Y_EOH,P,C,TS,CUR)))) *
        SUM(RTP_VINTYR(R,V,T,P),
            SUM(RPC_IRE(R,P,C,IE),
              %VAR%_IRE(R,V,T,P,C,S,IE %SOW%)$(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,T,P,S %SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C)
               ) +
*V06a_3 handle aux delivery cost to exchange processes, BUT NOT HANDLING different TSlevel!!!
* Negative IRE_FLOSUM is resonable for import flows only, and for the commodity itself
$IF DEFINED RTP_FFCS $SET MX "*(%SHFF%S(R,V,P,C,C%SOW%))"
            SUM((RPC_IRE(R,P,COM,IE),IO)$IRE_FLOSUM(R,T,P,COM,S,IE,C,IO),
                IRE_FLOSUM(R,T,P,COM,S,IE,C,IO) %MX% *
                (%VAR%_IRE(R,V,T,P,COM,S,IE %SOW%)$(NOT RPC_AIRE(R,P,COM))+(%VAR%_ACT(R,V,T,P,S %SOW%)*PRC_ACTFLO(R,V,P,COM))$RPC_AIRE(R,P,COM))
             ))) +
*V3.3.3 support costs also for storage flows (FCOST for IN, FDELV for OUT)
     SUM(OBJ_VFLO(RPC_STG(R,P,C),CUR,'COST'),
       SUM((RTP_VINTYR(R,V,T,P),RPCS_VAR(R,P,C,S)),
         SUM(TS_ANN(S,TS),SUM(%TPULSE% * (%VAR%_SIN(R,V,T,P,C,S%SOW%)*OBJ_FCOST(R,Y_EOH,P,C,TS,CUR)+%VAR%_SOUT(R,V,T,P,C,S%SOW%)*STG_EFF(R,V,P)*OBJ_FDELV(R,Y_EOH,P,C,TS,CUR))))))
$IF %STAGES%==YES )
       ) +

*V05c 980924 handle the fact that commodity costs may be associated with capacity
* note that G_YRFR fraction in the cal_*.mod files
* [AL] Moved cost summation over TPULSEYR inside called routines; V must be in RTP, but T need not be
     SUM(ANNUAL(S),
$        BATINCLUDE cal_caps.%1 T 'SUM(TS_ANN(TS,SL),SUM(%TPULSE%*(OBJ_FCOST(R,Y_EOH,P,C,SL,CUR)+OBJ_FDELV(R,Y_EOH,P,C,SL,CUR)+OBJ_FTAX(R,Y_EOH,P,C,SL,CUR))))' TS
        ) +

*------------------------------------------------------------------------------
* Commodity blending costs
*------------------------------------------------------------------------------
     SUM((BLE_OPR(R,BLE,OPR),TT(T)),
        SUM(%TPULSE% * OBJ_BLNDV(R,Y_EOH,BLE,OPR,CUR)) * %VART%_BLND(R,T,BLE,OPR %SWS%)
        )

    =E=

$IF %STAGES% == YES $SET SOW ',SOW'

%2    SUM(OBV,SUM_OBJ('OBJVAR',OBV)*%VAR%_OBJ(R,OBV,CUR %SOW%));
