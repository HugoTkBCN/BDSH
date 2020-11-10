#!/bin/bash
##
## EPITECH PROJECT, 2020
## bdsh
## File description:
## error handling
##

error() {
    echo -e $"Error: $*\nRun ./bdsh -h" >>/dev/stderr
    exit 1
}

check_file() {
	if [[ $filename_changed == 0 ]]; then
		(( filename_changed++ ))
    	filename=${arguments[$nbr_arg]}
		if ! [[ -f $filename ]] || [[ -z $filename ]]; then
        	[[ -z $filename ]] && error || error "File $filename doesn't exist."
    	fi
		(( swipe++ ))
	else
		error "Option -f used more than once."
	fi
}

check_arg_j() {
	if [[ $print_json ==  0 ]]; then
    	(( print_json++ ))
	else
		error "Option -j used more than once."
	fi
}

get_filename_env_config_file() {
	if [[ -z "$filename" ]]; then
		if [[ $(echo $BDSH_FILE ) ]]; then
			filename=$(echo $BDSH_FILE)
		else 
			[[ -f .bdshrc ]] && content=$(cat .bdshrc) || error
			filename=${content#*=}
			! [[ -f $filename ]] && error "File $filename doesn't exist."
		fi
	fi
	[[ -z "$filename" ]] && error "No Filename specified."
}

get_arg_create() {
	if [[ ${arguments[$nbr_arg]} == "database" ]]; then
		action="CREATE/DATABASE"
	elif [[ ${arguments[$nbr_arg]} == "table" ]]; then
		action="CREATE/TABLE"
		((nbr_arg++))
		[[ ${arguments[$nbr_arg]} ]] && action+=/"${arguments[$nbr_arg]}" || error
		((nbr_arg++))
		[[ ${arguments[$nbr_arg]} ]] && action+=/"${arguments[$nbr_arg]}" || error
		((nbr_arg++))
		[[ ${arguments[$nbr_arg]} ]] && error
	else
		error
	fi
}

get_arg_insert() {
	action="INSERT"
	[[ ${arguments[$nbr_arg]} ]] && action+=/"${arguments[$nbr_arg]}" || error
	todo_add=2
	while [[ ${arguments[$nbr_arg]: -1} == '\' || $todo_add != 0 ]]; do 
		((nbr_arg++))
		[[ $todo_add == 2 ]] && action+=/ || action+=' '
		[[ ${arguments[$nbr_arg]: -1} == '\' ]] && action+="${arguments[$nbr_arg]::-1}" || action+="${arguments[$nbr_arg]}"
		((todo_add--))
	done
	((nbr_arg++))
	[[ ${arguments[$nbr_arg]} ]] && error
}

get_arg_describe() {
	action="DESCRIBE"
	[[ ${arguments[$nbr_arg]} ]] && action+=/"${arguments[$nbr_arg]}" || error
	((nbr_arg++))
	[[ ${arguments[$nbr_arg]} ]] && error
}

get_arg_select() {
	action="SELECT"
	[[ ${arguments[$nbr_arg]} ]] && action+=/"${arguments[$nbr_arg]}" || error
	((nbr_arg++))
	[[ ${arguments[$nbr_arg]} ]] && action+=/"${arguments[$nbr_arg]}" || error
	((nbr_arg++))
	if [[ ${arguments[$nbr_arg]} ]]; then
		[[ ${arguments[$nbr_arg]} == 'order' ]] && action+=/"${arguments[$nbr_arg]}" || error
	fi
	((nbr_arg++))
	[[ ${arguments[$nbr_arg]} ]] && error
}

main_error_handling_get_arg() {
    if [[ ${#@} == 0 ]]; then
		print_help
	fi
	arguments=($@)
    for arg in $@; do
		((nbr_arg++))
		if [[ $swipe != 0 ]]; then
			(( swipe-- ))
		else
        	case $arg in
        	-h)
				(( ${#@} > 1 )) && error || print_help
            	;;
        	-f)
				check_file
            	;;
        	-j)
				check_arg_j
				;;
			-jf | -fj)
				check_arg_j
				check_file
				;;
			create)
				get_arg_create $arguments $nbr_arg
				break
				;;
			insert)
				get_arg_insert $arguments $nbr_arg
				break
				;;
			describe)
				get_arg_describe $arguments $nbr_arg
				break
				;;
			select)
				get_arg_select $arguments $nbr_arg
				break
				;;
			*)
				error "Bad argument. ($arg)"
        	esac
		fi
    done
	get_filename_env_config_file
}