# MIDTERM ASSIGNMENT -> fastascan.sh script which takes two arguments: a directory and a number (lines you want to see from each file)

# Default or defined arguments
# Directory
if [[ -z $1 ]]; then 
folder="."
else
folder=$1
fi
# Number of lines
if [[ -z $2 ]]; then 
N=0
else
N=$2
fi

# Find all fa and fasta files/symlinks in current folder and subfolders (non hidden files)
fastafind=$(find $folder -name "*.fa" -not -path '*/.*' -or -name "*.fasta" -not -path '*/.*')

# RESULT SUMMARY
echo == RESULT SEARCH SUMMARY ==
# Count how many files
echo Number of files: $(echo $fastafind | wc -w)

# Count how many unique IDs
# Get the ID lines, isolate the IDs (taking into account if : before the ID) and count unique occurrences
awk '/>/{if(index($0,":")!=0) split ($1, A, /:/); else A[2]=$1; print A[2]}' $fastafind | sed 's/>//' | sort | uniq | wc -l > numID
# Sum all the counted IDs
echo Unique fasta IDs: $(cat numID)
# Remove the temporarily created file
rm numID

# FILE SUMMARY REPORT
echo ; echo == FILES SUMMARY REPORT ==
for file in $fastafind; do
# HEADER
# Filename without the relative path
filename=$(basename $file)
# Symlink or not
if [[ -h $file ]]; then 
symlink="Symlink"
else symlink="Not a symlink"
fi
# Number of sequences
numsequences=$(grep -c ">" $file)
# Total sequence length (aa or nt, without gaps, newlines and spaces)
sequence=$(awk '!/>/{gsub(/-/, "", $0); gsub(/ /, "", $0); print $0}' $file | tr -d '\n') 
seqlength=$(( $(echo $sequence | wc -c) - 1))
# Nucleotides or amino acid sequence
if echo "$sequence" | grep -qiE "[DEFHIKLMPQRSVWY]"; then
seqtype="Amino acid"
elif echo "$sequence" | grep -qiE "[ACTGN]"; then
seqtype="Nucleotide"
else
seqtype="Unknown"
fi

#Print header
echo  $filename "|" File type: $symlink "|" Number of sequences: $numsequences "|" Total sequence length: $seqlength "|" Sequence type: $seqtype

# CONTENT
num_lines=$(wc -l < $file)
# Print full content if file lines are fewer or equal than twice the number of lines asked
if [[ $num_lines -le $((2 * N)) ]]; then 
echo File content:
cat $file
echo
# Do not print anything if the number of lines asked is 0
elif [[ $N -eq 0 ]]; then
echo
continue
# Print the first and last lines if file lines are more than twice the number of lines asked
else 
echo File content:
head -n $N $file; echo ...; tail -n $N $file
echo
fi
done
