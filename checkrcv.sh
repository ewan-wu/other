#!/bin/sh

TIME_START=1455
echo "$TIME_START"

LOGFIELRCV=./rcvlog.log

#MAIL_TO="$sendmail.com"
MAIL_TO="zhang1141754887@126.com"


GetData(){
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
	spool ./rcvmsg.txt
	select * from icbc_40005_req_txn where status='01' and 
	ACCNO in ('100126119216227928','100126119216236409','2010027919200066838','2010027919024530788','1111824119100370609','2014002109040057802');
	spool off;
	exit
EOF
	count=`wc -l rcvmsg.txt |awk '{print $1}'` #判断查询指令成功条数
}

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
	spool ./rcvworkdate.txt
	select Hdate,work from pbholiday where work='1' and Hdate=$SYS_DATE;
	spool off;
	exit
EOF
	count1=`wc -c rcvworkdate.txt |awk '{print $1}'` #判断是否为工作日期空为工作日期
}


main(){
	while true 
	do
		SYS_DATE=`date '+%Y%m%d'`               #系统日期
		SYS_TIME=`date '+%Y-%m-%d %H:%M:%S'`    #系统时间

		current_time=`date '+%H%M'`             #获取系统时间
		if [ $current_time -eq $TIME_START ]
		then
			GetWorkDate
			if [ $count1 -eq 0 ]
			then
				echo "[$SYS_DATE]:-------非工作日--------------" >> $LOGFIELRCV
				sleep 82800 #休眠23小时后再检查
				continue
			fi
			echo "[$SYS_DATE][$SYS_TIME]:--------------检查开始---------------" >> $LOGFIELRCV
			GetData
			if [ $count -ne 6 ] 
			then
				#echo -e "$SYS_DATE 当前成功接收[$COUNT]条\n| mail -s "PBLS嘉吉余额查询有误[$SYS_TIME]" $MAIL_TO
				echo "1111111111111111"
				echo "[$SYS_DATE][$SYS_TIME]:-----------------PBLS嘉吉查询有误，请注意!----------" >> $LOGFIELRCV
               sleep 60
		   else
			   echo "[$SYS_DATE][$SYS_TIME]:-----------------PBLS嘉吉付款查询成功返回------------------" >> $LOGFIELRCV
			   sleep 82800 #切换到第二天检查 
			fi
		fi
	done
}
main
