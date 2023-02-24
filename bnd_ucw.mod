*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* BND_UCW.MOD Wrapper for setting bounds on UC RHS variables                  *
*=============================================================================*
* %1 - Stochastic dollar control or ''
* %2 - I or ''
*------------------------------------------------------------------------------
$ SET TMP
$ IF %STAGES%==YES $SET TMP (T-SUC_L(R,UC_N))
  CNT=0;
  UC_T_EACH(UC_T_SUCC) = YES;
$ BATINCLUDE bnd_ucv.mod  %VAR%_UC    ""  "" ""     UC_RHS    $UC_R_SUM(R,UC_N) LOOP(R, ); '' '%2' ",'','',''"
$ BATINCLUDE bnd_ucv.mod  %VAR%_UCR   "," "R" ""    UC_RHSR   $UC_R_EACH(R,UC_N) '' '' '' '%2' ",'',''" $UC_R_EACH(R,UC_N)
$ BATINCLUDE bnd_ucv.mod  %VAR%_UCT   "" "" ",TT"   UC_RHST   $(UC_R_SUM(R,UC_N)*UC_T_EACH(R,UC_N,TT)%1) LOOP(R, ); '' '%2' ",'',''" '' %TMP%
$ BATINCLUDE bnd_ucv.mod  %VAR%_UCRT  "," "R" ",TT" UC_RHSRT  $(UC_R_EACH(R,UC_N)*UC_T_EACH(R,UC_N,TT)%1) '' '' '' '%2' ",''" $UC_T_EACH(R,UC_N,TT) %TMP%
$ BATINCLUDE bnd_ucv.mod  %VAR%_UCTS  "" "" ",TT"   UC_RHSTS  $(UC_R_SUM(R,UC_N)*UC_T_EACH(R,UC_N,TT)%1) LOOP(R, ); ,S '%2' ",''" '' %TMP%
$ BATINCLUDE bnd_ucv.mod  %VAR%_UCRTS "," "R" ",TT" UC_RHSRTS $(UC_R_EACH(R,UC_N)*UC_T_EACH(R,UC_N,TT)%1) '' '' ,S '%2' "" $UC_T_EACH(R,UC_N,TT) %TMP%
  UC_T_EACH(UC_T_SUCC) = NO;
*-------------------------------------------------------------------------------
$IFI %STAGES%==YES IF(SW_PHASE EQ -9,
$IF  %STAGES%==YES   CNT$((SW_PARM GT 0)$CNT) = EPS;
$IFI %STAGES%==YES   SW_PHASE=-1; SW_PARM = (-2+4$(CNT GT 0))$CNT;);
