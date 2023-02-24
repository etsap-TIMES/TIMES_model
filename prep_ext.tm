*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PREP_ext.tm oversees all the added inperpolation activities needed by MACRO *
*   %1 - mod or v# for the source code to be used                             *
*=============================================================================*
* Comments: If TM_EC0 not defined, try loading MSADDF
*------------------------------------------------------------------------------
$IF NOT DEFINED TM_EC0
$IF EXIST msaddf.dd $INCLUDE msaddf.dd
$IF NOT DEFINED TM_EC0 OPTION CLEAR=TM_EC0;
*------------------------------------------------------------------------------
* Interpolate MACRO-specific parameters
$BATINCLUDE filparam TM_DDF 'R,' 'C' ",'','','','',''" DATAYEAR T '' ''
$BATINCLUDE filparam TM_EXPBND 'R,' 'P' ",'','','','',''" DATAYEAR T '' ''
$BATINCLUDE filparam TM_EXPF 'R,' '' ",'','','','',''" DATAYEAR T '' ''
$BATINCLUDE filparam TM_GR 'R,' '' ",'','','','',''" DATAYEAR T '' ''
$BATINCLUDE filparam TM_GROWV 'R,' '' ",'','','','',''" DATAYEAR T '' ''
*------------------------------------------------------------------------------
* Additions to support MACRO soft-link
  SCALAR TM_SL /0/;
  SETS MR(R), PP(T), TLAST(T), DM(C), XCP(J) /1, 6, 12/;
  ALIAS (MIYR_1,T_1);
  PARAMETER NYPER(ALLYEAR);
  PP(T+1) = YES;
  TLAST(T)$(ORD(T) EQ CARD(T)) = YES;
  TM_SL = (ROUND(TM_ARBM,1) EQ 1);
  IF(TM_SL,NYPER(T) = LAGT(T); ELSE NYPER(TT(T-1)) = (D(T)+D(TT))/2);
  NYPER(TLAST(T+1)) = LAGT(T);
  LOOP(R,DM(C)$DEM(R,C)=YES);
