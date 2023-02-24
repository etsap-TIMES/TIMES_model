*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* BND_CUM.MOD set the actual bounds for cumulative variables
*=============================================================================*
$SETLOCAL SW1 '' SETLOCAL SW2 ""
$IF %STAGES%==YES $SETLOCAL SW1 'S_' SETLOCAL SW2 ",'1'%SOW%"

* Ignore negative bounds; reset any N bounds at specific years
 %SW1%FLO_CUM(R,P,C,YEAR,LL,BD%SW2%)$((%SW1%FLO_CUM(R,P,C,YEAR,LL,BD%SW2%) LT 0)$%SW1%FLO_CUM(R,P,C,YEAR,LL,BD%SW2%)) = 0;
 FLO_CUM(R,P,C,YEAR,'EOH','N') $= FLO_CUM(R,P,C,YEAR,'%EOTIME%','N');
 FLO_CUM(RPC_CUMFLO(R,P,C,YEAR,LL),'N') = 0;

 %SW1%FLO_CUM(R,P,C,YEAR,LL,BD%SW2%)$%SW1%FLO_CUM(R,P,C,YEAR,LL,'FX'%SW2%) = %SW1%FLO_CUM(R,P,C,YEAR,LL,'FX'%SW2%)$BDNEQ(BD);

* Get modifiers for flexible model horizon
 LOOP((SAMEAS(J,'1'),MIYR_L), OPTION CLEAR=UNCD7; UNCD7(RPC_CUMFLO(R,P,C,YEAR,'%EOTIME%'),J+(FLO_CUM(R,P,C,YEAR,'EOH','N')-1),'')=YES;
   LOOP(UNCD7(R,P,C,YEAR,LL,JJ,''), FLO_CUM(R,P,C,YEAR,LL,'N') = MIN(0,ABS(MULTI(JJ,MIYR_L))-1)$MULTI(JJ,MIYR_L)));

* Set bounds
 %VAR%_CUMFLO.LO(R,P,C,YEAR,LL %SOW%)$%SW1%FLO_CUM(R,P,C,YEAR,LL,'LO'%SW2%) = %SW1%FLO_CUM(R,P,C,YEAR,LL,'LO'%SW2%)*(1/%CUFSCAL%)*(FLO_CUM(R,P,C,YEAR,LL,'N')+1);
 %VAR%_CUMFLO.UP(R,P,C,YEAR,LL %SOW%)$%SW1%FLO_CUM(R,P,C,YEAR,LL,'UP'%SW2%) = %SW1%FLO_CUM(R,P,C,YEAR,LL,'UP'%SW2%)*(1/%CUFSCAL%)*(FLO_CUM(R,P,C,YEAR,LL,'N')+1);

* Reset any N bounds at specific years
 COM_CUM(R,%1,YEAR,'0',C,'N') $= COM_CUM(R,%1,YEAR,'%EOTIME%',C,'N');
 COM_CUM(RC_CUMCOM(R,%1,YEAR,LL,C),'N') = 0;

 %SW1%COM_CUM(R,%1,YEAR,LL,C,BD%SW2%)$%SW1%COM_CUM(R,%1,YEAR,LL,C,'FX'%SW2%) = %SW1%COM_CUM(R,%1,YEAR,LL,C,'FX'%SW2%)$BDNEQ(BD);
 %SW1%COM_CUM(RC_CUMCOM(R,%1,LL,YEAR,C),BD%SW2%)$(YEARVAL(LL)>MIYR_VL)=EPS; RC_CUMCOM(R,%1,LL,YEAR,C)$(YEARVAL(LL)>MIYR_VL)=NO;

* Get modifiers for flexible model horizon
 LOOP((SAMEAS(J,'1'),MIYR_L), OPTION CLEAR=UNCD7; UNCD7(RC_CUMCOM(R,%1,YEAR,'%EOTIME%',C),J+(COM_CUM(R,%1,YEAR,'0',C,'N')-1),'')=YES;
   LOOP(UNCD7(R,%1,YEAR,LL,C,JJ,''), COM_CUM(R,%1,YEAR,LL,C,'N') = MIN(0,ABS(MULTI(JJ,MIYR_L))-1)$MULTI(JJ,MIYR_L)));

* Set bounds
 %SW1%COM_CUM(RC_CUMCOM(R,%1,YEAR,LL,C),L('LO')%SW2%)$(NOT %SW1%COM_CUM(RC_CUMCOM,L%SW2%)) = -INF$SUM((RTC(R,T,C),ANNUAL(S)),MIN(0,COM_BNDPRD(RTC,S,L)$DIAG(%1,'PRD')+COM_BNDNET(RTC,S,L)$DIAG(%1,'NET')+1-1));
 %VAR%_CUMCOM.LO(R,C,%1,YEAR,LL %SOW%)$%SW1%COM_CUM(R,%1,YEAR,LL,C,'LO'%SW2%) = %SW1%COM_CUM(R,%1,YEAR,LL,C,'LO'%SW2%)*(1/%CUCSCAL%)*(COM_CUM(R,%1,YEAR,LL,C,'N')+1);
 %VAR%_CUMCOM.UP(R,C,%1,YEAR,LL %SOW%)$%SW1%COM_CUM(R,%1,YEAR,LL,C,'UP'%SW2%) = %SW1%COM_CUM(R,%1,YEAR,LL,C,'UP'%SW2%)*(1/%CUCSCAL%)*(COM_CUM(R,%1,YEAR,LL,C,'N')+1);

$IFI %MACRO%==YES $EXIT
* Set lower bound for combined costs to -INF
 LOOP(COST_GMAP(COSTCAT,COSTAGG,COSTYPE),
   %VAR%_CUMCST.LO(R,YEAR,ALLYEAR,COSTCAT,CUR %SOW%)$REG_CUMCST(R,YEAR,ALLYEAR,COSTCAT,CUR,'UP') = -INF);
 %VAR%_CUMCST.UP(R,YEAR,ALLYEAR,COSTCAT,CUR %SOW%) $= REG_CUMCST(R,YEAR,ALLYEAR,COSTCAT,CUR,'UP');
 %VAR%_CUMCST.LO(R,YEAR,ALLYEAR,COSTCAT,CUR %SOW%) $= REG_CUMCST(R,YEAR,ALLYEAR,COSTCAT,CUR,'LO');
 %VAR%_CUMCST.FX(R,YEAR,ALLYEAR,COSTCAT,CUR %SOW%) $= REG_CUMCST(R,YEAR,ALLYEAR,COSTCAT,CUR,'FX');
