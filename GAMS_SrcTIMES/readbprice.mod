*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* Importing bprice and assigning it to the parameter COM_BPRICE
*=============================================================================*
PARAMETER SOL_BPRICE(R,YEAR,C,TS,CUR) //;

$KILL DAM_TVOC
$IF NOT EXIST Com_Bprice.gdx $EXIT
$GDXIN Com_Bprice
$LOAD sol_bprice
$IF DEFINED DAM_ELAST $LOAD DAM_COEF
$IF DEFINED DAM_ELAST $LOAD DAM_TVOC
$GDXIN

TRACKC(R,C)$COM_PROJ(R,'0',C) = YES;
TRACKC(R,C)$COM_TMAP(R,'DEM',C) = YES;
COM_BPRICE(R,T,C,S,CUR)$TRACKC(R,C) $= SOL_BPRICE(R,T,C,S,CUR);
OPTION CLEAR=TRACKC;
*--------------------------------------------------------------------
$IF NOT DEFINED DAM_ELAST $GOTO FINISH
* Apply elastic supply curves if requested
LOOP((R,T,C)$DAM_TVOC(R,T,C,'N'),TRACKC(R,C) = YES);
TRACKC(R,C)$DAM_BQTY(R,C) = NO;
TRACKC(R,C)$(NOT DAM_ELAST(R,C,'N')) = NO;
$IF DEFINED DAM_COST LOOP((R,T,C,CUR)$DAM_COST(R,T,C,CUR), TRACKC(R,C) = NO);
DAM_COST(R,T,C,CUR)$TRACKC(R,C) = 1$(DAM_TVOC(R,T,C,'N') GT 0)+EPS;
DAM_TQTY(R,T,C)$TRACKC(R,C) $= DAM_TVOC(R,T,C,'N');
OPTION CLEAR=DAM_TVOC,CLEAR=TRACKC;
*--------------------------------------------------------------------
$LABEL FINISH