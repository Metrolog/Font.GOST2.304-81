[![Build status](https://ci.appveyor.com/api/projects/status/robb062g2i4c7l9w?svg=true)](https://ci.appveyor.com/project/sergey-s-betke/font-gost2-304-81)
[![Join the chat at https://gitter.im/Metrolog/Font.GOST2.304-81](https://badges.gitter.im/Metrolog/Font.GOST2.304-81.svg)](https://gitter.im/Metrolog/Font.GOST2.304-81?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

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

- [CygWin][]
- [GitVersion][]
- [FontForge][] версии не младше 27.08.2015
- [TTFAutoHint][]
- [FastFont][] (для оптимизации генерируемых ttf шрифтов)
- [WIX][] (только для сборки msi модулей и msi дистрибутива для установки шрифта в Windows, требуется WiX 4)
- [MikTeX][]
- [CTANupload][]
- [latexmk][] (только для сборки TeX пакетов и документов)

Для подготовки среды сборки следует воспользоваться сценарием `install.ps1` (запускать от имени администратора).
Указанный сценарий установит все необходимые компоненты.

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

#### Стилевой пакет для LaTeX gost2.304 - `tex-pkg`

Сборка стилевого пакета осуществляется следующим образом:

	make tex-pkg

Данная цель требует предварительной сборки цели `ttf`.

#### .pdf файл документации пакета gost2.304 - `doc`

Сборка документации осуществляется следующим образом:

	make doc

Данная цель требует предварительной сборки цели `tex-pkg`, шрифтов.
По умолчанию собранный .pdf не отображается. Однако, следующая командная строка

	make doc VIEWPDF=yes

откроет .pdf на просмотр после удачной сборки.

#### Файл для загрузки стилевого пакета для LaTeX gost2.304 в CTAN - `ctan`

Сборка архива для CTAN осуществляется следующим образом:

	make ctan

#### Загрузка стилевого пакета для LaTeX gost2.304 в CTAN - `ctanupload`

Отправка подготовленного архива в CTAN осуществляется следующим образом:

	make ctanupload

#### MSI модуль (.msm файл) для включения в состав MS Installer дистрибутивов

Сборка .msm файла осуществляется следующим образом:

	make msm

Данная цель требует предварительной сборки цели `ttf`.

#### MSI пакет (.msi файл) для установки шрифтов в MS Windows, в том числе - для развёртывания в домене через GPO

Сборка .msi пакета осуществляется следующим образом:

	make msi

Данная цель требует предварительной сборки целей `ttf`, `msm`.

Внесение изменений
------------------

Репозиторий проекта размещён по адресу https://github.com/Metrolog/Font.GOST2.304-81.
Стратегия ветвления - [GitFlow](https://habrahabr.ru/post/106912/). В качестве GUI
к локальному репозиторию с поддержкой GitFlow рекомендую
[SourceTree](https://www.sourcetreeapp.com/).

Для внесения изменений в проект подготовьте собственный fork проекта, в соответствии
с GitFlow создайте либо feature, либо patch ветку, и предложите Pull Request в основной 
репозиторий. Для патчей ветки прошу именовать patch/<номер issue>.

Лицензионное соглашение
-----------------------

Полный текст лицензионного соглашения включён в файлы шрифта, а также размещён по указанной ссылке: <http://scripts.sil.org/OFL>.
Наименование шрифта, в том числе - локализованные наименования шрифта, не зарезервированы и не защищены.

[CTANupload]: http://ctan.org/pkg/ctanupload
[FontForge]: https://github.com/fontforge/fontforge
[CygWin]: http://cygwin.com/install.html "Cygwin"
[GitVersion]: https://github.com/GitTools/GitVersion
[GNUWin32 make]: http://gnuwin32.sourceforge.net/packages/make.htm "GNU make for windows"
[GNUWin32 Core Utils]: http://gnuwin32.sourceforge.net/packages/coreutils.htm
[GNUWin32 ZIP]: http://gnuwin32.sourceforge.net/packages/zip.htm
[GNUWin32 TAR]: http://gnuwin32.sourceforge.net/packages/gtar.htm
[MikTeX]: http://www.miktex.org
[latexmk]: https://www.ctan.org/pkg/latexmk/ "latexmk – Fully automated LaTeX document generation"
[Perl]: https://www.perl.org/get.html#win32 "Perl"
[TTC]: http://en.wikipedia.org/wiki/TrueType#TrueType_Collection "True Type Fonts Collection"
[TTFAutoHint]: http://www.freetype.org/ttfautohint
[FastFont]: http://www.microsoft.com/typography/tools/tools.aspx "FastFont"
[WOFF]: http://en.wikipedia.org/wiki/Web_Open_Font_Format "Web Open Font Format"
[WIX]: http://wixtoolset.org/releases/ "WiX Toolset 4"
