#!/usr/bin/env python3
import re
import base64
import zlib
import struct

def decrypt_moonsec_v3_advanced(encrypted_data):
    """
    Продвинутый дешифровщик для MoonSec V3 обфусцированных Lua скриптов
    """
    print("=== ПРОДВИНУТЫЙ АНАЛИЗ MOONSEC V3 ===")
    
    # Извлекаем основные компоненты
    result = {
        'variables': {},
        'functions': [],
        'strings': [],
        'numbers': [],
        'hex_values': [],
        'decoded_parts': []
    }
    
    # Анализируем структуру переменных
    print("\n--- АНАЛИЗ ПЕРЕМЕННЫХ ---")
    var_pattern = r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*([^;]+)'
    var_matches = re.findall(var_pattern, encrypted_data)
    
    for var_name, var_value in var_matches[:10]:
        result['variables'][var_name] = var_value.strip()
        print(f"Переменная: {var_name} = {var_value.strip()}")
    
    # Ищем функции
    print("\n--- АНАЛИЗ ФУНКЦИЙ ---")
    func_pattern = r'function\s*\(([^)]*)\)\s*([^{]*)'
    func_matches = re.findall(func_pattern, encrypted_data)
    
    for i, (params, body) in enumerate(func_matches[:10]):
        result['functions'].append({'params': params, 'body': body})
        print(f"Функция #{i+1}: ({params}) -> {body[:100]}...")
    
    # Ищем строки в кавычках
    print("\n--- АНАЛИЗ СТРОК ---")
    string_pattern = r'"([^"]*)"'
    string_matches = re.findall(string_pattern, encrypted_data)
    
    for i, string in enumerate(string_matches[:20]):
        result['strings'].append(string)
        print(f"Строка #{i+1}: {string}")
    
    # Ищем hex значения
    print("\n--- АНАЛИЗ HEX ЗНАЧЕНИЙ ---")
    hex_pattern = r'0x[0-9a-fA-F]+'
    hex_matches = re.findall(hex_pattern, encrypted_data)
    
    for i, hex_val in enumerate(hex_matches[:20]):
        result['hex_values'].append(hex_val)
        try:
            int_val = int(hex_val, 16)
            char_val = chr(int_val) if 32 <= int_val <= 126 else f"[{int_val}]"
            print(f"Hex #{i+1}: {hex_val} = {int_val} = {char_val}")
        except:
            print(f"Hex #{i+1}: {hex_val}")
    
    # Ищем числа
    print("\n--- АНАЛИЗ ЧИСЕЛ ---")
    number_pattern = r'\b(\d+)\b'
    number_matches = re.findall(number_pattern, encrypted_data)
    
    for i, num in enumerate(number_matches[:20]):
        result['numbers'].append(int(num))
        print(f"Число #{i+1}: {num}")
    
    # Попробуем декодировать некоторые части
    print("\n--- ПОПЫТКА ДЕКОДИРОВАНИЯ ---")
    
    # Ищем потенциальные закодированные блоки
    encoded_pattern = r'[A-Za-z0-9+/]{20,}={0,2}'
    encoded_matches = re.findall(encoded_pattern, encrypted_data)
    
    for i, encoded in enumerate(encoded_matches[:5]):
        try:
            decoded = base64.b64decode(encoded)
            try:
                decompressed = zlib.decompress(decoded)
                result['decoded_parts'].append(f"Base64 #{i}: {decompressed.decode('utf-8', errors='ignore')}")
                print(f"Base64 #{i} (decompressed): {decompressed.decode('utf-8', errors='ignore')}")
            except:
                try:
                    result['decoded_parts'].append(f"Base64 #{i}: {decoded.decode('utf-8', errors='ignore')}")
                    print(f"Base64 #{i}: {decoded.decode('utf-8', errors='ignore')}")
                except:
                    result['decoded_parts'].append(f"Base64 #{i}: [binary data, length={len(decoded)}]")
                    print(f"Base64 #{i}: [binary data, length={len(decoded)}]")
        except Exception as e:
            print(f"Ошибка декодирования Base64 #{i}: {e}")
    
    # Анализируем структуру кода
    print("\n--- СТРУКТУРНЫЙ АНАЛИЗ ---")
    
    # Ищем циклы while
    while_pattern = r'while\s+([^d]+)do'
    while_matches = re.findall(while_pattern, encrypted_data)
    print(f"Найдено {len(while_matches)} циклов while")
    
    # Ищем условные операторы
    if_pattern = r'if\s+([^t]+)then'
    if_matches = re.findall(if_pattern, encrypted_data)
    print(f"Найдено {len(if_matches)} условных операторов if")
    
    # Ищем операторы return
    return_pattern = r'return\s*\(([^)]+)\)'
    return_matches = re.findall(return_pattern, encrypted_data)
    print(f"Найдено {len(return_matches)} операторов return")
    
    return result

