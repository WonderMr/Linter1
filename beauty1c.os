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
	//Сообщить("=============================================");
	f_ret				=	"";
	Если Не ЗначениеЗаполнено(f_str) 
	Тогда
		Возврат Символы.ПС;
	КонецЕсли;
	//Сообщить(f_str);
	obj_re_sc			=	Новый РегулярноеВыражение("(([^;""]+?""+[^""]*?""+)*[^;""]*?;)");
    obj_s_start         =   Новый РегулярноеВыражение("^[\t ]*");
	obj_so_start        =   Новый РегулярноеВыражение("^([\t ]*)(\|)");
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
	if obj_so_start.Match(fixed2)
	Тогда
		fixed2          =   obj_so_start.Replace(fixed2, s(lvl+1)+"|");
	КонецЕсли;
    fixed3              =   obj_end.Replace(fixed2, Символы.ПС);
//	Сообщить("---------------------------------------------");
//	Сообщить(fixed3);
//	Сообщить("=============================================");
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

_obj_re_spaces          =   Новый РегулярноеВыражение("[\t ]{2,}");
_obj_re_s2          	=   Новый РегулярноеВыражение("\s{2,}");
_obj_re_printable  		=   Новый РегулярноеВыражение("[^\s|;]+");
_obj_re_nl              =   Новый РегулярноеВыражение("\r*\n");
_obj_re_comments		=	Новый РегулярноеВыражение("[\t ]*\/\/.*\r*\n");
_obj_re_tab				=	Новый РегулярноеВыражение("\t");
_re_funcs               =   "(?'pre'[^ꡏ]*?)?(?'type'Функция|Процедура)\s+(?'name'[^\s\(]*)\s*\((?'params'[^ꡏ]*?)\)\s*(?'exp'Экспорт)*(?'body'[^ꡏ]*?)?(?'end'КонецФункции|КонецПроцедуры)";
_re_funcs               =   "(?<code>[^ꡏ]*?)(?<until>(?<func_block>(?:;[^\r\n;\/]|^[^\|\r\n\/а-яА-ЯёЁ0-9]|^|^\s+)*(?<func_type>(Функция|Процедура|Function|Procedure))(?<func_name>[^\(]*)(?:;[^\r\n;]|^[^|\r\n])*[^\s\(\/]*[^\(]*(?<func_params>(?:(;[^\r\n;]|^[^|\r\n])*)\([^\)]*?\))\s*(?<func_exp>(Экспорт)*)|(?<comment_block>\/\/.*?$)|(?<pre_comp_instr_block>(?:;[^\r\n;\/]|^[^\|\r\n\/а-яА-ЯёЁ0-9]|^|^\s+)+\#.*$)|(?<any_end>(?:;[^\r\n;\/]|^[^\|\r\n\/а-яА-ЯёЁ0-9]|^|^\s+)*(?<end>Конец(?:Если|Функции|Процедуры|Цикла|Попытки));*)|(?<for_do_block>(?:;[^\r\n;\/]|^[^\|\r\n\/а-яА-ЯёЁ0-9]|^|^\s+)+(?<for_start>Для|For)(?<for_cond>[^ꡏ;]*?)(?<for_do>Цикл|Do))|(?:(?:;[^\r\n;\/]|^[^\|\r\n\/а-яА-ЯёЁ0-9]|^|^\s+)*(?<if_start>Если|if|ИначеЕсли|Elif)(?<if_condition>[^ꡏ;]*?)(?<if_then>Тогда|Then))|(?<try_block>(?:;[^\r\n;\/]|^[^\|\r\n\/а-яА-ЯёЁ0-9]|^|^\s+)+(?<try_except>Попытка|Try)\s+))|(?<elif_block>(?:;[^\r\n;\/]|^[^\|\r\n\/а-яА-ЯёЁ0-9]|^|^\s+)+(?<elif>Иначе|Else|Исключение|Exception)\s+))";
_obj_re_funcs			=	Новый РегулярноеВыражение(_re_funcs);
_re_opers               =   "(?'prestart'[^ꡏ]*?)?(?'oper'Попытка|Попытк|Если|Цикл)(?'body'[^ꡏ]+)(?'end'Конец(Цикла|Попытки|Если))(?'afterend'[^ꡏ]*)";
_obj_re_opers           =   Новый РегулярноеВыражение(_re_opers);
_obj_re_is_func        	=   Новый РегулярноеВыражение("ФУНКЦИЯ");
_obj_re_2_nl            =   Новый РегулярноеВыражение("[\r\n\t ]{2,}");
_obj_clean				=	Новый РегулярноеВыражение("^\s+");
_obj_isendsnl			=	Новый РегулярноеВыражение("\r*\n$");

ВхФайл                  =   Новый ЧтениеТекста();
ВхФайл.Открыть("c:\Repos\Linter1\test.bsl", "UTF-8");
inTxt                   =   ВхФайл.Прочитать();
ВхФайл.Закрыть();
Утверждения.ПроверитьНеРавенство(inTxt, "", "Этот файл = пустой");

