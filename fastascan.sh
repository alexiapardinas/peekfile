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

# Find all fa and fasta files/symlinks in current folder and subfolders
fastafind=$(find $folder -type f,l -name "*.fa" -or -type f,l -name "*.fasta")

# RESULT SUMMARY
echo == RESULT SEARCH SUMMARY ==
# Count how many files
echo Number of files: $(echo $fastafind | wc -w)

# Count how many unique IDs: get the ID lines, isolate the IDs and count unique occurrences
echo Unique fasta IDs: $(awk '/>/{print $1}' $fastafind | sed 's/>//' | sort | uniq | wc -l | cat)

# FILE SUMMARY REPORT
echo ; echo == FILES SUMMARY REPORT ==
for file in $fastafind; do

# Do not iterate in non readable files (permission denied)
if [[ ! -r $file ]]; then
echo  "=>" $file "|" WARNING: permission to read denied; echo
continue
fi

# HEADER
# Symlink or not
if [[ -h $file ]]; then symlink="Symlink"
else symlink="File"
fi
# Do not try to read binary files (such as hidden files)
if ! grep -q ">" $file; then
echo "=>" $file "|" File type: $symlink "|" WARNING: it is a binary file; echo
continue
fi

# Number of sequences
numsequences=$(grep -c ">" $file)
# Total sequence length (aa or nt, without gaps, newlines and spaces)
sequence=$(awk '!/>/{gsub(/-/, "", $0); gsub(/ /, "", $0); print $0}' $file | tr -d '\n') 
seqlength=$(( $(echo $sequence | wc -m) - 1)) # Substraction of the last newline character
# Nucleotides (DNA or RNA) or amino acid sequence
if echo "$sequence" | grep -qi "[^ACTGUN]"; then
seqtype="Amino acid"
else
seqtype="Nucleotide"
fi

# Print header
echo "=>" $file "|" File type: $symlink "|" Number of sequences: $numsequences "|" Sequence length: $seqlength "|" Sequence type: $seqtype

# CONTENT
num_lines=$(wc -l < $file)
# Print full content if file lines are fewer or equal than twice the number of lines asked
if [[ $num_lines -le $((2 * N)) ]]; then 
echo File content:
cat $file; echo
# Do not print anything if the number of lines asked is 0
elif [[ $N -eq 0 ]]; then echo
continue
# Print the first and last lines if file lines are more than twice the number of lines asked
else 
echo File content:
head -n $N $file; echo ...; tail -n $N $file; echo
fi
done
