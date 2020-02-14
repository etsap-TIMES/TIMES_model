*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*==============================================================================
* Exporting shadow prices of commodity balances to be used as bprice
* for elastic demands into a gdx file called Com_bprice.GDX
*==============================================================================
  PARAMETER DINV(R,ALLYEAR,ALLYEAR,CUR) / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER SOL_BPRICE(REG,ALLYEAR,COM,ALL_TS,CUR) /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0/;
*------------------------------------------------------------------------------
* General undiscounting via matrix inversion currently disabled; using direct method
  DINV(R,T,T,CUR)$G_RCUR(R,CUR) = 1/COEF_PVT(R,T);

 SOL_BPRICE(R,T,C,S,CUR)$(RCS_COMBAL(R,T,C,S,'LO')$DEM(R,C)) = DINV(R,T,T,CUR)*EQG_COMBAL.M(R,T,C,S);
 SOL_BPRICE(R,T,C,S,CUR)$(RCS_COMBAL(R,T,C,S,'FX')$DEM(R,C)) = DINV(R,T,T,CUR)*EQE_COMBAL.M(R,T,C,S);

* Check elastic supply curve requests
$IF DEFINED DAM_ELAST TRACKC(R,C)$((NOT DAM_BQTY(R,C))$DAM_ELAST(R,C,'N')) = YES;
$IF DEFINED DAM_COST LOOP((R,T,C,CUR)$DAM_COST(R,T,C,CUR), TRACKC(R,C) = NO);
 OPTION CLEAR=DAM_COEF,CLEAR=DAM_TVOC;
 DAM_COEF(RTCS_VARC(R,T,C,S))$TRACKC(R,C) = SUM(G_RCUR(R,CUR),DINV(R,T,T,CUR)*EQE_COMPRD.M(R,T,C,S))+EPS;
 DAM_TVOC(RTC(R,T,C),'N')$TRACKC(R,C) = SUM(RTCS_VARC(R,T,C,S),DAM_COEF(R,T,C,S)*VAR_COMPRD.L(R,T,C,S));
 OPTION CLEAR=TRACKC;

 EXECUTE_UNLOAD 'com_bprice',sol_bprice,DAM_COEF,DAM_TVOC;
 EXECUTE_UNLOAD '%GDXPATH%%RUN_NAME%_DP',sol_bprice,DAM_COEF,DAM_TVOC;
*------------------------------------------------------------------------------
