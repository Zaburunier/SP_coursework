openfile MACRO filename
	push dx; сохраняем параметр, находившиеся в регистре до вызова функции

	mov ax, 3d00h; код функции
	mov dx, offset filename; параметры функции
	int 21h; вызов прерывания

	pop dx; восстанавливаем параметр

ENDM

readfile MACRO handle, count, buffer
	push ax;
	push bx;
	push cx;
	push dx;

	mov ah, 3fh;
	mov bx, handle;
	mov cx, count;
	mov dx, offset buffer;
	int 21h;

	pop dx;
	pop cx;
	pop bx;
	pop ax;
ENDM


createfile MACRO filename
	push cx;
	push dx;

	mov ax, 3c00h;
	mov cx, 0;
	mov dx, offset filename;
	int 21h;
	pop dx;
	pop cx;
ENDM


freq_co MACRO string, c_array, f_array, len
	local freqCount, endOfString, found, not_found, cont, checking, found_c, nextStep; локальные метки
	push ax;
	push bx;
	push dx;
	push di;
	push si;
	push bp;
	local c_length: word, char: byte; локальные переменные
	mov c_length, 1;
	mov si, 0;
	freqCount:
		mov ah, string + si;
		cmp ah, 0; признак конца строки - код символа знака доллара
		je endOfString; если конец строки, то цикл из безусловных прыжков прерывается
		  
		  ; Сверяем со всеми находящимися в массиве символами
		mov char, ah;
		mov di, 0;
		mov dx, c_length;
		checking:
			mov ah, c_array + di;
			cmp ah, char;
			je found_c; совершаем прыжок, если нашлось сравнение
			inc di;
			cmp di, dx;
		jne checking;
		mov bx, 0;
		jmp nextStep;
		found_c:
		mov bx, 1;
		nextStep:
		  ; На основе значения BX совершаем дальнейшие действия
		cmp bx, 1;
		je found;
		cmp bx, 0;
		je not_found;

		found:
		inc f_array + di; увеличиваем частоту символа на 1
		jmp cont;

		not_found:
		inc c_length; новый символ
		mov di, dx; в DL сидит c_length до работы инкрементора
		mov dl, char;
		mov c_array + di - 1, dl; заносим символ в массив
		mov f_array + di - 1, 1; и частоту
		jmp cont;

		cont:
		inc si;
	jmp freqCount;
	endOfString:
	  ; Запоминаем длину для будущих операций
	mov ax, c_length;
	dec ax;
	mov len, ax;
	pop bp;
	pop si;
	pop di;
	pop dx;
	pop bx;
	pop ax;
ENDM




sorta MACRO f_array, c_array, i_array, len
	local sort, sortInner, lessEqual, indexing;
	push ax;
	push bx;
	push cx;
	push dx;
	push si;
	push di;
	mov di, len;
	dec di;
	sort:
		mov si, 0;
		sortInner:
			mov al, f_array + si ;
			mov bl, f_array + si + 1;
			cmp al, bl; сравниваем значения
			jle lessEqual; если порядок возрастания не нарушен, то пропускаем перестановку элементов
			mov f_array + si, bl;
			mov f_array + si + 1, al;
			  ; Не забываем про перестановку в массиве с самими символами
			mov cl, c_array + si;
			mov dl, c_array + si + 1;
			mov c_array + si, dl;
			mov c_array + si + 1, cl;
			lessEqual: 
			inc si;
			cmp si, di;
		jne sortInner;
		dec di;
		cmp di, 0;
	jne sort;
	  ; В этом же макросе добавим индексы отсортированным узлам
	mov di, len;
	mov si, 0;
	mov bx, 1;
	xor ah, ah;
	indexing:
		mov al, bl;
		mov i_array + si, al;
		inc bl;
		inc si;
		cmp si, di;
	jne indexing;
	pop di;
	pop si;
	pop dx;
	pop cx;
	pop bx;
	pop ax;
ENDM


