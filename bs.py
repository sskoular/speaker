import re
from bs4 import BeautifulSoup
html_doc = open('10things.html', 'r')
soup = BeautifulSoup(html_doc.read())


# .stripped_strings
# print(soup.prettify())
html_text = "\n" + soup.get_text()
no_parens = re.sub(r'(\[[^]]*\])|(\([^)]*\))|(\{[^}]*\})','',html_text)
no_parens = re.sub(r'\t', ' ', no_parens)

#names = re.findall("\n[\s]*[A-Z][A-Z]+[\s]+\n[^\n]*",no_parens)
#counter = 0
#output={}
#for string in names:
#    output[re.findall("[A-Z][A-Z]+",string)[0]]= re.sub("[A-Z][A-Z]+","",string)
    

#for key in output:
    #print key, 'says', output[key]
#print re.findall("[A-Z]+",string)[0]


# second attempt

# first find all the names
long_names = re.findall("\n[\s]*[A-Z][A-Z]+[\s]*\n",no_parens)

names = []
dialogue_long = []
for long_name in long_names:
    names.append(re.findall("[A-Z]+",long_name)[0])
temp = no_parens

#re.split('[A-Z][A-Z]+',temp)

for name in names:
	#print name
	#print temp.find(name)
	index = temp.find(name)+len(name)
	temp = temp[index:]
	#print temp
	#print re.findall("[ \t\r\n]*.+",temp)[0]
	found = re.findall("^[ \t\r\n]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+\n?[\t\r ]*.+",temp)
	if found:
		dialogue_long.append(found[0])
	else:
		dialogue_long.append(" ")


dialog = []  
for dog in dialogue_long:
	temp = re.sub('^[ \t\r\n]+|[ \t\r\n]+$','',dog)
	dialog.append(re.sub('[ \t\r\n]+',' ',temp))

d = 0
for name in names:
	if d < len(dialog):
		print name.encode('utf-8'), '\t', dialog[d].encode('utf-8')
    	d = d + 1

