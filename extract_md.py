import re

file_path = '/Users/user/Documents/trae_projects/School Plant_副本7/.idea/论文.md'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Extract mermaid blocks
mermaid_blocks = re.findall(r'```mermaid(.*?)```', content, re.DOTALL)
print("=== Mermaid Flowcharts ===")
for i, block in enumerate(mermaid_blocks):
    print(f"--- Flowchart {i+1} ---")
    print(block.strip())
    print()

# Extract sections containing "流程" (flow/process)
lines = content.split('\n')
in_flow_section = False
print("=== Process Descriptions ===")
for line in lines:
    if line.startswith('#') and '流程' in line:
        in_flow_section = True
        print(line)
        continue
    elif line.startswith('#') and in_flow_section:
        in_flow_section = False
        
    if in_flow_section and line.strip():
        print(line)
