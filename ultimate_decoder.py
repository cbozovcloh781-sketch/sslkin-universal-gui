#!/usr/bin/env python3
import re
import base64
import ast

def evaluate_math_expression(expr):
    """Вычисляет математические выражения в коде"""
    try:
        # Удаляем комментарии
        expr = re.sub(r'--.*$', '', expr)
        
        # Заменяем hex числа на десятичные
        expr = re.sub(r'0x([0-9a-fA-F]+)', lambda m: str(int(m.group(1), 16)), expr)
        
        # Удаляем лишние пробелы
        expr = expr.strip()
        
        # Вычисляем выражение
        result = eval(expr)
        return str(result)
    except:
        return expr

def decode_string_literals(code):
    """Декодирует строковые литералы"""
    # Ищем строки вида '\101\116\100' (octal)
    def decode_octal(match):
        try:
            octal_str = match.group(1)
            # Разбиваем на отдельные octal числа
            octal_numbers = re.findall(r'\\[0-7]{3}', octal_str)
            decoded = ''
            for oct_num in octal_numbers:
                decoded += chr(int(oct_num[1:], 8))
            return f'"{decoded}"'
        except:
            return match.group(0)
    
    code = re.sub(r'"([^"]*\\[0-7]{3}[^"]*)"', decode_octal, code)
    
    # Ищем hex строки
    def decode_hex(match):
        try:
            hex_str = match.group(1)
            hex_numbers = re.findall(r'\\x[0-9a-fA-F]{2}', hex_str)
            decoded = ''
            for hex_num in hex_numbers:
                decoded += chr(int(hex_num[2:], 16))
            return f'"{decoded}"'
        except:
            return match.group(0)
    
    code = re.sub(r'"([^"]*\\x[0-9a-fA-F]{2}[^"]*)"', decode_hex, code)
    
    return code

def simplify_complex_expressions(code):
    """Упрощает сложные выражения"""
    # Ищем математические выражения в скобках
    math_pattern = r'\(([^()]+)\)'
    
    def simplify_math(match):
        expr = match.group(1)
        # Проверяем, содержит ли выражение математические операции
        if re.search(r'[+\-*/%]', expr):
            try:
                result = evaluate_math_expression(expr)
                return f'({result})'
            except:
                return match.group(0)
        return match.group(0)
    
    # Применяем несколько раз для вложенных выражений
    for _ in range(5):
        code = re.sub(math_pattern, simplify_math, code)
    
    return code

def decode_function_calls(code):
    """Декодирует вызовы функций"""
    # Ищем функции вида (function()return{','}end)()
    def decode_func_call(match):
        func_body = match.group(1)
        if "return" in func_body:
            # Извлекаем возвращаемое значение
            return_match = re.search(r'return\s*([^;]+)', func_body)
            if return_match:
                return return_match.group(1)
        return match.group(0)
    
    code = re.sub(r'\(function\(\)([^}]+)end\)\(\)', decode_func_call, code)
    return code

def clean_variable_assignments(code):
    """Очищает присваивания переменных"""
    # Ищем присваивания вида local var = (complex_expression)
    lines = code.split('\n')
    cleaned_lines = []
    
    for line in lines:
        if 'local' in line and '=' in line:
            # Пытаемся упростить правую часть
            parts = line.split('=', 1)
            if len(parts) == 2:
                var_part = parts[0].strip()
                expr_part = parts[1].strip()
                
                # Упрощаем выражение
                simplified = simplify_complex_expressions(expr_part)
                simplified = decode_function_calls(simplified)
                
                # Если выражение стало простым числом, используем его
                if re.match(r'^[\d.]+$', simplified):
                    line = f"{var_part} = {simplified}"
        
        cleaned_lines.append(line)
    
    return '\n'.join(cleaned_lines)

