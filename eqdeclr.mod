*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQDECLR.MOD declarations for actual equations
*   %1 - mod or v# for the source code to be used
*=============================================================================*
*GaG Questions/Comments:
*   - declare all equations so that restarting changed models will work
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
  EQUATIONS
*-----------------------------------------------------------------------------
* Objective Function & Components
$IFI %MACRO%==YES $GOTO MACROBJ
*-----------------------------------------------------------------------------
* Overall OBJ linear combination of the regional objs (which are built from rest)
    EQ_OBJ 				'Overall Objective Function'

* OBJ cost components
   %EQ%_OBJELS(R,BD,CUR %SWD%)		'Costs of elastic demands'
   %EQ%_OBJFIX(R,CUR %SWD%) 		'Fixed Costs'
   %EQ%_OBJINV(R,CUR %SWD%) 		'Investment component'
   %EQ%_OBJSALV(R,CUR %SWD%) 		'Salvage'
   %EQ%_OBJVAR(R,CUR %SWD%) 		'Variable operating costs'
   %EQ%_OBJDAM(R,CUR %SWD%) 		'Damage costs'

*-----------------------------------------------------------------------------
$IFI %MACRO%==YES
$LABEL MACROBJ BATINCLUDE eqdeclr.tm
*-----------------------------------------------------------------------------
* Core Equations
*-----------------------------------------------------------------------------

* Relationship between process activity & individual primary commodity flows
   %EQ%_ACTFLO(R,ALLYEAR,ALLYEAR,P,S %SWTD%) 		'Process Activity/Primary Commodity Flows'

* Bound on activity
   %EQ%G_ACTBND(R,ALLYEAR,P,S %SWTD%) 			'Process activity Bound in a Period (=G=)' //
   %EQ%E_ACTBND(R,ALLYEAR,P,S %SWTD%) 			'Process activity Bound in a Period (=E=)' //
   %EQ%L_ACTBND(R,ALLYEAR,P,S %SWTD%) 			'Process activity Bound in a Period (=L=)' //

* Bound on commodities
   %EQ%G_BNDNET(R,ALLYEAR,C,S %SWTD%) 			'Net bound on a commodity (=G=)'
   %EQ%E_BNDNET(R,ALLYEAR,C,S %SWTD%) 			'Net bound on a commodity (=E=)'
   %EQ%L_BNDNET(R,ALLYEAR,C,S %SWTD%) 			'Net bound on a commodity (=L=)'
   %EQ%G_BNDPRD(R,ALLYEAR,C,S %SWTD%) 			'Production bound on a commodity (=G=)'
   %EQ%E_BNDPRD(R,ALLYEAR,C,S %SWTD%) 			'Production bound on a commodity (=E=)'
   %EQ%L_BNDPRD(R,ALLYEAR,C,S %SWTD%) 			'Production bound on a commodity (=L=)'

* Utilization of capacity, or the relationship between process capacity and activity
   %EQ%L_CAPACT(R,ALLYEAR,ALLYEAR,P,S %SWTD%) 		'Capacity Utilzation (=L=)'
   %EQ%E_CAPACT(R,ALLYEAR,ALLYEAR,P,S %SWTD%) 		'Capacity Utilzation (=E=)'
   %EQ%G_CAPACT(R,ALLYEAR,ALLYEAR,P,S %SWTD%) 		'Capacity Utilzation (=G=)'

* Basic commodity balance equations (by type) ensuring that production >=/= consumption
    %EQ%G_COMBAL(R,ALLYEAR,C,S %SWTD%) 			'Commodity Balance (=G=)' //
    %EQ%E_COMBAL(R,ALLYEAR,C,S %SWTD%) 			'Commodity Balance (=E=)' //
    %EQ%E_COMPRD(R,ALLYEAR,C,S %SWTD%) 			'Commodity Production (=E=)'
    %EQ%L_COMCES(R,ALLYEAR,C,C,S%SWTD%)     		'CES substitution steps (=L=)'

* Transfer of installed capacity between periods
    %EQ%G_CPT(R,ALLYEAR,P %SWTD%)                   	'Capacity Transfer (=G=)'
    %EQ%E_CPT(R,ALLYEAR,P %SWTD%)                   	'Capacity Transfer (=E=)'
    %EQ%L_CPT(R,ALLYEAR,P %SWTD%)                   	'Capacity Transfer (=L=)'

* Cumulative constraints
    %EQ%_CUMNET(R,C,ALLYEAR,ALLYEAR %SWD%) 		'Cummulative Net Commodity Limit (=E=)'
    %EQ%_CUMPRD(R,C,ALLYEAR,ALLYEAR %SWD%) 		'Cummulative Commodity Production Limit (=E=)'
    %EQ%_CUMFLO(R,P,C,ALLYEAR,LL %SWD%)    		'Cummulative Commodity Flow Limit (=E=)'

* Bound on the fraction of a flow within a time slice
    %EQ%G_FLOFR(R,T,P,C,S,L %SWTD%)			'Flow fraction (=G=)'
    %EQ%E_FLOFR(R,T,P,C,S,L %SWTD%)			'Flow fraction (=E=)'
    %EQ%L_FLOFR(R,T,P,C,S,L %SWTD%)			'Flow fraction (=L=)'

