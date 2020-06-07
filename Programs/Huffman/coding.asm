INCLUDE \..\Programs\macro.asm
INCLUDE \..\Programs\print_m.asm
.MODEL SMALL
.STACK 100h
.DATA
buffer DB 1024 dup (0)
fileName DB 'Huffman.txt', 0
fileHandle DW ?
newFileName DB 'Encoding.txt', 0
newFileHandle DW ?
cpFileName DB 'cp.txt', 0
cpFileHandle DW ?
_length DW 1024
len DW 10
symbolsArray DB 120 dup (0)
freqArray DB 120 dup (0)
indexArray DB 120 dup (0)
leftLinkArray DB 120 dup (0)
rightLinkArray DB 120 dup (0)
codeArray DB 960 dup (0)
enter_ DB 13, 10
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
	mov fileHandle, ax; после работы макроса в регистре AX находится дескриптор файла\

	readfile fileHandle, _length, buffer

	freq_co buffer, symbolsArray, freqArray, len

	sorta freqArray, symbolsArray, indexArray, len

	tree len, symbolsArray, freqArray, indexArray, leftLinkArray, rightLinkArray

	huffcodes len, symbolsArray, codeArray, indexArray, leftLinkArray, rightLinkArray

	createfile cpFileName
	mov cpFileHandle, ax;
	createfile newFileName
	mov newFileHandle, ax;

	writefile_cp cpFileHandle, symbolsArray, codeArray, len, enter_
	writefile_encode newFileHandle, buffer, symbolsArray, codeArray, enter_, len
	  ; Выход из программы
	mov ax, 4c00h
	int 21h
END START;