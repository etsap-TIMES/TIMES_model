*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* MOD_VARS.MOD lists the individual variables of all instances of the MODEL   *
*=============================================================================*
* Questions/Comments:
*  -
*-----------------------------------------------------------------------------
* Set of standard objective components
  SET OBV / OBJINV, OBJFIX, OBJSAL, OBJVAR /;

*-----------------------------------------------------------------------------
 POSITIVE VARIABLES
*-----------------------------------------------------------------------------
* Process-related variables
*-----------------------------------------------------------------------------
  %VAR%_ACT(R,ALLYEAR,ALLYEAR,P,S %SWD%) 		Overall activity of a process
  %VAR%_CAP(R,ALLYEAR,P %SWD%)           		Installed capacity of a process
  %VAR%_FLO(R,ALLYEAR,ALLYEAR,P,C,S %SWD%)		Level of process commodity flow
  %VAR%_IRE(R,ALLYEAR,ALLYEAR,P,C,S,IE %SWD%)		Inter-regional trade flow
  %VAR%_NCAP(R,ALLYEAR,P %SWD%)            		New capacity of a process

*-----------------------------------------------------------------------------
* Commodity-related variables
*-----------------------------------------------------------------------------
  %VAR%_COMNET(R,ALLYEAR,C,S %SWD%)     		Net commodity level
  %VAR%_COMPRD(R,ALLYEAR,C,S %SWD%)     		Production of commodity
  %VAR%_ELAST(R,ALLYEAR,C,S,J,BD %SWD%) 		Demand change due to price elasticity
  %VAR%_DEM(R,MILESTONYR,C %SWD%)       		Demand variable for MACRO

*-----------------------------------------------------------------------------
* Cumulative variables
*-----------------------------------------------------------------------------
  %VAR%_CUMCOM(R,C,COM_VAR,ALLYEAR,ALLYEAR %SWD%) 	Cumulative commodity PRD or NET
  %VAR%_CUMFLO(R,P,C,ALLYEAR,ALLYEAR %SWD%)      	Cumulative process flow
  %VAR%_CUMCST(R,ALLYEAR,ALLYEAR,COSTAGG,CUR %SWD%)	Cumulative regional cost

*-----------------------------------------------------------------------------
* Storage variables
*-----------------------------------------------------------------------------
  %VAR%_SIN(R,ALLYEAR,ALLYEAR,P,C,S %SWD%)  		Input flow into storage
  %VAR%_SOUT(R,ALLYEAR,ALLYEAR,P,C,S %SWD%) 		Output flow from storage

*-----------------------------------------------------------------------------
* Additional features
*-----------------------------------------------------------------------------
  %VAR%_BLND(R,ALLYEAR,COM,COM %SWD%)      		Refinery blending
  %VAR%_DAM(R,T,C,BD,J %SWD%)              		Damage variables
  %VAR%_RCAP(R,ALLYEAR,LL,P %SWD%)        		New retirements
  %VAR%_SCAP(R,ALLYEAR,LL,P %SWD%)        		Cumulative retirements
  %VAR%_UPS(R,ALLYEAR,ALLYEAR,P,S,L %SWD%) 		Start-ups
  %VAR%_UPT(R,ALLYEAR,ALLYEAR,P,S,UPT%SWD%)		Start-ups by type
  %VAR%_UDP(R,ALLYEAR,ALLYEAR,P,S,L %SWD%) 		Unit dispatching
  %VAR%_RLD(R,T,S,ITEM %SWD%)     		 	Residual loads

*=============================================================================*
* Objective Function Components
*   - investment cost + tax/sub + decommissioning in INV
*   - fixed O&M + fixed tax/sub in FIX
*   - variable O&M + commodity direct costs
*   - salvage
*=============================================================================*
  %VAR%_OBJ(R,OBV,CUR %SWD%)    	"Objective costs INV,SAL,FIX,VAR,DAM"
  %VAR%_OBJELS(R,BD,CUR %SWD%)  	"Change in Consumer surplus"
  VAS_UPDEV(ALLSOW)             	"Upside deviation of OBJ"


 VARIABLES
*=============================================================================*
* Objective Function Variables
*   - total discounted system cost
*=============================================================================*

   OBJz
   VAS_EXPOBJ 				Expected value of total OBJ

*-----------------------------------------------------------------------------
* Slack variables of user-constraints
*-----------------------------------------------------------------------------
  %VAR%_UC(UC_N %SWD%)			Slacks for UC constraints
  %VAR%_UCR(UC_N,R %SWD%)		Slacks for UCR constraints
  %VAR%_UCT(UC_N,T %SWD%)		Slacks for UCT constraints
  %VAR%_UCRT(UC_N,R,T %SWD%)		Slacks for UCRT constraints
  %VAR%_UCTS(UC_N,T,S %SWD%)		Slacks for UCTS constraints
  %VAR%_UCRTS(UC_N,R,T,S %SWD%)		Slacks for UCRTS constraints
  ;

*-----------------------------------------------------------------------------
* Other variables in model extensions
*-----------------------------------------------------------------------------
* [AL] ETL variables automatically by extension manager
$IF DECLARED VNRET $BATINCLUDE prepret.dsc DECL
$IF DEFINED PRC_REACT $BATINCLUDE powerflo.vda DECL
$IF NOT DEFINED VAR_STS PARAMETER VAR_STS(R,YEAR,T,P,S,L) //;