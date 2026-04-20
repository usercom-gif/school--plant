import re

file_path = '/Users/user/Documents/trae_projects/School Plant_副本7/.idea/论文.md'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Extract headers to get an idea of the structure
headers = re.findall(r'^(#{1,3})\s+(.*)$', content, re.MULTILINE)
print("=== Document Structure ===")
for level, title in headers:
    print(f"{'  ' * (len(level)-1)}- {title}")

