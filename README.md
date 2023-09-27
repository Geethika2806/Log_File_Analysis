# Log_File_Analysis
This shell script analyzes a log file and is capable of performing the following actions:

log_sum.sh [-L N] (-c|-2|-r|-F|-t) <filename>
-L: Limit the number of results to N
-c: Which IP address makes the most number of connection attempts?
-2: Which address makes the most number of successful attempts?
-r: What are the most common results codes and where do they come
from?
-F: What are the most common result codes that indicate failure (no
auth, not found etc) and where do they come from?
-t: Which IP number get the most bytes sent to them?
