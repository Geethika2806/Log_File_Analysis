# Log_File_Analysis
This shell script analyzes a log file and is capable of performing the following actions:
<br>
log_sum.sh [-L N] (-c|-2|-r|-F|-t) <filename> <br><br>
-L: Limit the number of results to N <br>
-c: Which IP address makes the most number of connection attempts?<br>
-2: Which address makes the most number of successful attempts? <br>
-r: What are the most common results codes and where do they come
from? <br>
-F: What are the most common result codes that indicate failure (no
auth, not found etc) and where do they come from? <br>
-t: Which IP number get the most bytes sent to them? <br>
