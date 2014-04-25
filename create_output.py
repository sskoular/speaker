import sys
import fileinput

f = open("temp2.txt", 'r')
pred_states = f.read()
pred_states = pred_states.split(" ")

i = 0
for line in fileinput.input():
	sys.stdout.write(pred_states[i] + "\t" + line)
	i = i + 1