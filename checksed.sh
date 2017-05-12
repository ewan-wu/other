#!/bin/sh

#if [ $# -eq 1 ]
#then
#	TIME_START=$1
#else
TIME_START=1652
TIME_START1=1653
TIME_START2=1654
TIME_START3=1655
#fi
#TIME_START=(0845 1100 1400 1610)
echo $TIME_START
echo $TIME_START1
echo $TIME_START2
echo $TIME_START3

LOGFILE=./sedLog.log
#MAIL_TO="$sendmail.com"
MAIL_TO="zhang1141754887@126.com"

GetWorkDate(){
	sqlplus -s ${DBUSER}/${DBPWD}@${TNS_NAME}<< EOF >/dev/null
	set heading off;
	set term off;
	set echo off;
	set pagesize 0;
	set linesize 2500;
	set trimspool on;
	set trimout on;
	set feedback off;
	set colsep |;
	set num 18;
	spool ./sedworkdate.txt;
	select * from pbholiday where work='1' and Hdate=$SYS_DATE;
	spool off;
	exit
EOF
	count2=`wc -c sedworkdate.txt |awk '{print $1}'` #判断是否为非工作日0为非工作日
}


GetSedMsg(){
	sqlplus -s ${DBUSER}/${DBPWD}@${TNS_NAME}<<EOF >/dev/null
	set heading off;
	set term off;
	set echo off;
	set pagesize 0;
	set linesize 2500;
	set trimspool on;
	set trimout on;
	set feedback off;
	set colsep |;
	set num 18;
	spool ./sedmsg.txt;
	select * from icbc_10017_req_txn where status='20' and SAC 
	in('100126119216227928','100126119216236409','2010027919200066838','2010027919024530788','1111824119100370609','2014002109040057802');
	spool off; 
	exit
EOF
	count=`wc -l sedmsg.txt|awk '{print $1}'` #判断前6条是否有发送失败，非空异常

}

#GetSedMsg1(){
#	sqlplus -s ${DBUSER}/${DBPWD}@${TNS_NAME}<<EOF >/dev/null
#	set heading off;
#	set term off;
#	set echo off;
#	set pagesize 0;
#	set linesize 2500;
#	set trimspool on;
#	set trimout on;
#	set feedback off;
#	set colsep |;
#	set num 18;
#	spool ./sedmsg1.txt;
#	select * from icbc_10017_req_txn where status in ('00','01','03') and SAC 
#	in('2010027919200066838','2010027919024530788','1111824119100370609','2014002109040057802');
#	spool off;
#	exit
#EOF
#	count1=`wc -l sedmsg1.txt|awk '{print $1}'` #判断必须检查的4条是否发送，不为4异常

#}

main(){
	while true
	do
		SYS_TIME=`date '+%Y-%m-%d %H:%M:%S'`            #系统时间
		SYS_DATE=`date '+%Y%m%d'`                       #系统日期

		#获取系统时间
		current_time=`date '+%H%M'`

		if [ $current_time -eq $TIME_START ]   #开始检查
		then
			GetWorkDate
			if [ $count2 -eq 0 ] 
			then
				echo "[$SYS_DATE]:--------系统当前不是工作时间----------" >> $LOGFILE
				sleep 82800
				continue
			fi
			GetSedMsg
			GetSedMsg1
			if [ $count -ne 0 ]
			then 
				#echo -e "$SYS_DATE 当前异常指令[$COUNT]条\n| mail -s "PBLS嘉吉客户付款指令发送异常记录[$SYS_TIME]" $MAIL_TO
				echo "123242321321"
				echo "[$SYS_DATE][$TIME_START]:-----------系统发送出错------------------" >> $LOGFILE
			else
				echo "[$SYS_DATE][$TIME_START]:-----------系统检查正常------------------" >> $LOGFILE
				sleep 60
				continue
			fi
		fi

		if [ $current_time -eq $TIME_START1 ] #11:00检查
		then
			GetSedMsg
			if [ $count -ne 0 ]
			then
				#echo -e "$SYS_DATE 当前异常指令[$COUNT]条\n| mail -s "PBLS嘉吉客户付款指令发送异常记录[$SYS_TIME]" $MAIL_TO
				echo "111111111111111"
				echo "[$SYS_DATE][$TIME_START1]:-----------系统发送出错------------------" >> $LOGFILE
			else
				echo "[$SYS_DATE][$TIME_START1]:-----------系统检查正常------------------" >> $LOGFILE
				sleep 60
			fi
		fi

		if [ $current_time -eq $TIME_START2 ] #14：00检查
		then
			GetSedMsg
			if [ $count -ne 0 ]
			then
				#echo -e "$SYS_DATE 当前异常指令[$COUNT]条\n| mail -s "PBLS嘉吉客户付款指令发送异常记录[$SYS_TIME]" $MAIL_TO
				echo "2222222222222"
				echo "[$SYS_DATE][$TIME_START2]:-----------系统发送出错------------------" >> $LOGFILE
			else
				echo "[$SYS_DATE][$TIME_START2]:-----------系统检查正常------------------" >> $LOGFILE
				sleep 60
			fi
		fi

		if [ $current_time -eq $TIME_START3 ] #16:10检查
		then
			GetSedMsg
			if [ $count -ne 0 ]
			then
				#echo -e "$SYS_DATE 当前异常指令[$COUNT]条\n| mail -s "PBLS嘉吉客户付款指令发送异常记录[$SYS_TIME]" $MAIL_TO
				echo "333333333333333"
				echo "[$SYS_DATE][$TIME_START3]:-----------系统发送出错------------------" >> $LOGFILE
			else
				echo "[$SYS_DATE][$TIME_START3]:-----------系统检查正常------------------" >> $LOGFILE
				sleep 57600
			fi
		fi  
	done
}
main
