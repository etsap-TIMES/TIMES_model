*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* EQOBJELS the objective function flexible demand utility 
*=============================================================================*
*GaG Questions/Comments:
*-----------------------------------------------------------------------------
$IFI %MICRO%==YES $BATINCLUDE pp_micro.mod NLP

    %EQ%_OBJELS(R,BD,CUR %SOW%)$(RDCUR(R,CUR)$SUM_OBJ(R,'OBJELS'))..

*------------------------------------------------------------------------------
* Direction with bound sign BDSIG
*------------------------------------------------------------------------------
*V0.5b 980824 - correct ORD adjustment
      SUM(RTCS_VARC(R,T,C,S)$(COM_ELAST(R,T,C,S,BD)$COM_STEP(R,C,BD)),
        COEF_PVT(R,T) * COM_BPRICE(R,T,C,S,CUR) *
        (SUM(RCJ(R,C,J,BD), %VART%_ELAST(R,T,C,S,J,BD %SWS%) *
          (1-BDSIG(BD)*(ORD(J)-.5)*COM_VOC(R,T,C,BD)/COM_STEP(R,C,BD))**(1/COM_ELAST(R,T,C,S,BD)))$(NOT COM_ELASTX(R,T,C,BD)) +
* Shaped elasticities
         SUM(RTC_SHED(R,T,C,BD,JJ(AGE)),
           SUM((RCJ(R,C,J,BD),SPAN(AGE+CEIL((ORD(J)-.5)*COM_VOC(R,T,C,BD)/COM_STEP(R,C,BD)*100-ORD(AGE)))),
             (SHAPED(BD,JJ,SPAN) *
              ((1-BDSIG(BD)*(ORD(J)-.5)*COM_VOC(R,T,C,BD)/COM_STEP(R,C,BD))/SHAPED(BD,'1',SPAN))**(1/MAX(1E-3,SHAPE(JJ,SPAN)))
             )**(1/COM_ELAST(R,T,C,S,BD)) * %VART%_ELAST(R,T,C,S,J,BD %SWS%))) +
         SUM(MI_DMAS(R,COM,C)$MI_DOPE(R,T,C),SUM(RCJ(R,C,J,BD),%VART%_ELAST(R,T,C,S,J,BD %SWS%) * MI_AGC(R,T,COM,C,J,BD)))
        )
      )$BDNEQ(BD)


* Micro NLP formulation
$IFI NOT %MICRO%==YES $GOTO RHS
   +  SUM(T$(ORD(T)>1), COEF_PVT(R,T) *
        SUM(DEM(R,C)$(MI_ELASP(R,T,C)$RD_NLP(R,C)), MI_CCONS(R,T,C) *
          ((%VART%_DEM(R,T,C%SWS%)**MI_ELASP(R,T,C))$(RD_NLP(R,C)=1) +
           ((SUM(MI_DMAS(R,C,COM),RD_SHAR(R,T,C,COM)**(1/MI_ESUB(R,T,C))*(COM_AGG(R,T,COM,C)*%VART%_DEM(R,T,COM%SWS%))**MI_RHO(R,T,C))**(1/MI_RHO(R,T,C)))**MI_ELASP(R,T,C))$(RD_NLP(R,C)>2) -
           DDF_QREF(R,T,C)**MI_ELASP(R,T,C))$(RD_NLP(R,C)>0)
          ))$LNX(BD)

$LABEL RHS
    =E=
    %VAR%_OBJELS(R,BD,CUR %SOW%);

*------------------------------------------------------------------------------

* Step bounds for linear CES demand functions
  %EQ%L_COMCES(RTC(R,T,COM),C,S%SWT%)$(RTCS_VARC(R,T,C,S)$MI_DOPE(R,T,C)$MI_DMAS(R,COM,C))..
   SUM(RCJ(R,C,J,BDNEQ(BD))$COM_ELAST(R,T,C,S,BD),%VAR%_ELAST(R,T,C,S,J,BD%SOW%)*COM_STEP(R,C,BD)/ORD(J)/(DDF_QREF(R,T,C)*COM_FR%MX%(R,T,C,S)*COM_VOC(R,T,C,BD)))
   =L= %VAR%_COMPRD(R,T,COM,'ANNUAL'%SOW%)/DDF_QREF(R,T,COM);
