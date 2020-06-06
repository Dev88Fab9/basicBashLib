#!/bin/bash

if [[ "${BASH_SOURCE[0]}" -ef "$0" ]]; then
    echo "This script is not meant to run standalone: it must be sourced"
    exit
fi


. ./main.sh

is_valid_port(){

    : 'BEGIN COMMENT
    """
        Check if a valid TCP/UDP port
        Args: port
        Local vars: port
        Global vars: err
        Exit codes:
        0: SUCCESS
        1: GENERIC FAILURE
    """
    END COMMENT'
    
    local port=0
    port=${1}
    reset_global_vars

    if [[ $port -le 1 || $port -ge 65535 ]]; then
        err_msg="Please insert a port in the range 1-65535"
        err=1
    fi  

    return $err
}

is_valid_ipv4(){

    : 'BEGIN COMMENT
    """
        Check if a valid IPv4 address
        Args: IP
        Local vars: ip
        Global vars: set_val, err, err_msg
        Exit codes:
        0: SUCCESS
        1: GENERIC FAILURE
    """
    END COMMENT'

    reset_global_vars

    
    local ip="${1}"
        
    if [[ ! $is_grep -ne 0 ]]; then
       err=127
       err_msg="grep command not found"
       return $err
    fi   
        
    if ! echo "$ip" | grep -E '(([0-9]{1,3})\.){3}([0-9]{1,3}){1}'  | grep -vqE '25[6-9]|2[6-9][0-9]|[3-9][0-9][0-9]' ; then
        err=1
        err_msg="not a valid IPv4 address"
    fi  
    
    return $err
}

is_valid_ipv6(){

    
    : 'BEGIN COMMENT
    """
        Check if a valid IPv6 address
        Args: IP
        Local vars: ip,str_REG
        Global vars: set_val, err, err_msg
        Exit codes:
        0: SUCCESS
        1: GENERIC FAILURE
    """
    END COMMENT'
    
    reset_global_vars

    err=0
    err_msg=""

    local ip="${1}"
    str_REG="^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]\
    {1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]\
    {1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|\
    ([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4})\
    {1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}\
    |::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]\
    |(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9])\
    {0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$"
    
        
    get_bash_ver
    
    if [[ $major_ver -lt 3 ]]; then
        err=99
        err_msg="is_valid_ipv6: at least bash 3.0 is required for this check"
        return $err
    fi  
        
    if [[ $major_ver -ge 3 && $minor_ver -ge 2 ]]; then
        if  ! [[ "$ip" =~ $str_REG ]]; then
            err=1
            err_msg="not a valid IPv6 address"
        fi  
    else
        if  ! [[ "$ip" =~ "$str_REG" ]]; then
            err=1
            err_msg="not a valid IPv6 address"
        fi  
    fi
        
    return $err
}

is_valid_host(){

    
    : 'BEGIN COMMENT
    """
        Check if a valid host
        Args: port
        Local vars: host
        Global vars: err
        Exit codes:
        0: SUCCESS
        1: GENERIC FAILURE
    """
    END COMMENT'
    
    local host=""
    host=${1}
    reset_global_vars
    
    if [[ -z $host  ]]; then
        err_msg="Please insert a valid host"
        err=1
    fi  
    
    return $err


}

check_net_tools(){


     : 'BEGIN COMMENT
    """
        Check which network tools are installed
        Args: N/A
        Local vars: N/A
        Global vars: is_dig,is_ip,is_nc,is_ncat,is_nslookup,is_telnet,is_ping,is_ss
        Exit codes:
        N/A
    """
    END COMMENT'

        is_nc=1
        is_ncat=1
        is_nslookup=1
        is_dig=1
        is_ip=1
        is_telnet=1
        is_ping=1
        is_ss=1

    if command -v nslookup >/dev/null 2>&1; then
            is_nslookup=0
    fi

    if command -v dig >/dev/null 2>&1; then
            is_dig=0
    fi

    if command -v ip >/dev/null 2>&1; then 
            is_ip=0
    fi

    if command -v telnet >/dev/null 2>&1; then
            is_telnet=0
    fi

    if command -v ping >/dev/null 2>&1; then
            is_ping=0
    fi

    if command -v ss >/dev/null 2>&1; then
            is_ss=0
    fi

    if command -v nc >/dev/null 2>&1; then
        if  man nc | grep '\-z'|grep -q "just scan"; then
            is_nc=0
        fi
    fi  

    if command -v ncat >/dev/null 2>&1; then
        is_ncat=0
    fi  
}

