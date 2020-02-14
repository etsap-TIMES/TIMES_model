*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* BND_UCW.MOD Wrapper for setting bounds on UC RHS variables                  *
*=============================================================================*
* %1 - Stochastic dollar control or ''
* %2 - I or ''
*------------------------------------------------------------------------------
  CNT=0;
  UC_T_EACH(UC_T_SUCC(R,UC_N,T)) = YES;
$ BATINCLUDE bnd_ucv.mod   %VAR%_UC     ""  "" ""      UC_RHS    $UC_R_SUM(R,UC_N) LOOP(R, ); ",'','',''" %2
$ BATINCLUDE bnd_ucv.mod   %VAR%_UCR    "," "R" ""     UC_RHSR   $UC_R_EACH(R,UC_N) '' '' ",'',''" '%2' $UC_R_EACH(R,UC_N)
$ BATINCLUDE bnd_ucv.mod   %VAR%_UCT    "" "" ",T"     UC_RHST   $(UC_R_SUM(R,UC_N)*UC_T_EACH(R,UC_N,T)%1) LOOP(R, ); ",'',''" %2
$ BATINCLUDE bnd_ucv.mod   %VAR%_UCRT   "," "R" ",T"   UC_RHSRT  $(UC_R_EACH(R,UC_N)*UC_T_EACH(R,UC_N,T)%1) '' '' ",''" '%2' $UC_T_EACH(R,UC_N,T)
$ BATINCLUDE bnd_ucv.mod   %VAR%_UCTS   "" "" ",T,S"   UC_RHSTS  $(UC_R_SUM(R,UC_N)*UC_T_EACH(R,UC_N,T)%1) LOOP(R, ); ",''" %2
$ BATINCLUDE bnd_ucv.mod   %VAR%_UCRTS  "," "R" ",T,S" UC_RHSRTS $(UC_R_EACH(R,UC_N)*UC_T_EACH(R,UC_N,T)%1) '' '' "" '%2' $UC_T_EACH(R,UC_N,T)
  UC_T_EACH(UC_T_SUCC(R,UC_N,T)) = NO;
*-------------------------------------------------------------------------------
$IFI %STAGES%==YES IF(SW_PHASE EQ -9,
$IF  %STAGES%==YES   CNT$((SW_PARM GT 0)$CNT) = EPS;
$IFI %STAGES%==YES   SW_PHASE=-1; SW_PARM = (-2+4$(CNT GT 0))$CNT;);
