*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQOBJ the objective functions
*   %1 - mod or v# for the source code to be used
*=============================================================================*
*GaG Questions/Comments:
*  - V-index used in place to T for MODLYEAR
* Note: PASTYEAR always have D(V) = 1
*  - V-vintage MODLYEAR year, the point in time where the investment took place
*-----------------------------------------------------------------------------
  SET K_EOH(ALLYEAR);

* [UR] 21.06.2003: K_EOH must include pastyears, since it links to past vintages
  K_EOH(EACHYEAR)$((YEARVAL(EACHYEAR) >= PYR_V1) * (YEARVAL(EACHYEAR) <= MIYR_VL)) = YES;

* Sets for periodic costs
  SET KTYAGE(LL,YEAR,LL,AGE);
  LOOP(SAMEAS('1',AGE),
    KTYAGE(K(LL),PERIODYR(T,Y_EOH(YEAR)),AGE+(ORD(YEAR)-ORD(LL)))$YK(YEAR,LL)=YES;
    KTYAGE(K(LL),YK(PYR_S,Y_EOH(YEAR)),AGE+(ORD(YEAR)-ORD(LL)))$YK(YEAR,LL)=YES);

* Set up summing of OBJ component variables
  SUM_OBJ(OBV,ITEM) = DIAG(OBV,ITEM);
  SUM_OBJ(OBV('OBJSAL'),OBV)  =  -1;
  SUM_OBJ(R,'OBJELS') = 1$SUM(RCJ(R,C,J,BD),1);
*-----------------------------------------------------------------------------
* Cases for ILED and TLIFE/D(t); values assigned in EQOBJINV
  SET OBJ_1A(R,ALLYEAR,P) //;
  SET OBJ_1B(R,ALLYEAR,P) //;
  SET OBJ_2A(R,ALLYEAR,P) //;
  SET OBJ_2B(R,ALLYEAR,P) //;
* Salvage controls
  SET OBJ_SUMS(R,ALLYEAR,P)   //;
  SET OBJ_SUMS3(R,ALLYEAR,P)  //;
  SET OBJ_SUMSI(R,ALLYEAR,P,ALLYEAR) //;
$IF DECLARED VNRET $BATINCLUDE prepret.dsc EQOBJ

*===============================================================================
* Investment Cost, Tax/Subsidy and Decomissioning components
*===============================================================================
$   BATINCLUDE eqobjinv.%1

*===============================================================================
* Elastic Demand costs
*===============================================================================
$IF %TIMESED%==YES  $ BATINCLUDE eqobjels.%1

*===============================================================================
* Fixed O&M Cost and Tax components
*===============================================================================
$   BATINCLUDE eqobjfix.%1 %1

*===============================================================================
* Variable O&M and direct commodity related cost components
*===============================================================================
$IFI '%OBLONG%%OBJ%'==YESALT $SET OBJ 'LIN' SET VARCOST LIN
$   BATINCLUDE eqobjvar.%1 %1

*===============================================================================
* Salvage value of investment and decommissioning costs
*===============================================================================
$   BATINCLUDE eqobsalv.%1 %1

*===============================================================================
* Annualized objective formulation
*===============================================================================
$IFI %OBJANN%==YES $BATINCLUDE eqobjann.tm

*===============================================================================
* Actual OBJ
*===============================================================================
$IFI NOT %STAGES%==YES  %EQ%_OBJ ..               -objZ +
$IFI %STAGES% == YES    %EQ%_ROBJ(REG(R)%SOW%) .. -%VAR%_UCR('OBJZ',R%SOW%) +

      SUM(RDCUR(R,CUR),

* Investment Costs, Tax/Subsidies and Decommissioning
* Salvage value of investment and decommissioning costs
* Fixed O&M and Tax/Subsidies
* Variable O&M and direct commodity costs
* Damages

        SUM((ITEM,OBV)$SUM_OBJ(ITEM,OBV),%VAR%_OBJ(R,OBV,CUR %SOW%)*SUM_OBJ(ITEM,OBV))

* Elastic Demand costs
$IF %TIMESED% == YES +SUM(BD,%VAR%_OBJELS(R,BD,CUR %SOW%)*BDSIG(BD))$SUM_OBJ(R,'OBJELS')
$IFI %MICRO% == YES  -%VAR%_OBJELS(R,'FX',CUR %SOW%)$SUM_OBJ(R,'OBJELS')

         )

* Extensions to objective function
$ IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod obj_ext %EXTEND%

    =E= 0
;

*===============================================================================
* Stochastic objective function
*===============================================================================
$IFI NOT %STAGES% == YES $EXIT

  EQ_EXPOBJ(AUXSOW(WW))..
     (SUM(SOW, SW_PROB(SOW) * %VAR%_UC('OBJZ'%SOW%))/SW_NORM - VAS_EXPOBJ)$(NOT SW_PHASE) +
     SUM(SOW,SUM(UC_N$(SUM(UC_T_SUM(UC_R_SUM(R,UC_N),T),1)$S_UCOBJ(UC_N,SOW)),
               S_UCOBJ(UC_N,SOW)*%VAR%_UC(UC_N%SOW%)) - %VAR%_UC('OBJ1'%SOW%))$(SW_PHASE GT 0) +
     SUM(SOW,SUM(UC_N$(SUM(UC_T_SUM(UC_R_SUM(R,UC_N),T),1)$S_UCOBJ(UC_N,WW)),
               S_UCOBJ(UC_N,WW)*%VAR%_UC(UC_N%SOW%)) - %VAR%_UC('OBJ1'%SWD%))$(SW_PHASE LT 0)

   =E=  0;

  EQ_UPDEV(SOW)$SW_LAMBDA..
     %VAR%_UC('OBJZ'%SOW%) - VAS_EXPOBJ$(SW_LAMBDA GT 0) - %VAR%_UC('OBJ1'%SOW%)$(SW_LAMBDA LT 0)
     =L=                     VAS_UPDEV(SOW)$(SW_LAMBDA GT 0) + VAS_UPDEV('1')$(SW_LAMBDA LT 0);

  %EQ%_SOBJ('N'%SOW%).. -%VAR%_UC('OBJZ'%SOW%) + SUM(R,%VAR%_UCR('OBJZ',R%SOW%)) =E= 0;

  EQ_OBJ..    
     ((VAS_EXPOBJ + SW_LAMBDA * SUM(SOW, SW_PROB(SOW) * VAS_UPDEV(SOW))/SW_NORM)$(SW_LAMBDA GE 0)
      - MIN(0,SW_LAMBDA)*VAS_UPDEV('1'))$(NOT SW_PHASE) +
     SUM(SOW,%VAR%_UC('OBJ1'%SOW%)$(ABS(SW_PHASE) EQ 1) + %VAR%_UC('OBJZ'%SOW%)$(ABS(SW_PHASE) EQ 2))

   =E=  objZ;
