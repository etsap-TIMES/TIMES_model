*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PREPPM.MOD oversees all the enhanced interpolation activities
*   %1 - mod or v# for the source code to be used
*=============================================================================*
$   SET RESET 0
$   IFI %INTEXT_ONLY% == YES     $SET RESET 15
$   IFI %DATAGDX% == YES         $BATINCLUDE prepxtra.mod SAVE
$   IFI %PREP_ANS%%RESET%==YES15 $BATINCLUDE prepxtra.mod POST
$   IFI %PREP_ANS% == YES        $EXIT
*-----------------------------------------------------------------------------
* Ensure that both MODLYEAR and DATAYEAR include PASTYEAR
* Also set the special year among datayears for the processing of control options.
 MODLYEAR(LL) = MILESTONYR(LL)+PASTYEAR(LL);
 DATAYEAR(PASTYEAR)  = YES;
 DATAYEAR('%DFLBL%') = YES;
* Build DM_YEAR for interpolation, excluding the special year:
 DM_YEAR(MILESTONYR) = YES;
 DM_YEAR(DATAYEAR) = (YEARVAL(DATAYEAR)>0);
* Set migrating years MY_FIL, and FIL2 of each MY_FIL to the period year, if within periods:
 LOOP(T,FIL2(DM_YEAR)$((YEARVAL(DM_YEAR) >= B(T)) * (YEARVAL(DM_YEAR) <= E(T))) = YEARVAL(T));
 MY_FIL(DM_YEAR)$(FIL2(DM_YEAR)*(NOT T(DM_YEAR))) = YES;
*-----------------------------------------------------------------------------
$IF DEFINED G_CUREX R_CUREX(R,CURR,CUR)$NO=0; R_CUREX(R,CURR,CUR)$(NOT R_CUREX(R,CURR,CUR))$=G_CUREX(CURR,CUR);
$IF DEFINED R_CUREX $INCLUDE curex
*-----------------------------------------------------------------------------
* Merge special case user attributes to generic case
 LOOP(DATAYEAR,PRC_MARK(R,'%DFLBL%',P,P,C,BD)$FLO_MARK(R,DATAYEAR,P,C,BD) = 3);
 PRC_MARK(R,DATAYEAR,P,P,C,BD) $= FLO_MARK(R,DATAYEAR,P,C,BD);
* Integration of COM costs
 OBJ_COMNT(R,DATAYEAR,C,S,'COST',CUR) $= COM_CSTNET(R,DATAYEAR,C,S,CUR);
 OBJ_COMNT(R,DATAYEAR,C,S,'TAX',CUR)  $= COM_TAXNET(R,DATAYEAR,C,S,CUR);
 OBJ_COMNT(R,DATAYEAR,C,S,'SUB',CUR)  $= COM_SUBNET(R,DATAYEAR,C,S,CUR)*(-1);
 OBJ_COMPD(R,DATAYEAR,C,S,'COST',CUR) $= COM_CSTPRD(R,DATAYEAR,C,S,CUR);
 OBJ_COMPD(R,DATAYEAR,C,S,'TAX',CUR)  $= COM_TAXPRD(R,DATAYEAR,C,S,CUR);
 OBJ_COMPD(R,DATAYEAR,C,S,'SUB',CUR)  $= COM_SUBPRD(R,DATAYEAR,C,S,CUR)*(-1);
* Integration of UC_COMxxx
 UC_COM(UC_N,'PRD',SIDE,R,DATAYEAR,C,S,'COMPRD')$(NOT UC_ATTR(R,UC_N,SIDE,'COMPRD','NET')) $= UC_COMPRD(UC_N,SIDE,R,DATAYEAR,C,S);
 UC_COM(UC_N,'PRD',SIDE,R,DATAYEAR,C,S,'COMCON')$(NOT UC_ATTR(R,UC_N,SIDE,'COMCON','NET')) $= UC_COMCON(UC_N,SIDE,R,DATAYEAR,C,S);
 UC_COM(UC_N,'NET',SIDE,R,DATAYEAR,C,S,'COMPRD')$UC_ATTR(R,UC_N,SIDE,'COMPRD','NET') $= UC_COMPRD(UC_N,SIDE,R,DATAYEAR,C,S);
 UC_COM(UC_N,'NET',SIDE,R,DATAYEAR,C,S,'COMCON')$UC_COMCON(UC_N,SIDE,R,DATAYEAR,C,S)  = UC_COMCON(UC_N,SIDE,R,DATAYEAR,C,S)*(-1);
 UC_COM(UC_N,'NET',SIDE,R,DATAYEAR,C,S,'COMNET') $= UC_COMNET(UC_N,SIDE,R,DATAYEAR,C,S);
