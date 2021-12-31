# -*- coding: utf-8 -*-
import  os
import  sys
import  re
from    collections import namedtuple
import  subprocess
from typing import NewType
class   p1parser:
    def __init__(self):
        self.rule               =   namedtuple("Rule"       , ["Text"  , "SubExp"])
        self.directive          =   namedtuple("Directive"  , ["UName" , "NName"])
        self.eq_pos             =   0        
        self.re_words2plus      =   re.compile(r'([^a-zа-яёА-ЯЁA-Z]+)')
        self.re_if              =   re.compile(r'(\s*)(ИНАЧЕ)*(ЕСЛИ)\s([^ꡏ]*?)(?:ТОГДА)\s+([^ꡏ|\n]*)')
        self.re_exps            =   re.compile(r'(\s*)(ПОПЫТКА)\s([^ꡏ]*)')
        self.re_exps2           =   re.compile(r'(\s*)(ИСКЛЮЧЕНИЕ)\s([^ꡏ]*)')
        self.re_exps3           =   re.compile(r'(\s*)(ВЫЗВАТЬИСКЛЮЧЕНИЕ\s[^ꡏ]*)')
        self.re_for             =   re.compile(r'(\s*)(ДЛЯ)\s([^ꡏ]*?)(?:ПО)\s+([^ꡏ|\n]*)ЦИКЛ\s+([^ꡏ|\n]*)')
        self.re_for_each        =   re.compile(r'(\s*)(ДЛЯ КАЖДОГО)\s([^ꡏ]*?)(?:ИЗ)\s+([^ꡏ|\n]*)ЦИКЛ\s+([^ꡏ|\n]*)')
        self.bsl_txt            =   ""
        self.file_in_name       =   ""
        self.file_out_name      =   ""
        self.words_in           =   ""
        self.bsl_no_comments    =   ""
        self.rules              =   []
        self.directives         =   []
        self.c1_words           =   []
        self.rules.append(self.rule(r"\t"                ,"    "))           # табы в 4 пробела
        self.rules.append(self.rule(r"[\t ]{2,}"         ," "))              # все пробелы в один 
        self.rules.append(self.rule(r"^[\t ]"            ,"\n"))             # пробел в самой первой строке
        self.rules.append(self.rule(r"\n[\t ]"           ,"\n"))             # все пробелы в начале строк
        self.rules.append(self.rule(r"[\t ]*;[\t ]*"     ,";"))              # убрать пробелы справа и слева от ;
        self.rules.append(self.rule(r"[\t ]*\)[\t ]*"    ,")"))              # убрать пробелы справа и слева от )
        self.rules.append(self.rule(r"[\t ]*\([\t ]*"    ,"("))              # убрать пробелы справа и слева от (
        self.rules.append(self.rule(r"[\t ]*\.[\t ]*"    ,"."))              # убрать пробелы справа и слева от )
        self.rules.append(self.rule(r"[\t ]*\.[\t ]*"    ,"."))              # убрать пробелы справа и слева от (
        self.rules.append(self.rule(r"\r*\n\r*\n"        ,"\n"))             # сворачиваем переносы строк
        self.rules.append(self.rule(r"(\s*\/\/.*)"       ,""))                  # Комментарии
        self.directives.append(self.directive("&НАКЛИЕНТЕ"                      ,"&НаКлиенте"))
        self.directives.append(self.directive("&НАСЕРВЕРЕ"                      ,"&НаСервере"))
        self.directives.append(self.directive("&НАСЕРВЕРЕБЕЗКОНТЕКСТА"          ,"&НаСервереБезКонтекста"))
        self.directives.append(self.directive("&НАКЛИЕНТЕНАСЕРВЕРЕБЕЗКОНТЕКСТА" ,"&НаКлиентеНаСервереБезКонтекста"))
        self.c1_words.append(self.directive("ФУНКЦИЯ"                           ,"Функция"))
        self.c1_words.append(self.directive("ПРОЦЕДУРА"                         ,"Процедура"))
        self.c1_words.append(self.directive("КОНЕЦПРОЦЕДУРЫ"                    ,"КонецПроцедуры"))
        self.c1_words.append(self.directive("КОНЕЦФУНКЦИИ"                      ,"КонецФункции"))
        self.c1_words.append(self.directive("ЭКСПОРТ"                           ,"Экспорт"))
        self.c1_words.append(self.directive("ВОЗВРАТ"                           ,"Возврат"))
        self.c1_words.append(self.directive("ЕСЛИ"                              ,"Если"))
        self.c1_words.append(self.directive("ПЕРЕМ"                             ,"Перем"))          # 
        self.c1_words.append(self.directive("ВОЗВРАТ"                           ,"Возврат"))        # 


    def read_bsl(self, file_path):
        self.file_in_name       =   file_path
        self.file_out_name      =   file_path+".out.txt"
        fpp                     =   open(file_path, encoding="UTF-8")
        self.bsl_txt            =   fpp.read()
        self.bsl_no_comments    =   re.sub(r"(\s*\/\/.*)", "", self.bsl_txt)                            # нужно для подготовки следующего пункта
        self.bsl_no_comments    =   self.re_words2plus.sub("\n", self.bsl_no_comments)
        self.words_in           =   self.bsl_no_comments.split("\n")                    # Сохраню написание всех слов
        self.bsl_txt            =   self.bsl_txt.upper()
        fpp.close()
        return

    def write_bsl(self):
        fpp                     =   open(self.file_out_name , mode="w", encoding="UTF-8")
        fpp.write(self.bsl_txt)
        fpp.close()
        return

    def give_spaces(self, count):
        ret                     =   ""
        for z                   in range(count):
            ret                 +=  " "
        return  ret
    
    def preformat(self):
        # предподготовка - выполняем правила замен из Rules
        for rule        in self.rules:
            self.bsl_txt        =   re.sub(rule.Text, rule.SubExp, self.bsl_txt)

    def format_eqs(self):
        # выравнивание = это надо делать в конце
        eq_s                    =   re.findall("\n([^\(\|][^\n\(\|]*?)(?=\=)(=)(\s+)(.*)", self.bsl_txt)
        for eq                  in  eq_s:
            if  len(eq[0])      >   self.eq_pos:
                    self.eq_pos =   len(eq[0])                              # вычисляем здесь самое крайнее появление равно

        for eq                  in  eq_s:                                   # выравниваем по нему
            spaces              =   self.give_spaces(self.eq_pos - len(eq[0]))
            self.bsl_txt        =   self.bsl_txt.replace("".join(eq), eq[0] + spaces + "=   "+eq[3])
        
        for eq                  in  re.findall("(Функция|Процедура)(\s+)(.*)"              , self.bsl_txt):
            spaces              =   self.give_spaces(self.eq_pos - len(eq[0]))
            self.bsl_txt        =   self.bsl_txt.replace("".join(eq), eq[0] + spaces + eq[2])
        for eq                  in  re.findall(r'([\t ]{2,}Возврат)(\s+)(.*)'              , self.bsl_txt):
            spaces              =   self.give_spaces(self.eq_pos - len(eq[0]))
            self.bsl_txt        =   self.bsl_txt.replace("".join(eq), eq[0] + spaces + eq[2])        
        return

    def trim(self, txt_in):
        if  txt_in              ==  "":
            return              ""
        ret                     =   re.sub('\r*\n'          ,' '    ,txt_in)            # whitespaces        
        ret                     =   re.sub('\s+'            ,' '    ,ret)               # whitespaces
        ret                     =   re.sub('(;\s)+'         ,';'    ,ret)               # 
        ret                     =   re.sub(r'^[\s*;\s*]+'   ,''     ,ret)               # точки с запятыми в начале
        ret                     =   re.sub(r'[\s*;\s*]+$'   ,''     ,ret)               # точки с запятыми в конце
        ret                     =   re.sub(r'^\n*'          ,''     ,ret)               # 
        ret                     =   re.sub(r'\n*$'          ,''     ,ret)               # 
        return                  ret

    def replace_by_array(self, rba_name, rba_arr, crlf_before = False, space_before = False, space_after = False):
        space_b                 =   " " if space_before else ""
        space_a                 =   " " if space_after  else ""
        if  rba_name            in  ["", "\n"]:
            return ""
        rba_name                =   self.trim(rba_name)
        for rba_elem            in  rba_arr:
            if rba_name.find(rba_elem.UName) == 0:
                if crlf_before:
                    return      ("\n" ) + space_b + rba_elem.NName + space_a
                else:
                    return      space_b + rba_elem.NName + space_a
        return rba_name
    
    def show_file(self, log):
        save_bsl                =   self.bsl_txt
        self.bsl_txt            =   log
        self.write_bsl()
        self.bsl_txt            =   save_bsl
        subprocess.Popen(["c:\\Program Files\\Notepad++\\notepad++.exe", self.file_out_name], shell=True,
             stdin=None, stdout=None, stderr=None, close_fds=True)

    def give_str(self,gs_lvl):
        ret_s                   =   "@crlf"+self.give_spaces((gs_lvl)*4)
        return                  ret_s

    def format_body(self, body_in):
        lvl                     =   1
        ret                     =   self.trim(body_in)+";"
        #Начинаем разделывать тело
        lines                   =   ret.split(";")                                          # разделяем по точке с запятой на строки
        prev_line               =   ""
        new_lines               =   []                                                      # сюда сложим наш разбор
        for z                   in  range(len(lines)-1):                                    # надо пройтись по всем разделённым
            line_in             =   prev_line + lines[z]                                    # обработаем "висячую строку"
            q_count             =   line_in.count('"')                                      # посчитаем текстовые кавычки
            obr_count           =   line_in.count("(")                                      # посчитаем сколько открывающих скобок
            obr_first           =   line_in.find("(") if line_in.find("(") else 0           # найдём позицию первой открывающей
            cbr_count           =   line_in.count(")")                                      # посчитаем сколько закрывающих скобок
            cbr_first           =   line_in.find(")") if line_in.find(")") else 0           # найдём позицию первой закрывающей

            # распишу блок
            # 1. Скобок одинаково и >0, открывающая в начале, кавычек - чёт
            # 2. Скобок одинаково и = 0, кавычек - чёт
            # 3. Скобок одинаково и = 0, кавычек - чёт
            if  (cbr_count > 0  and obr_count == cbr_count and obr_first<cbr_first  and q_count % 2 == 0)\
            or  (cbr_count == 0 and obr_count == 0                                  and q_count % 2 == 0):
                line            =   self.trim(line_in)
                line            =   "@crlf"+ self.give_spaces(lvl*4) + line + ";"
                new_lines.append(line)
                prev_line       =   ""
            else:
                prev_line       =   line_in + ";"
        # теперь поехали вынимать если, пока, для каждого    
        prev_line               =   ""
        lines                   =   []
        # надо пройтись по всем разделённым
        that_level_n            =   1
        in_if                   =   False
        #========================================================
            
        for z                   in  range(len(new_lines)):
            line_in                 =   new_lines[z].replace("@crlf","")            # уберём пока из них разделитель
            that_level_n            =   self.find_all(that_level_n, line_in, lines)
        ret                         =   "".join(lines)
        ret                         =   ret.replace("@crlf","\n")
        #self.show_file(ret)
        #print(ret)
        return                  ret

    def find_all(self, c_level, line, lines):
        ifs                         =   self.re_if.findall(line)
        ifs_found                   =   len(ifs)       >0
        #ifs_found                   =   False

        exps                        =   self.re_exps.findall(line)
        exps_found                  =   len(exps)      >0
        #exps_found                  =   False

        exps2                       =   self.re_exps2.findall(line)
        exps2_found                 =   len(exps2)     >0
        #exps2_found                 =   False

        exps3                       =   self.re_exps3.findall(line)
        exps3_found                 =   len(exps3)     >0
        #exps3_found                 =   False

        fors                        =   self.re_for.findall(line)
        for_found                   =   len(fors)      >0
        #for_found                   =   False

        fors_each                   =   self.re_for_each.findall(line)
        fors_each_found             =   len(fors_each) >0
        fors_each_found             =   False
        if ifs_found:
            for e_ifs       in  ifs:
                if(e_ifs[1] == "ИНАЧЕ"):
                    c_level             -=   1
                lines.append(self.give_str(c_level)   + e_ifs[1]+e_ifs[2])
                exp3                    =   e_ifs[3]
                lines.append(self.give_str(c_level+1) + e_ifs[3])
                lines.append(self.give_str(c_level)   + "ТОГДА")
                this_line           =   e_ifs[4]
                if(e_ifs[1] == "ИНАЧЕ"):
                    c_level             +=   1
                    c_level             =   self.find_all(c_level    , this_line, lines)
                else:
                    c_level             =   self.find_all(c_level + 1, this_line, lines)
        elif for_found:
            for e_for                       in fors:
                exp1                        =   e_for[1]
                exp2                        =   e_for[2]
                lines.append(self.give_str(c_level) + exp1 + " " + exp2)
                exp3                        =   e_for[3]
                exp4                        =   e_for[4]
                lines.append(self.give_str(c_level) + "ПО " + exp3)
                lines.append(self.give_str(c_level) + "ЦИКЛ")
                c_level                     =   self.find_all(c_level + 1, exp4, lines)
        elif fors_each_found:
            for e_for_e                     in fors_each:
                exp1                        =   e_for_e[1]
                exp2                        =   e_for_e[2]
                lines.append(self.give_str(c_level) + exp1 + " " + exp2)
                exp3                        =   e_for_e[3]
                exp4                        =   e_for_e[4]
                lines.append(self.give_str(c_level) + "ИЗ " + exp3)
                lines.append(self.give_str(c_level) + "ЦИКЛ")
                c_level                     =   self.find_all(c_level + 1, exp4, lines)
        elif exps_found:
            for exp                         in  exps:                
                exp1                        =   exp[1]
                exp2                        =   exp[2]
                lines.append(self.give_str(c_level) + exp1)
                c_level                     +=   1
                lines.append(self.give_str(c_level)   + exp2)
        elif exps2_found and not exps3_found:            
            for exp                         in  exps2:
                exp1                        =   exp[1]
                exp2                        =   exp[2]
                lines.append(self.give_str(c_level-1) + exp1)
                lines.append(self.give_str(c_level) + exp2)
        elif exps3_found: 
            for exp                         in  exps3:                
                exp1                        =   exp[1]
                lines.append(self.give_str(c_level) + exp1)
        else:
            test_line                   =   line.replace(" ","").replace(";","")
            if  test_line == "КОНЕЦЕСЛИ":
                c_level                 -=  1
                lines.append(self.give_str(c_level) + test_line + ";")
            elif test_line=="КОНЕЦПОПЫТКИ":
                c_level                 -=  1
                lines.append(self.give_str(c_level) + test_line + ";")
            elif test_line=="КОНЕЦЦИКЛА":
                c_level                 -=  1
                lines.append(self.give_str(c_level) + test_line + ";")
            else:
                lines.append(self.give_str(c_level)    +line.lstrip())
        return c_level


    def num_diffs(self, s):
        count                   =   0
        prev                    =   None
        for ch                  in s:
            if prev is not None and prev!=ch:
                count           +=  1
            prev                =   ch
        return count

    def decapitalize(self):
        local_bsl               =   self.bsl_txt
        words_txt               =   self.re_words2plus.sub("\n",local_bsl)
        words                   =   words_txt.split("\n")
        word_in_count           =   len(self.words_in)
        word_count              =   len(words)

        if not (word_count  ==  word_in_count):
            print("Количество входящих слов = " + str(word_in_count) + "\nКоличество исходящих слов = " + str(word_count) + "\nЭто нудопустимо")
            for z               in  range(word_count):
                try:
                    old_w_u         =   self.words_in[z-1].upper()
                    new_w_u         =   words[z-1].upper()
                except(Exception):
                    pass#print(str(.message()))
        for i                   in  range(len(words)):
            new_w               =   words[i]
            new_w_c             =   new_w.lower().capitalize()
            old_w               =   self.words_in[i] if i< len(self.words_in) else ""
            if  not new_w   == old_w:
                if not old_w[:1].isupper():
                    old_w       =   old_w.capitalize()
                #print("Различается написание "+ old_w + " и " + new_w)
                local_bsl       =   local_bsl.replace(new_w, old_w, 1)
        self.bsl_txt            =   local_bsl    

    def format_func(self):
        re.IGNORECASE           =   True
        re.UNICODE              =   True
        re.MULTILINE            =   True
        funcs                   =   re.findall(r'((\&НА\w+\s*\n|\n)(?=ФУНКЦИЯ|ПРОЦЕДУРА)(ФУНКЦИЯ|ПРОЦЕДУРА)\s+([\w\dА-Яа-я\_]+)(\(.*\));*(ЭКСПОРТ)*([^ꡏ]*?)(?=КОНЕЦФУНКЦИИ|КОНЕЦПРОЦЕДУРЫ)(КОНЕЦФУНКЦИИ|КОНЕЦПРОЦЕДУРЫ))'
                                                ,self.bsl_txt)
        #print(funcs[0][0])    
        #sys.exit
        for e_func              in  funcs:
            full_text           =   e_func[0]                                                                       # вся вместе
            run_at              =   self.replace_by_array(e_func[1],    self.directives,    crlf_before = False)    # обработка директив компилятора
            def_func            =   self.replace_by_array(e_func[2],    self.c1_words,      crlf_before = True, space_after= True)     # Функция Или Процедура
            name_offset         =   self.eq_pos - len(def_func)
            def_name            =   e_func[3]
            func_param          =   e_func[4]
            func_exp            =   self.replace_by_array(e_func[5],    self.c1_words,      space_before = True)    # экспорт или его отсутствие
            func_body           =   self.format_body(e_func[6])
            end_func            =   self.replace_by_array(e_func[7],    self.c1_words,      crlf_before = True)     # Конец [ Функция Или Процедура ]
            new_iter            =   "\n"\
                                +   run_at\
                                +   def_func\
                                +   self.give_spaces(name_offset+5)\
                                +   def_name\
                                +   func_param\
                                +   func_exp\
                                +   func_body\
                                +   end_func
            self.show_file(new_iter)
            self.bsl_txt        =   self.bsl_txt.replace(full_text  ,   new_iter)

    def process_bsl(self, file_path):
        self.read_bsl(file_path)
        self.preformat()            # предподготовка - выполняем правила замен из Rules
        self.format_func()
        self.format_eqs()           # выравнивание = это надо делать в конце
        #self.show_file(self.bsl_txt)
        self.decapitalize()
        #self.show_file(self.bsl_no_comments)
        self.show_file(self.bsl_txt)

p1                              =   p1parser()
cwd1                            =   os.getcwd()
for file in os.listdir(cwd1):
    if  file.capitalize().endswith(".bsl"):
        p1.process_bsl(os.path.join(cwd1, file))