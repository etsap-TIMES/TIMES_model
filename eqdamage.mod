*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*-----------------------------------------------------------------------------
* EQDAMAGE.mod - Extension for Linearized/Non-linear Damages
*-----------------------------------------------------------------------------
* Questions/Comments:
*-----------------------------------------------------------------------------
$ IF %1==E $GOTO LPDAM
$ IF NOT DEFINED DAM_ELAST PARAMETER DAM_ELAST //;

* Internal sets and parameters
  SET JSUBJ(J,J)           'All steps up to J' //;
  SET DAM_NUM(R,C,J,BD);
  SET DAMOBJ / DAM, DAS, DAM-EXT /;
  SET WWDAM /DELTA-ATM/, RTDAM(R,T,C%SWD%), SWW(ALLSOW,ALLSOW);
  PARAMETER DAM_SIZE(REG,T,COM,LIM) 'Size of emission steps' //;
*-----------------------------------------------------------------------------
  OPTION CLEAR=RXX;
$ BATINCLUDE filparam DAM_TQTY 'R,' C ",'0','0','0','0'" DATAYEAR T '' '' '' "YEAR,"
  DAM_TQTY(R,T,C)$(NOT DAM_TQTY(R,T,C)) $= DAM_BQTY(R,C);

* Enable damage costs for atmospheric CO2 concentration:
$IF %CLI%==YES RTC(R,T,C(CG(CM_VAR)))$((NOT RC(R,C))$DAM_TQTY(R,T,C)) = YES;

* Remove EPS costs unless uncertain
  DAM_COST(R,T,C,CUR)$((DAM_COST(R,T,C,CUR) EQ 0)$DAM_COST(R,T,C,CUR)) = 0;
$IFI %STAGES%==YES OPTION SWW<=SW_TSW; LOOP(SOW,DAM_COST(R,T,C,CUR)$S_DAM_COST(R,T,C,CUR,'1',SOW) = DAM_COST(R,T,C,CUR)+EPS);
  LOOP(RDCUR(R,CUR), RXX(RTC)$DAM_COST(RTC,CUR) = YES);
  LOOP(T,TRACKC(R,C)$RXX(R,T,C) = YES);
  DAM_TVOC(RXX(R,T,C),BD) $= DAM_VOC(R,C,BD);

  RHS_COMBAL(RTCS_VARC(RXX(R,T,C),S))$(NOT DAM_ELAST(R,C,'N')) = YES;
  RCS_COMBAL(RHS_COMBAL(RXX(R,T,C),S),'FX') = YES;

* If BQTY is zero set VOC to zero to, leading to constant cost
  DAM_TQTY(RXX(R,T,C))$(DAM_TQTY(R,T,C) LE 0) = MAX(0,DAM_TVOC(R,T,C,'LO'));
  DAM_TVOC(RXX(R,T,C),BD)$(NOT DAM_TQTY(R,T,C)) = 0;
  LOOP(T,DAM_ELAST(R,C,BD)$((NOT DAM_TQTY(R,T,C))$RXX(R,T,C)) = 0);
  DAM_STEP(TRACKC(R,C),'FX') = 0; Z = 100;
  DAM_STEP(TRACKC(R,C),BD)$((NOT DAM_STEP(R,C,BD))$DAM_ELAST(R,C,BD)) = 1;
  DAM_STEP(TRACKC(R,C),BD)$DAM_STEP(R,C,BD) = MIN(Z,ABS(ROUND(DAM_STEP(R,C,BD))));

* Ensure that elasticities are greater than or equal to 1:
  DAM_ELAST(TRACKC(R,C),'LO') = ABS(DAM_ELAST(R,C,'UP')$(NOT DAM_ELAST(R,C,'LO'))+DAM_ELAST(R,C,'LO'));
  DAM_ELAST(TRACKC(R,C),'UP') = ABS(DAM_ELAST(R,C,'LO')$(NOT DAM_ELAST(R,C,'UP'))+DAM_ELAST(R,C,'UP'));

