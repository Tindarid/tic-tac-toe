.386
.model flat,stdcall

option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\gdi32.inc
includelib \masm32\lib\gdi32.lib
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
koordinat proto
check proto
wincheck proto
drawgame proto
newGame proto
bot proto
botEasy proto
botMedium proto
botHard proto
maybewin proto
winmaybehelp proto

DAT STRUC
     year    DW ?
     month   DW ?
     dayweek DW ?
     day     DW ?
     hour    DW ?
     min     DW ?
     sec     DD ?
     msec    DD ?
DAT ENDS



.DATA                           
winKoor dd 100
ClassName db "SimpleWinClass",0
MsgBoxText1 db "Победил 1 игрок (крестики)!", 0
MsgBoxText2 db "Победил 2 игрок (нолики)!", 0
MsgBoxText3 db "Ничья!", 0
MenuName db "DefaultMenu", 0
MsgBoxCaption db "TicTacToe", 0
AppName db "TicTacToe",0
AboutText db "Автор: Валеев Нурсан", 0
AboutCaption db "About"
array db 0, 0, 0, 0, 0, 0, 0, 0, 0
botmode dw 3
stadia db 1
.DATA?                 
hInstance HINSTANCE ? 
CommandLine LPSTR ?
currentPoint POINT <>
kvadrat POINT <>
TimeForRand DAT <>
HANDLEWINDOW DWORD ?

.CONST
P_P0 equ 0
P_P1 equ 100
P_P2 equ P_P1+P_P1
P_P3 equ P_P1+P_P2
IDM_NEW equ 1
IDM_EXIT equ 2
IDM_PLAYER equ 3
IDM_EASY equ 4
IDM_MEDIUM equ 5
IDM_HARD equ 6
IDM_ABOUT equ 7

.CODE    
start:
invoke GetModuleHandle, NULL 
                            
mov hInstance,eax

invoke GetCommandLine 
mov CommandLine,eax
invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
invoke ExitProcess, eax
                      

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG
    LOCAL hwnd:HWND


    mov   wc.cbSize,SIZEOF WNDCLASSEX  
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL

    mov   wc.cbWndExtra,NULL
    push  hInstance
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_BTNFACE+1
    mov   wc.lpszMenuName, OFFSET MenuName
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax

    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,NULL,\
                ADDR ClassName,\
                ADDR AppName,\
                WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_VISIBLE,\
                CW_USEDEFAULT,\
                CW_USEDEFAULT,\
                P_P3+7,\
                P_P3+50,\
                NULL,\
                NULL,\
                hInst,\
                NULL
    mov   hwnd,eax

    invoke ShowWindow, hwnd,CmdShow
    invoke UpdateWindow, 0
    .WHILE TRUE  
       invoke GetMessage, ADDR msg,NULL,0,0
    .BREAK .IF (!eax)
       invoke TranslateMessage, ADDR msg
       invoke DispatchMessage, ADDR msg
    .ENDW
     mov     eax,msg.wParam
     ret

WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL hDC:HDC
    LOCAL ps:PAINTSTRUCT
    LOCAL hPen    :DWORD
    LOCAL hPenOld :DWORD
