#!/usr/bin/env python3
import re
import base64
import zlib
import struct
import sys

def extract_main_code(encrypted_data):
    """
    Извлекает основной исполняемый код из MoonSec V3 обфусцированного файла
    """
    print("=== ИЗВЛЕЧЕНИЕ ОСНОВНОГО КОДА MOONSEC V3 ===")
    
    # Ищем все длинные строки, которые могут содержать код
    string_pattern = r'"([^"]{100,})"'
    string_matches = re.findall(string_pattern, encrypted_data)
    
    print(f"Найдено {len(string_matches)} длинных строк")
    
    extracted_code = []
    
    for i, string_match in enumerate(string_matches):
        print(f"\n--- Анализ строки {i+1} ---")
        print(f"Длина: {len(string_match)} символов")
        print(f"Начало: {string_match[:100]}...")
        
        # Пытаемся декодировать как base64
        try:
            decoded = base64.b64decode(string_match)
            print(f"✓ Base64 декодировано успешно")
            
            # Пытаемся распаковать zlib
            try:
                decompressed = zlib.decompress(decoded)
                print(f"✓ Zlib распаковано успешно")
                print(f"Декодированный код: {decompressed.decode('utf-8', errors='ignore')[:200]}...")
                
                extracted_code.append({
                    'index': i+1,
                    'original': string_match[:100] + "...",
                    'decoded': decompressed.decode('utf-8', errors='ignore')
                })
                
            except Exception as e:
                print(f"✗ Zlib распаковка не удалась: {e}")
                # Сохраняем base64 декодированный результат
                decoded_text = decoded.decode('utf-8', errors='ignore')
                print(f"Base64 результат: {decoded_text[:200]}...")
                
                extracted_code.append({
                    'index': i+1,
                    'original': string_match[:100] + "...",
                    'decoded': decoded_text
                })
                
        except Exception as e:
            print(f"✗ Base64 декодирование не удалось: {e}")
            
            # Пытаемся найти Lua код в строке
            if 'function' in string_match or 'local' in string_match or 'end' in string_match:
                print(f"✓ Найден возможный Lua код")
                extracted_code.append({
                    'index': i+1,
                    'original': string_match[:100] + "...",
                    'decoded': string_match
                })
    
    # Создаем финальный файл с извлеченным кодом
    final_code = []
    final_code.append("-- ИЗВЛЕЧЕННЫЙ КОД ИЗ MOONSEC V3")
    final_code.append("-- Файл: ybaredguiforpc")
    final_code.append("-- Автоматически извлечено")
    final_code.append("")
    
    for i, code_block in enumerate(extracted_code):
        final_code.append(f"-- БЛОК КОДА {code_block['index']}")
        final_code.append(f"-- Оригинал: {code_block['original']}")
        final_code.append("")
        final_code.append(code_block['decoded'])
        final_code.append("")
        final_code.append("--" + "="*50)
        final_code.append("")
    
    # Сохраняем результат
    with open('extracted_main_code.lua', 'w', encoding='utf-8') as f:
        f.write('\n'.join(final_code))
    
    print(f"\n=== РЕЗУЛЬТАТ ===")
    print(f"Извлечено {len(extracted_code)} блоков кода")
    print(f"Результат сохранен в: extracted_main_code.lua")
    
    # Также создаем краткий отчет
    summary = []
    summary.append("=== КРАТКИЙ ОТЧЕТ О ДЕШИФРОВКЕ ===")
    summary.append(f"Файл: ybaredguiforpc")
    summary.append(f"Размер: {len(encrypted_data)} символов")
    summary.append(f"Извлечено блоков кода: {len(extracted_code)}")
    summary.append("")
    
    for i, code_block in enumerate(extracted_code):
        summary.append(f"Блок {i+1}: {len(code_block['decoded'])} символов")
        summary.append(f"  Начало: {code_block['decoded'][:100]}...")
        summary.append("")
    
    with open('decryption_summary.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(summary))
    
    print(f"Краткий отчет сохранен в: decryption_summary.txt")
    
    return extracted_code

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Использование: python3 final_moonsec_extractor.py <файл>")
        sys.exit(1)
    
    filename = sys.argv[1]
    
    try:
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            encrypted_data = f.read()
        
        extracted_code = extract_main_code(encrypted_data)
        
    except Exception as e:
        print(f"Ошибка: {e}")
        sys.exit(1)