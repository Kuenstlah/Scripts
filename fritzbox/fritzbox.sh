#!/bin/bash

#filename=`basename "$0"`
#filename="${filename%.*}"
pwd=`pwd`

xmlpath=/share/Web/xml/
xmlfile="$xmlpath/fritz_$1.xml"

date_hm=`date "+%m-%d-%Y %H:%M"`

if [[ $1 == 'status' ]];then
	echo '<?xml version="1.0" encoding="utf-8"?><fritzxml>' > $xmlfile
	curl -s "http://fritz.box:49000/igdupnp/control/WANIPConn1" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANIPConnection:1#GetStatusInfo" -d "@/share/Web/scripts/fritzbox/connection_state.xml" | egrep "New" >> $xmlfile
	echo '</fritzxml>' >> $xmlfile
elif [[ $1 == 'linkspeed' ]];then
	echo '<?xml version="1.0" encoding="utf-8"?><fritzxml>' > $xmlfile
	curl -s "http://fritz.box:49000/igdupnp/control/WANCommonIFC1" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1#GetAddonInfos" -d "@/share/Web/scripts/fritzbox/linkspeed.xml" | egrep "New" >> $xmlfile
	echo '</fritzxml>' >> $xmlfile
	current_rows=`wc -l $xmlfile.chart.csv| awk -F ' ' {'print $1'}`
	if [[ $current_rows -ge 70 ]];then
		/bin/sed 2D -i $xmlfile.chart.csv
	fi
	sendrate=`awk -F "[><]" '/NewByteSendRate/{print $3}' $xmlfile`
	receiverate=`awk -F "[><]" '/NewByteReceiveRate/{print $3}' $xmlfile`
	sendrate_new="$(($sendrate/1024/1024))"
	receiverate_new="$(($receiverate/1024/1024))"
	if [[ $sendrate_new == "0" ]] && [[ $receiverate_new == "0" ]];then 
		exit
	else
		grep -q "$date_hm," $xmlfile.chart.csv
		if [[ $? == "1" ]];then 
			echo -e "$date_hm,$receiverate_new,$sendrate_new" >> $xmlfile.chart.csv
		fi
	fi

else
	echo "Wrong parameter. Exiting."
	exit;
fi
