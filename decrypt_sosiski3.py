#!/usr/bin/env python3
import re
import base64

def decrypt_moonsec_obfuscated_code(obfuscated_code):
    """
    Попытка расшифровать MoonSec обфусцированный код
    """
    print("Начинаю расшифровку MoonSec обфусцированного кода...")
    
    # Удаляем заголовок MoonSec
    if "Protected_by_MoonSecV2" in obfuscated_code:
        print("Обнаружен MoonSec V2 защищенный код")
        
        # Извлекаем основную часть кода после заголовка
        lines = obfuscated_code.split('\n')
        main_code = []
        in_main_code = False
        
        for line in lines:
            if "local" in line and "function" in line:
                in_main_code = True
            if in_main_code:
                main_code.append(line)
        
        if main_code:
            print("Извлечена основная часть кода")
            return '\n'.join(main_code)
    
    # Попытка найти и декодировать base64 строки
    base64_pattern = r'[A-Za-z0-9+/]{20,}={0,2}'
    base64_matches = re.findall(base64_pattern, obfuscated_code)
    
    decoded_strings = []
    for match in base64_matches:
        try:
            decoded = base64.b64decode(match).decode('utf-8', errors='ignore')
            if len(decoded) > 10:  # Только значимые строки
                decoded_strings.append(f"Decoded: {decoded}")
        except:
            pass
    
    if decoded_strings:
        print("Найдены декодированные строки:")
        for s in decoded_strings:
            print(s)
    
    # Попытка извлечь переменные и функции
    variable_pattern = r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*='
    variables = re.findall(variable_pattern, obfuscated_code)
    
    function_pattern = r'function\s*\(([^)]*)\)'
    functions = re.findall(function_pattern, obfuscated_code)
    
    print(f"\nНайдено переменных: {len(variables)}")
    print(f"Найдено функций: {len(functions)}")
    
    return obfuscated_code

def analyze_lua_structure(code):
    """
    Анализ структуры Lua кода
    """
    print("\n=== АНАЛИЗ СТРУКТУРЫ LUA КОДА ===")
    
    # Поиск основных компонентов
    patterns = {
        'Services': r'game:GetService\("([^"]+)"\)',
        'Variables': r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=',
        'Functions': r'function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(',
        'Anonymous Functions': r'function\s*\(',
        'If Statements': r'if\s+',
        'For Loops': r'for\s+',
        'While Loops': r'while\s+',
        'String Literals': r'"([^"]*)"',
        'Number Literals': r'\b\d+\.?\d*\b',
        'Comments': r'--.*$',
    }
    
    for name, pattern in patterns.items():
        matches = re.findall(pattern, code, re.MULTILINE)
        if matches:
            print(f"{name}: {len(matches)} найдено")
            if len(matches) <= 5:  # Показываем только первые несколько
                for match in matches[:5]:
                    print(f"  - {match}")
    
    # Поиск специфичных для Roblox паттернов
    roblox_patterns = {
        'Players': r'Players\.',
        'RunService': r'RunService\.',
        'UserInputService': r'UserInputService\.',
        'TweenService': r'TweenService\.',
        'CoreGui': r'CoreGui\.',
        'Color3': r'Color3\.',
        'Vector3': r'Vector3\.',
        'CFrame': r'CFrame\.',
        'Instance': r'Instance\.',
    }
    
    print("\n=== ROBLOX СПЕЦИФИЧНЫЕ КОМПОНЕНТЫ ===")
    for name, pattern in roblox_patterns.items():
        matches = re.findall(pattern, code)
        if matches:
            print(f"{name}: {len(matches)} найдено")

def main():
    # Читаем файл sosiski3
    try:
        with open('sosiski3', 'r', encoding='utf-8', errors='ignore') as f:
            obfuscated_code = f.read()
    except FileNotFoundError:
        print("Файл sosiski3 не найден!")
        return
    except Exception as e:
        print(f"Ошибка при чтении файла: {e}")
        return
    
    print("=== РАСШИФРОВКА ФАЙЛА SOSISKI3 ===")
    print(f"Размер файла: {len(obfuscated_code)} символов")
    print(f"Количество строк: {len(obfuscated_code.split(chr(10)))}")
    
    # Анализируем структуру
    analyze_lua_structure(obfuscated_code)
    
    # Пытаемся расшифровать
    decrypted = decrypt_moonsec_obfuscated_code(obfuscated_code)
    
    # Сохраняем результат
    try:
        with open('sosiski3_decrypted.lua', 'w', encoding='utf-8') as f:
            f.write(decrypted)
        print("\nРезультат сохранен в файл sosiski3_decrypted.lua")
    except Exception as e:
        print(f"Ошибка при сохранении: {e}")
    
    # Показываем первые 500 символов расшифрованного кода
    print("\n=== ПРЕВЬЮ РАСШИФРОВАННОГО КОДА ===")
    print(decrypted[:500])
    if len(decrypted) > 500:
        print("...")

if __name__ == "__main__":
    main()