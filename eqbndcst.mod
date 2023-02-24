*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQBNDCOST: bounds on undiscounted cost components
*   %1 - 
*=============================================================================*
*[AL] Questions/Comments:
*
*-----------------------------------------------------------------------------
* Need a few more aliases and sets
 SET SUPERYR(T,ALLYEAR) 'SUpremum PERiod YeaR'   //;
 SET YKK(ALLYEAR,ALLYEAR,ALLYEAR)                //;
 SET RTP_IAN(REG,T,P,CUR)                        //;
 SET RT_IAN(REG,ALLYEAR,ALLYEAR,CUR,COSTAGG)     //;
 PARAMETER CST_ANNC(R,ALLYEAR,P,ALLYEAR,UC_NAME,CUR) //;
$IF NOT DEFINED OBJ_SUMII $EXIT
*-----------------------------------------------------------------------------
 SET COST_GMAP(COSTAGG,COSTAGG,COSTYPE) /
  INVTAXSUB.(INVTAX.TAX,INVSUB.SUB)
  INVALL   .(INV.COST,INVTAX.TAX,INVSUB.SUB)
  FOMTAXSUB.(FOMTAX.TAX,FOMSUB.SUB)
  FOMALL   .(FOM.COST,FOMTAX.TAX,FOMSUB.SUB)
  FIX      .(INV.COST,FOM.COST)
  FIXTAX   .(INVTAX.TAX,FOMTAX.TAX)
  FIXSUB   .(INVSUB.TAX,FOMSUB.TAX)
  FIXTAXSUB.(INVTAX.TAX,INVSUB.SUB,FOMTAX.TAX,FOMSUB.SUB)
  FIXALL   .(INV.COST,INVTAX.TAX,INVSUB.SUB,FOM.COST,FOMTAX.TAX,FOMSUB.SUB)
  COMTAXSUB.(COMTAX.TAX,COMSUB.SUB)
  FLOTAXSUB.(FLOTAX.TAX,FLOSUB.SUB)
  ALLTAX   .(INVTAX.TAX,FOMTAX.TAX,COMTAX.TAX,FLOTAX.TAX)
  ALLSUB   .(INVSUB.TAX,FOMSUB.TAX,COMSUB.TAX,FLOSUB.TAX)
  ALLTAXSUB.(INVTAX.TAX,INVSUB.SUB,FOMTAX.TAX,FOMSUB.SUB,COMTAX.TAX,COMSUB.SUB,FLOTAX.TAX,FLOSUB.SUB)
/;
*-----------------------------------------------------------------------------
* Construct SUPERYR (needed for filtering)
  SUPERYR(PERIODYR(T,LL))$(YEARVAL(LL) LE YEARVAL(T)) = YES;
  SUPERYR(T+1,LL)$((YEARVAL(LL) GT YEARVAL(T))$PERIODYR(T,LL)) = YES;
  LOOP(MIYR_1(T++1),SUPERYR(T,LL)$(YEARVAL(LL) GT M(T)) = YES);
* Add single MILESTONYR bounds to REG_CUMCST
  REG_CUMCST(R,T,T,COSTAGG,CUR,BD) $= REG_BNDCST(R,T,COSTAGG,CUR,BD);
* Add infinite bound for components if aggregate bound
  LOOP((COST_GMAP(COSTCAT,COSTAGG,COSTYPE),BD),
    REG_CUMCST(R,YEAR,LL,COSTAGG,CUR,'UP')$((NOT REG_CUMCST(R,YEAR,LL,COSTAGG,CUR,'UP'))$REG_CUMCST(R,YEAR,LL,COSTCAT,CUR,BD)) = INF);
  LOOP(BDLOX(BD),
    REG_CUMCST(R,YEAR,LL,COSTCAT,CUR,'UP')$((NOT REG_CUMCST(R,YEAR,LL,COSTCAT,CUR,'UP'))$REG_CUMCST(R,YEAR,LL,COSTCAT,CUR,BD)) = INF);
