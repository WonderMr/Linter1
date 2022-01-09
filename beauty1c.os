// BSLLS:LineLength-off
#Использовать asserts


Function test(c)//testComment
	_obj_re_nonprintable    =   Новый РегулярноеВыражение("\s+");
	_obj_re_comments		=	Новый РегулярноеВыражение("(?<![""|])\/\/.*");
	_obj_re_s2          	=   Новый РегулярноеВыражение("[\t ]{2,}");
	_obj_re_printable  		=   Новый РегулярноеВыражение("[^\s|;]+");
	_obj_re_nl              =   Новый РегулярноеВыражение("\r*\n");
	_obj_re_tab				=	Новый РегулярноеВыражение("\t");
	_pagba					=	Символ(43103);
	_re_funcs               =   "(?<code>[^" + _pagba + "]*?)(?<until>(?<pre_comp_instr_block>\s[\#\&].+)|"
							+	"(?<func_block>(?<!\/\/)[\s|;]"
							+		"(?<func_type>Функция|Процедура|Function|Procedure)"
							+		"(?<func_name>(?<!\/\/)\s+[^\s\(]*?)"
							+		"(?<func_params>(?<!\/\/)\([^\)]*?\))"
							+		"(?<func_exp>([\t ]*Экспорт)*))|"
							+	"(?<any_end_block>(?<!\/\/)[\s|;]"
							+		"(?<end>"
							+			"Конец(?:Если|Функции|Процедуры|Цикла|Попытки);*|"
							+			"End(?:Function|Procedure|If|Do|Try);*))|"
							+	"(?<for_do_block>(?<!\/\/)[\s|;]"
							+		"(?<for_start>Для\s|For\s|Пока\s|While\s)"
							+		"(?<for_cond>[^"+ _pagba +"]+?)"
							+		"(?<for_do>Цикл|Do))|"
							+	"(?<if_block>(?<!\/\/)[\s|;]"
							+		"(?<if_start>Если\s|If\s|ИначеЕсли\s|Elif\s)"
							+		"(?<if_condition>[^"+ _pagba +"]+?)"
							+		"(?<if_then>Тогда|Then))|"
							+	"(?<try_block>(?<!\/\/)[\s|;]"
							+		"(?<try_except>Попытка|Try)\s)|"
							+	"(?<elif_block>(?<!\/\/)[\s|;]"
							+		"(?<elif>Иначе\s|Else\s|Исключение\s|Exception\s))|"
							+	"\z)";	Сообщить("1");//FunctionName()
