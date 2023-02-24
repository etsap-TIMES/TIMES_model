*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQOBJCST the objective functions investment, fixed and variable costs
*   %1 - mod or v# for the source code to be used
*=============================================================================*
* Questions/Comments:
*  - Supports also alternative objective formulations
*-----------------------------------------------------------------------------

*===============================================================================
* Generate Investment equation summing over all active indexes by region and currency
*===============================================================================

   EQ_ANNINV(R,T,CUR)$RDCUR(R,CUR)..

   VAR_ANNCST('OBJINV',R,T,CUR)  =E=

* Revised accounting for MACRO: Calculate annualized cost from discounted
* lump-sum investments undiscounted back to the lump-sum commissioning year K

   SUM(RTP_CPTYR(R,V,T,P)$OBJ_ICUR(R,V,P,CUR), COEF_CPT(R,V,T,P) *
       COEF_OBINV(R,V,P,CUR) * (VAR_NCAP(R,V,P)$TT(V)+NCAP_PASTI(R,V,P)))
   ;

*===============================================================================
* Generate Fixed Cost equation summing over all active indexes by region and currency
*===============================================================================

   EQ_ANNFIX(R,T,CUR)$RDCUR(R,CUR) ..

   VAR_ANNCST('OBJFIX',R,T,CUR)*OBJ_PVT(R,T,CUR) =E=

* Revised accounting for MACRO: Calculate annualized cost from discounted 
* lump-sum fixed costs undiscounted back to the lump-sum commissioning year K

$IF DEFINED VNRET $BATINCLUDE prepret.dsc OBJFIX

   SUM(RTP_CPTYR(R,V,T,P)$COEF_OBFIX(R,V,P,CUR), COEF_CPT(R,V,T,P) * OBJ_PVT(R,T,CUR) *
       COEF_OBFIX(R,V,P,CUR) * (VAR_NCAP(R,V,P)$TT(V)+NCAP_PASTI(R,V,P)))
  ;

*===============================================================================
* Generate Variable cost equation summing over all active indexes by region and currency
*===============================================================================

   EQ_ANNVAR(R,T,CUR)$RDCUR(R,CUR) ..

$BATINCLUDE eqobjvar.mod mod *

   OBJ_PVT(R,T,CUR) * VAR_ANNCST('OBJVAR',R,T,CUR) 

$IF DEFINED DAM_COST -
$IF DEFINED DAM_COST $BATINCLUDE eqdamage.mod E * $EXIT
$IF NOT %TIMESED%==YES $GOTO DONELS
    -
   SUM((MI_DMAS(R,COM,C),BDNEQ(BD))$MI_ESUB(R,T,COM), BDSIG(BD) *
     SUM(RTCS_VARC(R,T,C,S)$COM_STEP(R,C,BD), COEF_PVT(R,T) * COM_BPRICE(R,T,C,S,CUR) *
       SUM(RCJ(R,C,J,BD),%VART%_ELAST(R,T,C,S,J,BD %SWS%) * MI_AGC(R,T,COM,C,J,BD))))
$LABEL DONELS
  ;
