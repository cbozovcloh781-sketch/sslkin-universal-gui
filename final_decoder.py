#!/usr/bin/env python3
import re
import base64

def evaluate_simple_math(expr):
    """Вычисляет простые математические выражения"""
    try:
        # Удаляем комментарии
        expr = re.sub(r'--.*$', '', expr)
        
        # Заменяем hex числа
        expr = re.sub(r'0x([0-9a-fA-F]+)', lambda m: str(int(m.group(1), 16)), expr)
        
        # Удаляем лишние пробелы
        expr = expr.strip()
        
        # Удаляем лишние скобки
        expr = re.sub(r'^\((.*)\)$', r'\1', expr)
        
        # Вычисляем
        result = eval(expr)
        return str(result)
    except:
        return expr

def simplify_all_expressions(code):
    """Упрощает все выражения в коде"""
    # Ищем все математические выражения
    lines = code.split('\n')
    simplified_lines = []
    
    for line in lines:
        # Ищем присваивания
        if '=' in line and 'local' in line:
            parts = line.split('=', 1)
            if len(parts) == 2:
                var_part = parts[0].strip()
                expr_part = parts[1].strip()
                
                # Упрощаем выражение
                simplified = expr_part
                
                # Удаляем сложные конструкции
                simplified = re.sub(r'\(function\(\)[^}]+end\)\(\)', '1', simplified)
                simplified = re.sub(r'#\{[^}]+\}', '0', simplified)
                simplified = re.sub(r'--\[\[[^\]]+\]\]', '', simplified)
                simplified = re.sub(r'--[^"]*"', '', simplified)
                
                # Вычисляем математику
                try:
                    result = evaluate_simple_math(simplified)
                    if result.isdigit() or ('.' in result and result.replace('.', '').isdigit()):
                        line = f"{var_part} = {result}"
                except:
                    pass
        
        simplified_lines.append(line)
    
    return '\n'.join(simplified_lines)

def clean_comments(code):
    """Очищает комментарии"""
    # Удаляем комментарии
    code = re.sub(r'--\[\[[^\]]+\]\]', '', code)
    code = re.sub(r'--[^\n]*', '', code)
    return code

def remove_obfuscated_parts(code):
    """Удаляет обфусцированные части"""
    # Удаляем сложные конструкции
    code = re.sub(r'\(function\(\)[^}]+end\)\(\)', '1', code)
    code = re.sub(r'#\{[^}]+\}', '0', code)
    code = re.sub(r'--\[\[[^\]]+\]\]', '', code)
    code = re.sub(r'--[^"]*"', '', code)
    
    # Удаляем сложные строки
    code = re.sub(r'"[^"]*\\[0-7]{3}[^"]*"', '""', code)
    code = re.sub(r'"[^"]*\\x[0-9a-fA-F]{2}[^"]*"', '""', code)
    
    return code

def format_clean_lua(code):
    """Форматирует очищенный Lua код"""
    # Удаляем лишние пробелы
    code = re.sub(r'\s+', ' ', code)
    
    # Добавляем переносы строк
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

def extract_main_function(code):
    """Извлекает основную функцию из кода"""
    # Ищем основную функцию
    main_pattern = r'function\s*\([^)]*\)\s*([^{]*)'
    match = re.search(main_pattern, code)
    
    if match:
        return match.group(0)
    return code

def main():
    print("Загружаю обфусцированный код...")
    
    with open('sosiski3', 'r', encoding='utf-8', errors='ignore') as f:
        obfuscated_code = f.read()
    
    print("Начинаю финальную деобфускацию...")
    
    # Извлекаем основную часть
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
    
    # Шаг 2: Очищаем комментарии
    print("Шаг 2: Очищаю комментарии...")
    code = clean_comments(code)
    
    # Шаг 3: Удаляем обфусцированные части
    print("Шаг 3: Удаляю обфусцированные части...")
    code = remove_obfuscated_parts(code)
    
    # Шаг 4: Упрощаем все выражения
    print("Шаг 4: Упрощаю все выражения...")
    code = simplify_all_expressions(code)
    
    # Шаг 5: Форматируем код
    print("Шаг 5: Форматирую код...")
    formatted_code = format_clean_lua(code)
    
    # Сохраняем результат
    with open('sosiski3_final.lua', 'w', encoding='utf-8') as f:
        f.write("-- Финально деобфусцированный Lua скрипт\n")
        f.write("-- Исходный файл: sosiski3\n")
        f.write("-- Тип: Roblox YBA чит скрипт\n")
        f.write("-- Статус: Максимально упрощен\n\n")
        
        f.write(formatted_code)
    
    print("Финальная деобфускация завершена!")
    print("Результат сохранен в файл: sosiski3_final.lua")
    
    # Показываем первые строки результата
    print("\nПервые строки финально деобфусцированного кода:")
    lines = formatted_code.split('\n')
    for i, line in enumerate(lines[:30]):
        if line.strip():
            print(f"{i+1:3d}: {line}")

if __name__ == "__main__":
    main()