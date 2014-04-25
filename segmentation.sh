suffix_temp="_temp.csv"
suffix="_output.tsv"
for i in *rucible_input.tsv; do 
	j=`echo $i| cut -d'_' -f 1`
	python feature_extraction.py < $i > $j$suffix_temp
	Rscript examine_vectors.R $j$suffix_temp
	python create_output.py < $i > $j$suffix
	#Rscript test.R 4 > $j$suffix
	echo "DONE WITH ONE!"
	echo $j
done

rm -f *_temp.csv
rm -f temp2.txt