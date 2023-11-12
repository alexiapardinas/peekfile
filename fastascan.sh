# Define optional arguments
folder=$1
nlines=$2

# Default arguments
if [[ -z $folder ]]; then folder="."; fi
if [[ -z $nlines ]]; then nlines=0; fi

# Find all fa and fasta files in current folder and subfolders
fastafind=$(find $folder -type f -name "*.fa" -or -name "*.fasta")

# Count how many files
echo $(echo $fastafind | wc -w)

# Count unique IDs in each fasta file
count=0
for fa in $fastafind; do 
grep ">" $fa | awk '{print $1}' | sed 's/>//' | sort | uniq | wc -l >> numID
done
# Sum all the counted IDs
awk '{n=n+$1} END {print n}' numID
# Remove the temporarily created file
rm numID

for file in $fastafind; do
echo == ${file##*/} # filename
if [[ -h $file ]]; then echo Symlink; else echo Not a symlink; fi # symlink or not
echo Number of sequences: $(grep -c ">" $file) # how many sequences
done
