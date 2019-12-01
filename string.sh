#!/bin/bash


#Logic of exit codes
#1: general error code
#2: usage error
#5: permission denied
#127: command not found
#130: CTRL+C was invoked


#to avoid remembering each specific variable
#returned by each function
#we will return the unique global variable
#ret_string
#it is set to blank at each call to avoid any clash

ret_string=""


Len(){

 : 'BEGIN COMMENT
 """
 		Get the length of a passed string
		and save it in the variable strlen

		Argument: one string
		Local var.: str_org, str
		Global var.: strlen
		Returns:
			0: SUCCESS
			1: FAILURE
"""
END COMMENT'

  local str_org=""
  local str=""
	str_org="${1}"

	if [[ -z "${str_org}" ]]; then
		echo "No input string provided"
		return 1
	else
    #we might have a null character
    #to avoid the function will stop to count
    #after displaying a warning message
    #we replace any NULL with simply a 0
    str=$(echo -n "${str_org}"|tr -s '\000' '0')
   	strlen=$(echo -n "${str}"|wc -m)
   	return 0
	fi

}

Trim(){
: 'BEGIN COMMENT
 """
                Remove any whitespace at the end and at the beginning of a string
                Argument: one string
                Local var.: str
                Global var.: trimmedi_str
                Returns:
                        0: SUCCESS
                        1: FAILURE
"""
END COMMENT'

	local str=""
  trimmed_str=""
  str="${1}"

  if [[ -z "${str}" ]]; then
		echo "No input string provided."
		return 1
  else
	   trimmed_str=$(echo "${str}"|xargs)
     if [[ $? -eq 0 ]]; then
	      return 0
     else
        trimmed_str=""
        return 1
	   fi
  fi
}

RTrim(){

  : 'BEGIN COMMENT
   """
                  Remove any whitespace at the end of a string
                  Argument: one string
                  Local var.: str
                  Global var.: rtrimmed_str
                  Returns:
                          0: SUCCESS
                          1: FAILURE
  """
  COMMENT'


  	local str=""
    rtrimmed_str=""
    str="${1}"


    if [[ -z "${str}" ]]; then
      echo "No input string provided."
      return 1
    else
      rtrimmed_str="${str%%*()}"
    fi

}


LTrim(){

    : 'BEGIN COMMENT
     """
                    Remove any whitespace at the beginning of a string
                    Argument: one string
                    Local var.: str
                    Global var.: ltrimmed_str
                    Returns:
                            0: SUCCESS
                            1: FAILURE
    """
    COMMENT'

    	local str=""
      ltrimmed_str=""
      str="${1}"


      if [[ -z "${str}" ]]; then
        echo "No input string provided."
        return 1
      else
        ltrimmed_str="${str##*()}"
        return 0
      fi

  }


  Mid(){

      : 'BEGIN COMMENT
       """
                      Return a substring from a string
                      Argument: string,start,[length]
                      Local var.: str
                      Global var.: mid_str
                      Returns:
                              0: SUCCESS
                              1: FAILURE
      """
      COMMENT'

      	local str=""
        local length=""
        local start="0"
        mid_str=""
        str="${1}"

        if [[ -z "${str}" ]]; then
          echo "No input string provided."
          return 1
        fi
        if [[ $# -lt 2 ]]; then
          return 2
        fi
        start=$(echo "${2}"|tr -cd '[:digit:]')
        if [[ -z "${start}" ]]; then
           return 2
        fi
        if [ $# -eq 3 ]; then
          length=$(echo "${3}"|tr -cd '[:digit:]')
        fi

        if [[ ! -z $length ]]; then
          mid_str="${str:$start:$length}"
        else
          mid_str="${str:$start}"
        fi
        return 0
}
