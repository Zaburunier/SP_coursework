INCLUDE \..\Programs\macro.asm
INCLUDE \..\Programs\print_m.asm
.MODEL SMALL
.STACK 100h
.DATA
stringMessage DB 'String: ', 0
readMessage DB 'Table after reading: ', 0
sortMessage DB 'Sorted table: ', 0
buffer DB 512 dup (0)
fileName DB 'Huffman.txt', 0
fileHandle DW ?
_length DB 255
len DW 12
symbolsArray DB 70 dup (0)
freqArray DB 70 dup (0)
indexArray DB 70 dup (0)
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
	prints stringMessage
	prints buffer
	freq_co buffer, symbolsArray, freqArray, len
	prints readMessage
	printa symbolsArray, len
	printindexes freqArray, len
	  ; Выход из программы
	mov ax, 4c00h
	int 21h
END START;