*-----------------------------------------------------------------------------
* Prepare INVCOST and ITAXSUB coefficients
LOOP(UC_ATTR(R,UC_N,SIDE,'NCAP','INVCOST'),LOOP(T,TRACKP(R,P)$UC_NCAP(UC_N,SIDE,R,T,P)=YES));
RT_IAN(R,T,T,CUR,'INV')$REG_CUMCST(R,T,T,'INV',CUR,'UP') = YES;
RTP_IAN(OBJ_ICUR(R,T,P,CUR))$(RT_IAN(R,T,T,CUR,'INV')+TRACKP(R,P)) = YES;
* Calculate annual undiscounted INVCOST coefficients
OPTION CLEAR=YK1; YK1(TT,T)$YK(T,TT) = YES;
CST_ANNC(R,TT,P,T(YEAR),'INVCOST',CUR)$(YK1(TT,T)$RTP_IAN(R,TT,P,CUR)) =
  SUM(OBJ_SUMII(R,TT,P,AGE,K_EOH(LL),JOT)$((ORD(LL)+ORD(AGE)+ORD(JOT)-1 > ORD(YEAR))$YK(T,LL)),
    SUM(INVSPRED(K_EOH,JOT,ALLYEAR,K)$((ORD(ALLYEAR)+ORD(AGE) > ORD(YEAR))$YK(T,ALLYEAR)),
      OBJ_ICOST(R,K,P,CUR)) * OBJ_CRF(R,TT,P,CUR) / OBJ_DIVI(R,TT,P));
* Add decommissioning costs when defined
LOOP(RTP_IAN(R,TT,P,CUR)$OBJ_DCOST(R,TT,P,CUR),
 CST_ANNC(R,TT,P,T(YEAR),'INVCOST',CUR)$YK1(TT,T) = 
   CST_ANNC(R,TT,P,T,'INVCOST',CUR) + OBJ_CRFD(R,TT,P,CUR) / OBJ_DIVIII(R,TT,P) *
   SUM(OBJ_SUMIII(R,TT,P,K_EOH,K,LL)$((ORD(LL)+ROUND(NCAP_%DECLIF%(R,TT,P)) > ORD(YEAR))$YK(T,LL)),
     OBJ_DCOST(R,K,P,CUR)));
* Calculate annual undiscounted INVTAXSUB coefficients
OPTION CLEAR=TRACKP, CLEAR=RTP_IAN;
LOOP(UC_ATTR(R,UC_N,SIDE,'NCAP',UC_ANNUL(UC_NAME(COSTCAT))),LOOP(T,TRACKP(R,P)$UC_NCAP(UC_N,SIDE,R,T,P)=YES));
RT_IAN(R,T,T,CUR,'INVTAXSUB')$(REG_CUMCST(R,T,T,'INVTAX',CUR,'UP')+REG_CUMCST(R,T,T,'INVSUB',CUR,'UP')) = YES;
RTP_IAN(OBJ_ICUR(R,T,P,CUR))$(RT_IAN(R,T,T,CUR,'INVTAXSUB')+TRACKP(R,P)) = YES;
LOOP(RTP_IAN(R,TT,P,CUR)$(OBJ_ITAX(R,TT,P,CUR)+OBJ_ISUB(R,TT,P,CUR)), 
  OPTION CLEAR=YKK; F = OBJ_CRF(R,TT,P,CUR)/OBJ_DIVI(R,TT,P);
  LOOP(OBJ_SUMII(R,TT,P,LIFE,K_EOH,JOT), Z=ORD(LIFE);
    YKK(YK(T(YEAR),LL),K)$((ORD(YEAR) < ORD(LL)+Z)$INVSPRED(K_EOH,JOT,LL,K)) = YES);
  CST_ANNC(R,TT,P,T,'INVTAX',CUR)$YK1(TT,T) = SUM(YKK(T,LL,K), F * OBJ_ITAX(R,K,P,CUR));
  CST_ANNC(R,TT,P,T,'INVSUB',CUR)$YK1(TT,T) = SUM(YKK(T,LL,K),-F * OBJ_ISUB(R,K,P,CUR));
);
OPTION CLEAR=TRACKP, CLEAR=RTP_IAN;
$IF %STAGES%==YES $SET SWT 'SW_T(TT%SOW%)$'
$IF %SCUM%==1 $SET SWT ''
*-----------------------------------------------------------------------------
  %EQ%_BNDCST(R,YEAR,SUPERYR(TT,ALLYEAR),COSTCAT,CUR %SOW%)$(%SWT%REG_CUMCST(R,YEAR,ALLYEAR,COSTCAT,CUR,'UP')) ..
