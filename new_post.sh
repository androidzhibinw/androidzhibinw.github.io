#!/bin/bash


help_msg="Usage:new_post.sh  your-title"
if [ "$#" -ne 1 ];then
     echo $help_msg
     exit
fi

time=`date +%Y-%m-%d`
echo $time

title=$1

cp _posts/yyyy-mm-dd-template.md _posts/${time}-${title}.md

