;  Вывести символ
printc MACRO C
	push ax;
	push dx;
	xor ax, ax;
	xor dx, dx;

	mov ah, 02h;
	mov dl, C;
	int 21h;

	pop dx;
	pop ax;
ENDM


;  Вывести строку
prints MACRO S
	local printString, endOfString;
	push ax;
	push si;
	xor ax, ax;
	xor si, si;
	local char: byte; локальная переменная в рамках макроса

	mov si, 0;
	printString:
		mov ah, S + si; 
		cmp ah, 0; признак конца строки - код символа знака доллара
		je endOfString; если конец строки, то цикл из безусловных прыжков прерывается
		mov char, ah;
		printc char; пользуемся собственным макросом
		inc si;
	jmp printString;
	endOfString:
	printc 13;
	printc 10;
	pop si;
	pop ax;
ENDM

printa MACRO array, len
	local printing, ending;
	push ax;
	push dx;
	push si;

	mov si, 0;
	mov ah, 02h; код функции
	printing:
		mov dl, array + si; текущая ячейка
		int 21h;
		printc 20h "разлепим" ячейки с помощью пробелов
		inc si;
		mov dx, len;
		cmp si, dx; признак конца массива (в основном файле заполнен нулями)
		je ending; прыжок за границы бесконечного цикла
	jmp printing;
	ending:
	printc 13;
	printc 10;
	pop si;
	pop dx;
	pop ax;
ENDM

printindexes MACRO i_array, len
	local printing, ending;
	push ax;
	push si;
	push di;
	local num: byte;
	mov ax, len;
	mov di, ax;
	mov si, 0;
	printing:
		mov al, i_array + si;
		mov num, al;
		cmp si, di;
		je ending;
		printn num; отправляем индекс на вывод
		printc 20h;
		inc si;
	jmp printing;
	ending:
	printc 13;
	printc 10;
	pop di;
	pop si;
	pop ax;

ENDM

printn MACRO N
	local transferDigitsToStack, printDigits;
	push ax;
	push bx;
	push cx;
	push dx;
	push si;
	xor ax, ax;
	xor bx, bx;
	xor cx, cx;
	xor dx, dx;
	xor si, si;
	local char: byte;

	  ; Процедура печати многозначного числа на консоль похожа на таковую в языках высокого уровня:
	  ; мы делим число на 10 до тех пор, пока не получим ноль, а каждый остаток отправляем в стек;
	  ; из-за того, что мы будем вытягивать цифры из стека задом наперёд - а в стек они приходили с конца, -
	  ; мы получим необходимое нам число.
	mov si, 0;
	mov al, N;
	transferDigitsToStack:
		xor dx, dx;
		inc si;
		mov bx, 10;
		div bx;
		mov bx, dx;
		push bx;
		cmp al, 0;
	jne transferDigitsToStack;
	mov cx, si;
	printDigits:
		pop dx;
		add dl, 030h;
		mov char, dl;
		printc char;
	loop printDigits;
	pop si;
	pop dx;
	pop cx;
	pop bx;
	pop ax;
ENDM

printtree MACRO len, c_array, f_array, i_array, ll_array, rl_array
	local printing, ending, not_space_i, not_space_f, not_space_l;
	push ax;
	push si;
	push di;
	local argument: byte;

	mov al, len;
	xor ah, ah;
	mov di, ax;
	mov si, 0;
	printing:
		printc 20h;

		mov al, i_array + si;
		mov argument, al;
		printn argument;
		  ; Для форматирования вывода добавим дополнительный пробел после однозначных чисел
		cmp al, 9;
		jg not_space_i;
		printc 20h;
		not_space_i:
		printc 20h;

		mov al, c_array + si;
		mov argument, al;
		printc argument;
		printc 20h;

		mov al, f_array + si;
		mov argument, al;
		printn argument;
		  ; Для форматирования вывода добавим дополнительный пробел после однозначных чисел
		cmp al, 9;
		jg not_space_f;
		printc 20h;
		not_space_f:
		printc 20h;

		mov al, ll_array + si;
		mov argument, al;
		printn argument;
		; Для форматирования вывода добавим дополнительный пробел после однозначных чисел
		cmp al, 9;
		jg not_space_l;
		printc 20h;
		not_space_l:
		printc 20h;

		mov al, rl_array + si;
		mov argument, al;
		printn argument;

		printc 13;
		printc 10;
		inc si;
		cmp si, di;
		je ending;
	jmp printing;
	ending:
	pop di;
	pop si;
	pop ax;
ENDM

printcodes MACRO c_array, code_array, len
	local printing, codes, continue, ending;
	push ax;
	push bx;
	push si;
	push di;
	local argument: byte;
	mov bx, len;
	mov si, 0;
	printing:
		mov al, c_array + si;
		cmp al, 0;
		je continue;
		mov argument, al;
		printc argument;
		printc 20h;

		mov di, 0;
		codes:
			push di;
			push bx;
			mov ax, si;
			mov bl, 8;
			mul bl;
			add ax, di;
			mov di, ax;
			mov al, code_array + di;
			mov argument, al;
			printc argument;
			pop bx;
			pop di;
			inc di;
			cmp di, 8;
		jne codes;
		printc 13;
		printc 10;

		continue:
		inc si;
		cmp si, bx;
		je ending;
	jmp printing;
	ending:
	pop di;
	pop si;
	pop ax;
ENDM