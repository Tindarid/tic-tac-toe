# tic-tac-toe
Tic-tac-toe (assembly language, masm32)
# Build:
```
ml /c /coff *.asm
rc menu.rc
link /SUBSYSTEM:WINDOWS /LIBPATH:...\masm32\lib *.obj *.res
```
![](screen.png)
