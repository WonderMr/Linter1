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

Function fix_start_pos(f_str, lvl)
    obj_b_start         =   Новый РегулярноеВыражение(";");
    fixed               =   obj_b_start.Replace(f_str, ";" + Символы.ПС);
    obj_s_start         =   Новый РегулярноеВыражение("^[\t ]*");
    fixed               =   obj_s_start.Replace(fixed, s(lvl));
    obj_end             =   Новый РегулярноеВыражение("$\r*\n*^[\t ]*$");
    fixed               =   obj_end.Replace(fixed, "");
    Возврат fixed; 
EndFunction

// парсит тело функции и возращает Beautified код
Function parse_body(prev_item, bodyStr, lvl)    
    _obj_re_2_nl        =   Новый РегулярноеВыражение("[\r\n]{2,}");
    obj_nl              =   Новый РегулярноеВыражение("\s");
    obj_oper_next       =   Новый РегулярноеВыражение("(?'prestart'[^ꡏ]*?)?(?'oper'Тогда|Цикл|Исключение|ИначеЕсли|Иначе)(?'body'[^ꡏ]+)");
    _obj_opers          =   Новый РегулярноеВыражение("(?'oper'\s+(Если|Тогда|Иначе|ИначеЕсли|КонецЕсли|Для|Каждого|Пока|Цикл|КонецЦикла|Из|Попытка|Исключение|КонецПопытки))\s+");
    ret_body            =   "";
    sel_add             =   ""; 
    bodyStr             =   obj_nl.Replace(bodyStr, " ");
    Если СтрДлина(prev_item) > 0
    Тогда              // если здесь непустое - значит вызвали из дочернего блока и надо его добавить в регулярку
        Если СтрНайти(НСтр(prev_item), "попытка") > 0
        Тогда
            prev_item    =   "Попытки";
        КонецЕсли;
        sel_add         =   "(?'pre'[^ꡏ]*?)Конец" + obj_nl.Replace(prev_item, "");
    КонецЕсли;
    // разбираем блока кода с операторами на части
    obj                 =   Новый РегулярноеВыражение(sel_add + "(?<prestart>[^ꡏ]*?)?(?<oper>Попытк|Если|Цикл)(?<body>[^ꡏ]+)(?<end>Конец(Цикла|Попытки|Если);)(?<afterend>[^ꡏ]*)");
    bodyParts           =   obj.Matches(bodyStr);
    bodys               =   bodyParts.Количество();
    Если bodys = 0                                                              
    Тогда //[^ꡏ]*?(Если|Для|Пока|Попытка|КонецЕсли|КонецЦикла|КонецПопытки)([^ꡏ]+)
        ret_body        =   fix_start_pos(bodyStr, lvl);                        // если матчей 0 - это нижний уровень глубины и здесь возвращается последний блок вложенности
    ИначеЕсли bodys = 1
    Тогда
        bodypart        =   bodyparts[0];                                       // этот самый матч
        сnt             =   bodypart.Группы.Количество();                       // в рекурсивных вызовах будет больше полей
        Если (сnt = 8) Тогда
            iter        =   1;                                                      // и нам нужно смещение
        Иначе
            iter        =   0;
        КонецЕсли;            
        preStart        =   fix_start_pos(bodyPart.Группы[2].Значение, lvl);        // от начала текст до оператора
        oper            =   fix_start_pos(bodyPart.Группы[3 + iter].Значение, lvl); // сам оператор
        bodyEnd         =   fix_start_pos(bodyPart.Группы[5 + iter].Значение, lvl); // название закрывающего операнда
        afterEnd        =   fix_start_pos(bodyPart.Группы[6 + iter].Значение, lvl);         // остаток кода без выравнивания блоково операндов        
        mains           =   bodyPart.Группы[4 + iter].Значение;                             // всё остальное, после оператора
        mainparts       =   obj_oper_next.matches(mains);                                   // разбираем её на запчасти
        Если (mainparts.Количество() > 0) Тогда                                         // если они там есть
            next_c_st   =   fix_start_pos(mainparts[0].Группы[2].Значение, lvl);        // next command statement
            next_body   =   fix_start_pos(mainparts[0].Группы[3].Значение, lvl); // здесь получается вложенный кусок от начала кода до новых циклов или закрытия всех
            condition   =   " " + mainparts[0].Группы[1].Значение;                      // паметры следующих операндов


            next_str    =   parse_body(oper, next_body, lvl + 1);                       // отправлямся на анализ в рекурсивных вызов на следующий уровень вниз
            Если _obj_opers.Match(next_str) Тогда
                lvl     =   lvl - 1;
            КонецЕсли;
        Иначе
            next_str    =   mains;                                                      // текст блока выполнения до Конец*
        КонецЕсли;            
        //next_str    =   parse_body(oper, next_body, lvl + 1);

        ret_body        =   preStart + Символы.ПС                                       // код перед оператором
                        +   oper + condition + Символы.ПС                               // оператор и условие
                        +   next_c_st + Символы.ПС                                      // следующий оператор
                        +   next_str + Символы.ПС
                        +   bodyEnd + Символы.ПС
                        +   afterEnd;
    Иначе
        Сообщить("Непредвиденный результат");
    КонецЕсли;
    ret_body            =   _obj_re_2_nl.Replace(ret_body, Символы.ПС);
    Возврат ret_body
EndFunction

_re_worlds              =   "([^ꡏ]*?)([\\_а-яА-ЯёЁa-zA-Z1-9]{2,});*";
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

    paramsFunc          =   _obj_re_2_nl.Replace(func.Группы[4].Значение, Символы.ПС);

    expFunc             =   func.Группы[5].Значение;

    bodyFunc            =   _obj_re_nl.Replace(func.Группы[6].Значение, Символы.ПС);
    bodyFunc            =   _obj_re_spaces.Replace(bodyFunc, " ");
    bodyFunc            =   parse_body("", bodyFunc, 1);

    endFunc             =   _obj_re_nl.Replace(func.Группы[7].Значение, " ");
    endFunc             =   _obj_re_spaces.Replace(endFunc, " ");
    Утверждения.ПроверитьНеРавенство(endFunc, "", "Пустое значение конца функции");
    tFuncNew            =   typeFunc + nameFunc + "(" + paramsFunc + ")" + expFunc + Символы.ПС
                        +   bodyFunc + Символы.ПС 
                        +   endFunc; 
    tFuncNew            =   _obj_end.Replace(tFuncNew, "");
    tFuncNew            =   preFunc + Символы.ПС + tFuncNew + Символы.ПС;
    wTxt                =   СтрЗаменить(wTxt, wholeMatch, tFuncNew);    
КонецЦикла;

ИсхФайл                 =   Новый ЗаписьТекста();
ИсхФайл.Открыть("c:\Repos\Linter1\test.bsl.txt", "UTF-8");
ИсхФайл.Записать(wTxt);
ИсхФайл.Закрыть();
ЗапуститьПриложение("""c:\Program Files\Notepad++\notepad++.exe"" c:\Repos\Linter1\test.bsl.txt");