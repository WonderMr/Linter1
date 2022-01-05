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
	//Сообщить(f_str);
	obj_temp_char       =   Новый РегулярноеВыражение("\@\!\#\$\%\!\@\$\%\^\#\!\@");
    obj_b_start         =   Новый РегулярноеВыражение("((?:^|;)*?[^""]*?)(;)([^""]*?(?:;|$))");
    obj_s_start         =   Новый РегулярноеВыражение("^[\t ]*");
	obj_empty           =   Новый РегулярноеВыражение("^[\t ]*\r*\n*;*[\t ]*\r*\n");	
    obj_end             =   Новый РегулярноеВыражение("$\r*\n*^[\t ]*$");	
	fixed1				=	obj_empty.Replace(f_str, "");
    fixed               =   obj_b_start.Replace(fixed1, "$1;" + Символы.ПС + "$3");
	fixed2              =   obj_s_start.Replace(fixed, s(lvl));
    fixed3              =   obj_end.Replace(fixed2, "");
    Возврат fixed3; 
EndFunction

Function get_code(p1, code, p2)
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
	_obj_opers          =   Новый РегулярноеВыражение("(?'code'[^ꡏ]*?)((\s|^)(?'elem'Для[^а-яА-ЯёЁ0-1a-zA-Z\\_]|Из[^а-яА-ЯёЁ0-1a-zA-Z\\_]|Цикл[^а-яА-ЯёЁ0-1a-zA-Z\\_]|Если[^а-яА-ЯёЁ0-1a-zA-Z\\_]|Тогда[^а-яА-ЯёЁ0-1a-zA-Z\\_]|Иначе[^а-яА-ЯёЁ0-1a-zA-Z\\_]|ИначеЕсли[^а-яА-ЯёЁ0-1a-zA-Z\\_]|Попытка[^а-яА-ЯёЁ0-1a-zA-Z\\_]|Исключение[^а-яА-ЯёЁ0-1a-zA-Z\\_]|Пока[^а-яА-ЯёЁ0-1a-zA-Z\\_]|КонецЕсли[^а-яА-ЯёЁ0-1a-zA-Z\\_]|КонецПопытки[^а-яА-ЯёЁ0-1a-zA-Z\\_]|КонецЦикла[^а-яА-ЯёЁ0-1a-zA-Z\\_]|По[^а-яА-ЯёЁ0-1a-zA-Z\\_]|И[^а-яА-ЯёЁ0-1a-zA-Z\\_]|Или[^а-яА-ЯёЁ0-1a-zA-Z\\_]))");
	_obj_clean			=	Новый РегулярноеВыражение("\s+");
	_obj_clean2			=	Новый РегулярноеВыражение("^\s{2}");
	_obj_clean3			=	Новый РегулярноеВыражение("^\s+|\s+$");
	ret					=	"";
	ops					=	_obj_opers.Matches(bodyStr);
	Если ops.Количество() = 0
	Тогда
		bodyStr			=	_obj_clean.Replace(bodyStr," ");
		ret				=	fix_start_pos(bodyStr, lvl) + Символы.ПС;
	Иначе
		prev_op			=	"";
		Для каждого op 
		Из ops Цикл
			op			=	op.Группы;
			next_op		=	_obj_clean.Replace(op[4].Значение, " ");
			next_op		=	_obj_clean3.Replace(next_op, "");
			code		=	_obj_clean.Replace(op[3].Значение, " ");
			code		=	_obj_clean3.Replace(op[3].Значение, "");
			НачалоОп	=	СтрСравнить(next_op, "Для") = 0
						Или	СтрСравнить(next_op, "Если") = 0
						Или	СтрСравнить(next_op, "Пока") = 0;
			ПолётНазад	=	СтрСравнить(next_op, "КонецЕсли;") = 0
						Или	СтрСравнить(next_op, "КонецЦикла;") = 0
						Или	СтрСравнить(next_op, "КонецПопытки;") = 0
						Или	СтрСравнить(next_op, "ИначеЕсли") = 0;
			Если НачалоОп
			Тогда
				ret		=	get_code(ret, fix_start_pos(code, lvl), Символы.ПС);
				ret		=	ret +	fix_start_pos(next_op, lvl);
				prev_op	=	next_op;
			ИначеЕсли 	СтрСравнить(next_op, "Или") = 0
			Или			СтрСравнить(next_op, "И") = 0
			Тогда
				ret		=	get_code(ret +	" ", code, Символы.ПС);
				ret		=	ret +	fix_start_pos(next_op, lvl);
				prev_op	=	next_op;			
			ИначеЕсли  	СтрСравнить(next_op, "Попытка") = 0
			Тогда
				ret		=	get_code(ret, fix_start_pos(code, lvl),  Символы.ПС);
				ret		=	ret +	fix_start_pos(next_op, lvl) + Символы.ПС;
				prev_op	=	next_op;
			ИначеЕсли  	СтрСравнить(next_op, "Из") = 0
			Тогда
				ret		=	ret +	" " + _obj_clean3.Replace(code, "") + " " + Символы.ПС;
				ret		=	ret +	fix_start_pos(next_op, lvl);
				prev_op	=	next_op;
			ИначеЕсли  	СтрСравнить(next_op, "Тогда") = 0
			Или			СтрСравнить(next_op, "Цикл") = 0
			Тогда
				Если 	СтрСравнить(prev_op, "Из") = 0
				Тогда
					ret		=	ret +	"          " + _obj_clean3.Replace(code, "") + Символы.ПС;
				ИначеЕсли СтрСравнить(prev_op, "Или") = 0
				Тогда
					ret		=	ret +	"  " + _obj_clean3.Replace(code, "") + " " + Символы.ПС;
				ИначеЕсли СтрСравнить(prev_op, "И") = 0
				Тогда
					ret		=	ret +	"    " + _obj_clean3.Replace(code, "") + " " + Символы.ПС;	
				Иначе
					ret		=	ret +	" " + _obj_clean3.Replace(code, "") + " " + Символы.ПС;
				КонецЕсли;
				ret		=	ret +	fix_start_pos(next_op, lvl) + Символы.ПС;
				lvl		=	lvl + 1;
				prev_op	=	next_op;
			ИначеЕсли  СтрСравнить(next_op, "Иначе") = 0
			Тогда
					ret		=	ret +	fix_start_pos(code, lvl) + Символы.ПС;
					ret		=	ret +	fix_start_pos(next_op, lvl-1) + Символы.ПС;
					prev_op	=	next_op;
			ИначеЕсли  СтрСравнить(next_op, "Исключение") = 0
			Тогда
					lvl		=	lvl + 1;
					ret		=	get_code(ret, fix_start_pos(code, lvl), Символы.ПС);
					ret		=	ret +	fix_start_pos(next_op, lvl - 1) + Символы.ПС;
					prev_op	=	next_op;
			ИначеЕсли  	ПолётНазад
			Тогда
				ret		=	get_code(ret, fix_start_pos(code, lvl), Символы.ПС);
				lvl		=	lvl - 1;
				ret		=	ret +	fix_start_pos(next_op, lvl) + Символы.ПС;
				prev_op	=	next_op;
			Иначе
				ret		=	ret +	fix_start_pos(code, 0) + Символы.ПС;
				ret		=	ret +	fix_start_pos(next_op, 0) + Символы.ПС;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Возврат ret;
