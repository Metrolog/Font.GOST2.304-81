Шрифты ЕСКД ГОСТ 2.304-81
=========================

Целью проекта является создание шрифтов по ГОСТ 2.304-81 в различных форматах, поддерживаемых [FontForge][].

Первоначальная и основная цель проекта - создать пакеты True Type шрифтов, оптимизированных для использования
с XeLaTeX (LuaTeX).
Однако, [FontForge][] поддерживает и генерацию TeX шрифтов, поэтому на базе данного проекта возможно создание
TeX совместимых шрифтов по ГОСТ 2.304-81.

Шрифты содержат необходимые математические символы, позволяющие использовать их в математическом режиме TeX.

Сборка проекта
--------------

Для внесения изменений в пакет и повторной сборки проекта потребуются следующие продукты:

- [FontForge][]
- [TTFAutoHint][]
- [GNUWin32 Core Utils][]
- [GNU make][]
- [latexmk][] (только для сборки TeX пакетов и документов)
- [Perl][] (только для сборки TeX пакетов и документов, требуется [latexmk][])

Сборка проекта осуществляется следующим образом:

	make

либо

	make all

### Цели

#### True Type Fonts - `ttf`

Сборка True Type Fonts (.ttf) осуществляется следующим образом:

	make ttf

[TTFAutoHint][] не обязателен, использовал его для того, чтобы добиться приличного качества отображения шрифтов
при малых кеглях, при этом не включая в проект "ручного" хинтирования. В принципе, можно полностью 
вручную добавить хинты в проект шрифта, тогда использование [TTFAutoHint][] не потребуется вовсе.

На данный момент по умолчанию используется автоинструктирование средствами [TTFAutoHint][], а не [FontForge][].
Для принудительного использования [FontForge][]:

	make ttf AUTOHINT=fontforge
	
#### True Type Fonts Collection - `ttc`

Сборка [True Type Fonts Collection (.ttc)](<http://en.wikipedia.org/wiki/TrueType#TrueType_Collection>) осуществляется следующим образом:

	make ttc

Данная цель требует предварительной сборки цели `ttf`.

Данный формат - удобная форма поставки пакета шрифтов семейства ГОСТ 2.304-81 в одном файле. Поддерживается Windows.

#### Web Open Font Format - `woff`

Сборка [WOFF][] осуществляется следующим образом:

	make woff

Данная цель требует предварительной сборки цели `ttf`.


Версии
------

В качестве версии при сборке подставляю автоматом имя ветки репозитория.
Поэтому разработку и сборку следует вести в ветках типа "0.1", "0.2", "1.0".

[FontForge]: https://github.com/fontforge/fontforge
[GNU make]: http://gnuwin32.sourceforge.net/packages/make.htm "GNU make for windows"
[GNUWin32 Core Utils]: http://gnuwin32.sourceforge.net/packages/coreutils.htm
[latexmk]: https://www.ctan.org/pkg/latexmk/ "latexmk – Fully automated LaTeX document generation"
[Perl]: https://www.perl.org/get.html#win32 "Perl"
[TTC]: http://en.wikipedia.org/wiki/TrueType#TrueType_Collection "True Type Fonts Collection"
[TTFAutoHint]: http://www.freetype.org/ttfautohint
[WOFF]: http://en.wikipedia.org/wiki/Web_Open_Font_Format "Web Open Font Format"