push hWnd
pop HANDLEWINDOW
    .IF uMsg==WM_DESTROY  
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_PAINT
    invoke BeginPaint,hWnd, ADDR ps
     mov    hDC,eax
    invoke CreatePen,0,1,00000000h
    mov hPen, eax
  
    invoke SelectObject,hDC,hPen
    mov hPenOld, eax
    invoke MoveToEx, hDC, P_P0, P_P0, NULL
    invoke LineTo,hDC,P_P3, P_P0
    invoke LineTo,hDC,P_P3, P_P3
    invoke LineTo,hDC,P_P0, P_P3
    invoke LineTo,hDC,P_P0, P_P0

    invoke MoveToEx, hDC, P_P1, P_P0, NULL
    invoke LineTo,hDC,P_P1, P_P3
    invoke MoveToEx, hDC, P_P2, P_P0, NULL
    invoke LineTo,hDC,P_P2, P_P3

    invoke MoveToEx, hDC, P_P0, P_P1, NULL
    invoke LineTo,hDC,P_P3, P_P1
    invoke MoveToEx, hDC, P_P0, P_P2, NULL
    invoke LineTo,hDC,P_P3, P_P2
    push ebx
    xor ebx, ebx
    mov kvadrat.x, ebx
    mov kvadrat.y, ebx
    .WHILE kvadrat.y!=P_P3
        .WHILE kvadrat.x!=P_P3
            .IF ([array+ebx]==0)
                nop
            .ELSEIF ([array+ebx]==1)
                invoke MoveToEx, hDC, kvadrat.x, kvadrat.y, NULL
                add kvadrat.x, P_P1
                add kvadrat.y, P_P1
                invoke LineTo,hDC,kvadrat.x, kvadrat.y
                sub kvadrat.y, P_P1
                invoke MoveToEx, hDC, kvadrat.x, kvadrat.y, NULL
                sub kvadrat.x, P_P1
                add kvadrat.y, P_P1
                invoke LineTo,hDC,kvadrat.x, kvadrat.y
                sub kvadrat.y, P_P1
            .ELSEIF ([array+ebx]==2)
                push kvadrat.x
                push kvadrat.y
                pop currentPoint.y
                pop currentPoint.x
                add currentPoint.y, P_P1
                add currentPoint.x, P_P1
                invoke Arc,hDC,kvadrat.x,kvadrat.y,currentPoint.x,currentPoint.y,0,0,0,0
            .ENDIF
            inc ebx
            add kvadrat.x, P_P1
        .ENDW
    mov kvadrat.x, P_P0
    add kvadrat.y, P_P1
    .ENDW
    pop ebx
    invoke SelectObject,hDC,hPenOld
    invoke DeleteObject,hPen
    invoke EndPaint,hWnd, ADDR ps
    .ELSEIF uMsg==WM_LBUTTONDOWN
	mov eax, lParam
	and eax, 0FFFFh
	mov currentPoint.x, eax
	mov eax, lParam
	shr eax, 16
	mov currentPoint.y, eax
	invoke koordinat
      push ebx
      push eax
      push edx
      xor ebx, ebx
      mov kvadrat.x, ebx
      mov kvadrat.y, ebx
      mov eax, currentPoint.x
      mov edx, currentPoint.y
      .WHILE kvadrat.y!=P_P3
        .WHILE kvadrat.x!=P_P3
            .IF (eax==kvadrat.x) && (edx==kvadrat.y) && ([array+ebx]==0)
                push eax
                mov ah, stadia
                mov [array+ebx], ah
                pop eax
                .IF stadia==1
                    inc stadia
                .ELSE
                    dec stadia
                .ENDIF
             .ENDIF
            inc ebx
            add kvadrat.x, P_P1
        .ENDW
       mov kvadrat.x, P_P0
       add kvadrat.y, P_P1
       .ENDW
      pop edx
      pop eax
      pop ebx
      invoke InvalidateRect, hWnd, NULL, FALSE
      invoke check
      invoke drawgame
      .IF (botmode!=FALSE) && (stadia==2)
      invoke bot
      invoke InvalidateRect, hWnd, NULL, FALSE
      .ENDIF
      invoke check
      invoke drawgame
    .ELSEIF uMsg==WM_COMMAND
    mov eax, wParam
    push ebx
    .IF eax==IDM_EXIT
    invoke DestroyWindow, hWnd
    .ELSEIF eax==IDM_NEW
    invoke newGame
    .ELSEIF eax==IDM_PLAYER
    mov bx, 0
    mov botmode, bx
    invoke newGame
    .ELSEIF eax==IDM_EASY
    mov bx, 1
    mov botmode, bx
    invoke newGame
    .ELSEIF eax==IDM_MEDIUM
    mov bx, 2
    mov botmode, bx
    invoke newGame
    .ELSEIF eax==IDM_HARD
    mov bx, 3
    mov botmode, bx
    invoke newGame
    .ELSEIF eax==IDM_ABOUT
    invoke MessageBox, NULL, addr AboutText, addr AboutCaption, MB_OK
    .ENDIF
    pop ebx
    .ELSEIF uMsg==WM_MOVE
       invoke InvalidateRect, hWnd, NULL, FALSE
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam ; Дефаултная функция обpаботки окна
        ret
    .ENDIF
    xor eax,eax

    ret
WndProc endp

koordinat proc
	mov eax, P_P0
	push ebx
	mov ebx, eax
	.WHILE TRUE
	   .BREAK .IF (eax==currentPoint.x) || (eax==currentPoint.y) || (ebx==P_P3)
	   .IF (currentPoint.x>ebx) && (currentPoint.x<eax)
		  mov kvadrat.x, ebx
	   .ENDIF
	   .IF (currentPoint.y>ebx) && (currentPoint.y<eax)
		  mov kvadrat.y, ebx
	   .ENDIF
	   mov ebx, eax
	   add eax, P_P1
	.ENDW
	pop ebx
      push kvadrat.x
      push kvadrat.y
      pop currentPoint.y
      pop currentPoint.x
	ret
koordinat endp

check proc
push eax
push ebx
push edx

xor eax, eax
mov ebx, 3
mov edx, 6
.WHILE eax!=3
invoke wincheck
inc eax
inc ebx
inc edx
.ENDW

xor eax, eax
xor ebx, ebx
xor edx, edx
inc ebx
inc edx
inc edx
.WHILE eax<9
invoke wincheck
add eax, 3
add ebx, 3
add edx, 3
.ENDW

xor eax, eax
mov ebx, 4
mov edx, ebx
add edx, ebx
invoke wincheck