def format_lua_properly(code):
    """Правильно форматирует Lua код"""
    # Удаляем лишние пробелы и переносы
    code = re.sub(r'\s+', ' ', code)
    
    # Добавляем переносы строк в нужных местах
    code = re.sub(r';\s*', ';\n', code)
    code = re.sub(r'end\s*', 'end\n', code)
    code = re.sub(r'function\s*', '\nfunction ', code)
    code = re.sub(r'if\s*', '\nif ', code)
    code = re.sub(r'for\s*', '\nfor ', code)
    code = re.sub(r'while\s*', '\nwhile ', code)
    code = re.sub(r'do\s*', '\ndo ', code)
    code = re.sub(r'then\s*', ' then\n', code)
    code = re.sub(r'else\s*', '\nelse\n', code)
    code = re.sub(r'local\s*', '\nlocal ', code)
    
    # Добавляем отступы
    lines = code.split('\n')
    formatted_lines = []
    indent_level = 0
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
        
        # Уменьшаем отступ для end
        if line.startswith('end'):
            indent_level = max(0, indent_level - 1)
        
        # Добавляем отступ
        formatted_line = '    ' * indent_level + line
        formatted_lines.append(formatted_line)
        
        # Увеличиваем отступ для блоков
        if line.startswith(('function', 'if', 'for', 'while', 'do')):
            indent_level += 1
    
    return '\n'.join(formatted_lines)

def extract_meaningful_strings(code):
    """Извлекает осмысленные строки из кода"""
    strings = re.findall(r'"([^"]+)"', code)
    meaningful_strings = []
    
    for string in strings:
        if len(string) > 3 and not string.isdigit():
            # Пытаемся декодировать
            try:
                # Проверяем, не является ли это base64
                if len(string) > 10 and string.isalnum():
                    decoded = base64.b64decode(string + '==').decode('utf-8', errors='ignore')
                    if decoded.isprintable():
                        meaningful_strings.append((string, decoded))
            except:
                pass
            
            # Проверяем, не содержит ли это escape последовательности
            if '\\' in string:
                try:
                    decoded = string.encode().decode('unicode_escape')
                    if decoded != string:
                        meaningful_strings.append((string, decoded))
                except:
                    pass
    
    return meaningful_strings

def main():
    print("Загружаю обфусцированный код...")
    
    with open('sosiski3', 'r', encoding='utf-8', errors='ignore') as f:
        obfuscated_code = f.read()
    
    print("Начинаю ультимативную деобфускацию...")
    
    # Извлекаем основную часть кода
    if "Protected_by_MoonSecV2" in obfuscated_code:
        lines = obfuscated_code.split('\n')
        main_code = []
        in_main_code = False
        
        for line in lines:
            if "local" in line and ("function" in line or "=" in line):
                in_main_code = True
            if in_main_code:
                main_code.append(line)
        
        if main_code:
            code = '\n'.join(main_code)
        else:
            code = obfuscated_code
    else:
        code = obfuscated_code
    
    print("Шаг 1: Извлечена основная часть кода")
    
    # Шаг 2: Декодируем строковые литералы
    print("Шаг 2: Декодирую строковые литералы...")
    code = decode_string_literals(code)
    
    # Шаг 3: Упрощаем математические выражения
    print("Шаг 3: Упрощаю математические выражения...")
    code = simplify_complex_expressions(code)
    
    # Шаг 4: Декодируем вызовы функций
    print("Шаг 4: Декодирую вызовы функций...")
    code = decode_function_calls(code)
    
    # Шаг 5: Очищаем присваивания переменных
    print("Шаг 5: Очищаю присваивания переменных...")
    code = clean_variable_assignments(code)
    
    # Шаг 6: Извлекаем осмысленные строки
    print("Шаг 6: Извлекаю осмысленные строки...")
    meaningful_strings = extract_meaningful_strings(code)
    
    # Шаг 7: Форматируем код
    print("Шаг 7: Форматирую код...")
    formatted_code = format_lua_properly(code)
    
    # Сохраняем результат
    with open('sosiski3_ultimate.lua', 'w', encoding='utf-8') as f:
        f.write("-- Ультимативно деобфусцированный Lua скрипт\n")
        f.write("-- Исходный файл: sosiski3\n")
        f.write("-- Тип: Roblox YBA чит скрипт\n\n")
        
        # Добавляем информацию о найденных строках
        if meaningful_strings:
            f.write("-- Найденные осмысленные строки:\n")
            for original, decoded in meaningful_strings[:30]:
                f.write(f"-- {original} -> {decoded}\n")
            f.write("\n")
        
        f.write(formatted_code)
    
    print("Ультимативная деобфускация завершена!")
    print("Результат сохранен в файл: sosiski3_ultimate.lua")
    
    # Показываем первые строки результата
    print("\nПервые строки ультимативно деобфусцированного кода:")
    lines = formatted_code.split('\n')
    for i, line in enumerate(lines[:50]):
        if line.strip():
            print(f"{i+1:3d}: {line}")

if __name__ == "__main__":
    main()