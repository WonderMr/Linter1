 КонецЕсли;

ИсхФайл                 =   Новый ЗаписьТекста();
ИсхФайл.Открыть("c:\Repos\Linter1\test.bsl.txt", "UTF-8");
ИсхФайл.Записать(wTxt);
ИсхФайл.Закрыть();
ЗапуститьПриложение("""c:\Program Files\Notepad++\notepad++.exe"" c:\Repos\Linter1\test.bsl.txt");


