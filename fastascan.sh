# Definition of the optional arguments
folder=$1
nlines=$2

# Default arguments
if [[ -z $folder ]]; then folder="."; fi
if [[ -z $nlines ]]; then nlines=0; fi

# Find all fa and fasta files in current folder and subfolders
fastafind=$(find $folder -type f -name "*.fa" -or -name "*.fasta")

# Count how many files
echo $(echo $fastafind | wc -w)

# Count unique IDs
cat $fastafind

