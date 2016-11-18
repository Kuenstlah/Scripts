#!/bin/bash
for id in `screen -x|grep "\.p"|awk -F '.' {'print $1'}|tr '\n' ' '`;do echo $id;screen -x $id;done
