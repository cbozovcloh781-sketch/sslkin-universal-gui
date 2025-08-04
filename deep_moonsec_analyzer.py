#!/usr/bin/env python3
import re
import base64
import zlib
import struct
import sys

def deep_analyze_moonsec_v3(encrypted_data):
    """
    Глубокий анализ MoonSec V3 обфусцированных Lua скриптов
    """
    print("=== ГЛУБОКИЙ АНАЛИЗ MOONSEC V3 ===")
    
    # Извлекаем все переменные с их значениями
    variables = {}
    var_pattern = r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*([^;]+)'
    var_matches = re.findall(var_pattern, encrypted_data)
    
    print(f"Найдено {len(var_matches)} переменных")
    
    # Обрабатываем переменные
    decoded_vars = {}
    for var_name, var_value in var_matches:
        var_value = var_value.strip()
        
        # Пытаемся декодировать base64 строки
        if var_value.startswith('"') and var_value.endswith('"'):
            clean_value = var_value[1:-1]
            
            # Пытаемся декодировать base64
            try:
                decoded = base64.b64decode(clean_value)
                # Пытаемся распаковать zlib
                try:
                    decompressed = zlib.decompress(decoded)
                    decoded_vars[var_name] = decompressed.decode('utf-8', errors='ignore')
                    print(f"✓ {var_name}: {decompressed.decode('utf-8', errors='ignore')[:100]}...")
                except:
                    decoded_vars[var_name] = decoded.decode('utf-8', errors='ignore')
                    print(f"✓ {var_name}: {decoded.decode('utf-8', errors='ignore')[:100]}...")
            except:
                decoded_vars[var_name] = clean_value
        else:
            decoded_vars[var_name] = var_value
    
    # Ищем функции
    func_pattern = r'function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)'
    func_matches = re.findall(func_pattern, encrypted_data)
    
    print(f"\nНайдено {len(func_matches)} функций:")
    for func_name, func_params in func_matches:
        print(f"  - {func_name}({func_params})")
    
    # Ищем вызовы loadstring
    loadstring_pattern = r'loadstring\s*\(\s*([^)]+)\s*\)'
    loadstring_matches = re.findall(loadstring_pattern, encrypted_data)
    
    print(f"\nНайдено {len(loadstring_matches)} вызовов loadstring")
    
    # Ищем строки, которые могут содержать код
    string_pattern = r'"([^"]{50,})"'
    string_matches = re.findall(string_pattern, encrypted_data)
    
    print(f"\nНайдено {len(string_matches)} длинных строк")
    
    # Анализируем структуру кода
    code_structure = []
    
    # Ищем основные блоки кода
    block_pattern = r'([a-zA-Z_][a-zA-Z0-9_]*)\s*\(\s*([^)]*)\s*\)'
    block_matches = re.findall(block_pattern, encrypted_data)
    
    print(f"\nНайдено {len(block_matches)} блоков кода")
    
    # Создаем подробный отчет
    report = []
    report.append("=== ОТЧЕТ О ДЕШИФРОВКЕ MOONSEC V3 ===")
    report.append(f"Файл: ybaredguiforpc")
    report.append(f"Размер: {len(encrypted_data)} символов")
    report.append("")
    
    report.append("=== ДЕШИФРОВАННЫЕ ПЕРЕМЕННЫЕ ===")
    for var_name, var_value in list(decoded_vars.items())[:30]:
        if len(var_value) > 200:
            report.append(f"{var_name} = \"{var_value[:200]}...\"")
        else:
            report.append(f"{var_name} = \"{var_value}\"")
    
    report.append("")
    report.append("=== ФУНКЦИИ ===")
    for func_name, func_params in func_matches:
        report.append(f"function {func_name}({func_params})")
    
    report.append("")
    report.append("=== ВЫЗОВЫ LOADSTRING ===")
    for i, match in enumerate(loadstring_matches[:5]):
        report.append(f"{i+1}. {match[:100]}...")
    
    # Сохраняем отчет
    with open('moonsec_analysis_report.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(report))
    
    print(f"\nПодробный отчет сохранен в: moonsec_analysis_report.txt")
    
    # Пытаемся найти основной исполняемый код
    print("\n=== ПОИСК ОСНОВНОГО КОДА ===")
    
    # Ищем строки, которые могут содержать исполняемый код
    for i, string_match in enumerate(string_matches[:10]):
        if len(string_match) > 100:
            print(f"Строка {i+1}: {string_match[:100]}...")
            
            # Пытаемся декодировать как base64
            try:
                decoded = base64.b64decode(string_match)
                try:
                    decompressed = zlib.decompress(decoded)
                    print(f"  Декодировано: {decompressed.decode('utf-8', errors='ignore')[:100]}...")
                except:
                    print(f"  Base64 декодировано: {decoded.decode('utf-8', errors='ignore')[:100]}...")
            except:
                pass
    
    return decoded_vars, func_matches, loadstring_matches

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Использование: python3 deep_moonsec_analyzer.py <файл>")
        sys.exit(1)
    
    filename = sys.argv[1]
    
    try:
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            encrypted_data = f.read()
        
        variables, functions, loadstrings = deep_analyze_moonsec_v3(encrypted_data)
        
    except Exception as e:
        print(f"Ошибка: {e}")
        sys.exit(1)