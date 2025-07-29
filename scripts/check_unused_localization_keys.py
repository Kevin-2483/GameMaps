import os
import json
import argparse

# 默认路径
DEFAULT_ARB_DIR = "lib/l10n"
DEFAULT_DART_DIR = "lib"

def load_arb_keys(arb_dir):
    keys = set()
    for filename in os.listdir(arb_dir):
        if filename.endswith(".arb"):
            path = os.path.join(arb_dir, filename)
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
                for key in data.keys():
                    if not key.startswith("@"):  # 排除注释
                        keys.add(key)
    return keys

def get_all_dart_files(dart_dir):
    dart_files = []
    for root, _, files in os.walk(dart_dir):
        for file in files:
            if file.endswith(".dart"):
                dart_files.append(os.path.join(root, file))
    return dart_files

def find_key_in_file_with_lines(key, filepath):
    lines = []
    with open(filepath, "r", encoding="utf-8") as f:
        for i, line in enumerate(f, 1):
            if key in line:
                lines.append(i)
    return lines

def main():
    parser = argparse.ArgumentParser(description="检查 Flutter 项目中未使用的本地化 key，并输出代码中 key 出现的行号")
    parser.add_argument("--arb_dir", default=DEFAULT_ARB_DIR, help="ARB 文件目录")
    parser.add_argument("--dart_dir", default=DEFAULT_DART_DIR, help="Dart 代码目录")
    parser.add_argument("--show_lines", action="store_true", help="显示代码中 key 出现的行号")
    args = parser.parse_args()

    print(f"加载本地化 key，从目录：{args.arb_dir} ...")
    keys = load_arb_keys(args.arb_dir)
    print(f"共找到 {len(keys)} 个本地化 key。")

    print(f"扫描 Dart 代码文件，从目录：{args.dart_dir} ...")
    dart_files = get_all_dart_files(args.dart_dir)
    print(f"共找到 {len(dart_files)} 个 Dart 文件。")

    unused_keys = []
    used_keys_info = {}

    for key in keys:
        used = False
        locations = []
        for file in dart_files:
            lines = find_key_in_file_with_lines(key, file)
            if lines:
                used = True
                if args.show_lines:
                    for line_no in lines:
                        locations.append((file, line_no))
        if used:
            if args.show_lines:
                used_keys_info[key] = locations
        else:
            unused_keys.append(key)

    print("\n—— 未被使用的本地化 key ——")
    if unused_keys:
        for k in unused_keys:
            print(k)
    else:
        print("没有发现未使用的 key，主人真厉害喵！")

    if args.show_lines:
        print("\n—— 已使用 key 及其出现位置 ——")
        for key, locs in used_keys_info.items():
            print(f"{key}:")
            for file, line_no in locs:
                print(f"  文件: {file} 行号: {line_no}")

if __name__ == "__main__":
    main()