* Adjust VOCs
  DAM_TVOC(RXX(R,T,C),BD)$(NOT DAM_TVOC(R,T,C,BD)) $= (DAM_STEP(R,C,BD)+.5)*DAM_VOC(R,C,'N')*DAM_TQTY(R,T,C);
  DAM_TVOC(RXX(R,T,C),'LO') = MIN(DAM_TQTY(R,T,C),DAM_TVOC(R,T,C,'LO')+INF$(NOT DAM_TVOC(R,T,C,'LO')));
  DAM_TVOC(RXX(R,T,C),'UP')$(NOT DAM_TVOC(R,T,C,'UP')) = 
    DAM_TVOC(R,T,C,'LO')*(1+((DAM_STEP(R,C,'UP')+0.5)/(DAM_STEP(R,C,'LO')+0.5)-1)$DAM_STEP(R,C,'LO'));

  LOOP(RXX(R,T,C), F = DAM_STEP(R,C,'LO'); Z = DAM_STEP(R,C,'UP');
    FIRST_VAL = DAM_TVOC(R,T,C,'LO'); LAST_VAL = DAM_TVOC(R,T,C,'UP');
    IF(F, DAM_SIZE(R,T,C,'FX') = 2*(FIRST_VAL-(FIRST_VAL*(4*Z+1)-LAST_VAL)/(1+Z*(4+1/F)));
    ELSE  DAM_SIZE(R,T,C,'FX') = FIRST_VAL+0.5*LAST_VAL/(Z+0.5));
  );
  DAM_SIZE(RXX(R,T,C),BDNEQ(BD))$DAM_STEP(R,C,BD) = MAX(0,(DAM_TVOC(R,T,C,BD)-0.5*DAM_SIZE(R,T,C,'FX')))/DAM_STEP(R,C,BD);
  DAM_SIZE(RXX(R,T,C),'UP')$(NOT DAM_STEP(R,C,'LO')) = MAX(0,DAM_TVOC(R,T,C,'UP')/(DAM_STEP(R,C,'UP')+0.5));
  DAM_SIZE(RXX(R,T,C),'N') = DAM_TQTY(R,T,C)-DAM_TVOC(R,T,C,'LO')+0.5*DAM_SIZE(R,T,C,'LO')$DAM_ELAST(R,C,'N');

  DAM_COEF(RTCS_VARC(R,T,C,S))$((NOT DAM_COEF(R,T,C,S))$TRACKC(R,C)) = 1;
  JSUBJ(JJ,J)$((ORD(J) LE ORD(JJ))$(ORD(JJ)<=100)) = YES;
* Set number of FX steps (any non-zero DAM_STEP(R,C,'N') disables endogenous damage)
  DAM_STEP(TRACKC(R,C),'FX')$(DAM_STEP(R,C,'N') EQ 0) = 1+1$SUM(T$(DAM_SIZE(R,T,C,'N') GT 0),YES);
  IF(CARD(DAM_COST)=0,SUM_OBJ('OBJDAM',ITEM)=0);
  RTDAM(RXX(R,T,C)%SOW%)$(%SWTX%YES+WWDAM(C)) = YES;

*-----------------------------------------------------------------------------
  SET OBV / OBJDAM /;
$IF %DAMAGE%==NO SUM_OBJ('OBJDAM',ITEM)=0;
$IFI %SPINES%==YES $%SW_TAGS%
$IF %DAMAGE%==NO $GOTO FINISH
$IF %DAMAGE%==NLP $GOTO NLPDAM
*-----------------------------------------------------------------------------
* Set bounds for damage variables:
  LOOP(SAMEAS(J,'1'),DAM_NUM(TRACKC(R,C),J+(DAM_STEP(R,C,BD)-1),BD) = YES);
  %VAR%_DAM.UP(R,T,C,BD,J %SWD%) = INF;
  %VAR%_DAM.UP(RTC(R,T,C),'LO',J%SOW%)$((ORD(J) LE DAM_STEP(R,C,'LO'))$RTDAM(RTC%SOW%)) = DAM_SIZE(RTC,'LO');
  %VAR%_DAM.UP(RTC(R,T,C),'LO','1'%SOW%)$(DAM_ELAST(R,C,'N')$RTDAM(RTC%SOW%)) = DAM_SIZE(RTC,'LO')+DAM_TQTY(RTC)-DAM_TVOC(RTC,'LO');
  %VAR%_DAM.UP(RTC(R,T,C),'UP',J%SOW%)$((ORD(J) LT DAM_STEP(R,C,'UP'))$RTDAM(RTC%SOW%)) = DAM_SIZE(RTC,'UP');
  %VAR%_DAM.UP(RTC(R,T,C),'FX','1'%SOW%)$(DAM_TVOC(R,T,C,'UP')$RTDAM(RTC%SOW%)) = DAM_SIZE(RTC,'FX');
  %VAR%_DAM.UP(RTC(R,T,C),'FX','2'%SOW%)$RTDAM(RTC%SOW%) = DAM_SIZE(RTC,'N')$(NOT DAM_ELAST(R,C,'N'));
