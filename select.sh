#!/bin/bash
##
## EPITECH PROJECT, 2020
## bdsh
## File description:
## select
##

match_regex() { 
    local str=$1 regex=$2 
    while [[ $str =~ $regex ]]; do 
        echo "${BASH_REMATCH[1]}"
        str=${str#*"${BASH_REMATCH[1]}"}
    done
}

get_maxlen() {
	maxlen=0
	while read line || [[ -n "$line" ]];
	do
		len=$(echo "${#line}")
		(( $len > $maxlen )) && maxlen=$len
    done < $row.txt
	return $maxlen
}
clean() {
	add_next=0
	nbr_line=0
	declare -a StringArray=(${var[$row]})
	for i in ${StringArray[@]}; do
		if [[ $add_next == 1 ]]; then
			tmp=$i
			[[ ${i: -1} == "," ]] && tmp=${tmp::-2} || tmp=${tmp::-1}
			echo " "$tmp
			((nbr_line++))
			add_next=0
		else
			tmp=${i:1}
			if [[ ${i: -1} != "\"" ]] && [[  ${i: -1} != ","  ]]; then
				echo -n $tmp
				add_next=1
			else
				[[ ${i: -1} == "," ]] && tmp=${tmp::-2} || tmp=${tmp::-1}
				echo $tmp
				((nbr_line++))
			fi
		fi
	done
	return $nbr_line
}

print_space() {
	len_word=0
	[[ $3 ]] && let "len_word=${#2}+${#3}+1" || len_word=${#2}
	for (( i=0; i<($1-$len_word+2); i+=1 )); do
		echo -n " "
	done
}

print_empty() {
	index=0
	for row in ${rows[@]}; do
		for (( i=0; i<${maxlen[$row]}+2; i+=1 )); do
			echo -n " "
		done
		((index++))
		[[ ${rows[$index]} ]] && echo -n "|"
	done
	echo ""
}

print_lines() {
	for (( i=0; i<$nbr_line; i+=1 )); do
		[[ ${tab[$i]} ]] && echo "${tab[$i]}" || print_empty ${maxlen[@]}
	done
}

get_lines() {
    while read line || [[ -n "$line" ]];
    	do
			if [[ $line != "EOF" ]]; then
				[[ ${tab[$index]} ]] && tab[$index]+="| "
				tab[$index]+=$line
        		tab[$index]+=$(print_space ${maxlen[$row]} $line)
				((index++))
			fi
    done < $row.txt
}

print_header_create_lines(){
    index_rows=0
	for row in ${rows[@]}; do
		index=0
		echo -n "$row"
		((index_rows++))
		[[ ${rows[$index_rows]} ]] && print_space ${maxlen[$row]} $row
		[[ ${rows[$index_rows]} ]] && echo -n "| "
		get_lines
		for (( index; index<$nbr_line; index+=1 )); do
			[[ ${tab[$index]} ]] && tab[$index]+="| "
			tab[$index]+=$(print_space ${maxlen[$row]} "")
		done
		rm $row.txt
	done
	echo ""
	for row in ${rows[@]}; do
		for (( i=0; i<${maxlen[$row]}+2; i+=1 )); do
			echo -n "-"
		done
		echo -n "-"
	done
	echo ""
}

select_fonction() {
	table=${todo[1]}
	declare -A var
	declare -A row
	declare -A maxlen
	declare -a tab
	IFS=',' read -ra rows <<< "${todo[2]}"
	for row in ${rows[@]}; do
		big_part=$(sed -n '/data_'$table'/,/\s*],/p' "$filename")
		regex='(\"'$row'\"[ ]{0,1}: \"[a-zA-Z0-9 ]*\"[,]*)'
		ret=$(match_regex "$big_part" "$regex")
		! [[ $ret ]] && error
		regex='\"'$row'\"[ ]{0,1}: (\"[a-zA-Z0-9 ]*\"[,]*)'
		var[$row]=$(match_regex "$ret" "$regex")
		var[$row]=$(clean "${var[$row]}")
		nbr_line=$(echo $?)
		echo "${var[${row[0]}]}" > $row.txt
		echo "EOF" >> $row.txt
		get_maxlen ${var[$row]}
		maxlen[$row]=$(echo $?)
	done
	print_header_create_lines
	if [[ ${todo[3]} == "order" ]]; then
		print_lines > tmp.txt
		sort tmp.txt > tmp2.txt
		cat tmp2.txt
		rm tmp.txt tmp2.txt
	else
		print_lines
	fi
}