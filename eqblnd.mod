*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*----------------------------------------------------------------------------*
*GG* V07_2 BLENDing equation
*  - %1 L/G/E/N
*  - %2 1/2/3/4
*----------------------------------------------------------------------------*
*GG* Move these to the appropriate modules
*----------------------------------------------------------------------------*
* DISCOUNT ANNUAL COSTS
*----------------------------------------------------------------------------*
*  add blending costs
*  SUM(BLE_TP(TP,BLE),
*    SUM(OPR$BLE_OPR(BLE,OPR), (PRICE_BLE(TP,BLE,OPR) *  BLND(TP,BLE,OPR)))
*  )
*
*----------------------------------------------------------------------------*
* ANNUALIZED ANNUAL COSTS
*----------------------------------------------------------------------------*
*  add blending costs
*  SUM(BLE_OPR(BLE,OPR)$BLE_TP(TP,BLE),
*    ANNC_BLE(TP,BLE,OPR) * BLND(TP,BLE,OPR)
*  )
*
*----------------------------------------------------------------------------*
* BALANCE (plus ELC)
*----------------------------------------------------------------------------*
*  add blending requirements
*  SUM(OPR$BLE_OPR(ENC_G,OPR),
*    BAL_BLE(TP,ENC_G,OPR) * BLND(TP,ENC_G,OPR)
*  ) +
*  SUM(BLE_TP(TP,BLE)$BLE_OPR(BLE,ENC_G),
*    -1 * BLND(TP,BLE,ENC_G)
*  ) +
*  SUM(BLE_OPR(BLE,OPR)$(BLE_INP(BLE,ENC_G) * BLE_TP(TP,BLE)),
*    -(BL_INP(BLE,ENC_G) + SUM(BLE_SPEOPR(BLE,SPE,OPR)$BLE_SPEINP(BLE,SPE,ENC_G),
*      TBL_INP(BLE,SPE,ENC_G,TP))) * BLND(TP,BLE,OPR)
*  )
*
*
*GG* V1.5r add blending requirements for electricity
*  SUM(BLE_OPR(BLE,OPR)$BLE_INP(BLE,ELC),
*    - BALE_BLE(TP,BLE,ELC,Z,'D') * BLND(TP,BLE,OPR)
*  )
*
*----------------------------------------------------------------------------*
* EMISSIONS
*----------------------------------------------------------------------------*
*  Emissions due to BLENDing
*  + SUM(BLE_OPR(BLE,OPR),
*        ENV_BL(ENV,BLE,OPR,TP) * BLND(TP,BLE,OPR))
*
*----------------------------------------------------------------------------*
* PEAKING
*----------------------------------------------------------------------------*
*  add blending requirements
*  SUM(BLE_OPR(BLE,OPR),
*    - EPK_BLE(TP,BLE,ELC,Z) * BLND(TP,BLE,OPR)
*  )
*

*============================================================================*
*  BLENDing equation by type                                                 *
*============================================================================*
  EQ%1_BLND(BLE_TP(%R_T%,BLE),SPE%SWX%)$(%SWTX%(BL_TYPE(R,BLE,SPE)=%2))..
  SUM(OPR$BLE_OPR(R,BLE,OPR), (BL_COM(R,BLE,OPR,SPE) - BL_SPEC(R,BLE,SPE)) *
                              RU_CVT(R,BLE,SPE,OPR) * %VAR%_BLND(R,T,BLE,OPR %SOW%))
  =%1=
  0;
