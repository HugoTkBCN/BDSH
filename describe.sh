#!/bin/bash
##
## EPITECH PROJECT, 2020
## bdsh
## File description:
## describe
##

describe_function() {
	table=${todo[1]}
	big_part=$(sed -n '/desc_'$table'/,/\s*],/p' "$filename")
	echo "$big_part" > tmp.txt
	tail -n +2 "tmp.txt" > tmp2.txt
	head -n -1 tmp2.txt > tmp.txt
	rows=$(cat tmp.txt)
	rm tmp.txt tmp2.txt
	for i in $rows; do
		tmp=${i:1}
		tmp=${tmp::-1}
		[[ ${tmp: -1} == "," ]] && tmp=${tmp::-2} || tmp=${tmp::-1}
		echo $tmp
	done
}