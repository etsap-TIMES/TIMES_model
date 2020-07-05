*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* Importing sol_bprice and assigning it to parameter COM_BPRICE
*=============================================================================*
 PARAMETER SOL_BPRICE(R,YEAR,C,TS,CUR) //;

$KILL DAM_TVOC
$SET MX com_bprice
$IFI %TIMESED%==YES $GOTO LOAD
$SET MX %GDXPATH%%TIMESED%
$IF EXIST %MX%_DP.gdx $SET MX %MX%_DP
$LABEL LOAD
$IF NOT EXIST %MX%.gdx $EXIT
$GDXIN %MX%
$LOAD sol_bprice
$IF DEFINED DAM_ELAST $LOAD DAM_COEF
$IF DEFINED DAM_ELAST $LOAD DAM_TVOC
$IF NOT ERRORFREE $CLEARERROR
$GDXIN

 OPTION DEM < COM_PROJ;
 DEM(R,C)$COM_TMAP(R,'DEM',C) = YES;
 COM_BPRICE(R,T,C,S,CUR)$DEM(R,C) $= SOL_BPRICE(R,T,C,S,CUR);
 OPTION CLEAR=DEM;
*--------------------------------------------------------------------
$IF NOT DEFINED DAM_ELAST $GOTO FINISH
* Apply elastic supply curves if requested
LOOP((R,T,C)$DAM_TVOC(R,T,C,'N'),TRACKC(R,C) = YES);
TRACKC(R,C)$DAM_BQTY(R,C) = NO;
TRACKC(R,C)$(NOT DAM_ELAST(R,C,'N')) = NO;
$IF DEFINED DAM_COST LOOP((R,T,C,CUR)$DAM_COST(R,T,C,CUR), TRACKC(R,C) = NO);
DAM_COST(R,T,C,CUR)$TRACKC(R,C) = 1$(DAM_TVOC(R,T,C,'N')>0)+EPS;
DAM_TQTY(R,T,C)$TRACKC(R,C) $= DAM_TVOC(R,T,C,'N');
OPTION CLEAR=DAM_TVOC,CLEAR=TRACKC;
*--------------------------------------------------------------------
$LABEL FINISH