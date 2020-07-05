*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2020 IEA-ETSAP.  Licensed under GPLv3 (see file LICENSE.txt).
*==============================================================================
* See the SETUP.DOC file for instructions on running the DDFNEW0 Utility
*==============================================================================

$BATINCLUDE initmty.tm
;
$BATINCLUDE macro.dd
;
*
*  Include data for ESUB (elasticity of substitution) and GR (GDP growth
*  rates)
FILE DDFFILE /DDF.DD/;
$INCLUDE GR.DD
*
* Output initial value of EC0 and GROWV
*
PUT DDFFILE;
*GG* V1.0 make 2 decimals points and allow for wider page
DDFFILE.NW=11;DDFFILE.ND=7;DDFFILE.PW=255;

PARAMETER TM_EC0I(R,T);

*GG* MMSCALE???
TM_EC0I(R,T)$(ORD(T) EQ 1) = TM_EC0(R);
$IF DEFINED TOT_OBJV  TM_EC0I(R,T) = TOT_OBJV(R,T) * TM_SCALE_CST;
$IF DEFINED REG_ACOST TM_EC0I(R,T) = SUM(ITEM$REG_ACOST(R,T,ITEM),REG_ACOST(R,T,ITEM)) * TM_SCALE_CST;

PUT / @1,'PARAMETERS  TM_EC0(R)' /  @1 '/' /;
  LOOP((R,T)$(ORD(T) EQ 1), PUT @1 R.TL, @32 TM_EC0I(R,T) / @1 '/;');

PUT / @1,'PARAMETERS  TM_KGDP(R)' /  @1 '/' /;
  LOOP(R, PUT @1 R.TL, @32 TM_KGDP(R) / @1 '/;');

PUT / @1,'PARAMETERS  TM_KPVS(R)' /  @1 '/' /;
  LOOP(R, PUT @1 R.TL, @32 TM_KPVS(R) / @1 '/;');

PUT / @1,'PARAMETERS  TM_DEPR(R)' /  @1 '/' /;
  LOOP(R, PUT @1 R.TL, @32 TM_DEPR(R) / @1 '/;');

PUT / @1,'PARAMETERS  TM_ESUB(R)' /  @1 '/' /;
  LOOP(R, PUT @1 R.TL, @32 TM_ESUB(R) / @1 '/;');

PUT / @1,'PARAMETERS  TM_GDP0(R)' /  @1 '/' /;
  LOOP(R, PUT @1 R.TL, @32 TM_GDP0(R) / @1 '/;');

PUT / @1,'SCALAR  TM_SCALE_UTIL' /  @1 '/' /;
  LOOP(R, PUT @1 TM_SCALE_UTIL / @1 '/;');

PUT / @1,'SCALAR  TM_SCALE_CST' /  @1 '/' /;
  LOOP(R, PUT @1 TM_SCALE_CST / @1 '/;');

PUT / @1,'SCALAR  TM_SCALE_NRG' /  @1 '/' /;
  LOOP(R, PUT @1 TM_SCALE_NRG / @1 '/;');

PUT / @1,'PARAMETERS  TM_DMTOL(R)' /  @1 '/' /;
  LOOP(R, PUT @1 R.TL, @32 TM_DMTOL(R) / @1 '/;');

PUT / @1,'PARAMETERS  TM_IVETOL(R)' /  @1 '/' /;
  LOOP(R, PUT @1 R.TL, @32 TM_IVETOL(R) / @1 '/;');

PUT / @1,'PARAMETERS TM_GROWV(R,ALLYEAR)' /;
PUT @1 '/' /;
LOOP ((R,T), PUT @1 R.TL, @10 '.', @11 T.TL:<4; PUT @32 TM_GR(R,T) /);
PUT @1 '/;' /;
*
* initialize Y
*
PARAMETERS TM_DDF_Y(R,T);

  TM_DDF_Y(R,T)$(ORD(T) EQ 1) = 1;

