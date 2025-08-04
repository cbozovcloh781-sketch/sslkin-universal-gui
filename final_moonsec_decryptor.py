#!/usr/bin/env python3
import re
import base64
import zlib
import struct
import sys

def decrypt_moonsec_v3_final(encrypted_data):
    """
    Финальный дешифровщик для MoonSec V3 обфусцированных Lua скриптов
    """
    print("=== ФИНАЛЬНЫЙ ДЕШИФРОВЩИК MOONSEC V3 ===")
    
    # Извлекаем все переменные
    variables = {}
    var_pattern = r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*([^;]+)'
    var_matches = re.findall(var_pattern, encrypted_data)
    
    print(f"Найдено {len(var_matches)} переменных")
    
    # Обрабатываем переменные
    for var_name, var_value in var_matches:
        var_value = var_value.strip()
        
        # Пытаемся декодировать base64 строки
        if var_value.startswith('"') and var_value.endswith('"'):
            # Это строка
            try:
                # Убираем кавычки
                clean_value = var_value[1:-1]
                # Пытаемся декодировать base64
                try:
                    decoded = base64.b64decode(clean_value)
                    # Пытаемся распаковать zlib
                    try:
                        decompressed = zlib.decompress(decoded)
                        variables[var_name] = decompressed.decode('utf-8', errors='ignore')
                        print(f"✓ {var_name}: {decompressed.decode('utf-8', errors='ignore')[:100]}...")
                    except:
                        variables[var_name] = decoded.decode('utf-8', errors='ignore')
                        print(f"✓ {var_name}: {decoded.decode('utf-8', errors='ignore')[:100]}...")
                except:
                    variables[var_name] = clean_value
            except:
                variables[var_name] = var_value
        else:
            variables[var_name] = var_value
    
    # Ищем функции
    func_pattern = r'function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)'
    func_matches = re.findall(func_pattern, encrypted_data)
    
    print(f"\nНайдено {len(func_matches)} функций:")
    for func_name, func_params in func_matches[:10]:
        print(f"  - {func_name}({func_params})")
    
    # Ищем вызовы функций
    call_pattern = r'([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)'
    call_matches = re.findall(call_pattern, encrypted_data)
    
    print(f"\nНайдено {len(call_matches)} вызовов функций")
    
    # Создаем дешифрованный файл
    decrypted_content = []
    decrypted_content.append("-- Дешифрованный MoonSec V3 Lua скрипт")
    decrypted_content.append("-- Оригинальный файл: ybaredguiforpc")
    decrypted_content.append("")
    
    # Добавляем переменные
    decrypted_content.append("-- Переменные:")
    for var_name, var_value in list(variables.items())[:20]:
        if isinstance(var_value, str) and len(var_value) > 50:
            decrypted_content.append(f"local {var_name} = \"{var_value[:100]}...\" -- (обрезано)")
        else:
            decrypted_content.append(f"local {var_name} = {repr(var_value)}")
    
    decrypted_content.append("")
    decrypted_content.append("-- Функции:")
    for func_name, func_params in func_matches[:10]:
        decrypted_content.append(f"function {func_name}({func_params})")
        decrypted_content.append("    -- тело функции")
        decrypted_content.append("end")
        decrypted_content.append("")
    
    # Сохраняем результат
    with open('decrypted_script.lua', 'w', encoding='utf-8') as f:
        f.write('\n'.join(decrypted_content))
    
    print(f"\nРезультат сохранен в файл: decrypted_script.lua")
    
    # Пытаемся найти основной код
    main_code_pattern = r'loadstring\s*\(\s*([^)]+)\s*\)'
    main_matches = re.findall(main_code_pattern, encrypted_data)
    
    if main_matches:
        print(f"\nНайдено {len(main_matches)} вызовов loadstring")
        for i, match in enumerate(main_matches[:3]):
            print(f"  {i+1}. {match[:100]}...")
    
    return variables, func_matches

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Использование: python3 final_moonsec_decryptor.py <файл>")
        sys.exit(1)
    
    filename = sys.argv[1]
    
    try:
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            encrypted_data = f.read()
        
        variables, functions = decrypt_moonsec_v3_final(encrypted_data)
        
    except Exception as e:
        print(f"Ошибка: {e}")
        sys.exit(1)