noCommentsTxt           =   _obj_re_comments.Replace(inTxt, "");
noTabsTxt               =   _obj_re_tab.Replace(noCommentsTxt, "");
noDoubleNL              =   _obj_re_nl.Replace(noTabsTxt, Символы.ПС);

inTxt					=	_obj_clean.Replace(inTxt,"");
funcs                   =   _obj_re_funcs.Matches(inTxt);
Утверждения.ПроверитьНеРавенство(funcs.Количество(), 0, "Совпадающих элементов не найдено");

wTxt                    =   noDoubleNL;
wTxt                    =   "";
lvl						=	0;
Для Каждого func
Из          funcs Цикл
    tFunc               =   func.Группы;
    wholeMatch          =   func.Группы[0].Значение;
	z					=	0;
	Для каждого item
	Из tFunc Цикл
		Если ЗначениеЗаполнено(item.Значение)
		Тогда
			//Сообщить(СтрШаблон("№ = %1, Name = %2, value = %3", строка(z), строка(item.Имя), строка(item.Значение)));
		КонецЕсли;
		z				=	z + 1;		
	КонецЦикла;
	// Сообщить("===============================================================");
	newstr				=	"Это Косяк";
	func_type			=	_obj_re_s2.Replace(tFunc[7].Значение, " ");
	func_name			=	_obj_re_s2.Replace(tFunc[8].Значение, " ");
	func_params			=	_obj_re_s2.Replace(tFunc[9].Значение, " ");
	func_exp			=	_obj_re_s2.Replace(tFunc[10].Значение, " ");
	if_start			=	_obj_re_s2.Replace(tFunc[19].Значение, " ");
	if_condition		=	_obj_re_s2.Replace(tFunc[20].Значение, " ");
	if_then				=	_obj_re_s2.Replace(tFunc[21].Значение, " ");	
	pre_comp_instr_block=	_obj_re_s2.Replace(tFunc[12].Значение, " ");	
	code				=	_obj_re_s2.Replace(tFunc[4].Значение,  " ");	
	end					=	_obj_re_s2.Replace(tFunc[14].Значение, " ");

	iscodenl			=	_obj_isendsnl.Match(code);
	comment_block		=	_obj_re_s2.Replace(tFunc[11].Значение, " ");
	try_except			=	_obj_re_s2.Replace(tFunc[23].Значение, " ");
	for_start			=	_obj_re_s2.Replace(tFunc[16].Значение, " ");
	for_cond			=	_obj_re_s2.Replace(tFunc[17].Значение, " ");
	for_do				=	_obj_re_s2.Replace(tFunc[18].Значение, " ");

	elif				=	_obj_re_s2.Replace(tFunc[25].Значение, " ");

	Если ЗначениеЗаполнено(func_type)
	Тогда
		newstr			=	Символы.ПС + Символы.ПС + fix_start_pos(СтрШаблон("%1 %2%3 %4", func_type, func_name, func_params, func_exp), 0) + Символы.ПС;
		lvl				=	lvl + 1;
	КонецЕсли;
	Если ЗначениеЗаполнено(pre_comp_instr_block)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + fix_start_pos(pre_comp_instr_block, 0) + Символы.ПС;
	КонецЕсли;
	Если ЗначениеЗаполнено(if_start)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + Символы.ПС + fix_start_pos(if_start + " " + if_condition, lvl) + Символы.ПС;
		newstr			=	newstr + fix_start_pos(if_then, lvl);
		lvl				=	lvl + 1;
	КонецЕсли;
	Если ЗначениеЗаполнено(elif)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + fix_start_pos(elif, lvl - 1);
	КонецЕсли;
	Если ЗначениеЗаполнено(end)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		lvl				=	lvl - 1;
		newstr			=	newstr + fix_start_pos(end + ";" , lvl) + Символы.ПС;
	КонецЕсли;
	Если ЗначениеЗаполнено(try_except)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + fix_start_pos(try_except + Символы.ПС, lvl);
		lvl				=	lvl + 1;
	КонецЕсли;
	Если ЗначениеЗаполнено(comment_block)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		Если не (iscodenl)
		Тогда
			newstr		=	newstr + Символы.ПС + fix_start_pos(comment_block, lvl);
		Иначе
			newstr		=	newstr + comment_block;
		КонецЕсли;		
	КонецЕсли;
	Если ЗначениеЗаполнено(for_start)
	Тогда
		newstr			=	fix_start_pos(code, lvl);
		newstr			=	newstr + Символы.ПС + fix_start_pos(for_start + " " + for_cond, lvl) + Символы.ПС;
		newstr			=	newstr + fix_start_pos(for_do, lvl);
		lvl				=	lvl + 1;
	КонецЕсли;
	wTxt				=	wTxt + newstr + Символы.ПС;
	Если СтрСравнить(newstr, "Это косяк") = 0
	Тогда
		Сообщить(newstr);
	КонецЕсли;
	//Сообщить(wTxt);
	Продолжить;
КонецЦикла;

obj_re_equals			=	Новый РегулярноеВыражение("^([^""\n\(\>\<]+)?\s*=\s*(\s.*)$");
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

//_in_words				=	_obj_re_printable.Matches(noTabsTxt);
_in_words				=	_obj_re_printable.Matches(inTxt);
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