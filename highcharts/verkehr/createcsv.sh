#!/bin/bash
#######################
######## Setup ########
#######################
cfg=`/bin/echo $0|cut -d '.' -f1`.cfg
[ -f "$cfg" ] && source "$cfg" || /bin/echo "Error - config <$cfg> is missing. Do not use additional . in path to call the script, except for ending."

function createcsv(){
        name=$1
        locstart=$2
        locdest=$3

        csvfile="$xmlpath/verkehr_${name}.csv"
        tmp_json_file=/tmp/json_${name}.txt
        curl -s "https://maps.googleapis.com/maps/api/directions/json?origin=${locstart}&destination=${locdest}&key=$google_api_key" > $tmp_json_file


        distance=($(jq -r '.routes[0].legs[0].distance.value' $tmp_json_file))
        duration=($(jq -r '.routes[0].legs[0].duration.value' $tmp_json_file))

        if [[ $distance == "0" ]] && [[ $duration == "0" ]];then
                exit
        else
                grep -q "$date_hm,$distance,$duration" $csvfile
                if [[ $? == "1" ]];then
                        echo -e "$date_hm,$distance,$duration" >> $csvfile
                fi
        fi

        rm -f $tmp_json_file
}

call_jobs
