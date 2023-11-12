# Define optional arguments
folder=$1
nlines=$2

# Default arguments
if [[ -z $folder ]]; then 
folder="."
fi

if [[ -z $nlines ]]; then 
nlines=0
fi

# Find all fa and fasta files in current folder and subfolders
fastafind=$(find $folder -type f -name "*.fa" -or -name "*.fasta")

# Count how many files
echo Number of files: $(echo $fastafind | wc -w)

# Count unique IDs in each fasta file
count=0
for fa in $fastafind; do 
grep ">" $fa | awk '{print $1}' | sed 's/>//' | sort | uniq | wc -l >> numID
done
# Sum all the counted IDs
awk '{n=n+$1} END {print "Unique fasta IDs: " n}' numID
# Remove the temporarily created file
rm numID

# File summary
for file in $fastafind; do

# HEADER
# Filename
echo == ${file##*/}
# Symlink or not
if [[ -h $file ]]; then 
echo Symlink
else echo Not a symlink
fi
# Number of sequences
echo Number of sequences: $(grep -c ">" $file)
# Total sequence length (aa or nt, without gaps, newlines and spaces)
echo Total sequence length: $(grep -v ">" $file | tr -d '\n' | sed 's/ //g; s/-//g' | wc -c)
# Nucleotide or amino acid sequence
if grep -v ">" $file | grep -q "[DEFGHIKLMPQRSVWY]"; then
echo Amino acid sequence
elif grep -v ">" $file | grep -qi "[AGCTN]"; then 
echo Nucleotide sequence
fi

# CONTENT
num_lines=$(wc -l < $file)
# Print full content if file lines are fewer than twice the number of lines asked
if [[ $num_lines -le $((2 * nlines)) ]]; then 
cat $file
elif [[ $nlines == 0 ]]; then 
continue
else 
head -n $nlines $file; echo ...; tail -n $nlines $file
fi
echo
done
