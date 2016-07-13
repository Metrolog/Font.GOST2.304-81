Шрифты ЕСКД ГОСТ 2.304-81
=========================

GOST2-304 - семейство чертёжных шрифтов по ГОСТ 2.304-81.

Репозиторий этого пакета размещён на github:
http://github.com/Metrolog/Font.GOST2.304-81

Использование
-------------

Для использования этого шрифта в LaTeX, включите

    \usepackage{gost2-304}

в преамбулу Вашего LaTeX документа. Смотрите подробную информацию
в документации в PDF.

Установка
---------

1. Запустите `latex gost2-304.ins` для генерации стилевого пакета LaTeX.

2. Создайте следующие каталоги в локальной папке texmf:

   - doc/latex/gost2-304
   - fonts/map/dvips/gost2-304
   - fonts/enc/dvips/gost2-304
   - fonts/afm/public/gost2-304
   - fonts/tfm/public/gost2-304
   - fonts/type1/public/gost2-304
   - fonts/opentype/public/gost2-304
   - fonts/truetype/public/gost2-304
   - tex/latex/gost2-304

3. Скопируйте все необходимые файлы в дерево каталогов texmf:

   - gost2-304.pdf - в doc/latex/gost2-304
   - gost2-304.map - в fonts/map/dvips/gost2-304
   - остальные файлы в каталоге dvips - в fonts/enc/dvips/gost2-304
   - все файлы в каталоге afm - в fonts/afm/public/gost2-304
   - все файлы в каталоге tfm - в fonts/tfm/public/gost2-304
   - все файлы в каталоге type1 - в fonts/type1/public/gost2-304
   - все файлы в каталоге opentype - в fonts/opentype/public/gost2-304
   - все файлы в каталоге truetype - в fonts/truetype/public/gost2-304
   - gost2-304.sty - в tex/latex/gost2-304

4. Регенерация базы пакетного менеджера TeX:

        texhash

5. Активируем map файл:

        updmap --enable Map=gost2-304.map

License
-------

Copyright (c) 2014-2016 by Sergey S. Betke <sergey.s.betke@yandex.ru>

The font components of this software, e.g. MetaFont (.mf), TeX font metric
(.tfm), and Type 1 (.pfb) files, are licensed under the SIL Open Font
License, Version 1.1. This license is in the accompanying file OFL.txt,
and is also available with a FAQ at: http://scripts.sil.org/OFL

The LaTeX support files contained in this software may be modified
and distributed under the terms and conditions of the LaTeX Project
Public License, version 1.3c or greater (your choice).
The latest version of this license is in
  http://www.latex-project.org/lppl.txt
and version 1.3 or later is part of all distributions of LaTeX
version 2005/12/01 or later.

This work has the LPPL maintenance status 'maintained'.

The Current Maintainer of this work is Sergey S. Betke.

This work consists of the files gost2-304.dtx, gost2-304.ins
and the derived files gost2-304.pdf and gost2-304.sty,
related GOST2-304* font files.
