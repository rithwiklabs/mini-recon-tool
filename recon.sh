#!/bin/bash

# COLORS
BOLD='\033[1m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
NC='\033[0m'

show_banner()
{
	sleep 0.3
	echo -e "${CYAN}"
	echo -e  "${BLUE}==========================${NC}"
    	echo -e  "     ${BOLD}${CYAN}MINI RECON TOOL   ${NC}"
    	echo -e  "${BLUE}==========================${NC}"
	echo -e "${NC}"
    	echo -e "${GREEN}[1]${NC} Ping Target"
    	echo -e "${GREEN}[2]${NC} DNS Lookup"
    	echo -e "${GREEN}[3]${NC} Whois Lookup"
    	echo -e "${GREEN}[4]${NC} Port Scan"
    	echo -e "${GREEN}[5]${NC} Exit"
    	
    	echo
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
    	echo -e "${BLUE}====================================${NC}"
    	echo -e "${YELLOW}        $1${NC}"
    	echo -e "${BLUE}====================================${NC}"
    	echo
}

show_summary()
{
    	echo
    	echo -e  "${BLUE}==========================${NC}"
    	echo -e "${GREEN}Scan Completed Successfully${NC} "
    	echo -e  "${BLUE}==========================${NC}"
    	echo -e "${CYAN}Target : $1${NC}"
    	echo -e "${CYAN}Time   : $(date +"%Y-%m-%d %H:%M:%S")${NC}"
    	echo -e  "${BLUE}==========================${NC}"
    	echo
}

loading()
{
    	echo -ne "${MAGENTA}Processing${NC}"

    	for i in 1 2 3
    	do
        	echo -n "."
        	sleep 1
    	done

    	echo
}

check_tools()
{
	missing_tools=()
	tools=("nmap" "whois" "host")

	for tool in "${tools[@]}"
	do
		if ! command -v "$tool" &> /dev/null
		then
			missing_tools+=("$tool")
		fi
	done
	if [ ${#missing_tools[@]} -ne 0 ]
	then
		echo
		echo -e "${RED}[-] Missing Required Tools :${NC}"
		for missing in "${missing_tools[@]}"
		do 
			echo -e "${YELLOW} ---> $missing${NC}"
		done
		
		echo
		echo -e "${CYAN}Install them using :${NC}"
		echo "sudo apt install ${missing_tools[*]}"
		
		exit 1
	fi
}

check_tools
echo -e "${GREEN}[+] All Required Tools Found${NC}"
sleep 1
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
                		echo -e "${YELLOW}[*] Pinging $tg ...${NC}"
                		loading
                		echo
                		ping -c 4 $tg | tee -a $report
                		echo
                		write_log "Ping scan performed on $tg."
                		echo -e "${GREEN}[+] Report saved to $report${NC}"
                		show_summary $tg
            	else
                		echo
                		echo -e "${RED}[-] Target unreachable or invalid!${NC}"
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
                		echo -e "${YELLOW}[*] Fetching DNS info for $domain ...${NC}"
                		loading
                		echo
                		host $domain | tee -a $report
                		echo
                		write_log "DNS lookup performed on $domain."
                		echo -e "${GREEN}[+] Report saved to $report${NC}"
                		show_summary $domain
            	else
                		echo
                		echo -e "${RED}[-] Invalid or unreachable domain!${NC}"
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
                		echo -e "${YELLOW}[*] Fetching Whois info for $domain ...${NC}"
                		loading
                		echo
                		whois $domain | grep -E "Registrar:|Creation Date:|Registry Expiry Date:|Name Server:" | tee -a $report
                		write_log "Whois lookup performed on $domain."
	                	echo
	                	echo -e "${GREEN}[+] Report saved to $report${NC}"
	                	show_summary $domain
	            else
                		echo
                		echo -e "${RED}[-] Invalid or unreachable domain!${NC}"
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
                		echo -e "${YELLOW}[*] Scanning open ports on $tg ...${NC}"
                		loading
                		echo
                		nmap $tg | tee -a $report
                		echo
                		write_log "Port Scan performed on $tg."
                		echo -e "${GREEN}[+] Report saved to $report${NC}"
                		show_summary $tg
            	else
                		echo
                		echo -e "${RED}[-] Target unreachable or invalid!${NC}"
            	fi
            	;;

        	5)
            	echo
            	echo -e "${CYAN}Exiting Mini Recon Tool... 😎${NC}"
            	break
            	;;

        	*)
            	echo
            	echo -e "${RED}[-] Invalid Choice!!!${NC}"
            	;;

	esac

done