tree MACRO len, c_array, f_array, i_array, ll_array, rl_array
	local _tree, ending;
	push ax;
	push bx;
	push cx;
	push dx;
	push si;
	push di;
	local _len: word;
	  ; Всего 2n - 1 узлов
	mov ax, len;
	mov _len, ax;
	mov bl, 2;
	mul bl;
	sub al, 1;
	mov di, ax; в DI будет храниться конечное число узлов
	mov si, 0;
	_tree:
		mov al, i_array + si;
		mov bl, i_array + si + 1;
		mov cl, f_array + si;
		mov dl, f_array + si + 1;
		  ; Запоминаем значения AX и DI
		  ; DI будет временно использоваться для индексации
		  ; Через AX пройдёт конвертация байта локальной переменной _length в слово для дальнейшей индексации
		push di;
		push ax; 
		mov ax, _len;
		xor ah, ah;
		mov di, ax;
		pop ax;
		  ; Заносим связи
		  ; Теперь в AL и BL находятся два индекса
		mov ll_array + di, al;
		mov rl_array + di, bl;
		add cl, dl;
		  ; Заносим частоту
		  ; Последняя ячейка - по адресу "длина - 1", так что наш новый узел располагается по адресу "длина"
		  ; В CL хранится сумма частот
		mov f_array + di, cl;
		inc di; стало на 1 ячейку больше
		mov cx, di;
		  ; Заносим новый индекс
		  ; В CL хранится новое значение длины
		mov i_array + di - 1, cl;
		  ; Возвращаем в локальную переменную новое, увеличенное значение длины
		mov ax, di;
		mov _len, ax;
		pop di;
		  ; Осталось правильно расположить элемент в таблице
		sortnewelement c_array, f_array, i_array, ll_array, rl_array, _len
		add si, 2;
		cmp si, di;
		jge ending;
	jmp _tree;
	ending:
	mov dx, di;
	mov len, dx;
	pop di;
	pop si;
	pop dx;
	pop cx;
	pop bx;
	pop ax;
ENDM

sortnewelement MACRO c_array, f_array, i_array, ll_array, rl_array, new_len
	local sortInner, lessEqual;
	push ax;
	push bx;
	push si;
	push di;
	mov ax, new_len;
	mov si, ax;
	  ; Процедура практически скопирована из sorta
	  ; за исключением того, что сделать достаточно одного цикла, который будет перемещать наш новый элемент
	sortInner:
		mov al, f_array + si - 2;
		mov bl, f_array + si - 1;
		cmp al, bl; сравниваем значения
		jle lessEqual; если порядок возрастания не нарушен, то пропускаем перестановку элементов
		mov f_array + si - 2, bl;
		mov f_array + si - 1, al;
		  ; Не забываем про перестановку в остальных строках таблицы
		mov cl, c_array + si - 2;
		mov dl, c_array + si - 1;
		mov c_array + si - 2, dl;
		mov c_array + si - 1, cl;

		mov cl, i_array + si - 2;
		mov dl, i_array + si - 1;
		mov i_array + si - 2, dl;
		mov i_array + si - 1, cl;

		mov cl, ll_array + si - 2;
		mov dl, ll_array + si - 1;
		mov ll_array + si - 2, dl;
		mov ll_array + si - 1, cl;

		mov cl, rl_array + si - 2;
		mov dl, rl_array + si - 1;
		mov rl_array + si - 2, dl;
		mov rl_array + si - 1, cl;
		lessEqual: 
		dec si;
		cmp si, 1;
	jne sortInner;	

	pop di;
	pop si;
	pop bx;
	pop ax;
ENDM


