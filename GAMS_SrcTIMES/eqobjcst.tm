*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
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

$IF DEFINED PRC_RCAP $BATINCLUDE prepret.dsc OBJFIX

   SUM(RTP_CPTYR(R,V,T,P)$COEF_OBFIX(R,V,P,CUR), COEF_CPT(R,V,T,P) * OBJ_PVT(R,T,CUR) *
       COEF_OBFIX(R,V,P,CUR) * (VAR_NCAP(R,V,P)$TT(V)+NCAP_PASTI(R,V,P)))
  ;

*===============================================================================
* Generate Variable cost equation summing over all active indexes by region and currency
*===============================================================================

    EQ_ANNVAR(R,T,CUR)$RDCUR(R,CUR) ..

$BATINCLUDE eqobjvar.mod mod *

    SUM(PERIODYR(T,Y_EOH),OBJ_DISC(R,Y_EOH,CUR)) * VAR_ANNCST('OBJVAR',R,T,CUR);