*-----------------------------------------------------------------------------
$IF %STAGES%==YES $SET SWD '%SOW%' SET SOW '%SWD%' SET SWTD SUM
$IFI NOT %OBJ%==LIN         $SET TPULSE (PERIODYR(T,Y_EOH),YK(ALLYEAR,Y_EOH))$YK(Y_EOH,YEAR),
$IFI %OBJ%==LIN             $SET TPULSE (TPULSEYR(T,Y_EOH),YK(ALLYEAR,Y_EOH))$YK(Y_EOH,YEAR),TPULSE(T,Y_EOH)*
$IFI %VARCOST%==LIN         $SET TPULSE (PERIODYR(T,Y),MILESTONYR(Y_EOH),YK(ALLYEAR,Y))$(YK(Y,YEAR)$TPULSE(Y_EOH,Y)),TPULSE(Y_EOH,Y)*
$IFI %OBJ%%VARCOST%==LINLIN $SET TPULSE (TPULSEYR(T,Y),MILESTONYR(Y_EOH),YK(ALLYEAR,Y))$(YK(Y,YEAR)$TPULSE(Y_EOH,Y)),TPULSE(Y_EOH,Y)*TPULSE(T,Y)*
*------------------------------------------------------------------------------
* Investment Costs
  (SUM((OBJ_SUMII(R,T,P,AGE,K_EOH(LL),JOT),SPAN(AGE+MIN(ORD(LL)+ORD(JOT)-ORD(YEAR)-1,0)))$YK(TT,T),
    SUM(INVSPRED(K_EOH,JOT,Y,K)$YK(ALLYEAR,Y),
      OBJ_ICOST(R,K,P,CUR) *
      MAX(0,MIN(YEARVAL(ALLYEAR)+1,YEARVAL(Y)+ORD(AGE))-MAX(YEARVAL(YEAR),YEARVAL(Y)))) *
    %VART%_NCAP(R,T,P %SWS%) * OBJ_CRF(R,T,P,CUR) / OBJ_DIVI(R,T,P))$(NOT RT_IAN(R,YEAR,ALLYEAR,CUR,'INV')) +
   SUM((T,P)$CST_ANNC(R,T,P,TT,'INVCOST',CUR),CST_ANNC(R,T,P,TT,'INVCOST',CUR)*%VART%_NCAP(R,T,P %SWS%))$RT_IAN(R,YEAR,ALLYEAR,CUR,'INV')
  )$SAMEAS(COSTCAT,'INV') +

* Decommissioning Costs
  SUM(RTP(R,T,P)$(YK(TT,T)$OBJ_DCOST(R,T,P,CUR)),
    SUM(OBJ_SUMIII(R,T,P,K_EOH,K,LL)$YK(ALLYEAR,LL), OBJ_DCOST(R,K,P,CUR) *
      MAX(0,MIN(ORD(ALLYEAR)+1,ORD(LL)+ROUND(NCAP_%DECLIF%(R,T,P)))-MAX(ORD(YEAR),ORD(LL)))) *
    %VART%_NCAP(R,T,P %SWS%) * OBJ_CRFD(R,T,P,CUR) / OBJ_DIVIII(R,T,P)
    )$SAMEAS(COSTCAT,'INV') +

