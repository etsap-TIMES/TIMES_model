*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*============================================================================*
*  Set the Cut-off Point for Applying the Market Penetration Cost Penalty    *
*============================================================================*
  TM_CAPTB(R,P) = SUM(RTP(R,T,P),TM_EXPBND(RTP));
* set the bounds for the step variables for quad approx, * clearing them first
  VAR_XCAPP.UP(RTP,J)   = INF;
  VAR_XCAPP.UP(RTP(R,T,P),XCP(J))$((ORD(J)<7)$TM_CAPTB(R,P)) = TM_CAPTB(R,P);

*============================================================================*
*  Set the Lower Bound and Fix the First Year                                *
*   - Demands                                                                *
*   - Investment                                                             *
*   - Capital                                                                *
*   - Marginal Costs of Demands                                              *
*============================================================================*
* user scalar (from CONSTANT table) to control lower bound on demands
  VAR_D.LO(RTC(R,T,C))$DEM(R,C)                   = TM_DMTOL(R) * TM_D0(R,C);
  VAR_D.FX(RTC(R,T,C))$(DEM(R,C)*(ORD(T) EQ 1))   = TM_D0(R,C);
  VAR_D.FX(RTC(R,T,C))$((COM_PROJ(R,T,C) EQ 0)$DEM(R,C))   = 0;
  VAR_DEM.FX(RTC(R,T,C))$((TM_DDATPREF(R,C)=0)$DEM(R,C)) = COM_PROJ(R,T,C);

  VAR_INV.L(R,T)                                  = TM_IV0(R) * TM_L(R,T);
  VAR_INV.FX(R,T(T_1))                            = TM_IV0(R);

  VAR_K.L(R,T)                                    = TM_K0(R) * TM_L(R,T);
* user scalar (from CONSTANT table) to control investment tolerance
  VAR_K.LO(R,T)                                   = TM_K0(R) * (TM_L(R,T) ** (TM_IVETOL(R)$(NOT TM_SL)));
  VAR_K.FX(R,T(T_1))                              = TM_K0(R);

  VAR_SP.FX(RTC(R,T,C))$DEM(R,C)                  = 0;

*SK* V0.4 set MM_C for base year
* VAR_C.FX(R,T(MIYR_1)) = TM_C0(R);
  VAR_C.LO(R,TT) = TM_C0(R)*.5;
