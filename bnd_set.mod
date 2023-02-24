*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* BND_SET.MOD set the actual bounds on variables
*  %1 - variable reference
*  %2 - primary index into variable
*  %3 - qualifier/bound expression
*  %4 - control index
*  %5 - stochastic qualifier
*=============================================================================*
*GaG Questions/Comments:
*  - FX take precedence as is set last!!!
*  - take primary index loop control criteria too, or reset all in case change
*    in data (e.g., process moves from 1 region to another?) LATTER!!!
*-----------------------------------------------------------------------------
*$ONLISTING
* reset any existing bounds
  %1.LO(%2%SWD%) = 0;
  %1.UP(%2%SWD%) = INF;
* assign from user data
  %1.LO(%4%SOW%)%5  $=  %3(%2,'LO');
  %1.UP(%4%SOW%)%5  $=  %3(%2,'UP');
  %1.FX(%4%SOW%)%5  $=  %3(%2,'FX');

*-----------------------------------------------------------------------------
* Stochastic bounds
$IF%6 NOT %STAGES%==YES $EXIT
$IF NOT DECLARED S_%3 $EXIT
  %1.LO(%4%SOW%)%5  $=  S_%3(%2,'LO','1',SOW);
  %1.UP(%4%SOW%)%5  $=  S_%3(%2,'UP','1',SOW);
  %1.FX(%4%SOW%)%5  $=  S_%3(%2,'FX','1',SOW);
*$OFFLISTING
