import nltk
import fileinput
from collections import Counter
import re
import setuptools

num_impt_words = 50

text = ""
data = []
for line in fileinput.input():
	#if len(line.split("\t")) != 2:
	#	print line.split("\t")
	text = text + line.split("\t")[1]
	#text = text + line
	data.append(line)

text_tokens = nltk.word_tokenize(text)
word_pos = nltk.pos_tag(text_tokens)

impt_words = []
wanted_tags = ['CD', 'FW', 'JJ', 'JJR', 'JJS', 'NN', 'NNS',
 'NNP', 'NNPS', 'PDT', 'RB', 'RBR', 'RBS', 'RP', 'UH',
  'VB', 'VBD', 'VBG', 'VBN', 'VBP', 'VBZ']

adj = ['JJ', 'JJR', 'JJS']
noun = ['NN', 'NNS', 'NNP', 'NNPS']
adv = ['RB', 'RBR', 'RBS']
verb = ['VB', 'VBD', 'VBG', 'VBN', 'VBP', 'VBZ']
excl = ['UH']

for item in word_pos:
	if item[1] in wanted_tags and len(item[0]) > 3:
		try:
			impt_words.append(re.findall(r'\w+', item[0].lower())[0])
		except:
			continue

word_counts = Counter(impt_words).most_common(num_impt_words)

speakers = []

for line in data:
	split_line = line.split("\t")
	#split_line = []
	#split_line.append("nothing")
	#split_line.append(line)

	if split_line[0] not in speakers:
		speakers.append(split_line[0])

	# speaker id
	output = str(speakers.index(split_line[0]))
	# word count
	output = output  + ',' + str(len(split_line[1].split()))

	tagged_sentence = nltk.pos_tag(nltk.word_tokenize(split_line[1]))
	num_adj = 0
	num_noun = 0
	num_verb = 0
	num_adv = 0
	num_excl = 0
	for tagged_word in tagged_sentence:
		if tagged_word[1] in adj:
			num_adj = num_adj + 1
		if tagged_word[1] in noun:
			num_noun = num_noun + 1
		if tagged_word[1] in verb:
			num_verb = num_verb + 1
		if tagged_word[1] in adv:
			num_adv = num_adv + 1
		if tagged_word[1] in excl:
			num_excl = num_excl + 1

	# parts of speech frequency (adj, noun, verb, adverb, and exclamation)
	output = output  + ',' + str(num_adj) + ',' + str(num_noun) + ',' + str(num_verb) + ','
	output = output + str(num_adv) + ',' + str(num_excl)

	# keyword frequency
	for word_count in word_counts:
		output = output + ',' + str(split_line[1].count(word_count[0]))

	# printing feature vector
	print output

