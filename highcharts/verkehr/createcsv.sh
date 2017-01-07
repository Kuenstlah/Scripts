#!/bin/bash
#######################
######## Setup ########
#######################
cfg=`/bin/echo $0|cut -d '.' -f1`.cfg
[ -f "$cfg" ] && source "$cfg" || /bin/echo "Error - config <$cfg> is missing. Do not use additional . in path to call the script, except for ending."

csvline="$date_hm"

function createcsv(){
        name=$1
        locstart=$2
        locdest=$3

        csvfile="$xmlpath/traffic.csv"
        tmp_json_file="$csvfile.tmp"
        curl --insecure "https://maps.googleapis.com/maps/api/directions/json?origin=${locstart}&destination=${locdest}&key=$google_api_key" > $tmp_json_file
	cat $tmp_json_file
        duration=($(jq -r '.routes[0].legs[0].duration.value' $tmp_json_file))
	duration_new="$(($duration/60))"
	if [[ $duration_new -gt 0 ]];then
                csvline="$csvline,$duration_new"
	else
                echo "$date_hm - duration_new: $duration_new - duration: $duration" >> ${csvfile}.log
                exit
	fi
}
call_jobs

current_rows=`wc -l $csvfile| awk -F ' ' {'print $1'}`
if [[ $current_rows -ge 50 ]];then
	/bin/sed 2D -i $csvfile
fi

grep -q "$csvline" $csvfile
if [[ $? == "1" ]];then
	echo -e "$csvline" >> $csvfile
fi

rm -f $tmp_json_file
