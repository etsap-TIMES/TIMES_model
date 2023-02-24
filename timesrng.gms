*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*============================================================================*
* Create Ranging GDX at execution time
*============================================================================*
$ONWARNING
$ONMULTI
$OFFLISTING
$PHANTOM EMPTY
ALIAS (*,R,REG,ALLYEAR,P,RNGLIM);
ALIAS (*,C,COM,J,S,T,ALL_REG,IE,CUR,BD,OBV,LL);
ALIAS (*,COM_GRP,CG,ITEM,IO,UC_N,CM_VAR,CM_BOX);
ALIAS (*,PRC,KP,UNIT);
PARAMETER  VAR_NCAPRNG(R,ALLYEAR,P,RNGLIM) / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
$IF EXIST timesrng.inc $INCLUDE timesrng.inc
EXECUTE_UNLOAD 'timesrng',VAR_NCAPRNG;
