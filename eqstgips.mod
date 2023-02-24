*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQSTG Inter-Period Storage (IPS) and TIME-Slice Storage (TSS)               *
*=============================================================================*
*UR Questions/Comments:
*
*-----------------------------------------------------------------------------*
*$ONLISTING

  %EQ%_STGIPS(RTP_VINTYR(%R_V_T%,P),IPS %SWT%)$(((MIYR_1(V)*MIYR_1(T)+LIM(IPS))*SUM(PRC_STGIPS(R,P,C),1))$PRC_MAP(R,'STK',P)) ..

* storage level in the end of period T
     %VAR%_ACT(R,V,T,P,'ANNUAL' %SOW%)$LIM(IPS) +
     SUM((IO(IPS),MODLYEAR,MIYR_1(LL))$RTP_VINTYR(R,MODLYEAR,T,P),
       %VAR%_ACT(R,MODLYEAR,LL-LEAD(LL),P,'ANNUAL' %SOW%))

    =E=

     (
* storage level in the end of period T-1
         (SUM(TT(T-1),
           (%VARTT%_ACT(R,V,TT,P,'ANNUAL'%SWS%)$RTP_VINTYR(R,V,TT,P))$PRC_VINT(R,P) +
           (%VARTT%_ACT(R,TT,TT,P,'ANNUAL'%SWS%)$RTP_VINTYR(R,TT,TT,P))$(NOT PRC_VINT(R,P))) +
* [AL] In the first period VAR_ACT is not available, but exogenous charge can be used
          SUM(MIYR_1(LL),%VAR%_ACT(R,V,LL-LEAD(LL),P,'ANNUAL' %SOW%))$MIYR_1(T)) *
* storage losses
* [AL] Initial storage level/charge is reduced to (1-LOSS)**D(T) during the period
         POWER(1-STG_LOSS(R,V,P,'ANNUAL'),D(T)) +

* in- and output flows to/from storage
* [AL] Added summing over PERIODYR, as the storage operates during the whole period
         SUM(TOP(PRC_STGIPS(R,P,C),IO),
          (%VAR%_SIN(R,V,T,P,C,'ANNUAL' %SOW%)$IPS(IO) - %VAR%_SOUT(R,V,T,P,C,'ANNUAL' %SOW%)$(NOT IPS(IO))) * 
* storage losses
* [AL] Inflows and outflows occur, on average, at the mid-point of each year
          SUM(PERIODYR(T,Y_EOH),((1-STG_LOSS(R,V,P,'ANNUAL'))**(E(T)-YEARVAL(Y_EOH)+0.5))) / PRC_ACTFLO(R,V,P,C)
         )
       )$LIM(IPS) +
* Exogenous charge at BOH
     SUM((IO(IPS),MIYR_1(LL)),STG_CHRG(R,LL-LEAD(LL),P,'ANNUAL'))
;
$OFFLISTING

