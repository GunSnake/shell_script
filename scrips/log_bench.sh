#!/bin/bash

#---------------------------------------------------------
# This bash script is use for copy log data which they are
# locate in different dirs into final dir.
# It backup and zip all your data into files, avoid any 
# mistake thus you run this in production environment.
# Release on MIT license.
# Author: GunSnake
# Email: GunSnake@anlike.cc
#---------------------------------------------------------

# 日志目标文件夹位置
final_dir='/Users/juntinlaker/data/api_logs/retailer_api'

# log back file
backup_name='back_log.tar.gz'

# 需要迁移的日志文件夹位置
template_dir='/Users/juntinlaker/data/api/retailer_api/logs'

#backup log folder
if [ $( uname ) != 'Linux' ];then
	tar -zcf $backup_name -P $final_dir
	if [ $( ls | grep $backup_name ) != $backup_name ]; then
		echo 'backup log failed, please try it again or confirm you have the permition';
		exit 2
	fi
	echo 'backup success!';
else
	echo 'not a Linux system, cant handle it';
	exit 2
fi

# 循环复制处理日志目录下的文件/文件夹
loop_cp ()
{
	local dir="$1"
	local destination_dir="$2/$1"
	if [ -d "$dir" ]; then
                cd $dir
		if [ ! -e $destination_dir ]; then
			mkdir $destination_dir
		fi
		for tem_dir in `ls`
		do
        	    loop_cp $tem_dir $destination_dir
		done
        fi
	if [ -f "$dir" ];then
		# 当存在同名文件时，复制两个文件的反并集到目标日志位置
		if [ -f "$destination_dir" ]; then
                	cp $dir $destination_dir | uniq -u | > $destination_dir
			echo "merge $destination_dir success" >> ~/result.log;
		else 
			cp $dir $destination_dir
			echo "copy $destination_dir success" >> ~/result.log;
		fi
        fi		
}
cd $template_dir

# 循环复制处理日志目录下的文件/文件夹
for move_tmp_dir in `ls`
do
	loop_cp $move_tmp_dir $final_dir
	cd $template_dir
done



exit 0
