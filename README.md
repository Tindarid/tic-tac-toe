# tic-tac-toe
TicTacToe (assembler language)
# How to assembly and run:
ml /c /coff *.asm

rc menu.rc

link /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib *.obj *.res

TicTacToe.exe
![](screen.png)