* Investment Taxes and Subsidies
  (SUM(OBJ_SUMII(R,T,P,AGE,K_EOH,JOT)$(YK(TT,T)$OBJ_ITAX(R,T,P,CUR)),
    SUM((INVSPRED(K_EOH,JOT,LL,K),SPAN(AGE+MIN(ORD(LL)-ORD(YEAR),0)))$YK(ALLYEAR,LL),
      OBJ_ITAX(R,K,P,CUR) * (MIN(ORD(ALLYEAR)+1,ORD(LL)+ORD(AGE))-MAX(ORD(YEAR),ORD(LL)))) *
    %VART%_NCAP(R,T,P %SWS%) * OBJ_CRF(R,T,P,CUR) / OBJ_DIVI(R,T,P))$(NOT RT_IAN(R,YEAR,ALLYEAR,CUR,'INVTAXSUB')) +
   SUM((T,P)$CST_ANNC(R,T,P,TT,'INVTAX',CUR),CST_ANNC(R,T,P,TT,'INVTAX',CUR)*%VART%_NCAP(R,T,P %SWS%))$RT_IAN(R,YEAR,ALLYEAR,CUR,'INVTAXSUB')
  )$SAMEAS(COSTCAT,'INVTAX') +

  (SUM(OBJ_SUMII(R,T,P,AGE,K_EOH,JOT)$(YK(TT,T)$OBJ_ISUB(R,T,P,CUR)),
    SUM((INVSPRED(K_EOH,JOT,LL,K),SPAN(AGE+MIN(ORD(LL)-ORD(YEAR),0)))$YK(ALLYEAR,LL),
      OBJ_ISUB(R,K,P,CUR) * (MIN(ORD(ALLYEAR)+1,ORD(LL)+ORD(AGE))-MAX(ORD(YEAR),ORD(LL)))) *
    %VART%_NCAP(R,T,P %SWS%) * OBJ_CRF(R,T,P,CUR) / OBJ_DIVI(R,T,P))$(NOT RT_IAN(R,YEAR,ALLYEAR,CUR,'INVTAXSUB')) -
   SUM((T,P)$CST_ANNC(R,T,P,TT,'INVSUB',CUR),CST_ANNC(R,T,P,TT,'INVSUB',CUR)*%VART%_NCAP(R,T,P %SWS%))$RT_IAN(R,YEAR,ALLYEAR,CUR,'INVTAXSUB')
  )$SAMEAS(COSTCAT,'INVSUB') +
*------------------------------------------------------------------------------
* Fixed O&M Cost - shaped or not
  SUM((OBJ_SUMIV(LL,R,T,P,JOT,LIFE),SPAN(LIFE+MIN(ORD(LL)+ORD(JOT)-ORD(YEAR)-1,0)))$YK(TT,T),
      SUM(INVSTEP(LL,JOT,K,JOT)$YK(ALLYEAR,K), OBJ_FOM(R,K,P,CUR) * 
        MAX(0,MIN(YEARVAL(ALLYEAR)+1,YEARVAL(K)+ORD(LIFE))-MAX(YEARVAL(YEAR),YEARVAL(K)))) *
      %VART%_NCAP(R,T,P %SWS%) / OBJ_DIVIV(R,T,P)
     )$SAMEAS(COSTCAT,'FOM') +
* Fixed O&M Cost - YES shaped
  SUM(RTP_SHAPE(R,T,P,'1',J,JJ)$YK(TT,T),
    SUM((OBJ_SUMIV(K,R,T,P,JOT,LIFE),INVSTEP(K,JOT,LL,JOT),SPAN(LIFE+MIN(ORD(LL)-ORD(YEAR),0)))$YK(ALLYEAR,LL), 
      SUM(OPYEAR(LIFE,AGE)$((ORD(LL)+ORD(AGE) > ORD(YEAR))$(ORD(LL)+ORD(AGE) < ORD(ALLYEAR)+2)),
          SHAPE(J,AGE)*MULTI(JJ,LL+(ORD(AGE)-1))-1) * OBJ_FOM(R,LL,P,CUR)) *
    %VART%_NCAP(R,T,P %SWS%) / OBJ_DIVIV(R,T,P)
  )$SAMEAS(COSTCAT,'FOM') +

* Fixed O&M Taxes - shaped or not
  SUM((OBJ_SUMIV(LL,R,T,P,JOT,LIFE),SPAN(LIFE+MIN(ORD(LL)+ORD(JOT)-ORD(YEAR)-1,0)))$(YK(TT,T)$OBJ_FTX(R,T,P,CUR)),
      SUM(INVSTEP(LL,JOT,K,JOT)$YK(ALLYEAR,K), OBJ_FTX(R,K,P,CUR) *
        MAX(0,MIN(YEARVAL(ALLYEAR)+1,YEARVAL(K)+ORD(LIFE))-MAX(YEARVAL(YEAR),YEARVAL(K)))) *
      %VART%_NCAP(R,T,P %SWS%) / OBJ_DIVIV(R,T,P)
     )$SAMEAS(COSTCAT,'FOMTAX') +
