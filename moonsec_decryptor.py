#!/usr/bin/env python3
import re
import base64
import zlib
import struct

def decrypt_moonsec_v3(encrypted_data):
    """
    Дешифровщик для MoonSec V3 обфусцированных Lua скриптов
    """
    print("Анализируем MoonSec V3 файл...")
    
    # Удаляем заголовок MoonSec V3
    if "MoonSec V3" in encrypted_data:
        print("Найден заголовок MoonSec V3")
        # Ищем начало основного кода после заголовка
        start_pattern = r'\]\):gsub\(.+?\)'
        match = re.search(start_pattern, encrypted_data)
        if match:
            start_pos = match.end()
            encrypted_data = encrypted_data[start_pos:]
            print(f"Удален заголовок, начало кода с позиции {start_pos}")
    
    # Ищем закодированные строки в формате MoonSec V3
    # Обычно это base64 строки, закодированные в hex или другие форматы
    hex_pattern = r'0x[0-9a-fA-F]+'
    hex_matches = re.findall(hex_pattern, encrypted_data)
    
    print(f"Найдено {len(hex_matches)} hex значений")
    
    # Ищем строки в кавычках
    string_pattern = r'"([^"]*)"'
    string_matches = re.findall(string_pattern, encrypted_data)
    
    print(f"Найдено {len(string_matches)} строк в кавычках")
    
    # Ищем base64 строки
    base64_pattern = r'[A-Za-z0-9+/]{20,}={0,2}'
    base64_matches = re.findall(base64_pattern, encrypted_data)
    
    print(f"Найдено {len(base64_matches)} потенциальных base64 строк")
    
    # Попробуем декодировать base64 строки
    decoded_strings = []
    for i, b64_str in enumerate(base64_matches[:10]):  # Проверим первые 10
        try:
            decoded = base64.b64decode(b64_str)
            # Попробуем распаковать как zlib
            try:
                decompressed = zlib.decompress(decoded)
                decoded_strings.append(f"Base64 #{i}: {decompressed.decode('utf-8', errors='ignore')}")
            except:
                # Если не zlib, попробуем как обычную строку
                try:
                    decoded_strings.append(f"Base64 #{i}: {decoded.decode('utf-8', errors='ignore')}")
                except:
                    decoded_strings.append(f"Base64 #{i}: [binary data, length={len(decoded)}]")
        except Exception as e:
            print(f"Ошибка декодирования base64 #{i}: {e}")
    
    # Анализируем структуру кода
    print("\n=== АНАЛИЗ СТРУКТУРЫ КОДА ===")
    
    # Ищем функции и переменные
    function_pattern = r'function\s*\(([^)]*)\)'
    functions = re.findall(function_pattern, encrypted_data)
    print(f"Найдено {len(functions)} функций")
    
    # Ищем переменные
    var_pattern = r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)'
    variables = re.findall(var_pattern, encrypted_data)
    print(f"Найдено {len(variables)} локальных переменных")
    
    # Ищем числа
    number_pattern = r'\b\d+\b'
    numbers = re.findall(number_pattern, encrypted_data)
    print(f"Найдено {len(numbers)} числовых значений")
    
    return {
        'hex_values': hex_matches[:20],
        'strings': string_matches[:20],
        'base64_decoded': decoded_strings,
        'functions': functions,
        'variables': variables[:20],
        'numbers': numbers[:20]
    }

def main():
    import sys
    
    if len(sys.argv) != 2:
        print("Использование: python3 moonsec_decryptor.py <файл>")
        sys.exit(1)
    
    filename = sys.argv[1]
    
    try:
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        print(f"Загружен файл: {filename}")
        print(f"Размер: {len(content)} символов")
        
        result = decrypt_moonsec_v3(content)
        
        print("\n=== РЕЗУЛЬТАТЫ ДЕШИФРОВКИ ===")
        
        print("\n--- Hex значения ---")
        for i, hex_val in enumerate(result['hex_values']):
            print(f"{i+1}: {hex_val}")
        
        print("\n--- Строки ---")
        for i, string in enumerate(result['strings']):
            print(f"{i+1}: {string}")
        
        print("\n--- Декодированные base64 ---")
        for decoded in result['base64_decoded']:
            print(decoded)
        
        print("\n--- Функции ---")
        for i, func in enumerate(result['functions']):
            print(f"{i+1}: {func}")
        
        print("\n--- Переменные ---")
        for i, var in enumerate(result['variables']):
            print(f"{i+1}: {var}")
        
        print("\n--- Числа ---")
        for i, num in enumerate(result['numbers']):
            print(f"{i+1}: {num}")
            
    except Exception as e:
        print(f"Ошибка: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()