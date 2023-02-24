*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* Importing sol_bprice and assigning it to parameter COM_BPRICE
*=============================================================================*
 PARAMETER SOL_BPRICE(R,YEAR,C,TS,CUR) //;

$IF NOT ERRORFREE $EXIT
$KILL DAM_TVOC
$SET TMP com_bprice
$IFI %TIMESED%==YES $GOTO LOAD
$SETLOCAL TMP %GDXPATH%%TIMESED%
$IF EXIST %TMP%_DP.gdx $SETLOCAL TMP %TMP%_DP
$IF NOT EXIST %TMP%.gdx $DROPLOCAL TMP
$LABEL LOAD
$GDXIN %TMP%
$IF NOT ERRORFREE $GOTO FINISH
$IFI %MACRO%==MLF $SET MX SET MACRO 'Yes'
$LOAD sol_bprice
$IF NOT ERRORFREE $GOTO FINISH
$SETGLOBAL MX %MX% SET TIMESED 'YES'
$IF DEFINED DAM_ELAST $LOAD DAM_COEF
$IF DEFINED DAM_ELAST $LOAD DAM_TVOC
$IFI %MACRO%==MLF     $LOAD SOL_ACFR
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
$IFI NOT %MACRO%==MLF $CLEARERROR