* Prepare flags for flow tax/sub
 SET OBJ_VFLO(R,P,C,CUR,UC_COST);
 SET RPC_CUR(REG,PRC,COM,CUR);
 OPTION RPC_CUR <= FLO_TAX; OBJ_VFLO(RPC_CUR,'TAX') = YES;
 OPTION RPC_CUR <= FLO_SUB; OBJ_VFLO(RPC_CUR,'SUB') $= OBJ_VFLO(RPC_CUR,'TAX');
 FLO_TAX(R,LL--ORD(LL),P,C,S,CUR)$((NOT FLO_TAX(R,'%DFLBL%',P,C,S,CUR))$FLO_TAX(R,LL,P,C,S,CUR)$OBJ_VFLO(R,P,C,CUR,'SUB')) = 3;
 FLO_SUB(R,LL--ORD(LL),P,C,S,CUR)$((NOT FLO_SUB(R,'%DFLBL%',P,C,S,CUR))$FLO_SUB(R,LL,P,C,S,CUR)$OBJ_VFLO(R,P,C,CUR,'SUB')) = 3;
*-----------------------------------------------------------------------------
* Starting data pre-preprocessing with temporary control sets for parameters
$IF NOT SET DEF_IEBD $SET DEF_IEBD 10
  IE_DEFAULT(INT_DEFAULT) = 3;
$IF SET RETIRE $BATINCLUDE prepret.dsc PREP PRC_RCAP RCAP_BND
*-----------------------------------------------------------------------------
* Use RVP for extrapolating vintaged flow parameters
$ BATINCLUDE fillvint
  RVP(RTP(R,V,P))$PRC_VINT(R,P) = YES;