* Bound on the total flow
    %EQ%G_FLOBND(R,T,P,CG,S %SWTD%) 			'Flow bound (=G=)'
    %EQ%E_FLOBND(R,T,P,CG,S %SWTD%) 			'Flow bound (=E=)'
    %EQ%L_FLOBND(R,T,P,CG,S %SWTD%) 			'Flow bound (=L=)'

* Market share equation allocating commodity percentages of a group
    %EQ%G_INSHR(R,ALLYEAR,ALLYEAR,P,C,CG,S %SWTD%) 	'Commodity Input Group Share (=G=)'
    %EQ%E_INSHR(R,ALLYEAR,ALLYEAR,P,C,CG,S %SWTD%) 	'Commodity Input Group Share (=E=)'
    %EQ%L_INSHR(R,ALLYEAR,ALLYEAR,P,C,CG,S %SWTD%) 	'Commodity Input Group Share (=L=)'

* Inter-period storage equation
    %EQ%_STGIPS(R,ALLYEAR,ALLYEAR,P,ITEM %SWTD%) 	'Inter-period storage equation'
    %EQ%_STGAUX(R,ALLYEAR,ALLYEAR,P,C,S %SWTD%) 	'Storage auxiliary flows'

* Inter-regional exchange balance
    %EQ%_IRE(R,ALLYEAR,P,C,IE,S %SWTD%) 		'Inter-regional Exchange Process Balance (=E=)'

* Bound on inter-regional exchange of a commodity
    %EQ%G_IREBND(R,ALLYEAR,C,S,ALL_REG,IE %SWTD%) 	'Limit on Inter-regional Exchange (=G=)'
    %EQ%E_IREBND(R,ALLYEAR,C,S,ALL_REG,IE %SWTD%) 	'Limit on Inter-regional Exchange (=E=)'
    %EQ%L_IREBND(R,ALLYEAR,C,S,ALL_REG,IE %SWTD%) 	'Limit on Inter-regional Exchange (=L=)'

* Bound on total exchange of a commodity to/from all regions
    %EQ%G_XBND(ALL_REG,ALLYEAR,C,S,IE %SWTD%) 		'Limit on Total Exchange (=G=)'
    %EQ%E_XBND(ALL_REG,ALLYEAR,C,S,IE %SWTD%) 		'Limit on Total Exchange (=E=)'
    %EQ%L_XBND(ALL_REG,ALLYEAR,C,S,IE %SWTD%) 		'Limit on Total Exchange (=L=)'

* Product share equation allocating commodity percentages of a group
    %EQ%G_OUTSHR(R,ALLYEAR,ALLYEAR,P,C,CG,S %SWTD%) 	'Commodity Output Group Share (=G=)'
    %EQ%E_OUTSHR(R,ALLYEAR,ALLYEAR,P,C,CG,S %SWTD%) 	'Commodity Output Group Share (=E=)'
    %EQ%L_OUTSHR(R,ALLYEAR,ALLYEAR,P,C,CG,S %SWTD%) 	'Commodity Output Group Share (=L=)'

* Process market-share equation of total commodity production
    %EQ%G_FLOMRK(R,ALLYEAR,ITEM,C,S %SWTD%) 		'Process market-share (=G=)' //
    %EQ%E_FLOMRK(R,ALLYEAR,ITEM,C,S %SWTD%) 		'Process market-share (=E=)' //
    %EQ%L_FLOMRK(R,ALLYEAR,ITEM,C,S %SWTD%) 		'Process market-share (=L=)' //

* Peaking Equation
    %EQ%_PEAK(R,ALLYEAR,COM_GRP,S %SWTD%) 		'Commodity Peaking constraint (=G=)'

* Commodity-to-commodity transformation
    %EQ%_PTRANS(R,ALLYEAR,ALLYEAR,P,CG,CG,S %SWTD%) 	'Commodity-to-Commodity Transform (=E=)'

* Time-slice storage equation
    %EQ%_STGTSS(R,ALLYEAR,ALLYEAR,P,S %SWTD%)		'Time-slice storage equation'
    %EQ%_STSBAL(R,ALLYEAR,ALLYEAR,P,TSL,S,L%SWTD%)   	'Time-slice storage balancer'
    EQ_STSLEV(R,ALLYEAR,ALLYEAR,P,TSLVL,S,ALLSOW)    	'Time-slice storage levelizer'

* Bound on storage flow
    %EQ%G_STGIN(R,ALLYEAR,P,C,S %SWTD%) 		'Bound on input flow of storage (=G=)'
    %EQ%E_STGIN(R,ALLYEAR,P,C,S %SWTD%) 		'Bound on input flow of storage (=E=)'
    %EQ%L_STGIN(R,ALLYEAR,P,C,S %SWTD%) 		'Bound on input flow of storage (=L=)'
    %EQ%G_STGOUT(R,ALLYEAR,P,C,S %SWTD%) 		'Bound on output flow of storage (=G=)'
    %EQ%E_STGOUT(R,ALLYEAR,P,C,S %SWTD%) 		'Bound on output flow of storage (=E=)'
    %EQ%L_STGOUT(R,ALLYEAR,P,C,S %SWTD%) 		'Bound on output flow of storage (=L=)'

