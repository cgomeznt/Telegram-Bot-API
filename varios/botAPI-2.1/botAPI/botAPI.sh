#!/bin/bash

last_message="0"
# Ciclo que hace que el script se este ejecutando cada 15, este script no depende del CRON
while true
do
sleep 7

# Carga los archivos con las variables requeridas y todas las funciones
source ./conf/botAPI.conf
source ./bin/WS
source ./bin/logs
source ./bin/security
source ./bin/validations
source ./bin/commands

# Ejecuta las Funciones de WS
getMeBot
getUpdatesBot
getWebHookInfoBot

# Ejecuta las Funciones de commands
poblarVar


# Verifica la existencia de "pending_update_count" y si hay los libera.
# Los "pending_update_count" son los mensajes que no se han marcado como leidos y esto ocaciona que se llene esta informacion hasta el punto que no acepta mas mensajes y por lo tanto deja de procesar el bot.
# Cuidado con esto...!!! los puede volver locos
# https://api.telegram.org/bot517700779:AAERzljXV_q2tGbIam_npSzw3Oa6GvEoFwc/getWebhookInfo
deletePendingUpdate


#
# Valida que no se repita el ultimo mensaje al bot
#
# if [ `cat $last_message_id` -eq $message_id ] ; then
#    echo -e "El ID de mensaje no ha variado..!!!"
# else
if [ $last_message -eq $message_id ] || [ $last_message -eq 0 ] ; then
   echo -e "El ID de mensaje no ha variado..!!!"
   last_message="$message_id"
   clearVar
   showVar
else
    
   showVar
   # Como es otro mensaje lo almacena en archivo para que puede ser leido luego y comparar
   # echo "$message_id" > $last_message_id
   last_message="$message_id"

   # Valida que sea un usuario autorizado
   if [ `getIdAuthorized` -eq 0 ] ; then
       continue
   fi
   # Aqui estan las opciones del bot a las cuales el respondera.
   if [ `echo $textMessage | awk '{print $1}' | grep -w "/help"` ] ; then
       echo "Es help"
       logsInfo 
       ruta_filetmp=`modifyMessages $ruta_help`
       sendMessageBot $id_chat `cat $ruta_filetmp`
       rm $ruta_filetmp
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/port_list"` ] ; then
       echo "Es port_list"
       logsInfo 
       portList
       sendMessageBot $id_chat `cat $ruta_port_list`
       rm $ruta_port_list
       unset -f portList
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/port_status"` ] ; then
       echo "Es port_status"
       logsInfo 
       if [ `portStatusValidation` -eq 0 ] ; then
           continue
       fi
       portStatus 
       rm $ruta_port_status
       unset -f portStatus
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/port_start"` ] ; then
       echo "Es port_start"
       logsInfo 
       if [ portStartValidation -eq 0 ] ; then
           continue
       fi
       portStart `echo $textMessage | awk '{print $2}'`
       unset -f portStart
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/port_stop"` ] ; then
       echo "Es port_stop"
       logsInfo 
       if [ `portStopValidation` -eq 0 ] ; then
           continue
       fi
       portStop `echo $textMessage | awk '{print $2}'`
       unset -f portStop
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/list_client"` ] ; then
       echo "Es list_client"
       logsInfo 
       listClient
       unset -f listClient
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/list_branch"` ] ; then
       echo "Es list_branch"
       logsInfo 
       if [ `listBranchValidation` -eq 0 ] ; then
           continue
       fi
       listBranch
       unset -f listBranch
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/list_port"` ] ; then
       echo "Es list_port"
       logsInfo
       if [ `listPortValidation` -eq 0 ] ; then
           continue
       fi
       listPort
       unset -f listPort
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/git_info"` ] ; then
       echo "Es git_info"
       logsInfo
       if [ `gitInfoValidation` -eq 0 ] ; then
           continue
       fi
       gitInfoScript
       unset -f gitInfoScript
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/git_update"` ] ; then
       echo "Es git_update"
       logsInfo
       if [ `gitUpdateValidation` -eq 0 ] ; then
           continue
       fi
       gitUpdateScript
       unset -f gitUpdateScript
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/make"` ] ; then
       logsInfo
       if [ `makeValidation` -eq 0 ] ; then
           continue
       fi
       makeScript
       unset -f makeScript
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/make_schematool"` ] ; then
       logsInfo
       if [ `makeValidation` -eq 0 ] ; then
           continue
       fi
       makeSchemaToolScript
       unset -f makeSchemaToolScript
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/assign_ticket"` ] ; then
       logsInfo
       # if [ `makeValidation` -eq 0 ] ; then
       #     continue
       # fi
       assignTicket
       unset -f assignTicket
   else
       echo "No es ninguna de las opciones validas para el bot"
       logsWarn
       ruta_filetmp=`modifyMessages $ruta_helperror`
       sendMessageBot $id_chat `cat $ruta_filetmp`
   fi
fi
clearVar
done
