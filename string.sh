#!/bin/bash

Len(){

	 : 'BEGIN COMMENT
	 """
			Returns the length of a passed string
			Args: one string
			Local vars: str
			Global vars: set_val, err, err_msg
			Exit codes:
				0: SUCCESS
				1: GENERIC FAILURE
				2: FAILURE (wrong usage)
	"""
	END COMMENT'


	reset_global_vars

	if [[ -z "${1+x}" ]];then
	  err=2
	  err_msg="Len: no input provided"
	  return $err
	fi
	if ! command -v wc >/dev/null 2>&1; then
	   err_msg="Len - 'wc' : command not found"
	   err=127
	   return $err
	fi

	local str="${1}"

	  #Notes:
	  #a NULL character is not counted
	  #in case of UNICODE character
	  #the number of characters are returned
	  #NOT the number of bytes

	  set_val=$(echo -n "${str}"|wc -m)
	  if [[ $? -ne 0 ]]; then
		set_val=""
		err=1
		err_msg="Len: an error has occured."
	  fi

	return $err

}

Trim(){

	: 'BEGIN COMMENT
	"""
				Removes any whitespace at the end and at the beginning of a string
				Args: one string
				Local vars: str
				Global vars: set_val,err,err_msg
				Exit codes:
						0: SUCCESS
						1: GENERIC FAILURE
						2: FAILURE (wrong usage)
	"""
	END COMMENT'
	
	reset_global_vars

	if [[ -z "${1+x}" ]]; then
		err=2
		err_msg="Trim: no input provided"
		return $err
	fi

	local str="${1}"
	
	set_val=$(echo "${str}"|xargs)
	if [[ $? -ne 0 ]]; then
		set_val=""
		err=1
		err_msg="Trim: an error has occured"
	fi

	return $err

}

RTrim(){

	  : 'BEGIN COMMENT
	   """
					  Removes any whitespace at the end of a string
					  Args: one string
					  Local vars: str
					  Global vars: set_val,err,err_msg
					  Exit codes:
							  0: SUCCESS
							  1: GENERIC FAILURE
							  2: FAILURE (wrong usage)

	  """
	  COMMENT'
	  
	  reset_global_vars
	  
	  if [[ -z "${1+x}" ]];then
		err=2
		err_msg="RTrim: no input provided"
		return $err
	  fi

	local str="${1}"


		set_val="${str%%*()}"
		if [[ $? -ne 0 ]]; then
			  err_msg="RTrim: an error has occured"
			err=1
		fi

		return $err

}


