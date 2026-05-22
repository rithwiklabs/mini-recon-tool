#!/bin/bash

show_banner()
{
	echo
	echo "=========================="
    	echo "     MINI RECON TOOL      "
    	echo "=========================="

    	echo "1. Ping Target"
    	echo "2. DNS Lookup"
    	echo "3. Whois Lookup"
    	echo "4. Port Scan"
    	echo "5. Exit"
}
	
log_header()
{
	echo  | tee -a $report
    	echo "========== $( date +"%Y-%m-%d  %H:%M:%S" ) ==========" | tee -a $report
}

write_log()
{
	echo "[$( date +"%Y-%m-%d  %H:%M:%S" )] $1"  >> logs/activity.log
}

validate_target()
{
    	ping -c 2 $1 > /dev/null 2>&1

    	if [ $? -eq 0 ]
    	 then
        	return 0
    	else
        	return 1
    	fi
}

section_header()
{
    	echo
    	echo "===================================="
    	echo "        $1"
    	echo "===================================="
    	echo
}

show_summary()
{
    	echo
    	echo "=========================="
    	echo " Scan Completed Successfully "
    	echo "=========================="
    	echo "Target : $1"
    	echo "Time   : $(date +"%Y-%m-%d %H:%M:%S")"
    	echo
}

loading()
{
    	echo -n "Processing"

    	for i in 1 2 3
    	do
        	echo -n "."
        	sleep 1
    	done

    	echo
}

while true
do
    	show_banner

    	echo
    	read -p "Enter your choice : " ch
    	case $ch in

        	1)
            	read -p "Enter target (IP or domain): " tg
            	validate_target $tg
            	if [ $? -eq 0 ]
            	 then
                		report="reports/${tg}.txt"
                		log_header
                		echo
                		section_header "PING RESULTS"
                		echo "Pinging $tg ..."
                		loading
                		echo
                		ping -c 4 $tg | tee -a $report
                		echo
                		write_log "Ping scan performed on $tg."
                		echo "Report saved to $report"
                		show_summary $tg
            	else
                		echo
                		echo "Target unreachable or invalid!"
            	fi
            	;;

        	2)
            	read -p "Enter domain : " domain
            	validate_target $domain
	            if [ $? -eq 0 ]
            	 then
                		report="reports/${domain}.txt"
                		log_header
                		echo
                		section_header "DNS RESULT"              
                		echo "Fetching DNS info for $domain ..."
                		loading
                		echo
                		host $domain | tee -a $report
                		echo
                		write_log "DNS lookup performed on $domain."
                		echo "Report saved to $report"
                		show_summary $domain
            	else
                		echo
                		echo "Invalid or unreachable domain!"
            	fi
            	;;

        	3)
            	read -p "Enter domain : " domain
	            validate_target $domain
	            if [ $? -eq 0 ]
      	       then
             		report="reports/${domain}.txt"
	                	log_header
                		echo
                		section_header "WHOIS RESULTS"
                		echo "Fetching Whois info for $domain ..."
                		loading
                		echo
                		whois $domain | grep -E "Registrar:|Creation Date:|Registry Expiry Date:|Name Server:" | tee -a $report
                		write_log "Whois lookup performed on $domain."
	                	echo
	                	echo "Report saved to $report"
	                	show_summary $domain
	            else
                		echo
                		echo "Invalid or unreachable domain!"
            	fi
            	;;

        	4)
            	read -p "Enter target : " tg
	            validate_target $tg
	            if [ $? -eq 0 ]
      	       then
                		report="reports/${tg}.txt"
	                	log_header
	                	echo
	                	section_header "PORT SCAN RESULTS"
                		echo "Scanning open ports on $tg ..."
                		loading
                		echo
                		nmap $tg | tee -a $report
                		echo
                		write_log "Port Scan performed on $tg."
                		echo "Report saved to $report"
                		show_summary $tg
            	else
                		echo
                		echo "Target unreachable or invalid!"
            	fi
            	;;

        	5)
            	echo
            	echo "Exiting Mini Recon Tool..."
            	break
            	;;

        	*)
            	echo
            	echo "Invalid Choice!!!"
            	;;

	esac

done