EndFunction

_re_worlds              =   "([^ꡏ]*?)([\\\_а-яА-ЯёЁa-zA-Z1-9]{2,});*";
_re_spaces              =   "[\t ]{2,}";
_obj_re_spaces          =   Новый РегулярноеВыражение(_re_spaces);
_obj_end                =   Новый РегулярноеВыражение("$\r*\n*^[\t ]*$");
_re_nl                  =   "\r*\n";
_obj_re_nl              =   Новый РегулярноеВыражение(_re_nl);
_re_tabs                =   "\t";
_re_comments            =   "[\t ]*\/\/.*\r*\n";
_re_funcs               =   "(?'pre'[^ꡏ]*?)?(?'type'Функция|Процедура)\s+(?'name'[^\s\(]*)\s*\((?'params'[^ꡏ]*?)\)\s*(?'exp'Экспорт)*(?'body'[^ꡏ]*?)?(?'end'КонецФункции|КонецПроцедуры)";
_re_opers               =   "(?'prestart'[^ꡏ]*?)?(?'oper'Попытка|Попытк|Если|Цикл)(?'body'[^ꡏ]+)(?'end'Конец(Цикла|Попытки|Если))(?'afterend'[^ꡏ]*)";
_obj_re_opers           =   Новый РегулярноеВыражение(_re_opers);
_r_func                 =   Новый РегулярноеВыражение("ФУНКЦИЯ");
_re_2_nl                =   "[\r\n\t ]{2,}";
_obj_re_2_nl            =   Новый РегулярноеВыражение(_re_2_nl);