* Fixed O&M Taxes - Shaped
  SUM(RTP_SHAPE(R,T,P,'2',J,JJ)$(YK(TT,T)$OBJ_FTX(R,T,P,CUR)),
    SUM((OBJ_SUMIV(K,R,T,P,JOT,LIFE),INVSTEP(K,JOT,LL,JOT),SPAN(LIFE+MIN(ORD(LL)-ORD(YEAR),0)))$YK(ALLYEAR,LL), 
      SUM(OPYEAR(LIFE,AGE)$((ORD(LL)+ORD(AGE) > ORD(YEAR))$(ORD(LL)+ORD(AGE) < ORD(ALLYEAR)+2)),
          SHAPE(J,AGE)*MULTI(JJ,LL+(ORD(AGE)-1))-1) * OBJ_FTX(R,LL,P,CUR)) *
    %VART%_NCAP(R,T,P %SWS%) / OBJ_DIVIV(R,T,P)
  )$SAMEAS(COSTCAT,'FOMTAX') +

* Fixed O&M Subsidies - shaped or not
  SUM((OBJ_SUMIV(LL,R,T,P,JOT,LIFE),SPAN(LIFE+MIN(ORD(LL)+ORD(JOT)-ORD(YEAR)-1,0)))$(YK(TT,T)$OBJ_FSB(R,T,P,CUR)),
      SUM(INVSTEP(LL,JOT,K,JOT)$YK(ALLYEAR,K), OBJ_FSB(R,K,P,CUR) *
        MAX(0,MIN(YEARVAL(ALLYEAR)+1,YEARVAL(K)+ORD(LIFE))-MAX(YEARVAL(YEAR),YEARVAL(K)))) *
      %VART%_NCAP(R,T,P %SWS%) / OBJ_DIVIV(R,T,P)
     )$SAMEAS(COSTCAT,'FOMSUB') +
* Fixed O&M Subsidies - Shaped
  SUM(RTP_SHAPE(R,T,P,'3',J,JJ)$(YK(TT,T)$OBJ_FSB(R,T,P,CUR)),
    SUM((OBJ_SUMIV(K,R,T,P,JOT,LIFE),INVSTEP(K,JOT,LL,JOT),SPAN(LIFE+MIN(ORD(LL)-ORD(YEAR),0)))$YK(ALLYEAR,LL), 
      SUM(OPYEAR(LIFE,AGE)$((ORD(LL)+ORD(AGE) > ORD(YEAR))$(ORD(LL)+ORD(AGE) < ORD(ALLYEAR)+2)),
          SHAPE(J,AGE)*MULTI(JJ,LL+(ORD(AGE)-1))-1) * OBJ_FSB(R,LL,P,CUR)) *
    %VART%_NCAP(R,T,P %SWS%) / OBJ_DIVIV(R,T,P)
  )$SAMEAS(COSTCAT,'FOMSUB') +
