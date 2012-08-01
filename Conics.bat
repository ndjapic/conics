rem Ovaj bat fajl poziva zeros.exe ((c) Nenad) koji nije deo DOSa!
find /n "function" < Conics.pas > Conics.tmp
find /n "procedure" < Conics.pas >> Conics.tmp
find /n "(*" < Conics.pas >> Conics.tmp
zeros.exe < Conics.tmp | find /v " (*" | sort > Conics.txt
Conics.exe > Conics.eps
pkzip -ex Conics Conics.pas Conics.bat Conics.eps Conics.txt
del Conics.txt
del Conics.tmp
