*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* CAL_STG the code associated with the storage flows in the EQ_COMxxx
*   %1 - 'IN/OUT' for consumption/production
*   %2 - 'OUT/IN' for consumption/production
*   %3 - STG_EFF for output
*   %4 - STG_EFF for output
*   %5 - for day-night storage indicator
*=============================================================================*
* Questions/Comments:
* %6 - NCAP_PKCNT multiplier
*-----------------------------------------------------------------------------
*V05c 980923 - check that commodity not just capacity related
  SUM((TOP(RPC_STG(R,P,C),'%1'),RPCS_VAR(R,P,C,TS))$%5,
       SUM(RTP_VINTYR(R,V,T,P),
          (%VAR%_S%1(R,V,T,P,C,TS %SOW%)%3-%4%VAR%_S%2(R,V,T,P,C,TS %SOW%)$RPC_STGN(R,P,C,'%2'))%6)$(NOT RPC_STGN(R,P,C,'%1')) *
* equation coarser than variable or finer than variable
        RS_FR(R,S,TS)
     ) +