Сообщить("2");Сообщить("//FunctionName()
|//FunctionName()");
    ret                 =   "";
    Для i = 1
    По  c
    Цикл
        ret             =   ret + " ";
    КонецЦикла;
    Возврат ret; 
EndFunction // FunctionName()

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
	//Сообщить("=============================================");
	f_ret				=	"";
	Если Не ЗначениеЗаполнено(f_str)
	Тогда
			Возврат "";
	КонецЕсли;
	//Сообщить(f_str);
	//obj_re_semicolons	=	Новый РегулярноеВыражение("(?<=;|^)(([^"";\n]*|([^"";\n]*""[^""]*""[^"";]*)*?)(;|\z))");
	obj_re_semicolons	=	Новый РегулярноеВыражение("(?<=;|^)(([^"";\n]*|([^"";\n]*""[^""]*""[^"";]*)*)(;|$))");
    obj_re_spaces_from  =   Новый РегулярноеВыражение("^([\t ]*)(?=([^\s]))");
	obj_re_space_to     =   Новый РегулярноеВыражение("^([\t ]*)(\||\+|\-)");
	obj_re_empty_strings =   Новый РегулярноеВыражение("^[\t ]*\r*\n*;*[\t ]*\r*\n|\s*\r*\n*\z");
	obj_re_clean	=	Новый РегулярноеВыражение("$(\r*\n*\s)*");
	obj_re_clean2	=	Новый РегулярноеВыражение("$(\s*\r*\n)");
    obj_end             =   Новый РегулярноеВыражение("\r*\n*$\r*\n*");
	Сообщить("f_str");
	Сообщить(f_str);
	fixed1				=	obj_re_empty_strings.Replace(f_str, "");
	semicolon_string	=	obj_re_semicolons.Matches(fixed1);

	Для каждого s_string
	Из semicolon_string Цикл		
		this_str		=	s_string.Группы[1].Значение;
		f_ret			=	f_ret + obj_re_clean.Replace(this_str, Символы.ПС);
		Сообщить("this_str");
		Сообщить(this_str);
	КонецЦикла;
	Сообщить("f_ret");
	Сообщить(f_ret);

	Если не semicolon_string.Количество() > 0
	Тогда
		f_ret			=	obj_end.Replace(fixed1, Символы.ПС);
		fixed2          	=   obj_re_spaces_from.Replace(fixed1, s(lvl));
	Else
		fixed1				=	obj_re_empty_strings.Replace(f_ret, "");
		start				=	obj_re_spaces_from.Matches(fixed1);
		fixed2          	=   obj_re_spaces_from.Replace(fixed1, s(lvl));
	КонецЕсли;
	
	if obj_re_space_to.Match(fixed2)
	Тогда
		fixed2          =   obj_re_space_to.Replace(fixed2, s(lvl + 1) + "$2"+"  ");
	КонецЕсли;
	fixed2				=	fixed2+(Символы.ПС);
    Возврат fixed2
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

_obj_re_nonprintable    =   Новый РегулярноеВыражение("\s+");
_obj_re_comments		=	Новый РегулярноеВыражение("(?<![""|])\/\/.*");
_obj_re_s2          	=   Новый РегулярноеВыражение("[\t ]{2,}");
_obj_re_printable  		=   Новый РегулярноеВыражение("[^\s|;]+");
_obj_re_nl              =   Новый РегулярноеВыражение("\r*\n");
_obj_re_tab				=	Новый РегулярноеВыражение("\t");
_pagba					=	Символ(43103);
_re_funcs               =   "(?<code>[^" + _pagba + "]*?)(?<until>(?<pre_comp_instr_block>\s[\#\&].+)|"
						+	"(?<func_block>(?<!\/\/)[\s|;]"
						+		"(?<func_type>Функция|Процедура|Function|Procedure)"
						+		"(?<func_name>(?<!\/\/)\s+[^\s\(]*?)"
						+		"(?<func_params>(?<!\/\/)\([^\)]*?\))"
						+		"(?<func_exp>([\t ]*Экспорт)*))|"
						+	"(?<any_end_block>(?<!\/\/)[\s|;]"
						+		"(?<end>"
						+			"Конец(?:Если|Функции|Процедуры|Цикла|Попытки);*|"
						+			"End(?:Function|Procedure|If|Do|Try);*))|"
						+	"(?<for_do_block>(?<!\/\/)[\s|;]"
						+		"(?<for_start>Для\s|For\s|Пока\s|While\s)"
						+		"(?<for_cond>[^"+ _pagba +"]+?)"
						+		"(?<for_do>Цикл|Do))|"
						+	"(?<if_block>(?<!\/\/)[\s|;]"
						+		"(?<if_start>Если\s|If\s|ИначеЕсли\s|Elif\s)"
						+		"(?<if_condition>[^"+ _pagba +"]+?)"
						+		"(?<if_then>Тогда|Then))|"
						+	"(?<try_block>(?<!\/\/)[\s|;]"
						+		"(?<try_except>Попытка|Try)\s)|"
						+	"(?<elif_block>(?<!\/\/)[\s|;]"
						+		"(?<elif>Иначе\s|Else\s|Исключение\s|Exception\s))|"
						+	"\z)";
_obj_re_funcs			=	Новый РегулярноеВыражение(_re_funcs);
_obj_re_equals			=	Новый РегулярноеВыражение("^(([^""\n]?|([^""\n]*""[^""\n]*""[^""\n]*?))*?)(\s*)([\=\+\-])\s*([^\n]+)");

ВхФайл                  =   Новый ЧтениеТекста();
in_name					=	"c:\Repos\Linter1\beauty1c.os";
ВхФайл.Открыть(in_name, "UTF-8");
inTxt                   =   ВхФайл.Прочитать();
ВхФайл.Закрыть();
Утверждения.ПроверитьНеРавенство(inTxt, "", "Этот файл = пустой");

noCommentsTxt           =   _obj_re_comments.Replace(inTxt, "");
noTabsTxt               =   _obj_re_tab.Replace(noCommentsTxt, "");
//noDoubleNL              =   _obj_re_nl.Replace(noTabsTxt, Символы.ПС);

funcs                   =   _obj_re_funcs.Matches(noTabsTxt);
Утверждения.ПроверитьНеРавенство(funcs.Количество(), 0, "Совпадающих элементов не найдено");

wTxt                    =   noTabsTxt;
wTxt                    =   "";
lvl						=	0;
newstr					=	"";
Для Каждого func
Из          funcs Цикл
    tFunc               =   func.Группы;
    wholeMatch          =   func.Группы[0].Значение;
	z					=	0;

	match					=	_obj_re_s2.Replace(tFunc[0].Значение,  " ");//+
	code					=	_obj_re_s2.Replace(tFunc[2].Значение,  " ");//+
	until					=	_obj_re_s2.Replace(tFunc[3].Значение,  " ");//+
	pre_comp_instr_block	=	_obj_re_s2.Replace(tFunc[4].Значение,  " ");//+
	func_type				=	_obj_re_s2.Replace(tFunc[6].Значение,  " ");//+
	func_name				=	_obj_re_s2.Replace(tFunc[7].Значение, " ");//+
	func_params				=	_obj_re_s2.Replace(tFunc[8].Значение, " ");//+
	func_exp				=	_obj_re_s2.Replace(tFunc[9].Значение, " ");//+
	end					=	_obj_re_s2.Replace(tFunc[11].Значение, " ");//+
	for_start			=	_obj_re_s2.Replace(tFunc[13].Значение, " ");//+
	for_cond			=	_obj_re_s2.Replace(tFunc[14].Значение, " ");//+
	for_do				=	_obj_re_s2.Replace(tFunc[15].Значение, " ");//+
	if_start			=	_obj_re_s2.Replace(tFunc[17].Значение, " ");//+
	if_condition		=	_obj_re_s2.Replace(tFunc[18].Значение, " ");//+
	if_then				=	_obj_re_s2.Replace(tFunc[19].Значение, " ");//+
	try_except			=	_obj_re_s2.Replace(tFunc[21].Значение, " ");//+
	elif_or_except		=	_obj_re_s2.Replace(tFunc[23].Значение, " ");//+

	newstr				=	"Это Косяк";	
	//Сообщить("===============================================================");
	//Сообщить(match);
	//Сообщить("===============================================================");
	Для каждого item
	Из tFunc Цикл
		Если ЗначениеЗаполнено(item.Значение)
		Тогда
			//Сообщить(СтрШаблон("№ = %1, Name = %2, value = %3", строка(z), строка(item.Имя), _obj_re_nl.replace(строка(item.Значение), " ")));
		КонецЕсли;
		z				=	z + 1;		
	КонецЦикла;
		
	Если ЗначениеЗаполнено(func_type)
	Тогда
		newstr			=	Символы.ПС + fix_start_pos(СтрШаблон("%1 %2%3 %4", func_type, func_name, func_params, func_exp), 0);
		lvl				=	lvl + 1;
	ИначеЕсли ЗначениеЗаполнено(pre_comp_instr_block)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + fix_start_pos(pre_comp_instr_block, 0);
	ИначеЕсли ЗначениеЗаполнено(if_start)
	Тогда
		Если СтрНайти(if_start, "ИначеЕсли")> 0 
		Тогда
			lvl				=	lvl - 1;
		КонецЕсли;
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + fix_start_pos(if_start + " " + if_condition, lvl);
		newstr			=	newstr + fix_start_pos(if_then, lvl);
		lvl				=	lvl + 1;
	ИначеЕсли ЗначениеЗаполнено(elif_or_except)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + fix_start_pos(elif_or_except, lvl - 1);
	ИначеЕсли ЗначениеЗаполнено(end)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + fix_start_pos(end, lvl - 1);
		lvl				=	lvl - 1;
		if lvl = 0 
		Тогда
			newstr			=	newstr + Символы.ПС;
		КонецЕсли;
	ИначеЕсли ЗначениеЗаполнено(try_except)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + fix_start_pos(try_except, lvl);
		lvl				=	lvl + 1;
	ИначеЕсли ЗначениеЗаполнено(for_start)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + fix_start_pos(for_start + " " + for_cond, lvl);
		newstr			=	newstr + fix_start_pos(for_do, lvl);
		lvl				=	lvl + 1;
	Иначе
		newstr			=	fix_start_pos(code, lvl);
	КонецЕсли;
	wTxt			=	wTxt + newstr;
	//Сообщить(wTxt);
	Продолжить;
КонецЦикла;

eqs						=	_obj_re_equals.Matches(wTxt);
max						=	0;
Для каждого eq
Из eqs Цикл
	Если СтрСравнить(eq.Группы[5].Значение, "=")=0 
	И eq.Группы[1].Длина > max
	Тогда
		max 			=	eq.Группы[1].Длина;	
	КонецЕсли;
КонецЦикла;

Пока не max % 4 = 0
Цикл
	max					=	max + 1;
КонецЦикла;


Результат = Новый Массив;
Кэш = Новый Соответствие;
Для каждого Элемент из eqs Цикл
	Если ЗначениеЗаполнено(Элемент.Группы[1].Значение)
	Тогда
		ИмяЭтого		= Элемент.Группы[0].Значение;
	Иначе
		ИмяЭтого		= Элемент.Группы[5].Значение+Элемент.Группы[6].Значение;
	КонецЕсли;
   Если Кэш[ИмяЭтого]=неопределено Тогда
		Сообщить("Добавляю "+ИмяЭтого);
	   Кэш[ИмяЭтого] = Истина;
	   Результат.Добавить(Элемент);
   КонецЕсли;
КонецЦикла;

Для каждого eq
Из Результат Цикл
	left_part			=	eq.Группы[1].Значение;
	spaces_part			=	eq.Группы[4].Значение;
	mid_part			=	eq.Группы[5].Значение;
	right_part			=	eq.Группы[6].Значение;
	full_match			=	eq.Группы[0].Значение;
	left_len			=	СтрДлина(left_part);
	spaces_len			=	СтрДлина(spaces_part);
	Если ЗначениеЗаполнено(left_part)
	Тогда
	
	newspaces			=	max - left_len;
		new_equals			=	left_part + ss(newspaces) + mid_part + "  " + right_part;
	Иначе
		
	new_equals			=	ss(max) + mid_part + "  " + right_part;
	КонецЕсли;
	Сообщить(new_equals);
	wTxt				=	СтрЗаменить(wTxt, full_match, new_equals);
	//Сообщить(wTxt);
КонецЦикла;

in_test_txt				=	_obj_re_nonprintable.Replace(noCommentsTxt, "");
out_test_txt			=	_obj_re_nonprintable.Replace(wTxt, "");

_in_words				=	_obj_re_printable.Matches(in_test_txt);
_in_w_count				=	_in_words.Количество();
_out_words				=	_obj_re_printable.Matches(out_test_txt);
_out_w_count			=	_out_words.Количество();
//Если не _in_w_count = _out_w_count
//Тогда
//	Сообщить("Есть расхождения в данных, начинаю сравнение");
	z					=	0;
	Пока z < _in_w_count - 1 Цикл
		in_w			=	_in_words[z].Группы[0].Значение;
		out_w			=	_out_words[z].Группы[0].Значение;
		in_txt			=	"in :" + in_w + Символы.ПС;
		out_txt			=	"out:" + out_w + Символы.ПС;
		Утверждения.ПроверитьРавенство(in_w, out_w, in_txt + out_txt);
		z				=	z + 1;
	КонецЦикла;
//КонецЕсли;

ИсхФайл                 =   Новый ЗаписьТекста();
ИсхФайл.Открыть(in_name + ".txt", "UTF-8");
ИсхФайл.Записать(wTxt);
ИсхФайл.Закрыть();
ЗапуститьПриложение("""c:\Program Files\Notepad++\notepad++.exe"" " + in_name + ".txt");