#!/usr/bin/env python3
import re
import base64
import zlib

def decode_base64_strings(code):
    """Декодирует base64 строки в коде"""
    # Ищем base64 строки
    base64_pattern = r'([A-Za-z0-9+/]{20,}={0,2})'
    matches = re.findall(base64_pattern, code)
    
    for match in matches:
        try:
            decoded = base64.b64decode(match).decode('utf-8', errors='ignore')
            code = code.replace(match, f'"{decoded}"')
        except:
            pass
    
    return code

def decode_hex_strings(code):
    """Декодирует hex строки"""
    # Ищем hex строки вида \xXX
    hex_pattern = r'\\x([0-9a-fA-F]{2})'
    
    def hex_replace(match):
        try:
            return chr(int(match.group(1), 16))
        except:
            return match.group(0)
    
    code = re.sub(hex_pattern, hex_replace, code)
    return code

def decode_unicode_escapes(code):
    """Декодирует unicode escape последовательности"""
    # Ищем unicode escape последовательности
    unicode_pattern = r'\\u([0-9a-fA-F]{4})'
    
    def unicode_replace(match):
        try:
            return chr(int(match.group(1), 16))
        except:
            return match.group(0)
    
    code = re.sub(unicode_pattern, unicode_replace, code)
    return code

def simplify_variable_names(code):
    """Упрощает имена переменных для лучшей читаемости"""
    # Заменяем сложные имена переменных на простые
    var_mapping = {}
    var_counter = 1
    
    # Ищем переменные вида _0x123456 или подобные
    var_pattern = r'\b(_0x[a-fA-F0-9]+)\b'
    
    def replace_var(match):
        var_name = match.group(1)
        if var_name not in var_mapping:
            var_mapping[var_name] = f'var_{var_counter}'
            var_counter = var_counter + 1
        return var_mapping[var_name]
    
    code = re.sub(var_pattern, replace_var, code)
    return code

def format_lua_code(code):
    """Форматирует Lua код для лучшей читаемости"""
    # Удаляем лишние пробелы
    code = re.sub(r'\s+', ' ', code)
    
    # Добавляем переносы строк после ключевых слов
    keywords = ['function', 'if', 'else', 'end', 'for', 'while', 'do', 'then', 'local']
    for keyword in keywords:
        code = re.sub(f'\\b{keyword}\\b', f'\n{keyword}', code)
    
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

def extract_strings(code):
    """Извлекает и декодирует строки из кода"""
    # Ищем строки в кавычках
    string_pattern = r'"([^"]*)"'
    strings = re.findall(string_pattern, code)
    
    decoded_strings = []
    for string in strings:
        # Пробуем разные методы декодирования
        decoded = string
        try:
            # Пробуем base64
            if len(string) > 10 and string.isalnum():
                decoded = base64.b64decode(string + '==').decode('utf-8', errors='ignore')
        except:
            pass
        
        try:
            # Пробуем hex
            if string.startswith('\\x'):
                decoded = bytes.fromhex(string.replace('\\x', '')).decode('utf-8', errors='ignore')
        except:
            pass
        
        decoded_strings.append((string, decoded))
    
    return decoded_strings

def main():
    print("Загружаю обфусцированный код...")
    
    with open('sosiski3', 'r', encoding='utf-8', errors='ignore') as f:
        obfuscated_code = f.read()
    
    print("Начинаю полную деобфускацию...")
    
    # Шаг 1: Извлекаем основную часть кода
    if "Protected_by_MoonSecV2" in obfuscated_code:
        print("Обнаружен MoonSec V2 код")
        
        # Ищем основную часть после заголовка
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
    
    # Шаг 2: Декодируем строки
    print("Шаг 2: Декодирую строки...")
    code = decode_base64_strings(code)
    code = decode_hex_strings(code)
    code = decode_unicode_escapes(code)
    
    # Шаг 3: Упрощаем имена переменных
    print("Шаг 3: Упрощаю имена переменных...")
    code = simplify_variable_names(code)
    
    # Шаг 4: Извлекаем и анализируем строки
    print("Шаг 4: Анализирую строки...")
    strings = extract_strings(code)
    
    # Шаг 5: Форматируем код
    print("Шаг 5: Форматирую код...")
    formatted_code = format_lua_code(code)
    
    # Сохраняем результат
    with open('sosiski3_clean.lua', 'w', encoding='utf-8') as f:
        f.write("-- Деобфусцированный Lua скрипт\n")
        f.write("-- Исходный файл: sosiski3\n")
        f.write("-- Тип: Roblox YBA чит скрипт\n\n")
        
        # Добавляем информацию о найденных строках
        if strings:
            f.write("-- Найденные строки:\n")
            for original, decoded in strings[:20]:  # Показываем первые 20
                if decoded != original and len(decoded) > 3:
                    f.write(f"-- Оригинал: {original}\n")
                    f.write(f"-- Декодировано: {decoded}\n")
            f.write("\n")
        
        f.write(formatted_code)
    
    print("Деобфускация завершена!")
    print("Результат сохранен в файл: sosiski3_clean.lua")
    
    # Показываем первые строки результата
    print("\nПервые строки деобфусцированного кода:")
    lines = formatted_code.split('\n')
    for i, line in enumerate(lines[:30]):
        print(f"{i+1:3d}: {line}")

if __name__ == "__main__":
    main()