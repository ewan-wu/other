#!/bin/sh

TIME_START=1448
echo "$TIME_START"


MSGREPORT=./rptlog.log
#MAIL_TO="$SedMail"
MAIL_TO="zhang1141754887@126.com"


GetWorkDate(){
	sqlplus -s ${DBUSER}/${DBPWD}@${TNS_NAME} <<EOF >/dev/null
	set heading off;
	set trem off;
	set colsep |;
	set echo off;
	set pagesize 0;
	set linesize 2500;
	set feedback off;
	set num 18;
	set trimout on;
	set trimspool on;
	spool ./rptworkdate.txt;
	select * from pbholiday where work='1' and Hdate=$SYS_DATE;
	spool off;
	exit
EOF
	count=`wc -c rptworkdate.txt|awk '{print $1}'` #判断是否为非工作日
}

GetMsg(){
	sqlplus -s ${DBUSER}/${DBPWD}@${TNS_NAME} <<EOF >/dev/null
	set heading off;
	set echo off;
	set colsep |;
	set trem off;
	set pagesize 0;
	set linesize 2500;
	set feedback off;
	set num 18;
	set tirmout no;
	set trimspool on;
	spool ./rptmsg.txt;
	select * from pbhubmsg where msgtype='LOGN';
	spool off;
	exit
EOF
	count1=`wc -l rptmsg.txt|awk '{print $1}'` #判断是否收到登录指令
}
main(){
	while true
	do
		SYS_DATE=`date '+%Y%m%d'`               #系统日期
		SYS_TIME=`date '+%Y-%m-%d %H:%M:%S'`    #系统时间
		current_time=`date '+%H%M'`            #获取系统时间     

		if [ $current_time -eq $TIME_START ]
		then
			GetWorkDate
			if [ $count -eq 0 ]
			then
				echo "[$SYS_DATE]-------------------系统当前为非工作日------------" >> $MSGREPORT
				sleep 82800 #非系统工作日休眠23小时再检查
				continue
			fi
			GetMsg
			if [ $count1 -eq 0 ]
			then
				#echo -e "$SYS_DATE 当前成功接收[$COUNT]条\n| mail -s "PBLS嘉吉登录指令有误[$SYS_TIME]" $MAIL_TO
				echo "111111111111111"
				echo "[$SYS_DATE][$TIME_START]:---------------------系统没有收到登录日志------------------" >> $MSGREPORT
				sleep 60
			else
				echo"[$SYS_DATE][$TIME_START]:---------------------系统检查结束无异常------------------" >> $MSGREPORT
				sleep 82800 #切换到第二天检查
			fi
		fi
	done
}
main