*-----------------------------------------------------------------------------
*       Interpolation Options
*       =====================
* The placeholder for the option flag is parameter data point of year zero.
* Example: NCAP_COST(R,'0',P,CUR) is an option for NCAP_COST(R,T,P,CUR).
* Available option codes: See documentation
*
* Interpolation can be effectively denied for non-cost parameters only.
*
*=============================================================================
* COST PARAMETERS: Interpolated by COEF_OBJ, only special options processed here
*-----------------------------------------------------------------------------
* General attributes
*-----------------------------------------------------------------------------
*$BATINCLUDE prepparm G_DRATE R CUR ",'0','0','0','0'" YEAR 1 1
$BATINCLUDE filparam G_RFRIR 'R,' '' ",'0','0','0','0','0'" YEAR V
*-----------------------------------------------------------------------------
* Capacity related attributes
*-----------------------------------------------------------------------------
$BATINCLUDE prepparm NCAP_COST R 'P,CUR' ",'0','0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm NCAP_DCOST R 'P,CUR' ",'0','0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm NCAP_DLAGC R 'P,CUR' ",'0','0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm NCAP_FOM R 'P,CUR' ",'0','0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm NCAP_FSUB R 'P,CUR' ",'0','0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm NCAP_FTAX R 'P,CUR' ",'0','0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm NCAP_ISUB R 'P,CUR' ",'0','0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm NCAP_ITAX R 'P,CUR' ",'0','0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm NCAP_VALU R 'P,C,CUR' ",'0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm NCAP_ISPCT R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 0
*-----------------------------------------------------------------------------
* Commodity related attributes
*-----------------------------------------------------------------------------
$BATINCLUDE prepparm OBJ_COMNT R 'C,TS,COSTYPE,CUR' ",'0','0'" T 1 0
$BATINCLUDE prepparm OBJ_COMPD R 'C,TS,COSTYPE,CUR' ",'0','0'" T 1 0
*-----------------------------------------------------------------------------
* Flow related attributes & inter-regional exchange flows (6)
*-----------------------------------------------------------------------------
$BATINCLUDE prepparm ACT_COST R 'P,CUR' ",'0','0','0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm FLO_COST R 'P,C,TS,CUR' ",'0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm FLO_DELIV R 'P,C,TS,CUR' ",'0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm FLO_SUB R 'P,C,TS,CUR' ",'0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm FLO_TAX R 'P,C,TS,CUR' ",'0','0'" V 'RTP(R,V,P)' 0
$BATINCLUDE prepparm IRE_PRICE R 'P,C,TS,ALL_REG,IE,CUR' "" V 'RTP(R,V,P)' 0
$IF DEFINED DAM_COST $BATINCLUDE prepparm DAM_COST R 'C,CUR' ",'0','0','0'" T 1 EPS 3
*=============================================================================
***** REGULAR NON-COST PARAMETERS: Interpolated over DM_YEAR by default ******
*-----------------------------------------------------------------------------
* Capacity related attributes
*-----------------------------------------------------------------------------
$BATINCLUDE fillparm NCAP_AF R 'P,TS,BD' ",'0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RPSB
$BATINCLUDE fillparm NCAP_AFA R 'P,BD' ",'0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RPB
$BATINCLUDE fillparm NCAP_AFS R 'P,TS,BD' ",'0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RPSB
$BATINCLUDE fillparm NCAP_BPME R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm NCAP_CDME R P ",'0','0','0','0','0'" V 'RVP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm NCAP_CEH R P ",'0','0','0','0','0'" V 'RVP(R,V,P)' 'GE 0' X_RP
$BATINCLUDE fillparm NCAP_CHPR R 'P,BD' ",'0','0','0','0'" V 'RVP(R,V,P)' 'GE 0' X_RPB
$BATINCLUDE fillparm NCAP_CLED R 'P,C' ",'0','0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm NCAP_CLAG R 'P,C,IO' ",'0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm NCAP_COM R 'P,C,IO' ",'0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm NCAP_DELIF R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RP
$BATINCLUDE fillparm NCAP_DLAG R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RP
$BATINCLUDE fillparm NCAP_DLIFE R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RP
$BATINCLUDE fillparm NCAP_DRATE R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RP
$BATINCLUDE fillparm NCAP_FDR R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RP
$BATINCLUDE fillparm NCAP_ELIFE R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RP
$BATINCLUDE fillparm NCAP_ICOM R 'P,C' ",'0','0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm NCAP_ILED R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RP
$BATINCLUDE fillparm NCAP_OCOM R 'P,C' ",'0','0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm NCAP_PKCNT R 'P,TS' ",'0','0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm NCAP_TLIFE R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RP
*-----------------------------------------------------------------------------
* Commodity related attributes
*-----------------------------------------------------------------------------
$BATINCLUDE fillparm COM_AGG R 'C,COM' ",'0','0','0','0'" T 1 'GE 0'
$BATINCLUDE fillparm COM_ELAST R 'C,TS,L' ",'0','0','0'" T 1 'GE 0'
$BATINCLUDE fillparm COM_FR R 'C,TS' ",'0','0','0','0'" T 1 'GE 0' X_RCS
$BATINCLUDE fillparm COM_IE R 'C,TS' ",'0','0','0','0'" T 1 'GE 0'
$BATINCLUDE fillparm COM_PKFLX R 'C,TS' ",'0','0','0','0'" T 1 'GE 0'
$BATINCLUDE fillparm COM_PKRSV R C ",'0','0','0','0','0'" T 1 'GE 0'
$BATINCLUDE fillparm COM_PROJ R C ",'0','0','0','0','0'" T 1 'GE 0'
$BATINCLUDE fillparm COM_VOC R 'C,BD' ",'0','0','0','0'" T 1 'GE 0'
*-----------------------------------------------------------------------------
* Flow related attributes & inter-regional exchange
*-----------------------------------------------------------------------------
$BATINCLUDE fillparm ACT_CSTUP R 'P,TSL,CUR' ",'0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm ACT_CSTSD R 'P,UPT,BD,CUR' ",'0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm ACT_CSTRMP R 'P,BD,CUR' ",'0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm ACT_TIME R 'P,LIM' ",'0','0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm FLO_FUNC R 'P,CG1,CG2,TS' ",'0','0'" V 'RVP(R,V,P)' 'GE 0' X_RPGGS
$BATINCLUDE fillparm FLO_PKCOI R 'P,C,TS' ",'0','0','0'" V 'RVP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm FLO_SUM R 'P,CG1,C,CG2,TS' ",'0'" V 'RVP(R,V,P)' 'GE 0' X_RPGCGS
$BATINCLUDE fillparm PRC_ACTFLO R 'P,CG' ",'0','0','0','0'" V 'RTP(R,V,P)' 'GE 0' X_RPG
$BATINCLUDE prepparm PRC_MARK R 'P,ITEM,C,BD' ",'0'" T 1 1 11
$BATINCLUDE fillparm IRE_FLO R 'P,C,REG,COM,TS' ",'0'" V '(RVP(R,V,P) OR RTP(REG,V,P))' 'GE 0'
$BATINCLUDE fillparm IRE_FLOSUM R 'P,C,TS,IE,COM,IO' "" V 'RVP(R,V,P)' 'GE 0'
*-----------------------------------------------------------------------------
* Storage attributes
*-----------------------------------------------------------------------------
$BATINCLUDE fillparm STG_CHRG R 'P,S' ",'0','0','0','0'" V '(M(V) GE MIYR_V1-1)' 'GE 0'
$BATINCLUDE fillparm STG_EFF R P ",'0','0','0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm STG_LOSS R 'P,S' ",'0','0','0','0'" V 'RTP(R,V,P)' 'GE 0'
$BATINCLUDE fillparm STG_SIFT R 'P,C,S' ",'0','0','0'" T 'RTP(R,T,P)' 'GE 0'
*-----------------------------------------------------------------------------
* User constraints
*-----------------------------------------------------------------------------
$BATINCLUDE fillparm UC_ACT 'UC_N,SIDE,R' 'P,TS' ",'0','0'" T 'RTP(R,T,P)' 'GE 0'
$BATINCLUDE fillparm UC_CAP 'UC_N,SIDE,R' P ",'0','0','0'" T 1 'GE 0'
$BATINCLUDE fillparm UC_COM 'UC_N,COM_VAR,SIDE,R' 'C,TS,UC_GRPTYPE' "" T 1 'GE 0'
$BATINCLUDE fillparm UC_FLO 'UC_N,SIDE,R' 'P,C,TS' ",'0'" T 1 'GE 0'
$BATINCLUDE fillparm UC_IRE 'UC_N,SIDE,R' 'P,C,TS,IE' "" T 'RTP(R,T,P)' 'GE 0'
$BATINCLUDE fillparm UC_NCAP 'UC_N,SIDE,R' P ",'0','0','0'" T 'RTP(R,T,P)' 'GE 0'
$BATINCLUDE fillparm UC_UCN 'UC_N,SIDE,R' UCN ",'0','0','0'" T 1 'GE 0'
$BATINCLUDE filparam UC_TIME 'UC_N,R,' '' ",'0','0','0'" DATAYEAR T '' '' '' "YEAR,"
*=============================================================================
******* NON-REGULAR NON-COST PARAMETERS: NOT interpolated by default *********
*-----------------------------------------------------------------------------
* Capacity and commodity related attributes
*-----------------------------------------------------------------------------
$BATINCLUDE prepparm CAP_BND R 'P,BD' ",'0','0','0'" T 'RTP(R,T,P)' 1
$BATINCLUDE prepparm NCAP_BND R 'P,LIM' ",'0','0','0'" T 'RTP(R,T,P)' 1
$BATINCLUDE prepparm COM_BNDNET R 'C,TS,BD' ",'0','0'" T 1 1
$BATINCLUDE prepparm COM_BNDPRD R 'C,TS,BD' ",'0','0'" T 1 1
*-----------------------------------------------------------------------------
* Flow related attributes & inter-regional exchange
*-----------------------------------------------------------------------------
$BATINCLUDE prepparm ACT_BND R 'P,TS,BD' ",'0','0'" T 'RTP(R,T,P)' 1
$BATINCLUDE prepparm FLO_BND R 'P,CG,TS,BD' ",'0'" T 'RTP(R,T,P)' 1
$BATINCLUDE prepparm FLO_FR R 'P,C,TS,LIM' ",'0'" T 'RTP(R,T,P)' 1
$BATINCLUDE prepparm FLO_SHAR R 'P,C,CG,TS,BD' "" V 'RVP(R,V,P)' 1 '' +
$BATINCLUDE prepparm IRE_BND R 'C,TS,ALL_REG,IE,BD' "" T 1 1
$BATINCLUDE prepparm IRE_XBND ALL_REG 'C,TS,IE,BD' ",'0'" T 1 1
*-----------------------------------------------------------------------------
* Storage attributes
*-----------------------------------------------------------------------------
$BATINCLUDE prepparm STGIN_BND R 'P,C,S,BD' ",'0'" T 'RTP(R,T,P)' 1
$BATINCLUDE prepparm STGOUT_BND R 'P,C,S,BD' ",'0'" T 'RTP(R,T,P)' 1
*-----------------------------------------------------------------------------
* User constraints
*-----------------------------------------------------------------------------
$BATINCLUDE prepparm UC_RHSRT 'ALL_R,UC_N' LIM ",'0','0','0'" T 1 1
$BATINCLUDE prepparm UC_RHSRTS 'ALL_R,UC_N' 'TS,LIM' ",'0','0'" T 1 1
$BATINCLUDE prepparm UC_RHST UC_N LIM ",'0','0','0','0'" T 1 1
$BATINCLUDE prepparm UC_RHSTS UC_N 'TS,LIM' ",'0','0','0'" T 1 1
$BATINCLUDE prepparm REG_BNDCST R 'COSTAGG,CUR,BD' ",'0','0'" T 1 1
*-----------------------------------------------------------------------------
* Parameters that are by default inter/extrapolated over PASTYEARS
*-----------------------------------------------------------------------------
$ BATINCLUDE prepparm FLO_SHAR R 'P,C,CG,TS,BD' "" PASTMILE 'RVP(R,PASTMILE,P)' 1 3 -ABS
*-----------------------------------------------------------------------------
*=============================================================================
* Additions through extensions:
*------------------------------------------------------------------------------
$   IFI %STAGES% == YES     $BATINCLUDE prep_ext.stc
$   IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod prep_ext %EXTEND%
$   IFI %INTEXT_ONLY%==YES  $BATINCLUDE prepxtra.mod XTIE
*=============================================================================
***************************** SHAPE/MULTI INDEXES ****************************
*-----------------------------------------------------------------------------
$BATINCLUDE preshape NCAP_AFX R P "" V RXX RTP(R,V,P)
$BATINCLUDE preshape NCAP_AFSX R 'P,BD' ",'0','0','0'" V UNCD7 RTP(R,V,P)
$BATINCLUDE preshape NCAP_AFM R P "" V RXX RTP(R,V,P)
$BATINCLUDE preshape NCAP_FOMX R P "" V RXX RTP(R,V,P)
$BATINCLUDE preshape NCAP_FSUBX R P "" V RXX RTP(R,V,P)
$BATINCLUDE preshape NCAP_FTAXX R P "" V RXX RTP(R,V,P)
$BATINCLUDE preshape FLO_FUNCX R 'P,CG1,CG2' ",'0','0'" V UNCD7 RTP(R,V,P)
$BATINCLUDE preshape COM_ELASTX R 'C,BD' ",'0','0','0'" T UNCD7 1 15
$BATINCLUDE preshape NCAP_FOMM R P "" V RXX RTP(R,V,P)
$BATINCLUDE preshape NCAP_FSUBM R P "" V RXX RTP(R,V,P)
$BATINCLUDE preshape NCAP_FTAXM R P "" V RXX RTP(R,V,P)
$BATINCLUDE preshape NCAP_CPX R P "" V RXX RTP(R,V,P)
*-----------------------------------------------------------------------------
* All non-cost parameters have now been interpolated / extrapolated and user-defined options processed.
* Second interpolation pass is still needed for cost parameters (dense interpolation).
  OPTION CLEAR = UNCD7;
*-----------------------------------------------------------------------------
* Augment datayear with MILESTONYR, as any MODLYEAR may now contain user data.
* Remove the special year from DATAYEAR, as the controls are processed.
  DATAYEAR(MILESTONYR) = YES;
  DATAYEAR('%DFLBL%') = NO;
*-----------------------------------------------------------------------------
* Optional weighting of vintaged attributes
$IF NOT %VINTOPT%==1 $EXIT
$BATINCLUDE fillvint FLO_FUNC R 'P,CG1,CG2,TS' X_RPGGS
$BATINCLUDE fillvint FLO_SUM R 'P,CG1,C,CG2,TS' X_RPGCGS
$BATINCLUDE fillvint NCAP_CDME R P X_RP
$BATINCLUDE fillvint NCAP_CHPR R 'P,BD' X_RPB
$BATINCLUDE fillvint FLO_SHAR R 'P,C,CG,TS,BD' X_RPCGSB
OPTION CLEAR=PASTSUM;
*-----------------------------------------------------------------------------