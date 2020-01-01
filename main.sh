#!/bin/bash
#
#Library containing common string functions 
#mimicking basic/vbscripts naming
#
#Version: 0.2
#Author: Fabrizio Pani
#License: GPL v2
#Dec. 2019

##########################Logic of exit codes####################
#0: success
#1: general error code
#2: usage error
#5: permission denied
#99: unsupported system
#100: system issue
#127: command not found
#130: CTRL+C was invoked
#
################################################################
########################Logic of global variables###############
#we will use the below global vars
#and reset them at each function call
#the caller might optionally reset them
#
#set_val        : returned value from a function
#a_set_val    : returned array of values set from a function
#err	        	: contains the last error code
#             		: ( 0 means the operation is successful )
#err_msg      : contains the last error message
###############################################################

reset_global_vars(){

	
	 : 'BEGIN COMMENT
	 """
			Resets global variables
			Args: N/A
			Local vars: N/A
			Global vars: a_set_val, set_val, err, err_msg
			Exit codes: N/A
	"""
	END COMMENT'

	a_set_val=()
	set_val=""
	err=0
	err_msg=""

}

get_bash_ver(){


	 : 'BEGIN COMMENT
	 """
			retrieves bash major, minor and release version
			Args: N/A, 
			Local vars: N/A
			Global vars: major_ver, minor_ver,fix_ver
			Exit codes: N/A
	"""
	END COMMENT'
	
	
major_ver=$(bash --version|head -n1|awk -F"," '{print $2}'|awk  '{print $2}'|awk -F"." '{print $1}')
minor_ver=$(bash --version|head -n1|awk -F"," '{print $2}'|awk  '{print $2}'|awk -F"." '{print $2}')
fix_ver=$(bash --version|head -n1|awk -F"," '{print $2}'|awk  '{print $2}'|awk -F"." '{print $3}'|awk -F"-"  '{print $1}')

}