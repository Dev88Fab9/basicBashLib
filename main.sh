#!/bin/bash
#
#Library containing common string functions
#mimicking basic/vbscripts naming
#
#Version: 0.2
#Author: Fabrizio Pani
#License: GPL v2
#Dec. 2019
#set -x
##########################Logic of exit codes####################
#0:     success
#1:     general error code
#2:     usage error
#5:     permission denied
#99:    unsupported system
#100:   system issue
#127:   command not found
#130:   CTRL+C was invoked
#
################################################################
########################Logic of global variables###############
#we will use the below global vars
#and reset them at each function call
#the caller might optionally reset them
#
#set_val            : returned value from a function
#a_set_val          : returned array of values set from a function
#err                : contains the last error code
#                   : ( 0 means the operation is successful )
#err_msg            : contains the last error message
###############################################################

if [[ "${BASH_SOURCE[0]}" -ef "$0" ]];then
    echo "This script cannot be run standalone, it must be sourced"
    exit
fi


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


    major_ver=$(bash --version|head -n1|awk -F"," '{print $2}'|awk '{print $2}'\
	|awk -F"." '{print $1}')
    minor_ver=$(bash --version|head -n1|awk -F"," '{print $2}'|awk '{print $2}'\
	|awk -F"." '{print $2}')
    fix_ver=$(bash --version|head -n1|awk -F"," '{print $2}'|awk '{print $2}'\
	|awk -F"." '{print $3}'|awk -F"-"  '{print $1}')

}


chk_tools(){
    : 'BEGIN COMMENT
    """
        check if essentials tools are in the system
        and set relative global variable
        Args: N/A,
        Local vars: N/A
        Global vars: is_awk,is_grep,is_sed,is_tr,is_xargs,is_wc
        Exit codes: N/A
    """
    END COMMENT'

    is_grep=1
    is_tr=1
    is_sed=1
    is_awk=1
    is_xargs=1
    is_wc=1


    if command -v grep >/dev/null 2>&1; then
            is_grep=0
    fi
    if command -v tr >/dev/null 2>&1; then
            is_tr=0
    fi
    if command -v sed >/dev/null 2>&1; then
            is_sed=0
    fi
    if command -v awk >/dev/null 2>&1; then
            is_awk=0
    fi
    if command -v xargs >/dev/null 2>&1; then
            is_xargs=0
    fi
    if command -v wc >/dev/null 2>&1; then
            is_wc=0
    fi
}


f_check_root(){
    : 'BEGIN COMMENT
         """
            Check if root
            Args: N/A
            Local vars: N/A
            Global vars: set_val, err, err_msg
            Exit codes: N/A
        """
        END COMMENT'

    reset_global_vars
    if [[ $(id -u) -ne 0 ]]; then
        err_msg="Sorry, you need to be root for this."
        err=5
        return $err
    fi

    }
	

f_err_handling(){
    : 'BEGIN COMMENT
    """
        Error trap function
        Args: $0, $LINENO, $?
        Local vars: ret
        Global vars: N/A
        Exit codes: N/A
    """
    END COMMENT'

    local ret
    ret=${3}

    echo "Sorry, ${1:2} terminated with the error $ret at line ${2}"
}


f_exit_handling(){
    : 'BEGIN COMMENT
    """
        exit function
        Args: N/A
        Local vars: ret
        Global vars: N/A
        Exit codes: N/A
    """
    END COMMENT'

    local ret
    ret=${1}

    if [[ $ret -eq 0 ]]; then
        echo "${0:2} terminated successfully."
    fi

}


f_set_error(){
    : 'BEGIN COMMENT
    """
        Call an exit/trap function
        Args: N/A
        Local vars: N/A
        Global vars: ERR
        Exit codes: N/A
    """
    END COMMENT'

    set -o pipefail  #trace ERR through pipes
    set -o errtrace  #trace ERR through 'time command' and other functions
    set -o nounset   #set -u : exit the script on an uninitialised variable
    #set -e : exit the script if any statement returns a non-true return value
	set -o errexit   


    trap 'f_err_handling  $0 ${LINENO} $?' ERR
    trap 'f_exit_handling $?' EXIT
}


f_unset_error(){

    : 'BEGIN COMMENT
    """
        unset error traps
        for instance when we do not want to
        exit for a grep, sed or awk not found string
        Args: N/A
        Local vars: N/A
        Global vars: ERR
        Exit codes: N/A
    """
    END COMMENT'

    set +o pipefail  #do not trace ERR through pipes
	# do not trace ERR through 'time command' and other functions
    set +o errtrace  
    set +o errexit   
	#set +e : do not exit the script if any statement returns a non-true 
	#return value
	trap - ERR
}


f_old_unsupported(){

	: 'BEGIN COMMENT
	"""
	  set this error message and exit

	  Args: N/A
	  Local vars: N/A
	  Global vars: N/A
	  Exit codes: N/A
	"""
	END COMMENT'

	echo ""
	echo -n "Your bash version $major_ver .$minor_ver.$fix_ver is too old"

}


#main
# in principle we require the old version 2.04 at least
# as from that version '/dev/tcp/host/port' and ''/dev/udp/host/port' are
# recognized
get_bash_ver
if [[ $major_ver -lt 2 ]]; then
	f_old_unsupported
	exit 99
elif [[ $major_ver -eq 2 && $minor_ver -lt "04" ]];then
	f_old_unsupported
	exit 99
fi
