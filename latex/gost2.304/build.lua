#!/ usr /bin/env texlua

module = "gost2.304"

unpackfiles = {"*.ins"}
unpackexe = "lualatex"
unpackopts = "-interaction=batchmode"

checkengines = {"xelatex", "lualatex"}
stdengine = "lualatex"
checkformat = "latex"
typesetexe = "lualatex"

packtdszip = true

kpse.set_program_name("kpsewhich")
dofile(kpse.lookup("l3build.lua"))