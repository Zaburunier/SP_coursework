INCLUDE \..\Programs\macro.asm
INCLUDE \..\Programs\print_m.asmе
.MODEL SMALL
.STACK 100h
.DATA 
buffer DB 512 dup (0)
fileName DB 'Huffman.txt', 0
fileHandle DW ?
_length DB 255
.CODE
START:
	  ; Инициализация сегмента данных и базовая очистка регистров перед началом работы
	mov ax, @Data
	mov ds, ax
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	xor si, si
	xor di, di

	openfile fileName 
	mov fileHandle, ax; после работы макроса в регистре AX находится дескриптор файла

	readfile fileHandle, _length, buffer
	prints buffer
	  ; Выход из программы
	mov ax, 4c00h;
	int 21h;
END START;