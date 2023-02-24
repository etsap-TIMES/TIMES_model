*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQUCWRAP.MOD Wrapper for defining the actual UC equations
*   %1 - equation type
*   %2 - bound type (BD/FX/UP/LO)
*   %3 - bound type2 (none/FX/UP/LO)
*   %4 - SUM(BD$ or none
*   %5 - ,1) or none
*=============================================================================*
$IF %6 %VAR_UC%==YES $EXIT
*-----------------------------------------------------------------------------
$SETLOCAL TSUM 'UC_T_SUM(R,UC_N,T),' SET SW1 %SOW%
$IF %STAGES%==YES $SETLOCAL SWS '(SW_UCT(UC_N,T,SOW)*' SETLOCAL SWD ')' SET TST '%TSUM%' SETLOCAL TSUM '(%TSUM%WW)$%SWSW%' SETLOCAL SWTD SW_TSW(SOW,TT,WW),
$IF %SCUM%==1 $SET SW1 ",'1'" SETLOCAL SWS '(' SETLOCAL TSUM '(%TST%SOW(WW))$SW_T(T,WW),SW_TPROB(T,WW)*' SETLOCAL SWTD SW_TSW(SOW(WW),TT,WW),SW_TPROB(TT,WW)*
*-----------------------------------------------------------------------------

*                             %1 %2                                         %3                                                                                  %4         %5              %6                           %7                     %8    %9                            %10

$   BATINCLUDE equserco.mod  mod %1 "(UC_N%SOW%)$(%4UC_RHS(UC_N,%2)%5$(SUM(UC_TS_SUM(UC_R_SUM(R,UC_N),S),1)*SUM(UC_T_SUM(R,UC_N,T),1)))"                        "SUM("     "SUM(%TSUM%"    "SUM(UC_TS_SUM(R,UC_N,S),"   "UC_R_SUM(R,UC_N),"     2    %VAR%_UC(UC_N%SW1%)           UC_RHS(UC_N,%2)

$   BATINCLUDE equserco.mod  mod %1 "R(UC_N,R%SOW%)$(%4UC_RHSR(R,UC_N,%2)%5$(SUM(UC_TS_SUM(UC_R_EACH(R,UC_N),S),1)*SUM(UC_T_SUM(R,UC_N,T),1)))"                 "("        "SUM(%TSUM%"    "SUM(UC_TS_SUM(R,UC_N,S),"   ""                      2    %VAR%_UCR(UC_N,R%SW1%)        UC_RHSR(R,UC_N,%2)

$   BATINCLUDE equserco.mod  mod %1 "T(UC_N,T%SWT%)$(%4UC_RHST(UC_N,T,%2)%5$SUM(UC_TS_SUM(UC_R_SUM(R,UC_N),S)$UC_T_EACH(R,UC_N,T),1))"                          "SUM("     "("             "SUM(UC_TS_SUM(R,UC_N,S),"   "UC_R_SUM(R,UC_N),"     0    %VAR%_UCT(UC_N,T%SOW%)        UC_RHST(UC_N,T,%2)

$   BATINCLUDE equserco.mod  mod %1 "RT(UC_N,R,T%SWT%)$UC_RHSMAP(UC_N,'EACH','SEVERAL',R,T,'ANNUAL'%3)"                                                         "("        "("             "SUM(UC_TS_SUM(R,UC_N,S),"   ""                      0    %VAR%_UCRT(UC_N,R,T%SOW%)     UC_RHSRT(R,UC_N,T,%2)

$   BATINCLUDE equserco.mod  mod %1 "TS(UC_N,T,S%SWT%)$(%4UC_RHSTS(UC_N,T,S,%2)%5$SUM(UC_TS_EACH(UC_R_SUM(R,UC_N),S)$UC_T_EACH(R,UC_N,T),1))"                   "SUM("     "("             "("                          "UC_R_SUM(R,UC_N),"     0    %VAR%_UCTS(UC_N,T,S%SOW%)     UC_RHSTS(UC_N,T,S,%2)

$   BATINCLUDE equserco.mod  mod %1 "RTS(UC_N,R,T,S%SWT%)$UC_RHSMAP(UC_N,'EACH','EACH',R,T,S%3)"                                                                "("        "("             "("                          ""                      0    %VAR%_UCRTS(UC_N,R,T,S%SOW%)  UC_RHSRTS(R,UC_N,T,S,%2)

$   BATINCLUDE equserco.mod  mod %1 "SU(UC_N,T%SOW%)$(%SWS%%4UC_RHST(UC_N,T,%2)%5$SUM(UC_TS_SUM(UC_R_SUM(R,UC_N),S)$UC_T_SUCC(R,UC_N,T),1))%SWD%"               "SUM("     "%SWTD%"        "SUM(UC_TS_SUM(R,UC_N,S),"   "UC_R_SUM(R,UC_N),"     1    %VAR%_UCT(UC_N,T%SW1%)        UC_RHST(UC_N,T,%2)

$   BATINCLUDE equserco.mod  mod %1 "RSU(UC_N,R,T%SOW%)$%SWS%UC_RHSMAP(UC_N,'SUCC','SEVERAL',R,T,'ANNUAL'%3)%SWD%"                                              "("        "%SWTD%"        "SUM(UC_TS_SUM(R,UC_N,S),"   ""                      1    %VAR%_UCRT(UC_N,R,T%SW1%)     UC_RHSRT(R,UC_N,T,%2)

$   BATINCLUDE equserco.mod  mod %1 "RSUS(UC_N,R,T,S%SOW%)$%SWS%UC_RHSMAP(UC_N,'SUCC','EACH',R,T,S%3)%SWD%"                                                     "("        "%SWTD%"        "("                          ""                      1    %VAR%_UCRTS(UC_N,R,T,S%SW1%)  UC_RHSRTS(R,UC_N,T,S,%2)

$   BATINCLUDE equserco.mod  mod %1 "SUS(UC_N,T,S%SOW%)$(%SWS%%4UC_RHSTS(UC_N,T,S,%2)%5$SUM(UC_TS_EACH(UC_R_SUM(R,UC_N),S)$UC_T_SUCC(R,UC_N,T),1))%SWD%"        "SUM("     "%SWTD%"        "("                          "UC_R_SUM(R,UC_N),"     1    %VAR%_UCTS(UC_N,T,S%SW1%)     UC_RHSTS(UC_N,T,S,%2)

$   BATINCLUDE equserco.mod  mod %1 "RS(UC_T_EACH(UC_R_EACH(R,UC_N),T),TSL,SL%SOW%)$(%4UC_RHSRTS(R,UC_N,T,SL,%2)%5$TS_GROUP(R,TSL,SL)$UC_TSL(R,UC_N,'LHS',TSL))" ( "SUM((UC_TSL(R,UC_N,SIDE,TSL),S(SL--RS_UCS(R,SL,SIDE))),UC_SIGN(SIDE)*" ( "" S    %VAR%_UCRTS(UC_N,R,T,SL%SOW%) UC_RHSRTS(R,UC_N,T,SL,%2)
