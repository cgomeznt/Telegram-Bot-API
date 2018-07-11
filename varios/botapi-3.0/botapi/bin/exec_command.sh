#!/bin/bash

PIDactual=$$

# Carga los archivos con las variables requeridas  todas las funciones
source ./conf/botToken.conf
source ./conf/paths.conf
source ./functions/webservices
source ./functions/logs
source ./functions/security
source ./functions/validations
source ./functions/commands
source ./functions/clearing

# Se obtiene la varible enviada desde el script principal
read forfile

cat ./tmp/command_$forfile.tmp | grep -v \# | awk -F":" '{print $1"="$2}' > ./tmp/var_$forfile.tmp
rm ./tmp/command_$forfile.tmp
source ./tmp/var_$forfile.tmp
rm ./tmp/var_$forfile.tmp
# showVar

# Como telegram deja registro de todos los comandos que son enviados al bot debemos ir limpiando, con esto
# con esto logramos que el bot no se colapse por la cantidad de mensajes  tambien con esto logramos 
# que el script pueda procesar todos los comando que ciertamente esten encolados 
update_id=$((update_id+1))
deletePendingUpdate $update_id

# Aqui estan las opciones del bot a las cuales el respondera.
if [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/help"` ] ; then
       logRunning 
       ruta_filetmp=`modifyMessages $ruta_help`
       sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
       rm $ruta_filetmp
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/port_list"` ] ; then
       logRunning 
       ruta_filetmp=`modifyMessages $ruta_espere_procesando`
       sendMessageBot $message_chat_id "`cat $ruta_filetmp`/port_list++el+PID:+$PIDactual"
       rm $ruta_filetmp
       grep -v \# $port_list | awk '{print $1}' > $ruta_port_list
       ruta_filetmp=`modifyMessages $ruta_port_list`
       sendMessageBot $message_chat_id `cat $ruta_filetmp`
       rm $ruta_filetmp
elif [  `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/port_status"` ] ; then
       logRunning
       ruta_filetmp=`modifyMessages $ruta_espere_procesando`
       sendMessageBot $message_chat_id "`cat $ruta_filetmp`/port_status++el+PID:+$PIDactual"
       rm $ruta_filetmp
       if [ `portStatusValidation` -eq 1 ] ; then
	       puerto=`echo $message_text | awk '{print $2}'`
	       status=`netstat -nat | grep -i listen | grep $puerto | wc -l`
	       if [ $status -eq 0 ] ; then
		   echo "El puerto $puerto, es inaccesible" > ./tmp/portstatus$forfile.tmp
		   ruta_filetmp=`modifyMessages ./tmp/portstatus$forfile.tmp`
		   sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
		   rm ./tmp/portstatus$forfile.tmp
		   rm $ruta_filetmp
	       else
		   echo "El puerto $2, esta operativo" > ./tmp/portstatus$forfile.tmp
		   ruta_filetmp=`modifyMessages ./tmp/portstatus$forfile.tmp`
		   sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
		   rm ./tmp/portstatus$forfile.tmp
		   rm $ruta_filetmp
		fi
       fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/port_start"` ] ; then
       logRunning
       if [ `portStatusValidation` -eq 1 ] ; then
		puerto=`echo $message_text | tr -d "\"" | awk '{print $2}'`
       		ruta_filetmp=`modifyMessages $ruta_espere_procesando`
       		sendMessageBot $message_chat_id "`cat $ruta_filetmp`/port_start+$puerto++el+PID:+$PIDactual"
       		rm $ruta_filetmp	
		$ruta_scripts/port.sh start $puerto
		# echo " $ruta_scripts/port.sh start $puerto "
		if [ $? -eq 0 ] ; then
			ruta_filetmp=`modifyMessages $ruta_port_start_ok`
			sendMessageBot $message_chat_id "`cat $ruta_filetmp`$puerto"
			rm $ruta_filetmp
		else
                        ruta_filetmp=`modifyMessages $ruta_port_start_bad`
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`$puerto"
                        rm $ruta_filetmp
		fi
	fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/port_stop"` ] ; then
       logRunning
       if [ `portStatusValidation` -eq 1 ] ; then
                puerto=`echo $message_text | tr -d "\"" | awk '{print $2}'`
                ruta_filetmp=`modifyMessages $ruta_espere_procesando`
                sendMessageBot $message_chat_id "`cat $ruta_filetmp`/port_stop+$puerto++el+PID:+$PIDactual"
                rm $ruta_filetmp     
                $ruta_scripts/port.sh stop $puerto -c
                if [ $? -eq 0 ] ; then
                        ruta_filetmp=`modifyMessages $ruta_port_stop_ok`
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`$puerto"
                        rm $ruta_filetmp
                else
                        ruta_filetmp=`modifyMessages $ruta_port_stop_bad`
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`$puerto"
                        rm $ruta_filetmp
                fi
        fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/list_client"` ] ; then
	logRunning
	ruta_filetmp=`modifyMessages $ruta_espere_procesando`
	sendMessageBot $message_chat_id "`cat $ruta_filetmp`/list_client++el+PID:+$PIDactual"
	rm $ruta_filetmp
	for i in `ls $ruta_workspace`
    	do
        	if [ -d $ruta_workspace/$i ] ; then echo $i >> "./tmp/listclient$forfile.tmp" ; fi
	done
    	ruta_client_tmp="./tmp/listclient$forfile.tmp"
	ruta_filetmp=`modifyMessages $ruta_client_tmp`
	sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
    	rm $ruta_client_tmp
    	rm $ruta_filetmp
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/list_branch"` ] ; then
	logRunning
	ruta_filetmp=`modifyMessages $ruta_espere_procesando`
	sendMessageBot $message_chat_id "`cat $ruta_filetmp`/list_branch++el+PID:+$PIDactual"
	rm $ruta_filetmp
        cliente=`echo $message_text | tr -d "\"" | awk '{print $2}'`
       	if [ `listBranchValidation` -eq 1 ] ; then
       		for i in `ls $ruta_workspace/$cliente`
        	do
                	if [ -d $ruta_workspace/$cliente/$i ] ; then echo $i >> "./tmp/listclient$forfile.tmp" ; fi
        	done
	        ruta_client_tmp="./tmp/listclient$forfile.tmp"
        	ruta_filetmp=`modifyMessages $ruta_client_tmp`
	        sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
	        rm $ruta_client_tmp
	        rm $ruta_filetmp
	fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/list_port"` ] ; then
	logRunning
	ruta_filetmp=`modifyMessages $ruta_espere_procesando`
	sendMessageBot $message_chat_id "`cat $ruta_filetmp`/list_port+$cliente+$branch++el+PID:+$PIDactual"
	rm $ruta_filetmp
        cliente=`echo $message_text | tr -d "\"" | awk '{print $2}'`
        branch=`echo $message_text | tr -d "\"" | awk '{print $3}'`
        if [ `listPortValidation` -eq 1 ] ; then
                for i in `ls $ruta_workspace/$cliente/$branch/$ruta_branches`
                do
                	if [ -d $ruta_workspace/$cliente/$branch/$ruta_branches/$i ] ; then echo $i >> "./tmp/listclient$forfile.tmp" 
		fi
                done
                ruta_client_tmp="./tmp/listclient$forfile.tmp"
                ruta_filetmp=`modifyMessages $ruta_client_tmp`
                sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
                rm $ruta_client_tmp
                rm $ruta_filetmp
        fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/git_info"` ] ; then
	logRunning
        cliente=`echo $message_text | tr -d "\"" | awk '{print $2}'`
        branch=`echo $message_text | tr -d "\"" | awk '{print $3}'`
	ruta_filetmp=`modifyMessages $ruta_espere_procesando`
	sendMessageBot $message_chat_id "`cat $ruta_filetmp`/git_info+$cliente+$branch++el+PID:+$PIDactual"
	rm $ruta_filetmp
        if [ `gitPathValidation` -eq 1 ] ; then
    		cd $ruta_workspace/$cliente/$branch
    		git-info.sh >> "$ruta_botapi/tmp/gitinfo$forfile.tmp"
    		cd $ruta_botapi
		ruta_gitinfo_tmp="./tmp/gitinfo$forfile.tmp"
    		ruta_filetmp=`modifyMessages $ruta_gitinfo_tmp`
		sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
    		rm $ruta_gitinfo_tmp
		rm $ruta_filetmp
	fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/git_update"` ] ; then
        logRunning
        cliente=`echo $message_text | tr -d "\"" | awk '{print $2}'`
        branch=`echo $message_text | tr -d "\"" | awk '{print $3}'`
        ruta_filetmp=`modifyMessages $ruta_espere_procesando`
        sendMessageBot $message_chat_id "`cat $ruta_filetmp`/git_update+$cliente+$branc++el+PID:+$PIDactual"
        rm $ruta_filetmp
        if [ `gitPathValidation` -eq 1 ] ; then
                cd $ruta_workspace/$cliente/$branch
                git-update.sh >> "$ruta_botapi/tmp/gitinfo$forfile.tmp"
		if [ $? -eq 0 ] ; then
                	cd $ruta_botapi
                	ruta_filetmp=`modifyMessages $ruta_gitupdate_good`
                	sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
                	rm $ruta_gitinfo_tmp
                	rm $ruta_filetmp
		else
                        cd $ruta_botapi
                        ruta_filetmp=`modifyMessages $ruta_gitupdate_bad`
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
                        rm $ruta_gitinfo_tmp
                        rm $ruta_filetmp
		fi
        fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/make"` ] ; then
        logRunning
        cliente=`echo $message_text | tr -d "\"" | awk '{print $2}'`
        branch=`echo $message_text | tr -d "\"" | awk '{print $3}'`
        puerto=`echo $message_text | tr -d "\"" | awk '{print $4}'`
        ruta_filetmp=`modifyMessages $ruta_espere_procesando`
        sendMessageBot $message_chat_id "`cat $ruta_filetmp`/make+$cliente+$branch+$puerto++el+PID:+$PIDactual"
        rm $ruta_filetmp
        if [ `makeValidation` -eq 1 ] ; then
		cd $ruta_workspace/$cliente/$branch/$ruta_branches/*$puerto
                ./make.sh $puerto >> "$ruta_botapi/tmp/make$forfile.tmp"
                if [ $? -eq 0 ] ; then
                        cd $ruta_botapi
                        ruta_filetmp="`modifyMessages ./tmp/make$forfile.tmp`"
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
                        rm $ruta_filetmp
                else
                        cd $ruta_botapi
                        ruta_filetmp=`modifyMessages $ruta_make_bad`
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
                        rm $ruta_filetmp
                fi
		rm ./tmp/make$forfile.tmp

	fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/make_schematool"` ] ; then
        logRunning
        cliente=`echo $message_text | tr -d "\"" | awk '{print $2}'`
        branch=`echo $message_text | tr -d "\"" | awk '{print $3}'`
        puerto=`echo $message_text | tr -d "\"" | awk '{print $4}'`
        ruta_filetmp=`modifyMessages $ruta_espere_procesando`
        sendMessageBot $message_chat_id "`cat $ruta_filetmp`/make_schematool+$cliente+$branch+$puerto++el+PID:+$PIDactual"
        rm $ruta_filetmp
        if [ `makeValidation` -eq 1 ] ; then
                cd $ruta_workspace/$cliente/$branch/$ruta_branches/*$puerto
                ./make.sh $puerto s >> "$ruta_botapi/tmp/make$forfile.tmp"
                if [ $? -eq 0 ] ; then
                        cd $ruta_botapi
                        ruta_filetmp="`modifyMessages ./tmp/make$forfile.tmp`"
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
                        rm $ruta_filetmp
                else
                        cd $ruta_botapi
                        ruta_filetmp=`modifyMessages $ruta_make_bad`
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
                        rm $ruta_filetmp
                fi
		rm ./tmp/make$forfile.tmp

        fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/work_all"` ] ; then
        logRunning
        cliente=`echo $message_text | tr -d "\"" | awk '{print $2}'`
        branch=`echo $message_text | tr -d "\"" | awk '{print $3}'`
        puerto=`echo $message_text | tr -d "\"" | awk '{print $4}'`
        #scmematool=`echo $message_text | tr -d "\"" | awk '{print $5}'`
        ruta_filetmp=`modifyMessages $ruta_espere_procesando`
        sendMessageBot $message_chat_id "`cat $ruta_filetmp`/work_all+$cliente+$branch+$puerto++el+PID:+$PIDactual"
        rm $ruta_filetmp
        if [ `makeValidation` -eq 1 ] ; then
                ./bin/work_all.sh $cliente $branch $puerto s $tokenbot $message_chat_id >> "$ruta_botapi/tmp/work_all$forfile.tmp"
                if [ $? -eq 0 ] ; then
                        ruta_filetmp="`modifyMessages ./tmp/work_all$forfile.tmp`"
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
                        rm $ruta_filetmp
                else
                        ruta_filetmp=`modifyMessages $ruta_make_bad`
                        sendMessageBot $message_chat_id "`cat $ruta_filetmp`"
                        rm $ruta_filetmp
                fi
                rm ./tmp/work_all$forfile.tmp

        fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/assign_ticket"` ] ; then
        logRunning
        ticket=`echo $message_text | tr -d "\"" | awk '{print $2}'`
        usuario=`echo $message_text | tr -d "\"" | awk '{print $3}'`
        ruta_filetmp=`modifyMessages $ruta_espere_procesando`
        sendMessageBot $message_chat_id "`cat $ruta_filetmp`/assign_ticket+$ticket+$usuario++el+PID:+$PIDactual"
        rm $ruta_filetmp
        if [ `assignTicketValidation` -eq 1 ] ; then

	curl \
   	-D- \
	   -u 'cgomez':'America21' \
	   -X PUT \
	   --data {\"fields\":{\"customfield_10171\":{\"name\":\"$usuario\"}}} \
	   -H "Content-Type: application/json" \
	   "https://consisint.atlassian.net/rest/api/2/issue/$ticket"
        ruta_filetmp=`modifyMessages $ruta_make_bad`
        sendMessageBot $message_chat_id "Se+asigno+el+ticket+$ticket+a+$usuario"
        rm $ruta_filetmp
	fi
elif [ `echo $message_text | tr -d "\"" | awk '{print $1}' | grep -w "/admin"` ] ; then
       logRunning 
       ruta_filetmp=`modifyMessages $ruta_admin`
       sendMessageBot $message_chat_id `cat $ruta_filetmp`
       rm $ruta_filetmp
else
	# echo "No es ninguna de las opciones validas para el bot"
	logWarn
	ruta_filetmp=`modifyMessages $ruta_helperror`
	sendMessageBot $message_chat_id `cat $ruta_filetmp`
	rm $ruta_filetmp
fi

logFinish
rm ./tmp/pid_$PIDactual.tmp
clearVar
clearFunction

