*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Copyright (C) 2000-2023 Energy Technology Systems Analysis Programme (ETSAP)
* This file is part of the IEA-ETSAP TIMES model generator, licensed
* under the GNU General Public License v3.0 (see file NOTICE-GPLv3.txt).
*=============================================================================*
* DUMPSOLV.MOD outputs the actual solution values when vintage index
*  Dumps output SET, SCALARS, PARAMETER, TABLE
*
*  1   - type indicator = 'L'evel/'M'arginal
*  2-n - for rest of line = component names
*
*      - Note that (declaration) is not output
*      - $BATINCLUDE dumpsol.mod ITEM1 ITEM2 ... must fit on one line
*
*=============================================================================*
*GaG Questions/Comments:
*-----------------------------------------------------------------------------
$IF '%1'==M  $set vy '(fil)' set disc coef_pvt(reg,fil)
$IF '%1'==L  $set vy '' set disc 1
option clear=fil;

file.tf = 0;
$offlisting
$set preditem ''

* hold the first parameter for later checking
$set whtype %1
*GG* later take 2nd as name of set controlling the TABLE column header to improve xeq
$shift

$label more

* only one call executes, so  done when no more parameters
$if %1a == a               $goto done

$if declared %1.%whtype%            $goto declared
* out error message if passed entity not declared
put / '*** UNKNOWN':20,'NAME':6,'%1':10 /;
$set preditem 'unknown'
$shift goto more

$label declared

file.nr=3;
$if dimension 0  %1        $goto done
$if dimension 1  %1        $goto done
$if dimension 2  %1        $goto done
$if dimension 3  %1        $goto done
$if not declared u1 alias(u1,u2,u3,u4,u5,u6,u7,u8,u9,*);
$if dimension 4  %1 $set r 'u1'                      set row row4a
$if dimension 5  %1 $set r 'u1,u2'                   set row row5a
$if dimension 6  %1 $set r 'u1,u2,u3'                set row row6a
$if dimension 7  %1 $set r 'u1,u2,u3,u4'             set row row7a
$if dimension 8  %1 $set r 'u1,u2,u3,u4,u5'          set row row8a
$if dimension 9  %1 $set r 'u1,u2,u3,u4,u5,u6'       set row row9a
file.tf=3;

set %row%(%r%);
$onuni

loop((REG,v,ll,%r%)$%1.%whtype%(REG,v,ll,%r%),
   fil(ll) = yes;
   %row%(%r%) = yes);

scalar colcnt;
IF(CARD(%row%) > 0,
$  set preditem 'table'
   put / ' ':9,'%whtype%: Solution Reference ','%1':10," '",%1.ts:40,"'" / @34;
   colcnt = 0;
   loop(fil$(colcnt < 19),
     put fil.tl:11;
     colcnt = colcnt + 1
   );
   loop((REG,%row%)$(DUMP0 + SUM((v,fil)$%1.%whtype%(REG,v,fil,%row%),1)),
      put  / @4 REG.TL:0,'.',%row%.te(%row%) @34;
      colcnt = 0;
      loop(fil,
         if(colcnt = 19,
            colcnt = 0
            put / @10 fil.tl:4 @30 '+++' @34);
         colcnt = colcnt + 1;
         z = sum(v%vy%,%1.%whtype%(REG,v,fil,%row%))
         if(z, put (z/%disc%):<10 ' '
         else  put ' ':11)
         ));
   put /;
);

$offuni
option clear=%row%,clear=fil;
$shift goto more
$label done
