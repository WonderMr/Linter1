// BSLLS:LineLength-off
#Использовать asserts
_re_worlds              =   "([^ꡏ]*?)([\\_а-яА-ЯёЁa-zA-Z1-9]{2,});*";
_re_spaces              =   "[\t ]{2,}";
_re_tabs                =   "\t";
_obj_re_spaces          =   Новый РегулярноеВыражение(_re_spaces);
_re_comments            =   "[\t ]*\/\/.*\r*\n";
_re_funcs               =   "(?'pre'[^ꡏ]*?)?(?'type'Функция|Процедура)\s+(?'name'[^\s\(]*)\s*\((?'params'[^ꡏ]*?)\)\s*(?'exp'Экспорт)*(?'body'[^ꡏ]*?)?(?'end'КонецФункции|КонецПроцедуры)";
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

    bodyFunc            =   _obj_re_2_nl.Replace(func.Группы[6].Значение, Символы.ПС);
    bodyFunc            =   _obj_re_spaces.Replace(bodyFunc, " ");

    endFunc             =   func.Группы[7].Значение;
    Утверждения.ПроверитьНеРавенство(endFunc, "", "Пустое значение конца функции");
    tFuncNew            =   preFunc + Символы.ПС 
                        +   typeFunc + nameFunc + "(" + paramsFunc + ")" + expFunc
                        +   _obj_re_2_nl.Replace(Символы.ПС + bodyFunc + Символы.ПС + endFunc, Символы.ПС); 
    wTxt                =   СтрЗаменить(wTxt, wholeMatch, tFuncNew);    
КонецЦикла;

ИсхФайл                 =   Новый ЗаписьТекста();
ИсхФайл.Открыть("c:\Repos\Linter1\test.bsl.txt", "UTF-8");
ИсхФайл.Записать(wTxt);
ИсхФайл.Закрыть();
ЗапуститьПриложение("""c:\Program Files\Notepad++\notepad++.exe"" c:\Repos\Linter1\test.bsl.txt");