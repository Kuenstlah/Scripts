#!/bin/bash
#######################
######## Setup ########
#######################

# Get $captcha_api
cfg=`echo $0|cut -d '.' -f1`.cfg
[ -f "$cfg" ] && source "$cfg" || echo "Error - config <$cfg> is missing. Do not use additional . in path to call the script, except for ending."

cd $path
if [[ update_gitrepos -eq 1 ]];then
	echo "Git update.."
	for i in `ls -1 $path|grep "pogomap_"`;do echo "##### $i";cd $path/$i;git pull;done
fi

function start_map(){
	map="$1"
	port=$2
	loc="$3"
	ps aux|grep -v grep|egrep -w "$loc|$path/$map" > /dev/null 2>&1
	if [[ $? -eq 1 ]];then
		echo -e "Map <$map>:\t\tStarting"
		[ $captcha -eq 1 ] && screen -d -S $map -m bash -c "$python_bin $path/$map/runserver.py --location '$2' --port $port --host $host  --locale de -cs -ck $captcha_api " \
				|| screen -d -S $map -m bash -c "$python_bin $path/$map/runserver.py --location '$2' --port $port --host $host  --locale de"
	else
		echo -e "Map <$map>:\t\tAlready running"
	fi

}

call_jobs