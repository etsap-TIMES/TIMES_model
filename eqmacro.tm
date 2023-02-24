*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
*  Utility Production Function, the Objective Function                        *
*=============================================================================*

EQ_UTIL ..

	SUM((R,T), TM_DFACT(R,T) * TM_PWT(T) * LOG(VAR_C(R,T)))

	=E=

	VAR_UTIL * MAX(1,LOG(TM_SCALE_UTIL*1000))/1000;
	;


*=============================================================================*
*  Production Constraint
*=============================================================================*

EQ_CONSO(R,T) ..

     VAR_C(R,T) =L= 

     (TM_AKL(R) * (VAR_K(R,T) ** (TM_KPVS(R)*TM_RHO(R))) * TM_L(R,T) ** ((1-TM_KPVS(R)) * TM_RHO(R)) +

      SUM(DEM(R,C), TM_B(R,C) * VAR_D(R,T,C) ** TM_RHO(R))) ** (1 / TM_RHO(R)) - VAR_INV(R,T) - VAR_EC(R,T);


*=============================================================================*
*  Demand Coupling Equation                                                   *
*  A demand relation is generated for each demand sector DM and ensures that  *
*  the end-use energy output from the demand devices which have output to DM  *
*  is greater than or equal to the end-use demand specified by the user.      *
*=============================================================================*

EQ_DD(R,T,C)$DEM(R,C) ..

	VAR_DEM(R,T,C)

	=E=

	((1/TM_SCALE_NRG) * (TM_AEEIFAC(R,T,C) * VAR_D(R,T,C) + TM_ADDER(R,T,C) + VAR_SP(R,T,C)))$(COM_PROJ(R,T,C) GT 0)
	;

*=============================================================================*
*  Capital Dynamics Equation                                                  *
*=============================================================================*

EQ_MCAP(R,T+1) ..

	VAR_K(R,T+1)

	=E=

	VAR_K(R,T) * TM_TSRV(R,T) + (D(T+1)*VAR_INV(R,T+1) + TM_TSRV(R,T)*D(T)*VAR_INV(R,T))/2
	;

*=============================================================================*
*  Terminal Condition for investment in last period                           *
*=============================================================================*

EQ_TMC(R,T)$(ORD(T) = CARD(T)) ..

  VAR_K(R,T) * (TM_GROWV(R,T) + TM_DEPR(R))/100

  =L=

  VAR_INV(R,T)
  ;

*=============================================================================*
*  Bound on Sum of Investment and Energy                                      *
*=============================================================================*
EQ_IVECBND(R,T)$(ORD(T) GT 1) ..

  VAR_INV(R,T) + VAR_EC(R,T)

  =L=

  TM_Y0(R) * TM_L(R,T) ** TM_IVETOL(R);


*=============================================================================*
*  Energy System Costs
*=============================================================================*

* Calculate annualized undiscounted investment costs
  TM_CSTINV(R,V,P)$RTP(R,V,P)
  =
  SUM(OBJ_ICUR(R,V,P,CUR), COEF_OBINV(R,V,P,CUR));


EQ_ESCOST(R,T) ..

  TM_SCALE_CST * (

  VAR_OBJCOST(R,T)
  +

* quadratic market penetration curve
  (SUM(RTP(R,T,P)$TM_CAPTB(R,P),
    0.5 * TM_QFAC(R) *
    TM_CSTINV(R,T,P) * (TM_CAPTB(R,P) / TM_EXPF(R,T) * SUM(XCP(J),VAR_XCAPP(R,T,P,J)*ORD(J))))
  )$(TM_QFAC(R) NE 0))

* add initial amortization (from CSA only)
  + TM_AMP(R,T)

  =E=

  VAR_EC(R,T);

*=============================================================================*
*  Variable definition for market penetration cost penalty function           *
*=============================================================================*
EQ_MPEN(RTP(R,TT(T+1),P))$((TM_QFAC(R) NE 0)$TM_CSTINV(R,TT,P)$TM_CAPTB(R,P)) ..

  VAR_CAP(R,TT,P)
  =L=
  TM_EXPF(R,T) * VAR_CAP(R,T,P) + VAR_XCAP(R,TT,P);

*=============================================================================*
*  Market Penetration Cost Penalty Function, Quadratic Approximation          *
*=============================================================================*

EQ_XCAPDB(RTP(R,TT(T+1),P))$((TM_QFAC(R) NE 0)$TM_CSTINV(R,TT,P)$TM_CAPTB(R,P)) ..

  VAR_XCAP(R,TT,P)

  =E=

  SUM(XCP(J),VAR_XCAPP(R,TT,P,J))
  ;

