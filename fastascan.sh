# Define optional arguments
folder=$1
N=$2

# Default arguments
if [[ -z $folder ]]; then 
folder="."
fi

if [[ -z $N ]]; then 
nlines=0
fi

# Find all fa and fasta files in current folder and subfolders
fastafind=$(find $folder -type f -name "*.fa" -or -name "*.fasta")

# Count how many files
echo Number of files: $(echo $fastafind | wc -w)

# Count unique IDs in each fasta file
for fa in $fastafind; do 
# Get the ID lines, isolate the IDs (taking into account if : before the ID) and count unique occurrences
awk '/>/{if(index($0,":")!=0) split ($1, A, /:/); else A[2]=$1; print A[2]}' $fa | sed 's/>//' | sort | uniq | wc -l >> numID
done
# Sum all the counted IDs
awk '{n=n+$1} END {print "Unique fasta IDs: " n}' numID
# Remove the temporarily created file
rm numID

# File summary
for file in $fastafind; do

# HEADER
# Filename (without the relative path)
echo == $(echo $file | grep -oE '[^/]+$')
# Symlink or not
if [[ -h $file ]]; then 
echo Symlink
else echo Not a symlink
fi
# Number of sequences
echo Number of sequences: $(grep -c ">" $file)
# Total sequence length (aa or nt, without gaps, newlines and spaces)
sequence=$(awk '!/>/{gsub(/-/, "", $0); gsub(/ /, "", $0); print $0}' $file | tr -d '\n') 
echo Total sequence length: $(( $(echo $sequence | wc -c) - 1))
# Nucleotides or amino acid sequence
if grep -qE "[RDQEHILKMFPSWYV]*" <<< "$sequence"; then
echo Amino acid sequence
elif grep -qE "[ACTGNactgn]*" <<< "$sequence"; then
echo Nucleotide sequence
else
echo Unknown sequence type
fi

# CONTENT
num_lines=$(wc -l < $file)
# Print full content if file lines are fewer than twice the number of lines asked
if [[ $num_lines -le $((2 * N)) ]]; then 
cat $file
elif [[ $N == 0 ]]; then
continue
else 
head -n $N $file; echo ...; tail -n $N $file
fi
echo
done
