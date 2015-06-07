������ ���� ���� 2.304-81
=========================

����� ������� �������� �������� ������� �� ���� 2.304-81 � ��������� ��������, �������������� [FontForge][].

�������������� � �������� ���� ������� - ������� ������ True Type �������, ���������������� ��� �������������
� XeLaTeX (LuaTeX).
������, [FontForge][] ������������ � ��������� TeX �������, ������� �� ���� ������� ������� �������� ��������
TeX ����������� ������� �� ���� 2.304-81.

������ �������� ����������� �������������� �������, ����������� ������������ �� � �������������� ������ TeX.

������ �������
--------------

��� �������� ��������� � ����� � ��������� ������ ������� ����������� ��������� ��������:

- [FontForge][]
- [TTFAutoHint][]
- [GNUWin32 Core Utils][]
- [GNUWin32 make][]
- [GNUWin32 ZIP][] (��� ������ ������ LaTeX ������ ��� CTAN)
- [GNUWin32 TAR][] (��� ������ ������ LaTeX ������ ��� CTAN)
- [latexmk][] (������ ��� ������ TeX ������� � ����������)
- [Perl][] (������ ��� ������ TeX ������� � ����������, ��������� [latexmk][])

������ ������� �������������� ��������� �������:

	make

����

	make all

### ����

#### True Type Fonts - `ttf`

������ True Type Fonts (.ttf) �������������� ��������� �������:

	make ttf

[TTFAutoHint][] �� ����������, ����������� ��� ��� ����, ����� �������� ���������� �������� ����������� �������
��� ����� ������, ��� ���� �� ������� � ������ "�������" ������������. � ��������, ����� ��������� 
������� �������� ����� � ������ ������, ����� ������������� [TTFAutoHint][] �� ����������� �����.

�� ������ ������ �� ��������� ������������ �������������������� ���������� [TTFAutoHint][], � �� [FontForge][].
��� ��������������� ������������� [FontForge][]:

	make ttf AUTOHINT=fontforge
	
#### True Type Fonts Collection - `ttc`

������ [True Type Fonts Collection (.ttc)](<http://en.wikipedia.org/wiki/TrueType#TrueType_Collection>) �������������� ��������� �������:

	make ttc

������ ���� ������� ��������������� ������ ���� `ttf`.

������ ������ - ������� ����� �������� ������ ������� ��������� ���� 2.304-81 � ����� �����. �������������� Windows.

#### Web Open Font Format - `woff`

������ [WOFF][] �������������� ��������� �������:

	make woff

������ ���� ������� ��������������� ������ ���� `ttf`.

#### �������� ����� ��� LaTeX gost2.304 - `ctan``

������ ������ ��� CTAN �������������� ��������� �������:

	make ctan

������ ���� ������� ��������������� ������ ���� `ttf`.

#### �������� ����� ��� LaTeX gost2.304 - `tex-pkg`

������ ��������� ������ �������������� ��������� �������:

	make tex-pkg

������ ���� ������� ��������������� ������ ���� `ttf`.

#### �������� .pdf ���� �� ���� LaTeX � ��������� ������ gost2.304 - `tex-tests`

������ ��������� ������ �������������� ��������� �������:

	make tex-tests

������ ���� ������� ��������������� ������ ���� `tex-pkg`.
�� ��������� ��������� .pdf �� ������������. ������, ��������� ��������� ������

	make VIEWPDF=yes

������� .pdf �� �������� ����� ������� ������.

������
------

� �������� ������ ��� ������ ���������� ��������� ��� ����� �����������.
������� ���������� � ������ ������� ����� � ������ ���� "0.1", "0.2", "1.0".

������������ ����������
-----------------------

������ ����� ������������� ���������� ������� � ����� ������, � ����� �������� �� ��������� ������: <http://scripts.sil.org/OFL>.
������������ ������, � ��� ����� - �������������� ������������ ������, �� ��������������� � �� ��������.

[FontForge]: https://github.com/fontforge/fontforge
[GNUWin32 make]: http://gnuwin32.sourceforge.net/packages/make.htm "GNU make for windows"
[GNUWin32 Core Utils]: http://gnuwin32.sourceforge.net/packages/coreutils.htm
[GNUWin32 ZIP]: http://gnuwin32.sourceforge.net/packages/zip.htm
[GNUWin32 TAR]: http://gnuwin32.sourceforge.net/packages/gtar.htm
[latexmk]: https://www.ctan.org/pkg/latexmk/ "latexmk � Fully automated LaTeX document generation"
[Perl]: https://www.perl.org/get.html#win32 "Perl"
[TTC]: http://en.wikipedia.org/wiki/TrueType#TrueType_Collection "True Type Fonts Collection"
[TTFAutoHint]: http://www.freetype.org/ttfautohint
[WOFF]: http://en.wikipedia.org/wiki/Web_Open_Font_Format "Web Open Font Format"
