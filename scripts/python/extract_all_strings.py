import re
import collections
import yaml
from pathlib import Path
import os
import argparse

# -------------------------------------------------------------------
# 核心解析逻辑 (这部分无需改动)
# -------------------------------------------------------------------
def neutralize_comments(code: str) -> str:
    """通过将注释替换为空格来“中和”它们，以保留原始代码的行列索引。"""
    def multi_line_replacer(match):
        comment_text = match.group(0)
        return ''.join(char if char == '\n' else ' ' for char in comment_text)
    sanitized_code = re.sub(r'/\*.*?\*/', multi_line_replacer, code, flags=re.DOTALL)
    sanitized_code = re.sub(r'//.*', lambda m: ' ' * len(m.group(0)), sanitized_code)
    return sanitized_code

def find_dart_strings_robust(code: str) -> list[dict]:
    """健壮的、基于状态机解析的函数，用于查找 Dart 代码中的字符串。"""
    # (此函数与上一版完全相同)
    strings_found = []
    i = 0
    while i < len(code):
        char = code[i]
        is_raw = False
        if char == 'r' and i + 1 < len(code) and code[i+1] in ('"', "'"):
            is_raw = True
            i += 1
            char = code[i]
        if char in ('"', "'"):
            quote_type = char
            if code[i:i+3] == quote_type * 3:
                quote_type = quote_type * 3
                start_index = i - (1 if is_raw else 0)
                end_quote_pos = code.find(quote_type, i + len(quote_type))
                if end_quote_pos != -1:
                    content = code[i + len(quote_type):end_quote_pos]
                    if re.search(r'[\u4e00-\u9fa5]', content):
                        strings_found.append({'start': start_index, 'end': end_quote_pos + len(quote_type)})
                    i = end_quote_pos + len(quote_type)
                    continue
                else:
                    i += len(quote_type)
                    continue
            else:
                start_index = i - (1 if is_raw else 0)
                j = i + 1
                string_content_for_check = ""
                while j < len(code):
                    str_char = code[j]
                    if not is_raw and str_char == '\\':
                        string_content_for_check += code[j:j+2]
                        j += 2
                        continue
                    if str_char == '$' and j + 1 < len(code) and code[j+1] == '{':
                        interpolation_start = j
                        j += 2
                        brace_level = 1
                        while j < len(code):
                            if code[j] == '{': brace_level += 1
                            elif code[j] == '}': brace_level -= 1
                            if brace_level == 0: break
                            j += 1
                        string_content_for_check += code[interpolation_start:j+1]
                        j += 1
                        continue
                    if str_char == quote_type:
                        if re.search(r'[\u4e00-\u9fa5]', string_content_for_check):
                            strings_found.append({'start': start_index, 'end': j + 1})
                        i = j + 1
                        break
                    string_content_for_check += str_char
                    j += 1
                else:
                    i += 1
                continue
        i += 1
    return strings_found

def extract_strings_from_code(dart_code: str) -> list[dict]:
    """从单段代码中提取包含中文字符串的完整语句。"""
    sanitized_code = neutralize_comments(dart_code)
    string_locations = find_dart_strings_robust(sanitized_code)
    bracket_pairs = {'(': ')', '[': ']', '{': '}'}
    open_brackets = bracket_pairs.keys()
    close_brackets = bracket_pairs.values()
    extracted_results = []
    found_boundaries = set()
    for loc in string_locations:
        left_bracket_pos = -1
        stack = collections.deque()
        for i in range(loc['start'] - 1, -1, -1):
            char = sanitized_code[i]
            if char in close_brackets:
                stack.append(char)
            elif char in open_brackets:
                if not stack:
                    left_bracket_pos = i
                    break
                elif bracket_pairs[char] == stack[-1]: stack.pop()
                else: break
        if left_bracket_pos == -1: continue
        right_bracket_pos = -1
        stack = collections.deque([sanitized_code[left_bracket_pos]])
        for i in range(left_bracket_pos + 1, len(sanitized_code)):
            char = sanitized_code[i]
            if char in open_brackets: stack.append(char)
            elif char in close_brackets:
                if stack and bracket_pairs.get(stack[-1]) == char:
                    stack.pop()
                    if not stack:
                        right_bracket_pos = i
                        break
        if right_bracket_pos != -1:
            statement_start = sanitized_code.rfind('\n', 0, left_bracket_pos) + 1
            statement_end = sanitized_code.find('\n', right_bracket_pos)
            if statement_end == -1:
                statement_end = len(sanitized_code)
            if (statement_start, statement_end) in found_boundaries: continue
            found_boundaries.add((statement_start, statement_end))
            snippet = dart_code[statement_start:statement_end]
            extracted_results.append({
                "code": snippet,
                "start_index": statement_start,
                "end_index": statement_end
            })
    return sorted(extracted_results, key=lambda x: x['start_index'])

