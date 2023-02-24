*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*------------------------------------------------------------------------------
* RPT_DAM.mod
*
* Output routine for Damage Costs
*------------------------------------------------------------------------------
$SETLOCAL SWP '' SETLOCAL SW1 ''
$IF %SOLVEDA%==1 $SETLOCAL SWP 'S' SETLOCAL SW1 "'1',"
$IFI %STAGES%==YES $SETLOCAL SWP 'S' SETLOCAL SW1 'SOW,'
  %VAR%_OBJ.M(R,'OBJDAM',CUR %SOW%)$RDCUR(R,CUR) = 0;
*------------------------------------------------------------------------------
* Always report the accurate non-linear costs
  OPTION CLEAR=RXX; LOOP(RDCUR(R,CUR), RXX(RTC)$DAM_COST(RTC,CUR) = YES);
*------------------------------------------------------------------------------
* If using climate module, enable damages for total emissions/concentration
$IF %CLI%==YES %SWP%CST_DAM(%SW1%R,T,C(CG(CM_VAR)))$((NOT RC(R,C))$RXX(R,T,C)) = 
$IF %CLI%==YES   %VART%_CLITOT.L(CM_VAR,T%SWS%)$CM_KIND(CM_VAR)+%VAR%_CLIBOX.L(CM_VAR,T%SOW%)$(NOT CM_KIND(CM_VAR));
*------------------------------------------------------------------------------
   %SWP%CST_DAM(%SW1%RXX(R,T,C))$RC(R,C) = 
     SUM(COM_TS(R,C,S),DAM_COEF(R,T,C,S) *
       (%VART%_COMNET.L(R,T,C,S%SWS%)$(NOT DAM_ELAST(R,C,'N'))+%VART%_COMPRD.L(R,T,C,S%SWS%)$DAM_ELAST(R,C,'N')));
   %SWP%DAM_OBJ(%SW1%RXX(R,T,C),CUR)$RDCUR(R,CUR) =
$IFI NOT %STAGES%==YES DAM_COST(R,T,C,CUR) *
$IFI %STAGES%==YES SUM(SWW(SOW,W)$(SW_TSW(SOW,T,W)$(NOT WWDAM(C))+SWW(W,SOW)$WWDAM(C)),S_DAM_COST(R,T,C,CUR,'1',W)) *
    (DAM_TVOC(R,T,C,'N')*(MIN(%SWP%CST_DAM(%SW1%R,T,C),DAM_SIZE(R,T,C,'N'))+DAM_SIZE(R,T,C,'N')*DAM_ELAST(R,C,'N')) +
     ((MIN(DAM_TQTY(R,T,C),%SWP%CST_DAM(%SW1%R,T,C))**(DAM_ELAST(R,C,'LO')+1) +
* Subtract full LO costs if DAM_ELAST(N) = -1 (constant term)
       DAM_ELAST(R,C,'N')*(DAM_TQTY(R,T,C)**(DAM_ELAST(R,C,'LO')+1)-DAM_SIZE(R,T,C,'N')**(DAM_ELAST(R,C,'LO')+1)) -
       MIN(DAM_SIZE(R,T,C,'N'),%SWP%CST_DAM(%SW1%R,T,C))**(DAM_ELAST(R,C,'LO')+1)) /
      (DAM_TQTY(R,T,C)**DAM_ELAST(R,C,'LO')*(DAM_ELAST(R,C,'LO')+1))) +
     ((%SWP%CST_DAM(%SW1%R,T,C)**(DAM_ELAST(R,C,'UP')+1) - 
       DAM_TQTY(R,T,C)**(DAM_ELAST(R,C,'UP')+1)) /
      (DAM_TQTY(R,T,C)**DAM_ELAST(R,C,'UP')*(DAM_ELAST(R,C,'UP')+1)))$(%SWP%CST_DAM(%SW1%R,T,C) GT DAM_TQTY(R,T,C)) +
* Shift cost curve by DAM_ELAST(N) if applicable
     DAM_ELAST(R,C,'N')*(%SWP%CST_DAM(%SW1%R,T,C)+DAM_ELAST(R,C,'N')*DAM_TQTY(R,T,C))
    );

$IF %SCUM%==1 $SETLOCAL SW1 "'1'," %SW_NOTAGS%
$IF %SCUM%==1 SDAM_OBJ(%SW1%RXX(R,T,C),CUR)$RDCUR(R,CUR) = SUM(W,SW_PROB(W)*SDAM_OBJ(W,R,T,C,CUR));

  %SWP%CST_DAM(%SW1%RXX(R,T,C)) = SUM(RDCUR(R,CUR),%SWP%DAM_OBJ(%SW1%R,T,C,CUR));
  %SWP%REG_ACOST(%SW1%R,T,'DAM') = SUM(RXX(R,T,C),%SWP%CST_DAM(%SW1%R,T,C));
  %SWP%CST_PVC(%SW1%'DAM',R,C)$DAM_STEP(R,C,'FX') = SUM(T,%SWP%CST_DAM(%SW1%R,T,C)*COEF_PVT(R,T));
* Complete also reporting of discounted costs
  %SWP%REG_WOBJ(%SW1%R,'DAM',CUR) = SUM(RXX(R,T,C)$((NOT DAM_ELAST(R,C,'N'))$DAM_STEP(R,C,'FX')),OBJ_PVT(R,T,CUR)*%SWP%DAM_OBJ(%SW1%R,T,C,CUR));
  %SWP%REG_WOBJ(%SW1%R,'DAS',CUR) = SUM(RXX(R,T,C)$(DAM_ELAST(R,C,'N')$DAM_STEP(R,C,'FX')),OBJ_PVT(R,T,CUR)*%SWP%DAM_OBJ(%SW1%R,T,C,CUR));
  %SWP%REG_WOBJ(%SW1%R,'DAM-EXT+',CUR) = %SWP%REG_WOBJ(%SW1%R,'DAM',CUR)+%SWP%REG_WOBJ(%SW1%R,'DAS',CUR);
  %SWP%REG_WOBJ(%SW1%R,'DAM',CUR) = (%SWP%REG_WOBJ(%SW1%R,'DAM',CUR)/%SWP%REG_WOBJ(%SW1%R,'DAM-EXT+',CUR)*%VAR%_OBJ.L(R,'OBJDAM',CUR%SOW%))$(%SWP%REG_WOBJ(%SW1%R,'DAM-EXT+',CUR) GT 0);
  %SWP%REG_WOBJ(%SW1%R,'DAS',CUR) = %VAR%_OBJ.L(R,'OBJDAM',CUR%SOW%) - %SWP%REG_WOBJ(%SW1%R,'DAM',CUR);
* Complete also reporting of discounted external damages
  %SWP%REG_WOBJ(%SW1%R,'DAM-EXT+',CUR) = SUM(RXX(R,T,C),OBJ_PVT(R,T,CUR)*%SWP%DAM_OBJ(%SW1%R,T,C,CUR)) - %VAR%_OBJ.L(R,'OBJDAM',CUR%SOW%);
* Weighted results
$IF %STAGES%%SCUM%==YES REG_WOBJ(R,DAMOBJ,CUR) = SUM(W,SW_PROB(W)*SREG_WOBJ(W,R,DAMOBJ,CUR));
