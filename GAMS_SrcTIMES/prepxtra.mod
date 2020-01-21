*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2020 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file LICENSE.txt).
*=============================================================================*
* PREPONLY.MOD oversees that all inputs are inperpolated when INTEXT_ONLY
*=============================================================================*
$ GOTO %1
$ LABEL XTIE
*=============================================================================
* COST PARAMETERS: Interpolated by COEF_OBJ, only special options processed here
*-----------------------------------------------------------------------------
$ BATINCLUDE prepparm NCAP_COST R 'P,CUR' ",'0','0','0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm NCAP_DCOST R 'P,CUR' ",'0','0','0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm NCAP_DLAGC R 'P,CUR' ",'0','0','0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm NCAP_FOM R 'P,CUR' ",'0','0','0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm NCAP_FSUB R 'P,CUR' ",'0','0','0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm NCAP_FTAX R 'P,CUR' ",'0','0','0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm NCAP_ISUB R 'P,CUR' ",'0','0','0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm NCAP_ITAX R 'P,CUR' ",'0','0','0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm NCAP_VALU R 'P,C,CUR' ",'0','0'" T 'RTP(R,T,P)' EPS 3
*-----------------------------------------------------------------------------
* Commodity related attributes (6)
*-----------------------------------------------------------------------------
$ BATINCLUDE prepparm COM_CSTNET R 'C,S,CUR' ",'0','0'" T 1 EPS 3
$ BATINCLUDE prepparm COM_CSTPRD R 'C,S,CUR' ",'0','0'" T 1 EPS 3
$ BATINCLUDE prepparm COM_SUBNET R 'C,S,CUR' ",'0','0'" T 1 EPS 3
$ BATINCLUDE prepparm COM_SUBPRD R 'C,S,CUR' ",'0','0'" T 1 EPS 3
$ BATINCLUDE prepparm COM_TAXNET R 'C,S,CUR' ",'0','0'" T 1 EPS 3
$ BATINCLUDE prepparm COM_TAXPRD R 'C,S,CUR' ",'0','0'" T 1 EPS 3
*-----------------------------------------------------------------------------
* Flow related attributes & inter-regional exchange flows (6)
*-----------------------------------------------------------------------------
$ BATINCLUDE prepparm ACT_COST R 'P,CUR' ",'0','0','0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm FLO_COST R 'P,C,S,CUR' ",'0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm FLO_DELIV R 'P,C,S,CUR' ",'0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm FLO_SUB R 'P,C,S,CUR' ",'0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE prepparm FLO_TAX R 'P,C,S,CUR' ",'0'" T 'RTP(R,T,P)' EPS 3
$ BATINCLUDE fillparm IRE_PRICE R 'P,C,S,ALL_R,IE,CUR' "" T 'RTP(R,T,P)' 'GE 0'
*-----------------------------------------------------------------------------
* Components of merged UC attribs
*-----------------------------------------------------------------------------
$ BATINCLUDE fillparm UC_COMCON 'UC_N,SIDE,ALL_R' 'C,S' ",'0','0'" T 1 'GE 0'
$ BATINCLUDE fillparm UC_COMNET 'UC_N,SIDE,ALL_R' 'C,S' ",'0','0'" T 1 'GE 0'
$ BATINCLUDE fillparm UC_COMPRD 'UC_N,SIDE,ALL_R' 'C,S' ",'0','0'" T 1 'GE 0'
*-----------------------------------------------------------------------------
* General attribs:
$ BATINCLUDE filparam MULTI 'J,' '' ",'','','','',''" LL MILESTONYR 'NO$' ''
$ BATINCLUDE filparam.gms G_DRATE 'R,' 'CUR'  ",'','','','',''" YEAR T '' ''
*-----------------------------------------------------------------------------
$ LABEL POST
  MODLYEAR(LL) = T(LL)+PASTYEAR(LL);
*-----------------------------------------------------------------------------
* Clean up some unwanted stuff
$IF DEFINED PRC_RESID LOOP(PYR_S(LL),NCAP_PASTI(R,LL,P)$PRC_RESID(R,'0',P)=0; NCAP_TLIFE(R,LL,P)$PRC_RESID(R,'0',P)=0);
$IF DEFINED PRC_RESID PRC_RESID(R,'0',P)=0;
*-----------------------------------------------------------------------------
* UC Default values
*-----------------------------------------------------------------------------
$ LABEL UCINT
* Check 'every T' specifications through using DFLBL:
* For T_SUM, fill in between user-specified year range or all
  UC_DT(R,UC_N)$UC_T_SUM(R,UC_N,'%DFLBL%') = YES; UC_T_SUM(UC_DT,'%DFLBL%') = NO;
  LOOP(UC_DT, Z=SMAX(UC_T_SUM(UC_DT,LL),ORD(LL));
    IF(Z > 0, F=SMIN(UC_T_SUM(UC_DT,LL),ORD(LL)); ELSE F=Z);
    IF(Z NE F,UC_T_SUM(UC_DT,T(LL))$((ORD(LL) GT F)$(ORD(LL) LT Z)) = YES;
    ELSE UC_T_SUM(UC_DT,T) = YES));
  OPTION CLEAR=UC_DT;
  UC_T_SUCC(R,UC_N,T)$UC_T_SUCC(R,UC_N,'%DFLBL%') = YES;
  UC_T_EACH(R,UC_N,T)$UC_T_EACH(R,UC_N,'%DFLBL%') = YES;
  LOOP(T(YEAR),
    UC_T_EACH(R,UC_N,LL+(ORD(YEAR)-ORD(LL)))$(EOHYEARS(LL)$PERIODYR(T,LL)$UC_T_EACH(R,UC_N,LL)) = YES;
    UC_T_SUCC(R,UC_N,LL+(ORD(YEAR)-ORD(LL)))$(EOHYEARS(LL)$PERIODYR(T,LL)$UC_T_SUCC(R,UC_N,LL)) = YES;
    UC_T_SUM(R,UC_N,LL+(ORD(YEAR)-ORD(LL)))$(EOHYEARS(LL)$PERIODYR(T,LL)$UC_T_SUM(R,UC_N,LL)) = YES;
  );
*-----------------------------------------------------------------------------
$ LABEL SAVE
  F=JNOW; Z=CARD("%GDXPATH%%RUN_NAME%")+16;
$IF %1==SAVE MODLYEAR(LL)=T(LL)+PASTYEAR(LL); PUT QLOG; FILE.PW=512;
$IFI %G2X6%%1==YESSAVE
  PUT_UTILITY 'SHELL' / 'mv -f _dd_.gdx ' '%GDXPATH%%RUN_NAME%' @(Z+16) (GSECOND(F)+100):0:0 '.GDX' @(Z+14) (GMINUTE(F)+100):0:0 @(Z+12) (GHOUR(F)+100):0:0 @(Z+9) (GDAY(F)+100):0:0 "_" @(Z+7) (GMONTH(F)+100):0:0 @(Z+4) GYEAR(F):0:0 @Z '~Data_' @(Z+25) ;