huffcodes MACRO len, c_array, code_array, i_array, ll_array, rl_array
	local coding, codingInner, continue, left_found, left_next, right_found, right_next, reverse, turn, null_char;
	push ax;
	push bx;
	push cx;
	push dx;
	push si;
	push di;
	local first: byte, last: byte;
	xor ch, ch;
	mov cx, len;
	mov si, 0;
	coding:
		mov al, c_array + si;
		cmp al, 0;
		  ; Если символ отсутствует, то узел вторичный и создавать ему код мы не будем
		je continue;
		  ; Если символ присутствует, то заносим индекс вместо;
		  ; сам символ нам на текущий момент безразличен, поскольку мы знаем его номер в массиве 
		  ; и сможем индексировать в массиве кодов
		mov al, i_array + si;
		  ; Проверка начинается с узла, следующего за текущим
		mov di, si;
		inc di;
		  ; В DX будет храниться счётчик количества символов;
		  ; в нужный момент мы перенесём его в DI (сохранив последний в стеке) 
		  ; и занесём 0 или 1 в соответствующую ячейку
		mov dx, 0;
		codingInner:
		      ;Проверяем левую связь
		      mov bl, ll_array + di;
		      cmp bl, al;
		        ; Если не совпадение, то проверяем правую
		        ; Если совпадение, то добавляем в необходимую ячейку массива ноль
		      jne left_next;
		        ; Теперь нашим текущим индексом становится тот узел, в котором мы обнаружили связь
		      mov al, i_array + di;
		        ; Запомним значение DI и занесём в него номер ячейки
		        ; Через AX пройдёт умножение на 8
		      push di;
		      push ax;
		      push dx;
		      mov ax, si;
		      mov bl, 8;
		      mul bl;
		      add ax, dx;
		        ; AX = SI * 8 + DX
		      mov di, ax;
		      mov code_array + di, 30h;
		      inc di;
		      pop dx;
		      pop ax;
		      pop di;
		        ; Смещаемся на одну ячейку
		      inc dx;

		      left_next:
		        ; Проверяем правую связь
		      mov bl, rl_array + di;
		      cmp bl, al;
		        ; Если не совпадение, то переходим к сравнению со следующим узлом
		        ; Если совпадение, то добавляем единичку
		      jne right_next;
		        ; Теперь нашим текущим индексом становится тот узел, в котором мы обнаружили связь
		      mov al, i_array + di;
		        ; Запомним значение DI и занесём в него значение счётчика
		      push di;
		      push ax;
		      push dx;
		      mov ax, si;
		      mov bl, 8;
		      mul bl;
		      add ax, dx;
		        ; AX = SI * 8 + DX
		      mov di, ax;
		      mov code_array + di, 31h;
		      inc di;
		      pop dx;
		      pop ax;
		      pop di;
		        ; Смещаемся на одну ячейку
		      inc dx;

		      right_next:
			  ; До конца таблицы
			inc di;
			cmp di, cx;
		jne codingInner;

		continue:
		  ; До конца таблицы
		inc si;
		cmp si, cx;
	jne coding;
	  ; Здесь же разворачиваем битовую последовательность в другую сторону
	mov si, 0;
	reverse:
		xor ah, ah;
		push si;
		mov ax, si;
		mov bl, 8;
		mul bl;
		mov di, ax;
		add al, 8;
		mov si, ax;
		mov dl, 4;
		turn:
			dec si;
			  ; Нужно учитывать факт того, что в наших восьми ячейках содержится и пустой код
			mov al, code_array + si;
			  ; Достаточно проверить только AL, поскольку в нём - символы с конца
			cmp al, 0;
			je null_char;
			mov bl, code_array + di;
			mov code_array + di, al;
			mov code_array + si, bl;
			inc di;
			null_char:
			dec dl;
			cmp si, di;
		jg turn;
		pop si;
		inc si;
		cmp si, cx;
	jne reverse;
	pop di;
	pop si;
	pop dx;
	pop cx;
	pop bx;
	pop ax;
ENDM


writefile_cp MACRO handle, c_array, code_array, len, enter_
	local writing, writing_inner, continue, null_char;
	push ax;
	push bx;
	push cx;
	push dx;
	push si;
	push di;
	xor ax, ax;
	mov ax, len;
	mov di, ax;
	mov si, 0
	writing:
		  ; Признак конца таблицы
		cmp c_array + si, 0;
		je continue;
		  ; Пишем символ
		mov ah, 40h;
		mov bx, handle;
		mov cx, 1;
		lea dx, c_array + si;
		int 21h;
		push di;
		push si;
		mov ax, si;
		mov bl, 8;
		mul bl;
		mov si, ax;
		mov di, 0;
		  ; Пишем коды
		writing_inner:
			mov ah, 40h;
			mov bx, handle;
			mov cx, 1;
			lea dx, code_array + si;
			int 21h;
			inc si;
			inc di;
			cmp di, 8;
		jne writing_inner;
		pop si;
		pop di;
		  ; Пишем перенос строки
		mov ah, 40h;
		mov bx, handle;
		mov cx, 2;
		lea dx, enter_;
		int 21h;
		continue:
		inc si;
		cmp si, di;
	jne writing;

	pop di;
	pop si;
	pop dx;
	pop cx;
	pop bx;
	pop ax;
ENDM

writefile_encode MACRO handle, string, c_array, code_array, enter_, len
	local encoding, searching, continue, not_found, null_char, coding_end, encoding_inner, ending;
	push ax;
	push bx;
	push si;
	push di;
	mov si, 0;
	encoding:
		mov ah, string + si;
		  ; Признак конца строки
		cmp ah, 0;
		je ending;
		  ; Запоминаем SI 
		push si;
		  ; Ищем символ в кодовой таблице
		mov si, 0;
		searching:
			mov al, c_array + si;
			cmp ah, al;
			jne not_found;
			  ; AX с символами нам больше не нужен, поскольку мы нашли совпадение и можем вычислить все индексы
			mov ax, si;
			mov bl, 8;
			mul bl;
			mov si, ax;
			mov di, 0;
			  ; Записываем кодовую последовательность
			encoding_inner:
				cmp code_array + si, 0
				je continue;
				mov ah, 40h;
				mov bx, handle;
				mov cx, 1;
				lea dx, code_array + si;
				int 21h;
				inc di;
				inc si;
				cmp di, 8;
				je continue;
			jmp encoding_inner;
			not_found:
			inc si;
			cmp si, len;
			je continue;
		jmp searching;
		continue:
		pop si;
		inc si;
	jmp encoding;
	ending:
	pop di;
	pop si;
	pop bx;
	pop ax;