check_tcp_port(){
    
    : 'BEGIN COMMENT
    """
        Check if a port is reachable
        Args: host, port
        Local vars: host, port, fd, max_fd, i,ret
        Global vars: set_val, err, err_msg
        Exit codes:
        0: SUCCESS
        1: GENERIC FAILURE
        2: FAILURE (wrong usage)
        99:FAILURE (UNSUPPORTED SYSTEM)
        100: FAILURE (SYSTEM ISSUE)
    """
    END COMMENT'

    reset_global_vars 

    local host=${1} 
    local port=${2}
    #file descriptor, values 0 1 2 are reserved
    #so we start from the 3
    local fd=3
    #system max file descriptor
    local max_fd=0
    #loops variables
    local ret=0
    local i=0

    if ! echo "$(uname) "| grep -iq Linux; then
        err=99 
        err_msg="check_tcp_port: you are not using Linux"
        return $err
    fi  
    if ! ls /proc/meminfo >/dev/null 2>&1; then
        err=99
        err_msg="Linux : no proc file system??"
        return $err
    fi
    #retrieving the maximum number of file descriptors
    #normally we should use only descriptors 3-9
    #but using from 3 to max file descriptors
    max_fd=$(cat /proc/sys/fs/file-max 2>/dev/null)
    if  [[ $? -ne 0 ]]; then
        max_fd=1024
    fi
    
    is_valid_host "$host"
     if [[ $? -ne 0 ]]; then
         return $err
     fi
     is_valid_port "$port"
     if [[ $? -ne 0 ]]; then
            return $err
     fi

    #find a free available descriptor
    while test -t ${fd}; do
        fd=$(( fd+1 ))
        if [[ $fd -ge $max_fd ]]; then
            err=100
           err_msg="check_tcp_port: fatal. No file descriptors available"
        fi
    done
    
    #checking the TCP port
    
    #u cannot normally pass a variable to exec,
    #   u must pass a costant, hence using eval
    eval 'exec '"$fd"'< "/dev/tcp/$host/$port"' 2>/dev/null
    err=$?      

    #if not successful we make other 3 attempts
    while [[ $err -ne 0 ]]; do
            #u cannot normally pass a variable to exec,
            #   u must pass a costant, hence using eval
        eval 'exec '"$fd"'< "/dev/tcp/$host/$port"' 2>/dev/null
        err=$?
        if [[ $err -ne 0 ]]; then
                #we sleep a random number 0-7 seconds
                sleep $(( RANDOM %7 ))
                i=$(( i+1 ))
                if [[ $i -ge 3 ]]; then
                    #only three attempts
                    break 3
                fi  
        fi
    done
        
    #closing the file descriptor    
    if  ls   ls /proc/$$/${fd}  2>/dev/null ; then
            exec ${fd}>&-
    fi

    return $err

}


check_udp_port(){
    
     : 'BEGIN COMMENT
     """
            Check if a UDP port is reachable
            Args: host, port
            Local vars: host, port
            Global vars: err, err_msg
            Exit codes:
                0: SUCCESS
                1: GENERIC FAILURE
                2: FAILURE (wrong usage)
                127:FAILURE (COMMAND NOT FOUND )
    """
    END COMMENT'

    reset_global_vars
    check_net_tools 

    local host=${1} 
    local port=${2}
    
     is_valid_host "$host"
     if [[ $? -ne 0 ]]; then
        return $err
     fi
    is_valid_port "$port"
    if [[ $? -ne 0 ]]; then
        return $err
    fi
        
    #we do not use the bash connect facility 
    #as for UDP it always returns 0 (success)
        
    if [[ $is_nc -ne 0 && $is_ncat -ne 0 ]]; then
        err=127
        err_msg="check_udp_port: nc -z or ncat missing"
        return $err
    fi
    if [[ $is_nc -eq 0 ]]; then
        if ! nc -uvz "$host" "$port" >/dev/null 2>&1; then
                err=1
                err_msg="UDP port check failed"
        fi  
        return $err 
    fi
    if ! ncat -uv "$host" "$port" </dev/null >/dev/null 2>&1; then 
                err=1
                err_msg="UDP port check failed"
    fi      
    
    return $err

}
