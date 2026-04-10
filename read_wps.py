import sys
import subprocess

def extract_text(file_path):
    try:
        # Using antiword which is built-in on macOS for parsing old .doc files
        result = subprocess.run(['textutil', '-convert', 'txt', '-stdout', file_path], capture_output=True, text=True)
        return result.stdout
    except Exception as e:
        return str(e)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        print(extract_text(sys.argv[1]))
