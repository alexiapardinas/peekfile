input_file="$1"
lines="$2"
head -n $lines $input_file
echo ...
tail -n $lines $input_file
