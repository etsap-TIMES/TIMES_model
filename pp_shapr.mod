*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* PP_SHPRC.MOD shape a process based attribute
*   %1 - attribute name
*   %2 - driving indexes
*   %3 - any qualifiers to help narrow loop (if none, set to YES)
*   %4 - mapped coefficient
*   %5 - optional -M(R,V,P) or 1
*=============================================================================*
*AL Comments:
*-----------------------------------------------------------------------------

SET RTP_SHAPI(REG,ALLYEAR,PRC,BD,J,J,LL,LL);
SET RTP_ISHPR(REG,ALLYEAR,PRC) //;
$SETLOCAL PASS %3
$IF %3 == '' $SETLOCAL PASS YES

LOOP(BD,RTP_ISHPR(RTP(R,V,P))$((%1%6X(RTP,BD) GE 1.5)$%1%6X(RTP,BD)) = YES);
RTP_ISHPR(RTP(R,V,P))$((%5 GE 1.5)$%5) = YES;

* Prepare for start and end years
OPTION CLEAR=FIL2; FIL2(V) = B(V)-YEARVAL(V);
PASTSUM(RTP_ISHPR(R,V,P)) = FIL2(V)+NCAP_ILED(R,V,P)+NCAP_TLIFE(R,V,P)-1;

* Shape attributes only for processes around for > 1 period
%1%6X(RTP_ISHPR(R,V,P),BD)$(PASTSUM(R,V,P)-FIL2(V)+1 < D(V)) = 0;

* Get hold of the shape and multi index J,JJ for each RVP, as well as start and end years
LOOP(SAMEAS(J,'1'),
 RTP_SHAPI(RTP_ISHPR(R,V(LL),P),BD,J+MAX(0,%1%6X(R,V,P,BD)-1),J+MAX(0,%5-1),LL+(FIL2(V)+NCAP_ILED(R,V,P)),LL+PASTSUM(R,V,P)) = YES;
);

  LOOP(SAMEAS(AGE,'1'),
* Calculate average SHAPE for plants still operating in each period:
    %4$((%PASS%)$RTP_ISHPR(R,V,P)) = %1%2 *
       SUM(RTP_SHAPI(R,V,P,BD,J,JJ,LL,YEAR), MULTI(JJ,T) *
         SUM(PERIODYR(T,EOHYEARS)$(YEARVAL(EOHYEARS) LE MAX(B(T),YEARVAL(YEAR))),
             SHAPE(J,AGE+(MIN(YEARVAL(EOHYEARS),YEARVAL(YEAR))-YEARVAL(LL)))) /
         (MAX(1,MIN(E(T),YEARVAL(YEAR))-MAX(B(T),YEARVAL(LL))+1))));

* If no shape index is pecified, set the BASE value for the attribute
RTP_ISHPR(RTP(R,V,P)) = (NOT RTP_ISHPR(R,V,P));
%4$(RTP_ISHPR(R,V,P)$(%PASS%)) = %1%2;
* Clear the temporary sets
OPTION CLEAR=RTP_SHAPI,CLEAR=RTP_ISHPR,CLEAR=PASTSUM;