def try_reverse_engineering(encrypted_data):
    """
    Попытка обратной инженерии кода
    """
    print("\n=== ПОПЫТКА ОБРАТНОЙ ИНЖЕНЕРИИ ===")
    
    # Ищем основные паттерны MoonSec V3
    patterns = {
        'gsub_pattern': r'gsub\([\'"]([^\'"]+)[\'"]([^\'"]*)[\'"]([^\'"]*)[\'"]\)',
        'string_concat': r'\.\.',
        'table_access': r'\[([^\]]+)\]',
        'function_call': r'([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)',
    }
    
    for pattern_name, pattern in patterns.items():
        matches = re.findall(pattern, encrypted_data)
        print(f"{pattern_name}: найдено {len(matches)} совпадений")
        if matches:
            print(f"Примеры: {matches[:3]}")
    
    # Попробуем извлечь логику
    print("\n--- ЛОГИЧЕСКИЙ АНАЛИЗ ---")
    
    # Ищем математические операции
    math_pattern = r'([0-9]+)\s*([+\-*/%])\s*([0-9]+)'
    math_matches = re.findall(math_pattern, encrypted_data)
    print(f"Математические операции: {len(math_matches)}")
    
    # Ищем битовые операции
    bit_pattern = r'([0-9]+)\s*([&|^])\s*([0-9]+)'
    bit_matches = re.findall(bit_pattern, encrypted_data)
    print(f"Битовые операции: {len(bit_matches)}")
    
    return patterns

def main():
    import sys
    
    if len(sys.argv) != 2:
        print("Использование: python3 advanced_moonsec_decryptor.py <файл>")
        sys.exit(1)
    
    filename = sys.argv[1]
    
    try:
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        print(f"Загружен файл: {filename}")
        print(f"Размер: {len(content)} символов")
        
        # Основной анализ
        result = decrypt_moonsec_v3_advanced(content)
        
        # Попытка обратной инженерии
        patterns = try_reverse_engineering(content)
        
        # Сохраняем результаты
        with open('decryption_results.txt', 'w', encoding='utf-8') as f:
            f.write("=== РЕЗУЛЬТАТЫ ДЕШИФРОВКИ MOONSEC V3 ===\n\n")
            
            f.write("--- ПЕРЕМЕННЫЕ ---\n")
            for var_name, var_value in result['variables'].items():
                f.write(f"{var_name} = {var_value}\n")
            
            f.write("\n--- ФУНКЦИИ ---\n")
            for i, func in enumerate(result['functions']):
                f.write(f"Функция #{i+1}: ({func['params']}) -> {func['body'][:200]}...\n")
            
            f.write("\n--- СТРОКИ ---\n")
            for i, string in enumerate(result['strings']):
                f.write(f"Строка #{i+1}: {string}\n")
            
            f.write("\n--- HEX ЗНАЧЕНИЯ ---\n")
            for i, hex_val in enumerate(result['hex_values']):
                f.write(f"Hex #{i+1}: {hex_val}\n")
            
            f.write("\n--- ДЕКОДИРОВАННЫЕ ЧАСТИ ---\n")
            for decoded in result['decoded_parts']:
                f.write(f"{decoded}\n")
        
        print(f"\nРезультаты сохранены в файл: decryption_results.txt")
        
    except Exception as e:
        print(f"Ошибка: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()