# -------------------------------------------------------------------
# 批量文件处理和YAML生成逻辑 (*** 已修改 ***)
# -------------------------------------------------------------------

def process_directory(root_dir: str, exclude_paths: list[str], output_dir: str):
    """
    主函数: 遍历目录，为每个提取的代码段在输出目录中生成一个独立的YAML文件。
    """
    root_path = Path(root_dir).resolve()
    exclude_paths_resolved = [Path(p).resolve() for p in exclude_paths]
    output_path = Path(output_dir).resolve()

    # 创建输出目录
    output_path.mkdir(parents=True, exist_ok=True)
    
    total_snippets_found = 0
    
    print(f"[*] 开始扫描目录: {root_path}")
    print(f"[*] 将排除以下路径: {exclude_paths}")
    print(f"[*] 提取结果将保存到目录: {output_path}")

    dart_files = list(root_path.rglob('*.dart'))
    print(f"[*] 共找到 {len(dart_files)} 个 .dart 文件。")

    for file_path in dart_files:
        is_excluded = any(file_path.is_relative_to(p) for p in exclude_paths_resolved)
        if is_excluded:
            continue
            
        try:
            content = file_path.read_text(encoding='utf-8')
            extracted_results = extract_strings_from_code(content)
            
            for result in extracted_results:
                total_snippets_found += 1
                start_line = content[:result['start_index']].count('\n') + 1
                end_line = content[:result['end_index']].count('\n') + 1
                
                # 创建独立的YAML文件
                record_data = {
                    'path': str(file_path.relative_to(root_path)).replace('\\', '/'),
                    'start_line': start_line,
                    'end_line': end_line,
                    'code': result['code'].strip()
                }

                # 生成智能文件名
                original_file_stem = file_path.stem
                output_filename = f"{original_file_stem}_{start_line}_{end_line}.yaml"
                record_file_path = output_path / output_filename
                
                # 写入该文件
                with open(record_file_path, 'w', encoding='utf-8') as f:
                    yaml.dump(record_data, f, allow_unicode=True, sort_keys=False, indent=2)

        except Exception as e:
            print(f"  ! 处理文件时出错 {file_path}: {e}")
            
    if total_snippets_found == 0:
        print("[*] 未找到任何包含中文字符串的代码段。")
    else:
        print(f"\n[*] 提取完成！共找到并生成了 {total_snippets_found} 个记录文件。")
        print(f"[*] 请在以下目录中查看结果: {output_path}")

# -------------------------------------------------------------------
# 脚本入口和配置 (*** 已修改 ***)
# -------------------------------------------------------------------
if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='从Dart项目中提取包含中文字符串的代码段，并将每个记录保存为独立的YAML文件。',
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument(
        'target_dir',
        nargs='?',
        default='.',
        help='要扫描的Flutter或Dart项目的根目录。\n(默认: 当前目录)'
    )
    
    # 将 --output 参数修改为 --directory
    parser.add_argument(
        '-d', '--directory',
        default='extracted_strings',
        help='用于存放提取结果的输出目录名。\n(默认: extracted_strings)'
    )
    
    parser.add_argument(
        '-e', '--exclude',
        action='append',
        default=['lib/l10n', 'build', '.dart_tool', '.idea'],
        help='需要排除的子目录路径。\n可以多次使用此参数来指定多个路径。\n(默认排除: lib/l10n, build, .dart_tool, .idea)'
    )

    args = parser.parse_args()

    target_abs = Path(args.target_dir).resolve()
    exclude_abs = [Path(args.target_dir).joinpath(p).resolve() for p in args.exclude]
    
    # 输出目录是相对于当前工作目录的
    output_dir_abs = Path(args.directory).resolve()

    process_directory(
        root_dir=str(target_abs), 
        exclude_paths=[str(p) for p in exclude_abs], 
        # 传递的是输出目录
        output_dir=str(output_dir_abs)
    )