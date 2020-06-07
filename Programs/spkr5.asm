INCLUDE \..\Programs\macro.asm
INCLUDE \..\Programs\print_m.asm
.MODEL SMALL
.STACK 100h
.DATA
buffer DB 512 dup (0)
fileName DB 'Huffman.txt', 0
fileHandle DW ?
_length DB 255
len DB 10
symbolsArray DB 70 dup (0)
freqArray DB 70 dup (0)
indexArray DB 70 dup (0)
leftLinkArray DB 70 dup (0)
rightLinkArray DB 70 dup (0)
codeArray DB 560 dup (0)
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

	printcodes symbolsArray, codeArray, len
	  ; Выход из программы
	mov ax, 4c00h
	int 21h
END START;