*-----------------------------------------------------------------------------
$LABEL LPDAM
* Damage cost equation
%2  %EQ%_OBJDAM(RDCUR(R,CUR)%SOW%)..
    SUM(RTC(R,T,C)$(DAM_STEP(R,C,'FX')$DAM_COST(R,T,C,CUR)),
$IFI %STAGES%==YES SUM(SWW(SOW,WW)$(SW_TSW(SOW,T,WW)$(NOT WWDAM(C))+SWW(WW,SOW)$WWDAM(C)),
      (SUM((DAM_NUM(R,C,JJ,'LO'),JSUBJ(JJ,J)),
         (%VAR%_DAM(R,T,C,'LO',J%SWD%) + DAM_ELAST(R,C,'N')*%VAR%_DAM.UP(R,T,C,'LO',J%SWD%))* 
         ((DAM_TQTY(R,T,C)-DAM_SIZE(R,T,C,'FX')/2-DAM_SIZE(R,T,C,'LO')*(ORD(JJ)-ORD(J)+.5))**DAM_ELAST(R,C,'LO') /
          DAM_TQTY(R,T,C)**DAM_ELAST(R,C,'LO') + DAM_ELAST(R,C,'N')))$DAM_TQTY(R,T,C) +
       %VAR%_DAM(R,T,C,'FX','1'%SWD%) * (1 + DAM_ELAST(R,C,'N')) +
       SUM((DAM_NUM(R,C,JJ,'UP'),JSUBJ(JJ,J)),
         %VAR%_DAM(R,T,C,'UP',J%SWD%) * 
         ((DAM_TQTY(R,T,C)+DAM_SIZE(R,T,C,'FX')/2+DAM_SIZE(R,T,C,'UP')*(ORD(J)-.5))**DAM_ELAST(R,C,'UP') /
          DAM_TQTY(R,T,C)**DAM_ELAST(R,C,'UP') + DAM_ELAST(R,C,'N')))$DAM_TQTY(R,T,C)
      ) * OBJ_PVT(R,T,CUR) *
$IFI NOT %STAGES%==YES DAM_COST(R,T,C,CUR)
$IFI %STAGES%==YES   S_DAM_COST(R,T,C,CUR,'1',WW))
    )

%3  =E=  SUM(OBV,SUM_OBJ('OBJDAM',OBV)*%VAR%_OBJ(R,OBV,CUR %SOW%));

$GOTO FINISH
*=============================================================================
$LABEL NLPDAM
* Set bounds for damage variables:
  DAM_STEP(TRACKC(R,C),'LO') = 1;
  DAM_STEP(TRACKC(R,C),'UP') = 1;
  LOOP(SAMEAS(J,'1'),DAM_NUM(TRACKC(R,C),J+(DAM_STEP(R,C,BD)-1),BD) = YES);
  %VAR%_DAM.UP(R,T,C,BD,J %SWD%) = INF;
  %VAR%_DAM.UP(RTC(R,T,C),'LO','1'%SOW%)$RTDAM(RTC%SOW%) = (DAM_TQTY(RTC)-DAM_SIZE(RTC,'N'))$DAM_STEP(R,C,'LO');
  %VAR%_DAM.UP(RTC(R,T,C),'FX','1'%SOW%)$RTDAM(RTC%SOW%) = EPS;
  %VAR%_DAM.UP(RTC(R,T,C),'FX','2'%SOW%)$RTDAM(RTC%SOW%) = DAM_SIZE(RTC,'N');
