*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* UC_CAP the code associated with the VAR_CAP variable in the EQ_USERCON
*     - %1 region summation index
*     - %2 period summation index
*     - %3 'T' or 'T+1' or 'T-1' index
*     - %4 'LHS' or 'RHS'
*     - %5 Type of constraint (0=EACH, 1=SUCC or 2=SEVERAL)
*=============================================================================*
*UR Questions/Comments:
*  -
*-----------------------------------------------------------------------------
* "SUM(UC_R_SUM(R,UC_N)," or bracket (
   %1
*      "SUM(UC_T_SUM(UC_N,T)," or bracket (
        %2
             SUM(RTP(R,%3,P)$UC_GMAP_P(R,UC_N,'CAP',P),

* VAR_CAP can always be directly used for UC_CAP
                     %VAR%_CAP(R,%3,P %SOW%) * UC_CAP(UC_N,%4,R,%6,P) *

* PROD operator needs to be 'tweaked' due to bug in older GAMS versions
$IF %5==1            PROD(UC_ATTR(R,UC_N,%4,'CAP','GROWTH'),
$IF %5==1                 POWER(ABS(UC_CAP(UC_N,%4,R,%6,P)),%7*UC_SIGN(%4)-1)) *
                     PROD(UC_ATTR(R,UC_N,%4,'CAP','CAPACT'),PRC_CAPACT(R,P)) *
                     PROD(L('N'),1)
             )
*       closing bracket of %2 :
        )
*  closing bracket of %1 :
   )

$IF NOT %VDA%%5==YESS $GOTO END
* Subtract offline capacity if requested
* SUM or bracket (
  +%2
     SUM(RTP(R,%3,P)$(RP_UPL(R,P,'FX')$UC_GMAP_P(R,UC_N,'CAP',P)), EPS+
         UC_CAP(UC_N,%4,R,%6,P)*PROD(UC_ATTR(R,UC_N,%4,'CAP','CAPACT'),PRC_CAPACT(R,P)) *
         SUM(RTP_VINTYR(R,V,%3,P),(%UPSCAPS%)))$UC_ATTR(R,UC_N,%4,'CAP','ONLINE')
   )
$IFI NOT %ABS%==YES $GOTO END
* Add reserve flows if requested
  +%2
     SUM(BS_UCMAP(UC_N,%4,R,P,C)$BS_COMTS(R,C,S),UC_FLO(UC_N,%4,R,%6,P,C,'ANNUAL') * PRC_CAPACT(R,P) *
         SUM((RTP_VINTYR(R,V,%3,P),BS_PRS(R,P,TS))$RS_FR(R,S,TS),RS_FR(R,TS,S) *
           SUM(LNX(L),%VAR%_BSPRS(R,V,T,P,C,TS,L%SOW%)$(IPS(L)+BS_SUPP(R,P)$(ABS(BS_RTYPE(R,C))>2)))))
   )

$LABEL END