LOOP((R,T)$(ORD(T) GT 1),
  TM_DDF_Y(R,T) = TM_DDF_Y(R,T-1) * (1+TM_GR(R,T-1)/100.)**((D(T-1)+D(T))/2);
);

* display the time periods and economic variables
DISPLAY T, TM_ESUB, TM_GR, TM_DDF_Y, TM_EC0I;

*
* scale and undiscount marginals, then normalize to base year
*
PARAMETERS TM_DDF_DM(R,T,C);
PARAMETERS TM_DDF_SP(R,T,C);
PARAMETERS TM_DDF_PREF(R,T,C);
OPTION CLEAR=TM_DDF_PREF;

TM_DDF_SP(RTC(R,T,C))$DEM(R,C) = SUM(RTCS_VARC(R,T,C,S),(EQG_COMBAL.M(R,T,C,S) + EQE_COMBAL.M(R,T,C,S)) / VDA_DISC(R,T) * G_YRFR(R,S));
LOOP((MIYR_1(TT),T), TM_DDF_PREF(RTC(R,TT,C))$((TM_DDF_PREF(R,TT,C) EQ 0)$DEM(R,C)) = TM_DDF_SP(R,T,C));
LOOP(MIYR_1(T),TM_DDF_PREF(RTC(R,T,C))$((TM_DDF_PREF(R,T,C) EQ 0)$DEM(R,C)) = 1);
LOOP(MIYR_1(TT),TM_DDF_SP(RTC(R,T,C))$((TM_DDF_SP(RTC) EQ 0)$DEM(R,C)) = TM_DDF_PREF(R,TT,C));

display tm_ddf_pref;
TM_DDF_DM(RTC(R,T,C))$DEM(R,C) = 1;
LOOP(MIYR_1(TT),TM_DDF_DM(RTC(R,T,C))$(COM_PROJ(R,TT,C)$DEM(R,C)) = COM_PROJ(R,T,C)/COM_PROJ(R,TT,C));
LOOP(MIYR_1(TT),TM_DDF_SP(RTC(R,T,C))$DEM(R,C) = TM_DDF_SP(R,T,C) / TM_DDF_PREF(R,TT,C));


* output the demand levels and marginals
DISPLAY TM_DDF_DM, TM_DDF_SP;

*
* initialize the remaining variables
*
PARAMETER TM_RHO(R);
  TM_RHO(R) = 1. - 1 / TM_ESUB(R);
PARAMETERS F2(R,T,C);
  F2(RTC(R,T,C))$DEM(R,C) = TM_DDF_DM(R,T,C) / (TM_DDF_Y(R,T) * TM_DDF_SP(R,T,C) ** (-TM_ESUB(R)));
DISPLAY F2;
PARAMETERS TM_DDF_DDAT(R,T,C);
  TM_DDF_DDAT(RTC(R,T,C))$(DEM(R,C)*(ORD(T) EQ 1)) = 0.0;
  TM_DDF_DDAT(RTC(R,T,C))$(DEM(R,C)*(ORD(T) GT 1)) = 100. * (1. - (F2(R,T,C)/F2(R,T-1,C))
                                            ** ((TM_RHO(R)-1.)/(((D(T-1)+D(T))/2) * TM_RHO(R))));
*
* output the PREFs and DDFs to a file
*
PUT @1,'PARAMETERS TM_DDF(R,ALLYEAR,C)' /;
PUT @1 '/' /;
LOOP (RTC(R,T,C)$DEM(R,C), PUT @1 R.TL, @10 '.',  @11 T.TL:<11, @21 '.', @22 C.TL, @32 TM_DDF_DDAT(R,T,C) /);
PUT @1 '/;' /;

PUT @1,'PARAMETERS TM_DDATPREF(R,C)' /;
PUT @1 '/' /;
LOOP ((DEM(R,C),T)$(ORD(T) EQ 1), PUT @1 R.TL, @10 '.', @11 C.TL, @32 TM_DDF_PREF(R,T,C) /);
PUT @1 '/;' /;
