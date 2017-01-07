#!/bin/bash
#######################
######## Setup ########
#######################

# Get $captcha_api
cfg=`/bin/echo $0|cut -d '.' -f1`.cfg
[ -f "$cfg" ] && source "$cfg" || /bin/echo "Error - config <$cfg> is missing. Do not use additional . in path to call the script, except for ending."

cd $path
if [[ update_gitrepos -eq 1 ]];then
	/bin/echo "Git update.."
	used=`grep start_map /home/pi/scripts/pogo/start.cfg |grep -v "#" |awk -F ' ' {'print $2'}|tr '\n' ' '`
	for i in $used;do /bin/echo "##### $i";cd $path/$i;/usr/bin/git pull;done
fi

function start_map(){
	map="$1"
	port=$2
	steps="$3"
	db="$4"
	loc="$5"
	echo "map: <$map> - port: <$port> - steps: <$steps> - db: <$db> - loc: <$loc>"
	/bin/ps aux|grep -v grep|egrep -w "$loc|$path/$map" > /dev/null 2>&1
	if [[ $? -eq 1 ]];then
		[ $captcha -eq 1 ] && /usr/bin/screen -d -S $map -m /bin/bash -c "$python_bin $path/$map/runserver.py -speed --location $loc --port $port --host $host --db-type $db_type  --db-name $db --db-user $db_user --db-pass $db_pw  --db-host $db_host --db-port $db_port --gmaps-key $gmaps_key --status-name $map --step-limit $steps --locale de -cs -ck $captcha_api" \
				|| /usr/bin/screen -d -S $map -m /bin/bash -c "$python_bin $path/$map/runserver.py -speed --location $loc --port $port --host $host  --locale de"
	else
		/bin/echo -e "Map <$map>:\t\tAlready running"
	fi

}

call_jobs
