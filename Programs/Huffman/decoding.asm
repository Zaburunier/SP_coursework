INCLUDE \..\Programs\macro.asm
INCLUDE \..\Programs\print_m.asm
.MODEL SMALL
.STACK 100h
.DATA
buffer DB 1024 dup (0)
destFileName DB 'Decoding.txt', 0
destFileHandle DW ?
sourceFileName DB 'Encoding.txt', 0
sourceFileHandle DW ?
cpFileName DB 'cp.txt', 0
cpFileHandle DW ?
_length DW 1024
len DW 10
symbolsArray DB 120 dup (0)
codeArray DB 960 dup (0)
enter_ DB 13, 10
readBuffer DB 8 dup (0)
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

	openfile cpFileName
	mov cpFileHandle, ax;
	openfile sourceFileName
	mov sourceFileHandle, ax;

	createfile destFileName
	mov destFileHandle, ax;

	readfile cpFileHandle, _length, buffer
	getcodes buffer, symbolsArray, codeArray, len

	readfile sourceFileHandle, _length, buffer
	decodestring buffer, symbolsArray, codeArray, readBuffer, destFileHandle, len
	

	  ; Выход из программы
	mov ax, 4c00h
	int 21h
END START;