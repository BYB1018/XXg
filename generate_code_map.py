# 生成树形结构并保存为 project_map.md
import os

def list_files(startpath):
    with open('project_map.md', 'w') as f:
        for root, dirs, files in os.walk(startpath):
            level = root.replace(startpath, '').count(os.sep)
            indent = ' ' * 4 * level
            f.write(f'{indent}{os.path.basename(root)}/\n')
            subindent = ' ' * 4 * (level + 1)
            for file in files:
                if file.endswith(('.py', '.js', '.ts')):
                    f.write(f'{subindent}{file}\n')

list_files('./')
