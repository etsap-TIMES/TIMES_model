*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* Filtering Domain Violations via GDX
$ GOTO %1
$ LABEL MAIN
$ SET TMP "'" SET MX
$ IFI %SYSTEM.FILESYS%==MSNT $SET TMP '"'
  DISPLAY 'GAMS Warnings detected; Data have been Filtered via GDX';
$ hiddencall gdxdump _dd_.gdx NODATA > _dd_.dmp
$ hiddencall sed %TMP%/^\(Scalar\|[^$(]*([^,]*)\|[^$].*empty *$\)/{N;d;}; /^\([^$]\|$\)/d; s/\$LOAD.. /\$LOADR /I%TMP% _dd_.dmp > _dd_.dd
$ IF gamsversion 301 $onFiltered
* Half-baked workaround for GAMS 342
$ IF %SYSTEM.GAMSVERSION%==342
$ ONRECURSE $BATINCLUDE gdxfilter DAM_COST GR_VARGEN NCAP_DISC NCAP_OLIFE NCAP_SEMI PRC_DSCNCAP PRC_RCAP PRC_REACT PRC_REFIT RCAP_BLK REG_BDNCAP TM_CATT TM_UDF UC_ACTBET UC_CLI UC_FLOBET S_COM_FR S_DAM_COST S_FLO_FUNC S_NCAP_AFS
$ INCLUDE _dd_.dd
$ GDXIN
$ IF %SYSTEM.GAMSVERSION%==342 $INCLUDE _dd_.dmp
$ hiddencall rm -f _dd_.dmp
$ EXIT
*------------------------------------------------------------------------------
$ LABEL DAM_COST
* Prepare for killing with GAMS 34.2
$ LABEL MORE
$ IF %1.==. $GOTO PUTOUT
$ IF DECLARED %1
$ IF NOT DEFINED %1 $SET MX %1 %MX%
$ SHIFT GOTO MORE
$ LABEL PUTOUT
$ echon $KILL %MX% > _dd_.dmp