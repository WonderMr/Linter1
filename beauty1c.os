// BSLLS:LineLength-off
#Использовать asserts

Function s(c)
    ret                 =   "";
    Для i = 1
    По  4*c
    Цикл
        ret             =   ret + " ";
    КонецЦикла;
    Возврат ret; 
EndFunction // FunctionName()

Function ss(c)
    ret                 =   "";
    Для i = 1
    По  c
    Цикл
        ret             =   ret + " ";
    КонецЦикла;
    Возврат ret; 
EndFunction // FunctionName()

Function fix_start_pos(f_str, lvl)
	Сообщить("=============================================");
	f_ret				=	"";
	Если Не ЗначениеЗаполнено(f_str) 
	Тогда
		Возврат "";
	КонецЕсли;
	Сообщить(f_str);
	obj_re_sc			=	Новый РегулярноеВыражение("(([^;""]+?""+[^""]*?""+)*[^;""]*?;)");
    obj_s_start         =   Новый РегулярноеВыражение("^[\t ]*");
	obj_empty           =   Новый РегулярноеВыражение("^[\t ]*\r*\n*;*[\t ]*\r*\n");	
    obj_end             =   Новый РегулярноеВыражение("$\r*\n*^[\t ]*$");	
	fixed1				=	obj_empty.Replace(f_str, "");
	semicolon_string	=	obj_re_sc.Matches(fixed1);

	Для каждого s_string
	Из semicolon_string Цикл		
		this_str		=	s_string.Группы[0].Значение;
		Если не СтрСравнить(this_str, ";") = 0
		Тогда
			f_ret		=	f_ret + obj_empty.Replace(this_str, "") + Символы.ПС;
		Иначе
			f_ret		=	fixed1;
		КонецЕсли;
	КонецЦикла;

	Если semicolon_string.Количество() > 0
	Тогда
		fixed2          =   obj_s_start.Replace(f_ret, s(lvl));
	Иначе
		fixed2			=	obj_s_start.Replace(fixed1, s(lvl));
	КонецЕсли;
    fixed3              =   obj_end.Replace(fixed2, " ");
	Сообщить("---------------------------------------------");
	Сообщить(fixed3);
	Сообщить("=============================================");
    Возврат fixed3
EndFunction

Function get_non_empty(p1, code, p2)
	space				=	Новый РегулярноеВыражение("^(\r*\n)+");
	p1					=	space.Replace(p1, "");
	space				=	Новый РегулярноеВыражение("[^\s]+");
	if space.match(code)
	then 
		return p1 + code + p2;
	else
		return p1;
	endif
EndFunction

