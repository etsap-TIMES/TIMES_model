*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2023 IEA-ETSAP.  Licensed under GPLv3 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* CUREX.GMS oversees the currency conversions
*   %1 - name of cost attribute
*   %2 - name of temp attribute (set to %1 if no temp used)
*   %3 - indexes before CUR
*   %4 - constant indexes before CUR (optional, for temp attribute)
*   %5 - indexes after CUR
*=============================================================================*
$IFI %INTEXT_ONLY% == YES $EXIT
$IF NOT '%1'=='' $GOTO SUBR
*--------------------------------------------------------------------------
SET CURMAP(REG,CUR,CUR);
ALIAS(CUR,CRU);
OPTION CLEAR=CURMAP,PROFILE=0;
R_CUREX(R,CUR,CUR) = 0;
*--------------------------------------------------------------------------
* Convert only if unambiguous single target RDCUR
LOOP((R,CURR),
 IF((SUM(RDCUR(R,CUR)$R_CUREX(R,CURR,CUR),1) EQ 1),
      CURMAP(RDCUR(R,CUR),CURR)$R_CUREX(R,CURR,CUR) = YES;
 ELSE CURMAP(RDCUR(R,CURR),CURR) = YES));
LOOP(CURMAP(R,CUR,CURR)$(NOT SAMEAS(CUR,CURR)), RDCUR(R,CURR) = NO);
R_CUREX(RDCUR(R,CUR),CUR) = 1;

* Resolve two-step chained conversion
OPTION CLEAR=RXX;
LOOP((CURMAP(RDCUR(R,CUR),CURR),CRU)$((NOT RDCUR(R,CURR))$CURMAP(R,CURR,CRU)),RXX(R,CURR,CRU)$(NOT R_CUREX(R,CRU,CUR))=YES);
LOOP(RXX(R,CURR,CRU),R_CUREX(R,CRU,CUR)$CURMAP(R,CUR,CURR)=R_CUREX(R,CRU,CURR)*R_CUREX(R,CURR,CUR));
LOOP(RXX(R,CURR,CRU),CURMAP(R,CURR,CRU)=NO; CURMAP(R,CUR,CRU)$CURMAP(R,CUR,CURR)=YES);
*--------------------------------------------------------------------------
$ONRECURSE
$BATINCLUDE curex NCAP_COST RYPM 'R,LL,P'
$BATINCLUDE curex NCAP_ITAX RYPM 'R,LL,P'
$BATINCLUDE curex NCAP_ISUB RYPM 'R,LL,P'
$BATINCLUDE curex NCAP_DCOST RYPM 'R,LL,P'
$BATINCLUDE curex NCAP_DLAGC RYPM 'R,LL,P'
$BATINCLUDE curex NCAP_FOM RYPM 'R,LL,P'
$BATINCLUDE curex NCAP_FSUB RYPM 'R,LL,P'
$BATINCLUDE curex NCAP_FTAX RYPM 'R,LL,P'
$BATINCLUDE curex ACT_COST RYPM 'R,LL,P'
$BATINCLUDE curex FLO_COST RYPCSM 'R,LL,P,C,S'
$BATINCLUDE curex FLO_DELIV RYPCSM 'R,LL,P,C,S'
$BATINCLUDE curex FLO_TAX RYPCSM 'R,LL,P,C,S'
$BATINCLUDE curex FLO_SUB RYPCSM 'R,LL,P,C,S'
$BATINCLUDE curex NCAP_VALU RYPCSM 'R,LL,P,C' ",'ANNUAL'"
$BATINCLUDE curex IRE_PRICE RYPCSRXM 'R,LL,P,C,S,ALL_R,IE'
$BATINCLUDE curex COM_BPRICE RYCSM 'R,LL,C,S'
$BATINCLUDE curex COM_CSTNET RYCSM 'R,LL,C,S'
$BATINCLUDE curex COM_TAXNET RYCSM 'R,LL,C,S'
$BATINCLUDE curex COM_SUBNET RYCSM 'R,LL,C,S'
$BATINCLUDE curex COM_CSTPRD RYCSM 'R,LL,C,S'
$BATINCLUDE curex COM_TAXPRD RYCSM 'R,LL,C,S'
$BATINCLUDE curex COM_SUBPRD RYCSM 'R,LL,C,S'
$BATINCLUDE curex REG_BNDCST REG_BNDCST 'R,LL,COSTAGG' '' ',BD'
$BATINCLUDE curex REG_CUMCST REG_CUMCST 'R,LL,YEAR,COSTAGG' '' ',BD'
$BATINCLUDE curex BL_VAROMC BL_VAROMC 'R,COM' '' '' 1
$BATINCLUDE curex BL_DELIVC BL_DELIVC 'R,C,COM' '' '' 1
$BATINCLUDE curex ACT_CSTUP ACT_CSTUP 'R,LL,P,TSL'
$BATINCLUDE curex ACT_CSTSD ACT_CSTSD 'R,LL,P,UPT,BD'
$BATINCLUDE curex ACT_CSTRMP ACT_CSTRMP 'R,LL,P,BD'
$BATINCLUDE curex ACT_CSTPL RYPM 'R,LL,P'
*--------------------------------------------------------------------------
$IF DEFINED TL_CT_COST $BATINCLUDE curex TL_CT_COST RYPM       'R,LL,P'
$IF DEFINED DAM_COST   $BATINCLUDE curex DAM_COST   RYCSM      'R,LL,C' ",'ANNUAL'"
$IF DEFINED S_DAM_COST $BATINCLUDE curex S_DAM_COST S_DAM_COST 'R,LL,C' '' ',J,ALLSOW'
$IF DEFINED S_COM_TAX  $BATINCLUDE curex S_COM_TAX  S_COM_TAX  'R,LL,C,S,COM_VAR' '' ',J,ALLSOW'
*--------------------------------------------------------------------------
OPTION PRO%PRF%,CLEAR=RYPM,CLEAR=RYPCSM,CLEAR=RYPCSRXM,CLEAR=RYCSM;
$OFFRECURSE
$GOTO FINISH
*--------------------------------------------------------------------------
$LABEL SUBR
$IF %6=='' $SET MX 1$YEARVAL(LL)
$IF NOT DECLARED %2 PARAMETER %2(%3,CUR);
$IFI NOT %1==%2 OPTION CLEAR=%2; %2(%3%4,CUR) $= %1(%3,CUR); OPTION CLEAR=%1;
  %1(%3,CUR%5) $= SUM(CURMAP(R,CUR,CURR)$%2(%3%4,CURR%5),%2(%3%4,CURR%5)*POWER(R_CUREX(R,CURR,CUR),%6%MX%));
$IFI %1==%2     %1(%3,CUR%5)$(NOT RDCUR(R,CUR)) = 0;
*--------------------------------------------------------------------------
$LABEL FINISH
