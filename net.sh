#!/bin/bash


is_valid_port(){

:

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
		
	if ! command -v grep >/dev/null 2>&1; then
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
	str_REG="^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$"
	
	
	
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


:


}

check_net_tools(){

		is_nc=1
		is_ncat=1
		is_nslookup=1
		is_dig=1
		is_ip=1
		is_telnet=1
		is_ping=1
		is_ss=1

	if command -v nc >/dev/null 2>&1; then
		is_nc=0
	fi

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
			Local vars: host, port, fd, max_fd, i
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
	#file descriptor
	local fd=3
	#system max file descriptor
	local max_fd=0
	local i=0

	if ! `uname` != "Linux"; then
		err=99 
		err_msg="check_tcp_port: you are not using Linux"
		return $err
	fi	
	if ! ls /proc/meminfo >/dev/null 2>&1; then
	    err=99
		err_msg="Linux : no proc file system"
		return $err
	fi
	max_fd=$(cat /proc/sys/fs/file-max 2>/dev/null)
	if  [[ $? -ne 0 ]]; then
	    #cannot determine the max value of available 
		#file descritprs
		#hence setting a value of 1024
		max_fd=1024
	fi
	
	
	is_valid_host $host
	if [[ $? -ne 0 ]]; then
		echo "$err_msg"
		return $err
	fi
	is_valid_port $port
	if [[ $? -ne 0 ]]; then
		echo "$err_msg"
		return $err
	fi

	#verify or find free descriptor
	while [ $ret -ne 0 ]; do
	    ls /proc/$$/$(( fd + i)) >/dev/null 2>&1
	    ret=$?

		if [[ $ret -ne 0 ]]; then
		    i=$(( i+1))
			fd=$(( fd+i))
		fi
		
		if [[ $fd -ge $max_fd ]]; then
		   err=100
		   err_msg="check_tcp_port: fatal. No file descriptors available"
		   return $err
		fi
		
	done
		
	if [[ $? -eq 0 ]]; then
		#we choose the a value of descriptor
		exec "${fd}"<>/dev/tcp/"${host}"/"${port}" 2>/dev/null 
	    if [[ $? -ne 0 ]]; then
			err=1
			err_msg="Connection failure"
	   fi
	else
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
	
	is_valid_host $host
	if [[ $? -ne 0 ]]; then
		echo "$err_msg"
		return $err
	fi
	is_valid_port $port
	if [[ $? -ne 0 ]]; then
		echo "$err_msg"
		return $err
	fi
		
	if [[ $is_nc -ne 0 && $is_ncat -ne 0 ]]; then
		err=127
		err_msg="check_udp_port: nc -z or ncat missing"
		return $err
	fi
	

	if [[ $is_nc -eq 0 ]]; then
		nc -uz $host $port 2>/dev/null 
			if [[ $? -ne 0 ]]; then
				err=1
				err_msg="udp port check failed"
			fi	
	else
		ncat -uz $host $port 2>/dev/null 
			if [[ $? -ne 0 ]]; then
				err=1
				err_msg="udp port check failed"
			fi	
	fi		
	return $err

}