*-----------------------------------------------------------------------------
* Damage cost equation
  %EQ%_OBJDAM(RDCUR(R,CUR)%SOW%)..
    SUM(RTC(R,T,C)$(DAM_STEP(R,C,'FX')$DAM_COST(R,T,C,CUR)), 
$IFI %STAGES%==YES SUM(SWW(SOW,WW)$(SW_TSW(SOW,T,WW)$(NOT WWDAM(C))+SWW(WW,SOW)$WWDAM(C)),
      (DAM_TVOC(R,T,C,'N')*(%VAR%_DAM(R,T,C,'FX','2'%SWD%)+DAM_SIZE(R,T,C,'N')*DAM_ELAST(R,C,'N')) +
       (((%VAR%_DAM(R,T,C,'LO','1'%SWD%)+DAM_SIZE(R,T,C,'N'))**(DAM_ELAST(R,C,'LO')+1) +
* Subtract full LO costs if DAM_ELAST(N) = -1 (constant term)
         DAM_ELAST(R,C,'N')*DAM_TQTY(R,T,C)**(DAM_ELAST(R,C,'LO')+1) -
         DAM_SIZE(R,T,C,'N')**(DAM_ELAST(R,C,'LO')+1)) /
        (DAM_TQTY(R,T,C)**DAM_ELAST(R,C,'LO')*(DAM_ELAST(R,C,'LO')+1)))$DAM_STEP(R,C,'LO') +
       (((%VAR%_DAM(R,T,C,'UP','1'%SWD%)+DAM_TQTY(R,T,C))**(DAM_ELAST(R,C,'UP')+1) -
         DAM_TQTY(R,T,C)**(DAM_ELAST(R,C,'UP')+1)) /
        (DAM_TQTY(R,T,C)**DAM_ELAST(R,C,'UP')*(DAM_ELAST(R,C,'UP')+1))) +
* Shift cost curve by DAM_ELAST(N) if applicable
       DAM_ELAST(R,C,'N')*(SUM(BDNEQ(BD),%VAR%_DAM(R,T,C,BD,'1'%SWD%))+DAM_ELAST(R,C,'N')*DAM_TQTY(R,T,C))
      ) * OBJ_PVT(R,T,CUR) *
$IFI NOT %STAGES%==YES DAM_COST(R,T,C,CUR)
$IFI %STAGES%==YES   S_DAM_COST(R,T,C,CUR,'1',WW))
    )

 =E=  SUM(OBV,SUM_OBJ('OBJDAM',OBV)*%VAR%_OBJ(R,OBV,CUR %SOW%));

*-----------------------------------------------------------------------------
$LABEL FINISH
*-----------------------------------------------------------------------------
* Emission balance equation

  %EQ%_DAMAGE(RTC(%R_T%,C) %SOW%)$(SUM(RDCUR(R,CUR)$DAM_COST(R,T,C,CUR),1)$RTDAM(RTC%SOW%))..

   SUM(DAM_NUM(R,C,JJ,BD),SUM(JSUBJ(JJ,J),%VAR%_DAM(R,T,C,BD,J %SOW%)))

   =E= (
$IF %CLI%==YES SUM(CM_VAR(C),%VART%_CLITOT(CM_VAR,T%SWS%)$CM_KIND(CM_VAR)+%VAR%_CLIBOX(CM_VAR,T%SOW%)$(NOT CM_KIND(CM_VAR)))$(NOT RC(R,C)) +
   SUM(COM_TS(RC(R,C),S),DAM_COEF(R,T,C,S)*%VAR%_COMNET(R,T,C,S %SOW%)$(NOT DAM_ELAST(R,C,'N')) +
                         DAM_COEF(R,T,C,S)*%VAR%_COMPRD(R,T,C,S %SOW%)$DAM_ELAST(R,C,'N'))
       )$DAM_STEP(R,C,'FX');
*-----------------------------------------------------------------------------
  OPTION CLEAR=TRACKC,CLEAR=RXX,CLEAR=DAM_TVOC; 
  DAM_TVOC(R,T,C,'N')$DAM_SIZE(R,T,C,'N') = ((DAM_SIZE(R,T,C,'N')/DAM_TQTY(R,T,C))**DAM_ELAST(R,C,'LO'))$DAM_ELAST(R,C,'N');