*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* COEFMAIN.MOD oversees the bulk of the coefficient calculations
*   %1 - mod or v# for the source code to be used
*=============================================================================*
*GaG Questions/Comments:
*-----------------------------------------------------------------------------
$IFI NOT %STAGES%==YES SOW(ALLSOW)=DIAG(ALLSOW,'1'); SW_T(T,ALLSOW)=SOW(ALLSOW);

* handle the capacity transfer and related equation coefficients
$   BATINCLUDE coef_cpt.%1 %1

* derive the coefficients related to NCAP I/O flows for new/released
$   BATINCLUDE coef_nio.%1

* derive the coefficients related to process transformation
$   BATINCLUDE coef_ptr.%1

* derive the coefficients for the OBJ
$   BATINCLUDE coef_obj.%1 %1

* derive the additional/adjusted coefficients needed for alternate objectives
$   BATINCLUDE coef_alt.lin VAR%CTST%

* derive shaped coefficients for process transformation and capacity transfer
$   BATINCLUDE coef_shp.%1
