*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* EQPTRANS is the flow-to-flow transformation constraint
*=============================================================================*
*GaG Questions/Comments:
*  - EQ_PTRANS should be dropped if substition for FLO_FUNC activated
*  - EQ level according to RPS_S1, VAR_FLOs according RPCS_VAR
*  - COEF_PTRAN created in coef_ptr.mod
*-----------------------------------------------------------------------------
*$ONLISTING
$SET SHP1 "" SET SHG ",P,COM_GRP,CG"
$IF DEFINED RTP_FFCS $SET SHP1 "*(%SHFF%S(R,V%SHG%%SOW%))"
$SET SHP1 "*(%SHFF%X(R,V,T%SHG%)$PRC_VINT(R,P))%SHP1%"
*-----------------------------------------------------------------------------

    %EQ%_PTRANS(RTP_VINTYR(%R_V_T%,P),COM_GRP,CG,RTS(S)%SWT%)$((RPS_S1(R,P,S) * RP_STD(R,P) *
* All valid tuples are now in RPCC_FFUNC (REDUCE taken into account); all STG now excluded
                SUM((RPC(R,P,C),RS_TREE(R,S,TS))$COEF_PTRAN(R,V,P,COM_GRP,C,CG,TS),1))$RPCC_FFUNC(R,P,COM_GRP,CG))..

* dependent commodities
*M2T* consider that the commodity may have a COM_TS shape
       SUM((COM_GMAP(R,CG,C),RS_TREE(R,S,TS))$RTPCS_VARF(R,T,P,C,TS),
           RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS)) *
* [UR] model reduction %REDUCE% is set in *.run
$           BATINCLUDE %cal_red% C COM TS P T
          )

    =E=

* control commodities
       SUM((RTPCS_VARF(R,T,P,C,TS),RS_TREE(R,S,TS))$COEF_PTRAN(R,V,P,COM_GRP,C,CG,TS),
           COEF_PTRAN(R,V,P,COM_GRP,C,CG,TS) *
           RS_FR(R,S,TS)*(1+RTCS_FR(R,T,C,S,TS)) *
* [UR] model reduction %REDUCE% is set in *.run
$           BATINCLUDE %cal_red% C COM TS P T
          ) %SHP1%
    ;

*$OFFLISTING
