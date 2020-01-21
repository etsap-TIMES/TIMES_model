*============================================================================*
* PP_QAPUT.MOD - puts out an error message
*   %1 - main header output flag
*   %2 - group header output flag
*   %3 - error level (e.g., WARNING, ERROR, FATAL)
*   %4 - group description
* -- group header written on first error for group; ERRLEV holds highest errlevel
*============================================================================*
    IF(NOT %1, %1=1; PUT QLOG @15;
      WHILE(QLOG.CC<67,PUT '*****'); PUT @21,'%SYSTEM.TITLE%':<>43 / @15;
      WHILE(QLOG.CC<67,PUT '*****'); PUT @29,'QUALITY ASSURANCE LOG':<>27;
    );
    PUT$(NOT %2) QLOG // ' *** %4 ';

* hold highest errorlevel for shutdown or not
$IF NOT %3==* %2=1+1$(ROUND(%3)>9); PUT QLOG / ' *00'@(5-%2) MIN(99,%3):%2:0; ERRLEV$(%3>ERRLEV)=%3;
