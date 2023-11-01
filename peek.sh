input_file="$1"
lines="$2"
if [[ -z $lines ]]; then lines=3; fi

num_lines=$(wc -l < $input_file)

if [[ $num_lines -le $((2 * lines)) ]]; then echo Full file; cat $input_file
else head -n $lines $input_file; echo ...; tail -n $lines $input_file; fi
