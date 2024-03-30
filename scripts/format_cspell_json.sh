tmp=$(mktemp)
jq -S '.words |= (map(ascii_downcase) | unique)' < cspell.json 1> $tmp || exit 1
cp $tmp cspell.json