// парсит тело функции и возращает Beautified код
Function parse_body(bodyStr, lvl)
	_obj_opers          =   Новый РегулярноеВыражение("(?'code'[^ꡏ]*?)(?:(?:\s|^)+[^\|# А-Яа-яёЁ1-9a-zA-Z\\_]+?(?'elem'Для\s+|Из\s+|Цикл\s+|Если\s+|Тогда\s+|Иначе\s+|ИначеЕсли\s+|Попытка\s+|Исключение\s+|Пока\s+|КонецЕсли[\s;]+|#КонецЕсли[\s]+|КонецПопытки[\s+;]|КонецЦикла[\s;]+|По\s+|И\s+|Или\s+|Возврат.*?$|[\s.*]?\z))");
	_obj_opers          =   Новый РегулярноеВыражение("(?'code'[^ꡏ]*?)(?'elem'(?'if'\sЕсли\s)|(?'then'Тогда)|(?'endif'\sКонецЕсли[\s;]+)|(?'return'\sВозврат)|(?'lastend'[\s.*]?\z)|(?'or'\sИли\s)|(?'For'\sДля\s)|(?'from'\sИз\s)|(?'cycle'\sЦикл\s)|(?'try'\sПопытка\s)|(?'exception'\sИсключение\s)|(?'else'\sИначе\s)|(?'entry'\sКонецПопытки[\s;]+)|(?'and'\sИ\s)|(?'endcycle'\sКонецЦикла[\s;]+))");
	_obj_opers          =   Новый РегулярноеВыражение("(?'code'[^ꡏ]*?)(?'elem'(?'if'[^\w#]Если.*?)|(?'ifpre'[^\s\|\/\#]+Если.*?)|(?'then'Тогда[^\w])|(?'endif'[^\w]КонецЕсли[^\w])|(?'return'[^\w]Возврат)|(?'lastend'[\s.*]?\z)|(?'or'[^\w]Или[^\w])|(?'For'[^\s\|]Для[^\w])|(?'from'[^\w]Из[^\w])|(?'cycle'[^\w]Цикл[^\w])|(?'try'[^\w]Попытка[^\w])|(?'exception'[^\W]Исключение[^\w])|(?'else'[^\w]Иначе[^\w])|(?'entry'[^\w]КонецПопытки[^\w])|(?'and'[\w]И[\w])|(?'endcycle'[^\w]КонецЦикла[^\w]))");
	_obj_opers          =   Новый РегулярноеВыражение("(?'code'[^ꡏ]*?)(?'elem'(?'ifpre'\#Если.*)|(?'if'([\s][^\|\#])+Если[\W])|(?'then'Тогда[^\w])|(?'endif'КонецЕсли)|(?'return'[^\w]Возврат)|(?'lastend'[\s.*]?\z)|(?'or'[^\w]Или[^\w])|(?'For'([\s][^\|\#])+Для[^\w])|(?'from'[^\w]Из[^\W])|(?'cycle'[^\w]Цикл[^\w])|(?'try'[^\w]Попытка[^\w])|(?'exception'[^\W]Исключение[^\w])|(?'else'([\s][^\|\#])+Иначе)|(?'elsepre'\#Иначе.*)|(?'entry'[^\w]КонецПопытки[^\w])|(?'and'[\w]И[\w])|(?'endcycle'[^\w]КонецЦикла[^\w]))");
	_obj_opers          =   Новый РегулярноеВыражение("(?'code'[^ꡏ]*?)(?'elem'(?'ifpre'\#Если.*)|(?'if'([\s\t^\^\#])+Если[^\w])|(?'then'[^\w]Тогда[^\w])|(?'endif'[^\#]КонецЕсли[^\w])|(?'endifpre'\#КонецЕсли.*)|(?'return'[^\w]Возврат\s)|(?'lastend'[\s.*]?\z)|(?'or'[^\w]Или[^\w])|(?'For'([\s][^\|\#])+Для[^\w])|(?'from'[^\w]Из[^\w])|(?'cycle'[^\w]Цикл[^\w])|(?'try'[^\w]Попытка[^\w])|(?'exception'\sИсключение\s+)|(?'else'([\s][^\|\#])+Иначе)|(?'elsepre'\#Иначе.*)|(?'entry'[^\w]КонецПопытки[^\w])|(?'and'[\s]И[\s])|(?'endcycle'[^\w]КонецЦикла[^\w]))");
	_obj_opers          =   Новый РегулярноеВыражение("(?'code'[^ꡏ]*?)(?'elem'(?'ifpre'#Если.*?$)|(?'if2'[^\S]Если[^\S])|(?'if'[^]*?[^#]Если)|(?'then'[\s]+?[^\s|]*?Тогда)|(?'or'[^\w]Или[^\w])|(?'and'[^\S]И[^\S])|(?'else'([\s\t^\^\#])+Иначе[^\w])|(?'elsepre'\#Иначе.*)|(?'endif'[^#]КонецЕсли)|(?'endifpre'\#КонецЕсли)|(?'For'[\^;][^\|]Для[\s])|(?'from'[^\w]Из[^\w])|(?'until'[;]*?[^(Для)]*?По[^\S])|(?'cycle'Цикл)|(?'endcycle'[^\w]КонецЦикла[^\w])|(?'try'[\S]Попытка[\S])|(?'exception'\sИсключение\s+)|(?'entry'[^\S]КонецПопытки;)|(?'return'[^\w]Возврат.*?(;|$))|(?'lastend'[\s.]*?\z))");
	_obj_re_s_plus		=	Новый РегулярноеВыражение("[\t ]+");
	_obj_re_SokrLP		=	Новый РегулярноеВыражение("^\s+|\s+$");
	ret					=	"";
	ops					=	_obj_opers.Matches(bodyStr);
	Если ops.Количество() = 0
	Тогда
		bodyStr			=	_obj_re_s_plus.Replace(bodyStr, " ");
		ret				=	fix_start_pos(bodyStr, lvl) + Символы.ПС;
	Иначе
		prev_op			=	"";
		Для каждого op 
		Из ops Цикл
			op			=	op.Группы;
			//Сообщить("Групп " + op.Количество());
		
			//next_op		=	_obj_re_s_plus.Replace(op[5].Значение, " ");
			op_irg		=	op[4].Значение;
			next_op		=	_obj_re_SokrLP.Replace(op_irg, "");

			op_code		=	op[3].Значение;
			//code		=	_obj_re_s_plus.Replace(op[4].Значение, " ");
			code		=	_obj_re_SokrLP.Replace(op_code, "");
			Сообщить("====================================");
			Сообщить("code1 = " + op_code);
			Сообщить("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
			Сообщить("code2 = " + code);
			Сообщить("------------------------------------");
			Сообщить("next_op1 = " + op_irg);
			Сообщить("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
			Сообщить("next_op2 = " + next_op);
			Сообщить("====================================");
			НачалоОп	=	СтрСравнить(next_op, "Для") = 0
						Или	СтрСравнить(next_op, "Если") = 0
						Или	СтрСравнить(next_op, "Пока") = 0;
			КонецOn		=	СтрНайти(next_op, "КонецЕсли") >= 0
						или СтрСравнить(code, "#КонецЕсли") = 0
						Или	СтрСравнить(next_op, "КонецЦикла") = 0
						Или	СтрСравнить(next_op, "КонецПопытки") = 0
						Или	СтрСравнить(next_op, "ИначеЕсли") = 0
						Или	СтрНайти(next_op, "Возврат") = 0;

			Если НачалоОп
			Тогда
				ret		=	get_non_empty(ret, fix_start_pos(code, lvl), Символы.ПС);
				ret		=	ret +	fix_start_pos(next_op, lvl);
				prev_op	=	next_op;
			ИначеЕсли 	СтрСравнить(next_op, "Или") = 0
			Или			СтрСравнить(next_op, "И") = 0
			Тогда
				ret		=	get_non_empty(ret +	" ", code, Символы.ПС);
				ret		=	ret +	fix_start_pos(next_op, lvl);
				prev_op	=	next_op;			
			ИначеЕсли  	СтрСравнить(next_op, "Попытка") = 0
			Тогда
				ret		=	get_non_empty(ret, fix_start_pos(code, lvl),  Символы.ПС);
				ret		=	ret +	fix_start_pos(next_op, lvl) + Символы.ПС;
				prev_op	=	next_op;
			ИначеЕсли  	СтрСравнить(next_op, "Из") = 0
			или			СтрСравнить(next_op, "По") = 0
			Тогда
				ret		=	ret +	" " + _obj_re_SokrLP.Replace(code, "") + " " + Символы.ПС;
				ret		=	ret +	fix_start_pos(next_op, lvl);
				prev_op	=	next_op;
			ИначеЕсли  	СтрСравнить(next_op, "Тогда") = 0
			Или			СтрСравнить(next_op, "Цикл") = 0
			Тогда
				Если 	СтрСравнить(prev_op, "Из") = 0
				Тогда
					ret		=	ret +	"          " + _obj_re_SokrLP.Replace(code, "") + Символы.ПС;
				ИначеЕсли СтрСравнить(prev_op, "Или") = 0
				Тогда
					ret		=	ret +	"  " + _obj_re_SokrLP.Replace(code, "") + " " + Символы.ПС;
				ИначеЕсли СтрСравнить(prev_op, "И") = 0
				Тогда
					ret		=	ret +	"    " + _obj_re_SokrLP.Replace(code, "") + " " + Символы.ПС;	
				Иначе
					ret		=	ret +	" " + _obj_re_SokrLP.Replace(code, "") + " " + Символы.ПС;
				КонецЕсли;
				ret		=	ret +	fix_start_pos(next_op, lvl) + Символы.ПС;
				lvl		=	lvl + 1;
				prev_op	=	next_op;
			ИначеЕсли  СтрСравнить(next_op, "Иначе") = 0
			Тогда
				ret		=	ret +	fix_start_pos(code, lvl) + Символы.ПС;
				ret		=	ret +	fix_start_pos(next_op, lvl - 1) + Символы.ПС;
				prev_op	=	next_op;
			ИначеЕсли  СтрСравнить(next_op, "Исключение") = 0
			Тогда
				lvl		=	lvl + 1;
				ret		=	get_non_empty(ret, fix_start_pos(code, lvl), Символы.ПС);
				ret		=	ret +	fix_start_pos(next_op, lvl - 1) + Символы.ПС;
				prev_op	=	next_op;
			ИначеЕсли  	КонецOn
			Тогда
				ret		=	get_non_empty(ret, fix_start_pos(code, lvl), Символы.ПС);
				lvl		=	lvl - 1;
				ret		=	ret +	fix_start_pos(next_op, lvl) + Символы.ПС;
				prev_op	=	next_op;
			Иначе
				ret		=	get_non_empty(ret,	fix_start_pos(code, lvl),  Символы.ПС);
				ret		=	get_non_empty(ret, fix_start_pos(next_op, lvl), Символы.ПС);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Возврат ret;
EndFunction

_obj_re_spaces          =   Новый РегулярноеВыражение("[\t ]{2,}");
_obj_re_printable  		=   Новый РегулярноеВыражение("[^\s|;]+");
_obj_re_nl              =   Новый РегулярноеВыражение("\r*\n");
_obj_re_comments		=	Новый РегулярноеВыражение("[\t ]*\/\/.*\r*\n");
_obj_re_tab				=	Новый РегулярноеВыражение("\t");
_re_funcs               =   "(?'pre'[^ꡏ]*?)?(?'type'Функция|Процедура)\s+(?'name'[^\s\(]*)\s*\((?'params'[^ꡏ]*?)\)\s*(?'exp'Экспорт)*(?'body'[^ꡏ]*?)?(?'end'КонецФункции|КонецПроцедуры)";
_obj_re_funcs			=	Новый РегулярноеВыражение(_re_funcs);
_re_opers               =   "(?'prestart'[^ꡏ]*?)?(?'oper'Попытка|Попытк|Если|Цикл)(?'body'[^ꡏ]+)(?'end'Конец(Цикла|Попытки|Если))(?'afterend'[^ꡏ]*)";
_obj_re_opers           =   Новый РегулярноеВыражение(_re_opers);
_obj_re_is_func        	=   Новый РегулярноеВыражение("ФУНКЦИЯ");
_obj_re_2_nl            =   Новый РегулярноеВыражение("[\r\n\t ]{2,}");

ВхФайл                  =   Новый ЧтениеТекста();
ВхФайл.Открыть("c:\Repos\Linter1\test.bsl", "UTF-8");
inTxt                   =   ВхФайл.Прочитать();
ВхФайл.Закрыть();
Утверждения.ПроверитьНеРавенство(inTxt, "", "Этот файл = пустой");

noCommentsTxt           =   _obj_re_comments.Replace(inTxt, "");
noTabsTxt               =   _obj_re_tab.Replace(noCommentsTxt, "");
noDoubleNL              =   _obj_re_nl.Replace(noTabsTxt, Символы.ПС);
funcs                   =   _obj_re_funcs.Matches(noDoubleNL);
Утверждения.ПроверитьНеРавенство(funcs.Количество(), 0, "Совпадающих элементов не найдено");

wTxt                    =   noDoubleNL;
Для Каждого func
Из          funcs Цикл
    tFunc               =   func.Группы;
    wholeMatch          =   func.Группы[0].Значение;
    preFunc             =   _obj_re_2_nl.Replace(func.Группы[1].Значение, Символы.ПС);
    typeFunc            =   func.Группы[2].Значение;
    Если _obj_re_is_func.IsMatch(typeFunc)
    Тогда
        typeFunc        =   typeFunc + "     ";
    Иначе
        typeFunc        =   typeFunc + "   ";
    КонецЕсли;
    nameFunc            =   func.Группы[3].Значение;

    paramsFunc          =   _obj_re_nl.Replace(func.Группы[4].Значение, " ");

    expFunc             =   _obj_re_nl.Replace(func.Группы[5].Значение, "");

    bodyFunc            =   _obj_re_nl.Replace(func.Группы[6].Значение, " ");
    bodyFunc            =   Символы.ПС + parse_body(func.Группы[6].Значение, 1);

    endFunc             =   _obj_re_nl.Replace(func.Группы[7].Значение, " ");
    endFunc             =   _obj_re_spaces.Replace(endFunc, " ");
    Утверждения.ПроверитьНеРавенство(endFunc, "", "Пустое значение конца функции");

    tFuncNew            =   typeFunc + nameFunc + "(" + paramsFunc + ") " + expFunc + Символы.ПС
                        +   bodyFunc + Символы.ПС
                        +   endFunc; 
    tFuncNew            =   preFunc + Символы.ПС + tFuncNew + Символы.ПС;
    wTxt                =   СтрЗаменить(wTxt, wholeMatch, tFuncNew);    
	Сообщить("Работаю над " + nameFunc);
КонецЦикла;

obj_re_equals			=	Новый РегулярноеВыражение("^([^""\n\(]+)?\s*=\s*(\s.*)$");
eqs						=	obj_re_equals.Matches(wTxt);
max						=	0;
Для каждого eq
Из eqs Цикл
	Если eq.Группы[1].Длина > max
	Тогда
		max 			=	eq.Группы[1].Длина;	
	КонецЕсли;
КонецЦикла;

Пока не max % 4 = 0
Цикл
	max					=	max + 1;
КонецЦикла;

Для каждого eq
Из eqs Цикл
	left_part			=	eq.Группы[1].Значение;
	right_part			=	eq.Группы[2].Значение;
	full_match			=	eq.Группы[0].Значение;
	left_len			=	СтрДлина(left_part);
	newspaces			=	max - left_len;
	new_equals			=	left_part + ss(newspaces) + "=  " + right_part;
	wTxt				=	СтрЗаменить(wTxt, full_match, new_equals);
КонецЦикла;

_in_words				=	_obj_re_printable.Matches(noTabsTxt);
_in_w_count				=	_in_words.Количество();
_out_words				=	_obj_re_printable.Matches(wTxt);
_out_w_count			=	_out_words.Количество();
Если не _in_w_count = _out_w_count
Тогда
	Сообщить("Есть расхождения в данных, начинаю сравнение");
	z					=	0;
	Пока z < _in_w_count - 1 Цикл
		in_w			=	_in_words[z].Группы[0].Значение;
		out_w			=	_out_words[z].Группы[0].Значение;
		Сообщить("in :" + in_w + Символы.ПС);
		Сообщить("out:" + out_w + Символы.ПС);
		Утверждения.ПроверитьРавенство(in_w, out_w, "Вот здесь и упадём");
		z				=	z + 1;
	КонецЦикла;
КонецЕсли;

ИсхФайл                 =   Новый ЗаписьТекста();
ИсхФайл.Открыть("c:\Repos\Linter1\test.bsl.txt", "UTF-8");
ИсхФайл.Записать(wTxt);
ИсхФайл.Закрыть();
ЗапуститьПриложение("""c:\Program Files\Notepad++\notepad++.exe"" c:\Repos\Linter1\test.bsl.txt");