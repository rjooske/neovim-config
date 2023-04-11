TMP=$(mktemp)
jq -S '.words |= (map(ascii_downcase) | sort)' < cspell.json 1> $TMP || exit 1
cp $TMP cspell.json