ENDM

getcodes MACRO buffer, c_array, code_array, len
	local codes, coding, next, end_of_code, ending, continue;
	push ax;
	push cx;
	push si;
	push di;
	local char_length: word;
	mov char_length, 0;
	mov si, 0;
	mov di, 0;
	codes:
		mov ah, buffer + si;
		  ; Признак конца буфера
		cmp ah, 0;
		je ending;
		inc char_length;
		mov c_array + di, ah;
		  ; Запоминаем DI и начинаем обращение к массиву кодов
		push di;
		mov ax, di;
		mov bl, 8;
		mul bl;
		mov di, ax;
		mov cx, 0;
		  ; Начинаем с символа, следующего за буквой (в файле они "слеплены")
		  ; Заносим все 8
		coding:
			inc si;
			mov ah, buffer + si;
			mov code_array + di, ah;
			inc di;
			inc cx;
			cmp cx, 8;
		jne coding;

		pop di;
		inc di;
		  ; Проскакиваем связку 13-10
		add si, 3;
	jmp codes;
	ending:
 	mov ax, char_length;
	mov len, ax;
	pop di;
	pop si;
	pop ax;
ENDM

decodestring MACRO buffer, c_array, code_array, r_buffer, handle, len
	local decoding, ending, decoding_inner, not_equal, found, found_continue, next_char, next, self_clear, continue, checking;
	push ax;
	push bx;
	push si;
	push di;
	local code_length: word;
	mov ax, len;
	mov bl, 8;
	mul bl;
	mov code_length, ax;
	mov si, 0;
	mov di, 0;
	decoding:
		mov ah, buffer + si;
		cmp ah, 0;
		je ending;
		  ; Будем записывать в буфер каждый новый символ и проверять на совпадение со всей считанной из файла таблицей
		  ; Если найдём совпадение, то отправляем в файл символ, обнуляем буфер и продолжаем
		mov r_buffer + di, ah;
		  ; Сверяем содержимое восьмибайтного буфера со всей кодовой таблицей
		  ; В DI будет кол-во символов в буфере, в SI - текущее положение
		push si;
		push di;
		mov si, 0;
		mov di, 0;
		  ; Проходим по всей кодовой таблице
		decoding_inner:
			push si;
			add si, di;
			mov ah, code_array + si;
			pop si;
			cmp ah, r_buffer + di;
			  ; Если несовпадение, то переходим к следующему символу
			jne next_char;
			  ; Если совпадение, то продолжаем сравнивать
			inc di;
			cmp di, 8;
			  ; Если мы прошли восемь ячеек и таким образом получили полное совпадение
			je found;
			  ; Иначе просто продолжаем
			jmp next;

			found:
			  ; Надо поделить SI на 8 из-за того, что мы индексировали с его помощью кодовый массив
			mov ax, si;
			mov bl, 8;
			div bl;
			mov si, ax;
			mov ah, 40h;
			mov bx, handle;
			mov cx, 1;
			lea dx, c_array + si;
			int 21h;
			  ; Теперь надо очистить буфер
			mov si, 0;
			self_clear:
				mov r_buffer + si, 0;
				inc si;
				cmp si, 8;
			jne self_clear;
			pop di;
			mov di, 0;
			  ; Если мы нашли совпадение по символу, то нам требуется не inc di, а обнуление, 
			  ; поскольку мы уже очистили буфер и нужно начинать запись заново
			jmp found_continue;

			next_char:
			  ; Если мы получили несовпадение, то надо обнулить DI, а SI добавить 8 (перейти к следующему символу)
			mov di, 0;
			add si, 8;
			next:
			  ; Сравниваем с концом кодового массива
			cmp si, code_length;
			jge continue;
		jmp decoding_inner;	

		continue:
		pop di;
		inc di;
		found_continue:
		pop si;
		inc si;
	jmp decoding;
	ending:
	pop di;
	pop si;
	pop bx;
	pop ax;
ENDM