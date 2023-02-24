*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*============================================================================*
* ppmain.tm oversees all the preprocessing activities needed by MACRO
$ BATINCLUDE prep_ext.tm
*============================================================================*
* Initialize the economic parameters
*============================================================================*

  TM_AEEIV(R,T,C)$DEM(R,C) = TM_DDF(R,T,C)/100;
  TM_ASRV(R)               = 1 - TM_DEPR(R)/100;
  TM_DFACTCURR(R,T)        = 1 - (TM_KPVS(R)/TM_KGDP(R) - TM_DEPR(R)/100 - TM_GROWV(R,T)/100);
  TM_RHO(R)                = 1 - 1/TM_ESUB(R);

* Capital survival defined as factor between the middle year of the period T+1 and the period T
  TM_TSRV(R,T)             = TM_ASRV(R) ** NYPER(T);

*============================================================================*
*  Calculate initial values for the economic variables for the first time period
*   - Capital Stock
*   - Investment during time period 0
*   - Consumption during time period 0
*   - GDP (Consumption + Investment) + Energy Costs
*============================================================================*

  TM_K0(R)  = TM_KGDP(R) * TM_GDP0(R);
  TM_IV0(R) = TM_K0(R) * (TM_DEPR(R) + SUM(T$(ORD(T) = 1),TM_GROWV(R,T)))/100;
  TM_C0(R)  = TM_GDP0(R) - TM_IV0(R);
  TM_Y0(R)  = TM_GDP0(R) + TM_EC0(R) + SUM(T_1(T),TM_AMP(R,T));

*============================================================================*
* Calculate intermediate values
*============================================================================*
  TM_AEEIFAC(R,T,C)$DEM(R,C)  = 1;
  TM_DFACT(R,T)               = 1;
  TM_L(R,T)                   = 1;

  LOOP(T,
    TM_AEEIFAC(R,T+1,C)$DEM(R,C) = TM_AEEIFAC(R,T,C) * (1 - TM_AEEIV(R,T+1,C)) ** NYPER(T);
    TM_DFACT(R,T+1)              = TM_DFACT(R,T) * TM_DFACTCURR(R,T) ** NYPER(T);
    TM_L(R,T+1)                  = TM_L(R,T) * (1 + TM_GROWV(R,T) / 100) ** NYPER(T);
  );

* Arbitrary multiplier on utility in last time period.
  LOOP(MIYR_1(T++1)$(TM_ARBM NE 1),
  TM_DFACT(R,T) = TM_DFACT(R,T) *
      (1-MIN(.999,TM_DFACTCURR(R,T))**(NYPER(T)*TM_ARBM)) /
      (1-MIN(.999,TM_DFACTCURR(R,T))**(NYPER(T) * 1 )));
* Weights for periods (use only if requested by TM_ARBM=1)
  TM_PWT(T) = 1; IF(TM_SL, Z=MAX(1,SMAX(T,D(T))); TM_PWT(T) = D(T)/Z);

  TM_D0(DEM(R,C)) = TM_SCALE_NRG * SUM(MIYR_1(T), COM_PROJ(R,T,C));

  TM_B(DEM(R,C))  = TM_D0(R,C) / TM_Y0(R);
  TM_B(DEM(R,C))  = TM_B(R,C) ** (1 - TM_RHO(R));
  TM_B(DEM(R,C))  = TM_SCALE_CST / TM_SCALE_NRG * TM_DDATPREF(R,C) * TM_B(R,C);

  TM_AKL(R)    =  TM_Y0(R) ** TM_RHO(R) - SUM(DEM(R,C), TM_B(R,C) * (TM_D0(R,C) ** TM_RHO(R)));
  TM_AKL(R)    =  TM_AKL(R) / (TM_K0(R) ** (TM_KPVS(R) * TM_RHO(R)));

  TM_YCHECK(R) = TM_AKL(R) * TM_K0(R) ** (TM_KPVS(R) * TM_RHO(R)) + SUM(DEM(R,C), TM_B(R,C) * TM_D0(R,C) ** TM_RHO(R));
  TM_YCHECK(R) = TM_YCHECK(R) ** (1 / TM_RHO(R));

* annual percent expansion factor converted into 1 period factor
  PARAMETER HELP_EXPF(R,T);
  HELP_EXPF(R,T) = TM_EXPF(R,T);
  TM_EXPF(R,T) = (1+HELP_EXPF(R,T)/100)**(D(T)/2) * (1+HELP_EXPF(R,T+1)/100)**(D(T+1)/2);
  OPTION CLEAR=HELP_EXPF;

display tm_b, tm_expf;
