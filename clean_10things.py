import re
from bs4 import BeautifulSoup
html_doc = open('americanbeauty.txt', 'r')
#soup = BeautifulSoup(html_doc.read())

#html_text = "\n" + soup.get_text()
html_text='\n'+html_doc.read()
temp = re.sub(r'\t', ' ', html_text)
temp = re.sub(r'(<[^>]*>)','',temp)
temp = re.sub(r'\(O\.C\.\)','',temp)
temp = re.sub(r'\(cont\'d\)','',temp)

long_names = re.findall("\n[\s]*[A-Z\-\.//']+\s?[A-Z]+[\s]*\n",temp)

names = []
for long_name in long_names:
    names.append(re.findall("[A-Z\-\.//']+\s?[A-Z]+",long_name)[0])
chunks = re.split('[ \t\r]*\n[ \t\r]*\n[ \t\r]*',temp)
del(names[-1])

n=0
dialog = []
for chunk in chunks:
	if n < len(names):
		found = re.findall("^"+names[n],chunk)
		if found:
			dialog.append(re.sub('[ ]+',' ',re.sub(r'(\[[^]]*\])|(\([^)]*\))|(\{[^}]*\})|(<[^>]*>)','',re.sub('[\n\t\r]+',' ',re.sub(names[n],'',chunk)))))
			n = n + 1
d = 0
for name in names:
	if d < len(dialog):
		print name.encode('utf-8'), '\t', dialog[d].encode('utf-8')
		d = d + 1

