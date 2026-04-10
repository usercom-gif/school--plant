import zipfile
import xml.etree.ElementTree as ET
import sys

def extract_text(docx_path):
    try:
        with zipfile.ZipFile(docx_path) as docx:
            xml_content = docx.read('word/document.xml')
        tree = ET.fromstring(xml_content)
        # The namespace used in docx xml
        namespaces = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        text = []
        for p in tree.findall('.//w:p', namespaces):
            paragraph_text = ""
            for t in p.findall('.//w:t', namespaces):
                if t.text:
                    paragraph_text += t.text
            text.append(paragraph_text)
        return '\n'.join(text)
    except Exception as e:
        return str(e)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        print(extract_text(sys.argv[1]))