LTrim(){

		: 'BEGIN COMMENT
		 """
						Removes any whitespace at the beginning of a string
						Argument: one string
						Local var.: str
						Global var.: set_val,err,err_msg
						Exit codes:
								0: SUCCESS
								1: GENERIC FAILURE
								2: FAILURE (wrong usage)
		"""
		COMMENT'
		
		reset_global_vars
		
		if [[ -z "${1+x}" ]];then
		  err=2
		  err_msg="LTrim: no input provided"
		  return $err
		fi
		local str="${1}"
		

		set_val="${str##*()}"
		if [[ $? -ne 0 ]]; then
		  err_msg="LTrim: an error has occured"
		  err=1
		fi
		return $err

  }


  Mid(){

	: 'BEGIN COMMENT
	"""
				  Returns a substring from a string
				  Args: string,start,[length]
				  Local vars: str
				  Global vars: mid_str
				  Exit codes:
						  0: SUCCESS
						  1: GENERIC FAILURE
						  2: FAILURE (WRONG USAGE)
	"""
	COMMENT'

	reset_global_vars
	
	if [[ -z "${1+x}" ]];then
		err=2
		err_msg="Mid: no string provided"
		return $err
	fi
	
	local length=""
	local start="0"
	local str="${1}"
	

	if [[ $# -lt 2 ]]; then
		err_msg="mid: missing start parameter."
		err=2
		return $err
	fi

	start=$(echo "${2}"|tr -cd '[:digit:]')
	if [[ -z "${start}" ]]; then
	  err_msg="Mid: start parameter in the wrong format."
	  err=2
	  return $err
	fi

	length="${3}"
	if [[ ! -z $length ]]; then
		set_val="${str:$start:$length}"
	else
		set_val="${str:$start}"	
	fi

	if [[ $? -ne 0 ]]; then
	  err_msg="Mid: an error has occured"
	  set_val=""
	  err=1
	fi

	return $err
	
}

Split(){

	: 'BEGIN COMMENT
	"""
			  Returns an array from a delimited string
			  The default delimiter is the space
			  Args: str, [delim]
			  Local vars: str, delim
			  Global vars: set_val
			  Exit codes:
					  0: SUCCESS
					  1: GENERIC FAILURE
					  2: FAILURE (WRONG USAGE)
				  127: FAILURE (COMMAND NOT FOUND)
	"""
	COMMENT'

	reset_global_vars
	if [[ -z "${1+x}" ]];then
		err=2
		err_msg="Split: no string provided"
		return $err
	fi

	local space=" "
	local str="${1}"
	local delim="${2:-${space}}"
	#local str_REG="[,.:;\'\#~_+\"/\/\*?]"
	local str_REG="[,.:;\'\#~_+\"/\/\*?\(\)]"
	

	#we will use grep instead of the bash =~ operator
	#for portability and consistency
	if ! command -v grep >/dev/null 2>&1; then
		err_msg="Fatal: grep not found"
		err=127
		return $err
	fi
	if [[  $delim != "$space" ]]; then
		if ! echo "$delim"|grep -q "$str_REG"; then
			err_msg="Split: Invalid delimiter\nThe following must be escaped:\n, & # \\ * ( )"
			err=2
			return $err
		fi
	fi
	
	 Len "$delim"
	 if [[ $set_val  -gt 1 ]]; then
			 err_msg="Split: Invalid delimiter - it must be one character only"
			 err=2
			 return $err
	 fi		
	set_val=""
	
	OIFS=$IFS
	IFS=$delim read -ra a_set_val <<< "$str"
	IFS=$OIFS
	if [[ $? -ne 0 ]]; then
		set_val=""
		a_set_val=()
		err_msg="Split: an error has occured"
		err=1
	fi

	return $err

}


Join(){

	: 'BEGIN COMMENT
	"""
			  Returns a string from an array
			  Args: array, [delim]
			  Local vars.: array, delim
			  Global vars: set_val
			  Exit codes:
					  0: SUCCESS
					  2: FAILURE (WRONG USAGE)
	"""
	COMMENT'

	reset_global_vars
	if [[ -z "${1+x}" ]];then
		err=2
		err_msg="Join: no array provided"
		return $err
	fi
	
	local space=" "
	local delim="${2:-${space}}"
	local array0="$1[@]"
	local array=("${!array0}")
	local elem=""

	 Len "$delim"
	 if [[ $set_val  -gt 1 ]]; then
			 err_msg="Join: Invalid delimiter - it must be one character only"
			 err=2
			 set_val=""
			 return $err
	 fi		
	set_val=""
	
	for elem in "${array[@]}"; do
		set_val="${set_val}${elem}${delim}"
		done	
	
	return $err
	
}



Ucase(){



	: 'BEGIN COMMENT
	"""
			  Makes a string uppercase
			  Args: string
			  Local vars.: str
			  Global vars: set_val
			  Exit codes:
					  0: SUCCESS
					  1: GENERIC FAILURE
					  127: COMMAND NOT FOUND
	"""
	COMMENT'


	reset_global_vars
	
	
	str=${1}
	
	
	command -v tr >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		set_val=$(echo "${1^^}")
		if [[ $? -ne 0 ]];then
			err=$?
			err_msg="Ucase - an error has occured"
		fi
	else
		err_msg="tr - command not found"
		err=127
	fi	
	
	
	return $err
		

}




Lcase(){



	: 'BEGIN COMMENT
	"""
			  Makes a string lowercase
			  Args: string
			  Local vars.: str
			  Global vars: set_val
			  Exit codes:
					  0: SUCCESS
					  1: GENERIC FAILURE
					  127: COMMAND NOT FOUND
	"""
	COMMENT'


	reset_global_vars
	
	
	str=${1}
	
	
	command -v tr >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		set_val=$(echo "${1}"| tr '[:upper:]'  '[:lower:]'  )
		if [[ $? -ne 0 ]];then
			err=$?
			err_msg="Lcase - an error has occured"
		fi
	else
		err_msg="tr - command not found"
		err=127
	fi	
	
	
	return $err
		

}


Capitalize(){



	: 'BEGIN COMMENT
	"""
			  Makes only the first character of a string uppercase
			  Args: string
			  Local vars.: str,char,str_part
			  Global vars: set_val
			  Exit codes:
					  0: SUCCESS
					  1: GENERIC FAILURE
					  127: COMMAND NOT FOUND
	"""
	COMMENT'


	reset_global_vars
	
	
	str=${1}
	char=${str:0:1}
	str_part=${str:1}
	
	
	
	command -v tr >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		char=$(echo "${char}"| tr '[:lower:]'  '[:upper:]'  )
		if [[ $? -ne 0 ]];then
			err=$?
			err_msg="Capitalize - an error has occured"
		fi
	else
		err_msg="tr - command not found"
		err=127
	fi	
	
	set_val="${char}${str_part}"
	
	
	return $err
		

}





