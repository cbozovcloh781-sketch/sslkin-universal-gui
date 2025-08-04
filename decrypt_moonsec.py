#!/usr/bin/env python3
import re
import base64
import zlib
import struct

def decrypt_moonsec_v3(encrypted_data):
    """
    Дешифровщик для MoonSec V3 обфусцированных Lua скриптов
    """
    try:
        # Удаляем заголовок MoonSec V3
        if "MoonSec V3" in encrypted_data:
            # Извлекаем основную часть после заголовка
            start = encrypted_data.find("]]):gsub")
            if start != -1:
                encrypted_data = encrypted_data[start:]
        
        # Ищем закодированные строки
        # MoonSec V3 использует base64 + zlib сжатие
        base64_pattern = r'[A-Za-z0-9+/]{20,}={0,2}'
        matches = re.findall(base64_pattern, encrypted_data)
        
        decrypted_parts = []
        
        for match in matches:
            try:
                # Декодируем base64
                decoded = base64.b64decode(match)
                
                # Пытаемся распаковать zlib
                try:
                    decompressed = zlib.decompress(decoded)
                    decrypted_parts.append(decompressed.decode('utf-8', errors='ignore'))
                except:
                    # Если не zlib, пробуем как обычную строку
                    try:
                        decrypted_parts.append(decoded.decode('utf-8', errors='ignore'))
                    except:
                        continue
                        
            except Exception as e:
                continue
        
        # Ищем hex-encoded строки
        hex_pattern = r'\\x[0-9a-fA-F]{2}'
        hex_matches = re.findall(hex_pattern, encrypted_data)
        
        for match in hex_matches:
            try:
                # Декодируем hex
                hex_val = match[2:]  # Убираем \x
                char_val = chr(int(hex_val, 16))
                decrypted_parts.append(char_val)
            except:
                continue
        
        # Ищем числовые константы и пытаемся их декодировать
        number_pattern = r'0x[0-9a-fA-F]+'
        number_matches = re.findall(number_pattern, encrypted_data)
        
        for match in number_matches:
            try:
                num_val = int(match, 16)
                if 32 <= num_val <= 126:  # Печатаемые ASCII символы
                    decrypted_parts.append(chr(num_val))
            except:
                continue
        
        return '\n'.join(decrypted_parts)
        
    except Exception as e:
        return f"Ошибка дешифровки: {str(e)}"

def extract_strings(data):
    """
    Извлекает строки из обфусцированного кода
    """
    # Ищем строки в кавычках
    string_pattern = r'["\']([^"\']+)["\']'
    strings = re.findall(string_pattern, data)
    
    # Ищем hex-encoded строки
    hex_string_pattern = r'\\x([0-9a-fA-F]{2})'
    hex_strings = re.findall(hex_string_pattern, data)
    
    result = []
    result.extend(strings)
    
    for hex_str in hex_strings:
        try:
            char_val = chr(int(hex_str, 16))
            result.append(char_val)
        except:
            continue
    
    return result

def analyze_moonsec_file(filename):
    """
    Анализирует MoonSec V3 файл и пытается его дешифровать
    """
    try:
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        print(f"Анализ файла: {filename}")
        print("=" * 50)
        
        # Проверяем, является ли это MoonSec V3 файлом
        if "MoonSec V3" in content:
            print("✓ Обнаружен MoonSec V3 обфусцированный файл")
        else:
            print("⚠ Файл не содержит заголовок MoonSec V3")
        
        # Извлекаем строки
        strings = extract_strings(content)
        print(f"\nНайдено строк: {len(strings)}")
        
        # Показываем первые 20 строк
        print("\nПервые 20 строк:")
        for i, s in enumerate(strings[:20]):
            if len(s.strip()) > 0:
                print(f"{i+1:2d}: {s}")
        
        # Пытаемся дешифровать
        print("\n" + "=" * 50)
        print("Попытка дешифровки:")
        print("=" * 50)
        
        decrypted = decrypt_moonsec_v3(content)
        
        if decrypted and len(decrypted.strip()) > 0:
            print("✓ Удалось извлечь некоторые данные:")
            print("-" * 30)
            print(decrypted[:2000])  # Показываем первые 2000 символов
            
            if len(decrypted) > 2000:
                print(f"\n... (показано 2000 из {len(decrypted)} символов)")
        else:
            print("⚠ Не удалось дешифровать данные")
        
        # Сохраняем результат
        output_file = filename + ".decrypted"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(decrypted)
        
        print(f"\nРезультат сохранен в: {output_file}")
        
    except Exception as e:
        print(f"Ошибка при анализе файла: {str(e)}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        filename = sys.argv[1]
    else:
        filename = "ybaredguiforpc"
    
    analyze_moonsec_file(filename)