ВхФайл                  =   Новый ЧтениеТекста();
ВхФайл.Открыть("c:\Repos\Linter1\test.bsl", "UTF-8");
inTxt                   =   ВхФайл.Прочитать();
ВхФайл.Закрыть();
Утверждения.ПроверитьНеРавенство(inTxt, "", "Этот файл = пустой");

noCommentsTxt           =   (Новый РегулярноеВыражение(_re_comments))   .Replace(inTxt, "");
noTabsTxt               =   (Новый РегулярноеВыражение(_re_tabs))       .Replace(noCommentsTxt, "");
noDoubleNL              =   (Новый РегулярноеВыражение(_re_2_nl))       .Replace(noTabsTxt, Символы.ПС);

funcs                   =   (Новый РегулярноеВыражение(_re_funcs))      .Matches(noDoubleNL);
Утверждения.ПроверитьНеРавенство(funcs.Количество(), 0, "Совпадающих элементов не найдено");

wTxt                    =   noDoubleNL;
Для Каждого func
Из          funcs Цикл
    tFunc               =   func.Группы;
    wholeMatch          =   func.Группы[0].Значение;
    preFunc             =   _obj_re_2_nl.Replace(func.Группы[1].Значение, Символы.ПС);
    typeFunc            =   func.Группы[2].Значение;
    Если _r_func.IsMatch(typeFunc)
    Тогда
        typeFunc        =   typeFunc + "     ";
    Иначе
        typeFunc        =   typeFunc + "   ";
    КонецЕсли;
    nameFunc            =   func.Группы[3].Значение;

    paramsFunc          =   _obj_re_nl.Replace(func.Группы[4].Значение, " ");

    expFunc             =   _obj_re_nl.Replace(func.Группы[5].Значение, "");

    bodyFunc            =   _obj_re_nl.Replace(func.Группы[6].Значение, Символы.ПС);
    bodyFunc            =   Символы.ПС + parse_body(bodyFunc, 1);

    endFunc             =   _obj_re_nl.Replace(func.Группы[7].Значение, " ");
    endFunc             =   _obj_re_spaces.Replace(endFunc, " ");
    Утверждения.ПроверитьНеРавенство(endFunc, "", "Пустое значение конца функции");
    tFuncNew            =   typeFunc + nameFunc + "(" + paramsFunc + ")" + expFunc + Символы.ПС
                        +   bodyFunc + Символы.ПС
                        +   endFunc; 
    //tFuncNew            =   _obj_end.Replace(tFuncNew, "");
    tFuncNew            =   preFunc + Символы.ПС + tFuncNew + Символы.ПС;
    wTxt                =   СтрЗаменить(wTxt, wholeMatch, tFuncNew);    
	Сообщить("Работаю над " + nameFunc);
КонецЦикла;

Равно					=	Новый РегулярноеВыражение("^([^""\n\(]+)?=(\s.*)$");
eqs						=	Равно.Matches(wTxt);
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
subtotal				=	max;
Для каждого eq
Из eqs Цикл		
	newspaces			=	(subtotal - eq.Группы[1].Длина);
	st					=	eq.Группы[1].Значение;
	en					=	eq.Группы[2].Значение;
	newl				=	st + ss(newspaces) + "=  " + en;
	wTxt				=	СтрЗаменить(wTxt, eq.Группы[0].Значение, newl);
КонецЦикла;

ИсхФайл                 =   Новый ЗаписьТекста();
ИсхФайл.Открыть("c:\Repos\Linter1\test.bsl.txt", "UTF-8");
ИсхФайл.Записать(wTxt);
ИсхФайл.Закрыть();
ЗапуститьПриложение("""c:\Program Files\Notepad++\notepad++.exe"" c:\Repos\Linter1\test.bsl.txt");