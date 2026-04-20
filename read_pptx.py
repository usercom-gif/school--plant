import zipfile
import xml.etree.ElementTree as ET
import sys

def extract_text_from_pptx(pptx_path):
    try:
        text_content = []
        with zipfile.ZipFile(pptx_path) as pptx:
            slide_files = [f for f in pptx.namelist() if f.startswith('ppt/slides/slide') and f.endswith('.xml')]
            slide_files.sort(key=lambda x: int(''.join(filter(str.isdigit, x))))
            
            for slide_file in slide_files:
                xml_content = pptx.read(slide_file)
                tree = ET.fromstring(xml_content)
                namespaces = {'a': 'http://schemas.openxmlformats.org/drawingml/2006/main'}
                
                slide_text = []
                for p in tree.findall('.//a:p', namespaces):
                    paragraph_text = ""
                    for t in p.findall('.//a:t', namespaces):
                        if t.text:
                            paragraph_text += t.text
                    if paragraph_text.strip():
                        slide_text.append(paragraph_text.strip())
                
                if slide_text:
                    text_content.append(f"--- Slide ---")
                    text_content.extend(slide_text)
                    text_content.append("")
                    
        return '\n'.join(text_content)
    except Exception as e:
        return f"Error extracting PPTX: {str(e)}"

if __name__ == '__main__':
    if len(sys.argv) > 1:
        print(extract_text_from_pptx(sys.argv[1]))