*------------------------------------------------------------------------------
$IF %SCUM%==1 $SET VART SUM(SW_TSW(W,T,W),SW_TPROB(T,W)*Z
* Variable commodity taxes and subsidies
  SUM(%TPULSE%
     (SUM(RHS_COMBAL(R,T,C,S), %VART%_COMNET(R,T,C,S %SWS%) * OBJ_COMNT(R,Y_EOH,C,S,'TAX',CUR)) +
      SUM(RHS_COMPRD(R,T,C,S), %VART%_COMPRD(R,T,C,S %SWS%) * OBJ_COMPD(R,Y_EOH,C,S,'TAX',CUR)))
    )$SAMEAS(COSTCAT,'COMTAX') -

  SUM(%TPULSE%
     (SUM(RHS_COMBAL(R,T,C,S), %VART%_COMNET(R,T,C,S %SWS%) * OBJ_COMNT(R,Y_EOH,C,S,'SUB',CUR)) +
      SUM(RHS_COMPRD(R,T,C,S), %VART%_COMPRD(R,T,C,S %SWS%) * OBJ_COMPD(R,Y_EOH,C,S,'SUB',CUR)))
    )$SAMEAS(COSTCAT,'COMSUB') +
*------------------------------------------------------------------------------
* Variable flow taxes and subsidies
  SUM(T$(YK(TT,T)*(M(T)+LAGT(T) GT YEARVAL(YEAR))),
     SUM(RTPCS_VARF(R,T,P,C,S)$OBJ_VFLO(R,P,C,CUR,'TAX'),
        SUM(TS_ANN(S,TS), SUM(%TPULSE% MAX(0,OBJ_FTAX(R,Y_EOH,P,C,TS,CUR)))) *
        SUM(RTP_VINTYR(R,V,T,P),
         %SWTD%(%SWSW%
$              BATINCLUDE %cal_red% C COM S P T
            )$(NOT RP_IRE(R,P)) +
            (SUM(RPC_IRE(R,P,C,IE),
               %VART%_IRE(R,V,T,P,C,S,IE %SWS%)$(NOT RPC_AIRE(R,P,C))+(%VART%_ACT(R,V,T,P,S %SWS%)*PRC_ACTFLO(R,V,P,C))$(RPC_AIRE(R,P,C))
                ) +
             SUM((RPC_IRE(R,P,COM,IE),IO)$(RTPCS_VARF(R,T,P,COM,S)$IRE_FLOSUM(R,T,P,COM,S,IE,C,IO)),
                  IRE_FLOSUM(R,T,P,COM,S,IE,C,IO) *
                  (%VART%_IRE(R,V,T,P,COM,S,IE %SWS%)$(NOT RPC_AIRE(R,P,COM))+(%VART%_ACT(R,V,T,P,S %SWS%)*PRC_ACTFLO(R,V,P,COM))$(RPC_AIRE(R,P,COM)))
             ))$RP_IRE(R,P)
           )
       ))$SAMEAS(COSTCAT,'FLOTAX') +

  SUM(T$(YK(TT,T)*(M(T)+LAGT(T) GT YEARVAL(YEAR))),
     SUM(RTPCS_VARF(R,T,P,C,S)$OBJ_VFLO(R,P,C,CUR,'SUB'),
        SUM(TS_ANN(S,TS), SUM(%TPULSE% MAX(0,-OBJ_FTAX(R,Y_EOH,P,C,TS,CUR)))) *
        SUM(RTP_VINTYR(R,V,T,P),
         %SWTD%(%SWSW%
$              BATINCLUDE %cal_red% C COM S P T
            )$(NOT RP_IRE(R,P)) +
            (SUM(RPC_IRE(R,P,C,IE),
               %VART%_IRE(R,V,T,P,C,S,IE %SWS%)$(NOT RPC_AIRE(R,P,C))+(%VART%_ACT(R,V,T,P,S %SWS%)*PRC_ACTFLO(R,V,P,C))$(RPC_AIRE(R,P,C))
                ) +
             SUM((RPC_IRE(R,P,COM,IE),IO)$(RTPCS_VARF(R,T,P,COM,S)$IRE_FLOSUM(R,T,P,COM,S,IE,C,IO)),
                  IRE_FLOSUM(R,T,P,COM,S,IE,C,IO) *
                  (%VART%_IRE(R,V,T,P,COM,S,IE %SWS%)$(NOT RPC_AIRE(R,P,COM))+(%VART%_ACT(R,V,T,P,S %SWS%)*PRC_ACTFLO(R,V,P,COM))$(RPC_AIRE(R,P,COM)))
             ))$RP_IRE(R,P)
           )
       ))$SAMEAS(COSTCAT,'FLOSUB') +
*------------------------------------------------------------------------------
$ IF %STAGES%==YES $SET SOW %SWD%
  SUM(COST_GMAP(COSTCAT,COSTAGG,COSTYPE), %VAR%_CUMCST(R,YEAR,ALLYEAR,COSTAGG,CUR %SOW%)*(1-2*DIAG(COSTYPE,'SUB')))
*------------------------------------------------------------------------------
   
   =E=   %VAR%_CUMCST(R,YEAR,ALLYEAR,COSTCAT,CUR %SOW%);


