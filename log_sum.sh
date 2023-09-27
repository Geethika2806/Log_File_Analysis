#!/bin/bash


Limit=99999


usage()

{ echo "Usage : $0 [-L N] (-c|-2|-r|-F|-t) [-e] <filename>"
          exit 1
        }

	while getopts "L:c2rFte" option; do

    case $option in

    L)
        Limit="$OPTARG"
        ;;

    c|2|r|F|t)
	fun="$option"
	;;
    e) blacklist_flag="true"
	    ;;
	

    *)
        echo "Not a valid argument"
        usage
        ;;

    esac

done



shift $((OPTIND-1))


if [ -z "$fun" ]; then
  echo "Error:No action could be performed. Mandatory arguments missing"
  usage
fi

if [ $# -eq 0 ] || [ "$1" = "-" ]; then
    data=$(cat -)
    temp_file=$(mktemp)
    echo "$data" > "$temp_file"
    exec < /dev/null 
    filename="$temp_file"
elif [ $# -eq 1 ]; then
  filename="$1"
else
  echo "error" 
  usage
fi


case $fun in
c)
	output=$(cat "$filename" | awk '{print $1}' | sort | uniq -c | sort -nr | head -n "$Limit" | awk '{print $2 " " $1}')
        ;;
2)


        output=$(for f in 200 304; do
                 succ_codes=$(cat "$filename" |awk '{print $9 " " $1}'| sort | uniq -c| sort -k2,2n -k1,1nr | grep -E " ($f) " | head -n "$Limit"| awk '{print $2 " " $3}')
                 echo "$succ_codes"
                 done)
        ;;

r)
 
        order=$(cat "$filename" | awk '{print $9}' | sort | uniq -c | sort -nr | awk '{print $2}')

        output=$(for f in $order; do
                 comm_codes=$(cat "$filename" | awk '{print $9 " " $1}' | sort | uniq -c | sort -k2,2n -k1,1nr | grep -E " ($f) "| head -n "$Limit"| awk '{print $2 " " $3 }')
                 echo "$comm_codes"
                 done)

        ;;
        
F)


        output=$(for f in 404 403 401; do
	         fail_codes=$(cat "$filename" |awk '{print $9 " " $1}'| sort | uniq -c| sort -k2,2nr -k1,1nr | grep -E " ($f) " | head -n "$Limit"| awk '{print $2 " " $3}')
	         echo "$fail_codes"
                 done)
        ;;
t) 



       unique_ips=$(cat "$filename" |  awk '{print $1 " " $10}' | sort -k2,2n | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3} [0-9]+\b' | awk '{print $1}' | sort | uniq)

       temp_out=$(for ip in $unique_ips; do
       total_bytes=0
       data=$(cat "$filename" |  awk '{print $1 " " $10}' | sort -k2,2n | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3} [0-9]+\b'|grep -E "^($ip) ")
       while read -r line;do
             current_ip=$(echo "$line" | awk '{print $1}')
             current_bytes=$(echo "$line" | awk '{print $2}')
             if [ "$current_ip" = "$ip" ]; then
                   total_bytes=$((total_bytes+current_bytes))
             fi
       done <<< "$data"

       echo "$ip $total_bytes"

       done)

       output=$( echo "$temp_out" | sort -k2,2nr | head -n "$Limit")


        ;;
 
*)
        echo "No action specified"
        ;;
esac

fun_blacklist()
 
   {  dns_list=$(cat dns.blacklist.txt)

      unique_ip=$(cat thttpd.log | awk '{print $1}' |sort| uniq -c | awk '{print $2}' )
      black_list=()
      
      for ip in $unique_ip; do
           dns_name=$(getent hosts "$ip" | awk '{print $2}')
	   for dns in $dns_list; do
	       if [ "$dns" == "$dns_name" ]; then
	                black_list+=("$ip")
			break
	       fi
	   done
      done
   }


      if [ "$blacklist_flag" = "true" ]; then
      fun_blacklist
      while read -r line; do
           ip_addr=$(echo "$line" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
           dns_name=$(getent hosts "$ip" | awk '{print $2}')
    
           for ip in $black_list; do
               if [ "$ip" == "$ip_addr" ]; then
                       echo "$line BLACKLISTED"
     
               else echo "$line"		       
               fi
           break
           done
       done <<< "$output"

      else echo "$output"
       
      fi 
 