* Retirements
    %EQ%_CUMRET(R,ALLYEAR,ALLYEAR,P%SWTD%) 		'Cumulative retirements'
    %EQ%L_REFIT(R,ALLYEAR,ALLYEAR,P%SWTD%) 		'Retrofit/life-extension (=L=)'
    %EQ%L_SCAP(R,ALLYEAR,P,IPS%SWD%)    		'Salvage capacity (=L=)'

* Cost bounds
    %EQ%_BNDCST(REG,ALLYEAR,T,ALLYEAR,COSTCAT,CUR %SWD%) 'Bound on cumulative costs'

* User-constraints
    %EQ%E_UC(UC_N %SWD%) 		'User-constraints (=E=)'
    %EQ%E_UCR(UC_N,R %SWD%) 		'User-constraints (=E=)'
    %EQ%E_UCT(UC_N,T %SWTD%) 		'User-constraints (=E=)'
    %EQ%E_UCRT(UC_N,R,T %SWTD%) 	'User-constraints (=E=)'
    %EQ%E_UCTS(UC_N,T,S %SWTD%) 	'User-constraints (=E=)'
    %EQ%E_UCRS(R,UC_N,T,TSL,S %SWD%) 	'User-constraints (=E=)'
    %EQ%E_UCRTS(UC_N,R,T,S %SWTD%) 	'User-constraints (=E=)'
    %EQ%E_UCSU(UC_N,T %SWD%) 		'User-constraints (=E=)'
    %EQ%E_UCSUS(UC_N,T,S %SWD%) 	'User-constraints (=E=)'
    %EQ%E_UCRSUS(UC_N,R,T,S %SWD%) 	'User-constraints (=E=)'
    %EQ%E_UCRSU(UC_N,R,T %SWD%) 	'User-constraints (=E=)'

$IF %VAR_UC% == YES $GOTO UCDONE
    EQG_UC(UC_N) 			'User-constraints (=G=)'
    EQG_UCR(UC_N,R) 			'User-constraints (=G=)'
    EQG_UCT(UC_N,T) 			'User-constraints (=G=)'
    EQG_UCRT(UC_N,R,T) 			'User-constraints (=G=)'
    EQG_UCTS(UC_N,T,S) 			'User-constraints (=G=)'
    EQG_UCRS(R,UC_N,T,TSL,S) 		'User-constraints (=G=)'
    EQG_UCRTS(UC_N,R,T,S) 		'User-constraints (=G=)'
    EQG_UCSU(UC_N,T) 			'User-constraints (=G=)'
    EQG_UCSUS(UC_N,T,S) 		'User-constraints (=G=)'
    EQG_UCRSUS(UC_N,R,T,S) 		'User-constraints (=G=)'
    EQG_UCRSU(UC_N,R,T) 		'User-constraints (=G=)'

    EQL_UC(UC_N) 			'User-constraints (=L=)'
    EQL_UCR(UC_N,R) 			'User-constraints (=L=)'
    EQL_UCT(UC_N,T) 			'User-constraints (=L=)'
    EQL_UCRT(UC_N,R,T) 			'User-constraints (=L=)'
    EQL_UCTS(UC_N,T,S) 			'User-constraints (=L=)'
    EQL_UCRS(R,UC_N,T,TSL,S) 		'User-constraints (=L=)'
    EQL_UCRTS(UC_N,R,T,S) 		'User-constraints (=L=)'
    EQL_UCSU(UC_N,T) 			'User-constraints (=L=)'
    EQL_UCSUS(UC_N,T,S) 		'User-constraints (=L=)'
    EQL_UCRSUS(UC_N,R,T,S) 		'User-constraints (=L=)'
    EQL_UCRSU(UC_N,R,T) 		'User-constraints (=L=)'
$LABEL UCDONE
*-----------------------------------------------------------------------------
*GG* V07_2 BLENDing equation
    EQL_BLND(R,YEAR,BLE,SPE,ALLSOW) 		'Blending (=L=)'
    EQG_BLND(R,YEAR,BLE,SPE,ALLSOW) 		'Blending (=G=)'
    EQE_BLND(R,YEAR,BLE,SPE,ALLSOW) 		'Blending (=E=)'
    EQN_BLND(R,YEAR,BLE,SPE,ALLSOW) 		'Blending non-binding'

* Damage Extension
    %EQ%_DAMAGE(R,T,C %SWD%) 	'Damages'

* Stochastic extension
    %EQ%_ROBJ(R%SWD%)   	'Deterministic objective by region and SOW'
    %EQ%_SOBJ(LIM%SWD%) 	'Deterministic objective by SOW'
    EQ_EXPOBJ(ALLSOW) 		'Expected value of total system cost'
    EQ_UPDEV(ALLSOW) 		'Upper absolute deviation'
;
