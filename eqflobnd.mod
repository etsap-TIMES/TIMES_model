*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQFLOBND limits the flow variable at higher TS-leves
*   %1 - equation declaration type
*   %2 - bound type for %1
*   %3 - qualifier that bound exists
*=============================================================================*
*UR Questions/Comments:
*-----------------------------------------------------------------------------
*$ONLISTING

  %EQ%%1_FLOBND(RTP_VARA(%R_T%,P),CG,S %SWT%)$(
* Make an equation of the bound if there are flow variables for commodities in CG that are strictly below S,
* ...or the tuple has been otherwise rejected for VAR bound (process is vintaged or IRE, or flow is reduced):
                                SUM(RTPCS_VARF(R,T,P,C,TS)$(TS_MAP(R,S,TS)*COM_GMAP(R,CG,C)),
                                    RS_BELOW(R,S,TS) OR FLO_BND(R,'%DFLBL%',P,CG,S,'%2')
                                   )$FLO_BND(R,T,P,CG,S,'%2')
                                ) ..

* sum over all flows that are either at S or below it
       (SUM((COM_GMAP(R,CG,C),RTPCS_VARF(R,T,P,C,TS))$TS_MAP(R,S,TS),
* sum all the existing flows
           SUM(RTP_VINTYR(R,V,T,P),
* [UR] model reduction %REDUCE% is set in *.run
            (
$              BATINCLUDE %cal_red% C COM TS P T
            )$RP_FLO(R,P) +

* [AL] add support for IRE
            SUM(RPC_IRE(R,P,C,IE),(%VAR%_IRE(R,V,T,P,C,TS,IE%SOW%)
$IF %REDUCE% == 'YES'
                 $(NOT RPC_AIRE(R,P,C))+(%VAR%_ACT(R,V,T,P,TS%SOW%)*PRC_ACTFLO(R,V,P,C))$RPC_AIRE(R,P,C)
* apply IRE bound on net flow if group used, otherwise on sum of IMP/EXP
            )*(1-2$XPT(IE)$(NOT COM(CG))))$RP_IRE(R,P)
           )
         )

     -  FLO_BND(R,T,P,CG,S,'%2'))$%3

  =%1= 0;

*$OFFLISTING
