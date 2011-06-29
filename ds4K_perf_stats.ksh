#!/bin/ksh

RAW_STATS_FILE="masds45k_output.txt"
TMP_STATS_FILE="/tmp/masds45k_output.txt"
SPLUNK_OUTPUT="/opt/splunk/etc/apps/ds4k/masds4500stats.txt"

/opt/IBM_DS/client/SMcli -n "MASA0DS4500" -c "save storageSubsystem performanceStats file=\"masds45k_output.txt\";" -S

awk '$0!~ /^$/ {print $0}' $RAW_STATS_FILE | awk ' /Logical/ {print}' | awk -F\, '{gsub(/Logical Drive /,"",$1);print $1,$2,$3,$4,$5,$6,$7,$8}' > $TMP_                         STATS_FILE

if [[ $? -ne 0 ]] ; then
   exit 1
else
   #Print out column headers
         printf "%-30s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n" "LUN_NAME" "Total_IOs" "Read_%" "Cache_Hit_%" "Cur_KB_Sec" "Max_KB_Sec" "Cur_IO_Sec" "Max                         _IO_Sec" > $SPLUNK_OUTPUT
   #Read in values from output.txt and print into columns
   while read LUN_NAME VALUE1 VALUE2 VALUE3 VALUE4 VALUE5 VALUE6 VALUE7; do
      printf "%-30s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n" "$LUN_NAME" "$VALUE1" "$VALUE2" "$VALUE3" "$VALUE4" "$VALUE5" "$VALUE6" "$VALUE7" >> $SPLUNK_OUTPUT
   done < $TMP_STATS_FILE
fi