add eax, 2
sub edx, 2
invoke wincheck

pop edx
pop ebx
pop eax
ret
check endp

wincheck proc 
      .IF (array[eax]==1) && (array[ebx]==1) && (array[edx]==1)
      invoke MessageBox, NULL, addr MsgBoxText1, addr MsgBoxCaption, MB_OK
      invoke newGame
      .ELSEIF ([array+eax]==2) && ([array+ebx]==2) && ([array+edx]==2)
      invoke MessageBox, NULL, addr MsgBoxText2, addr MsgBoxCaption, MB_OK
      invoke newGame
      .ELSE 
      nop
      .ENDIF
ret
wincheck endp

drawgame proc 
push eax
push ebx
xor ebx, ebx
xor eax, eax
.WHILE eax!=9
.IF [array+eax]!=0
    inc ebx
.ENDIF
inc eax
.ENDW
.IF ebx==9
      invoke MessageBox, NULL, addr MsgBoxText3, addr MsgBoxCaption, MB_OK
      invoke newGame
.ENDIF
pop ebx
pop eax
ret
drawgame endp

newGame proc
    push eax
    xor eax, eax
    .WHILE eax!=9
    mov array[eax], FALSE
    inc eax
    .ENDW
    mov stadia, TRUE
    invoke InvalidateRect, HANDLEWINDOW, NULL, TRUE
    pop eax
    ret
newGame endp

bot proc
.IF botmode==1
invoke botEasy
.ELSEIF botmode==2
invoke botMedium
.ELSEIF botmode==3
invoke botHard
.ENDIF
.IF stadia==1
    inc stadia
.ELSE
    dec stadia
.ENDIF
ret
bot endp

botEasy proc
push ebx
push eax
mov ebx, 9
invoke GetSystemTime, OFFSET TimeForRand
invoke nseed, TimeForRand.sec
.WHILE TRUE
invoke nrandom, ebx
.BREAK .IF ([array+eax]==0)
.ENDW
xor ebx, ebx
mov bh, 2
mov array[eax], bh
pop eax
pop ebx
ret
botEasy endp

botMedium proc
invoke maybewin
ret
botMedium endp

botHard proc
invoke maybewin
ret
botHard endp

maybewin proc
push eax
push ebx
push edx

xor eax, eax
mov ebx, 3
mov edx, 6
.WHILE eax!=3
invoke winmaybehelp
inc eax
inc ebx
inc edx
.ENDW

xor eax, eax
xor ebx, ebx
xor edx, edx
inc ebx
inc edx
inc edx
.WHILE eax<9
invoke winmaybehelp
add eax, 3
add ebx, 3
add edx, 3
.ENDW


xor eax, eax
mov ebx, 4
mov edx, ebx
add edx, ebx
invoke winmaybehelp

add eax, 2
sub edx, 2
invoke winmaybehelp
.IF winKoor<100
mov eax, winKoor
mov bh, 2
mov edx, 100
mov winKoor, edx
mov array[eax], bh
pop edx
pop ebx
pop eax
ret
.ENDIF

pop edx
pop ebx
pop eax
.IF botmode==2
invoke botEasy
.ELSEIF botmode==3
invoke GetSystemTime, OFFSET TimeForRand
invoke nseed, TimeForRand.sec
.IF array[4]==0
mov array[4], 2
.ELSEIF array[0]==0 || array[2]==0 || array[6]==0 || array[8]==0
push eax
push ebx
mov ebx, 9
.WHILE TRUE
invoke nrandom, ebx
.BREAK .IF ((eax==0 || eax==2 || eax==6 || eax==8) && array[eax]==0)
.ENDW
mov array[eax], 2
pop ebx
pop eax
.ELSE
invoke botEasy
.ENDIF
.ENDIF
ret
maybewin endp

winmaybehelp proc
      .IF ((array[eax]==2) && (array[ebx]==2) && (array[edx]==0)) || ((array[eax]==2) && (array[ebx]==0) && (array[edx]==2)) || ((array[eax]==0) && (array[ebx]==2) && (array[edx]==2))
      .IF array[eax]==0
      mov winKoor, eax
      .ELSEIF array[ebx]==0
      mov winKoor, ebx
      .ELSE 
      mov winKoor, edx
      .ENDIF   
      ret
      .ELSEIF (((array[eax]==1) && (array[ebx]==1) && (array[edx]==0)) || ((array[eax]==1) && (array[ebx]==0) && (array[edx]==1)) || ((array[eax]==0) && (array[ebx]==1) && (array[edx]==1))) && winKoor==100
      .IF array[eax]==0
      mov winKoor, eax
      .ELSEIF array[ebx]==0
      mov winKoor, ebx
      .ELSE 
      mov winKoor, edx
      .ENDIF
      ret
      .ELSE 
      .ENDIF
ret
winmaybehelp endp

end start
