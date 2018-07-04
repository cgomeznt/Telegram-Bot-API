#!/bin/bash

while true
do
sleep 15

source ./conf/botAPI.conf
source ./bin/WS
source ./bin/logs
source ./bin/security
source ./bin/validations
source ./bin/commands

# Funciones de WS
getMeBot
getUpdatesBot
getWebHookInfoBot
# Funciones de commands
poblarVar
showVar


# Verifica la existencia de "pending_update_count" y si hay los libera.
# Cuidado con esto...!!! los puede volver locos
# https://api.telegram.org/bot517700779:AAERzljXV_q2tGbIam_npSzw3Oa6GvEoFwc/getWebhookInfo
deletePendingUpdate


#
# Valida que no se repita el ultimo mensaje
#
echo "Este es last_message_id"
cat $last_message_id
echo "Est message_id = $message_id"
if [ `cat $last_message_id` -eq $message_id ] ; then
   echo -e "El ID de mensaje no ha variado..!!!"
else
    
   # Como es otro mensaje lo almacena en archivo para que puede ser leido luego y comparar
   echo "$message_id" > $last_message_id

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
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/port_status"` ] ; then
       echo "Es port_status"
       logsInfo 
       if [ `portStatusValidation` -eq 0 ] ; then
           continue
       fi
       portStatus 
       sendMessageBot $id_chat `cat $ruta_port_status`
       rm $ruta_port_status
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/port_start"` ] ; then
       echo "Es port_start"
       logsInfo 
       if [ portStartValidation -eq 0 ] ; then
           continue
       fi
       portStart `echo $textMessage | awk '{print $2}'`
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/port_stop"` ] ; then
       echo "Es port_stop"
       logsInfo 
       if [ `portStopValidation` -eq 0 ] ; then
           continue
       fi
       portStop `echo $textMessage | awk '{print $2}'`
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/list_client"` ] ; then
       echo "Es list_client"
       logsInfo 
       ruta_client_tmp=`listClient`
       ruta_filetmp=`modifyMessages $ruta_client_tmp` 
       sendMessageBot $id_chat `cat $ruta_filetmp`
       rm $ruta_client_tmp
       rm $ruta_filetmp
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/list_branch"` ] ; then
       echo "Es list__branch"
       logsInfo 
       if [ `listBranchValidation` -eq 0 ] ; then
           continue
       fi
       client_tmp=`echo $textMessage | awk '{print $2}'` 
       ruta_client_dir_tmp=`listBranch $client_tmp`
       ruta_filetmp=`modifyMessages $ruta_client_dir_tmp`
       sendMessageBot $id_chat `cat $ruta_filetmp`
       rm $ruta_client_dir_tmp
       rm $ruta_filetmp
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/list_port"` ] ; then
       echo "Es list_port"
       logsInfo
       if [ `listPortValidation` -eq 0 ] ; then
           continue
       fi
       client_tmp=`echo $textMessage | awk '{print $2}'`
       rama_tmp=`echo $textMessage | awk '{print $3}'`
       ruta_client_port_tmp=`listPort $client_tmp $rama_tmp`
       ruta_filetmp=`modifyMessages $ruta_client_port_tmp`
       sendMessageBot $id_chat `cat $ruta_filetmp`
       rm $ruta_client_port_tmp
       rm $ruta_filetmp
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/git_info"` ] ; then
       echo "Es git_info"
       logsInfo
       if [ `gitInfoValidation` -eq 0 ] ; then
           continue
       fi
       client_tmp=`echo $textMessage | awk '{print $2}'`
       rama_tmp=`echo $textMessage | awk '{print $3}'`
       ruta_gitinfo_tmp=`gitInfoScript $client_tmp $rama_tmp`
       ruta_filetmp=`modifyMessages $ruta_gitinfo_tmp`
       sendMessageBot $id_chat `cat $ruta_filetmp`
       rm $ruta_gitinfo_tmp
       rm $ruta_filetmp
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/git_update"` ] ; then
       echo "Es git_update"
       logsInfo
       if [ `gitUpdateValidation` -eq 0 ] ; then
           continue
       fi
       client_tmp=`echo $textMessage | awk '{print $2}'`
       rama_tmp=`echo $textMessage | awk '{print $3}'`
       hash_tmp=`echo $textMessage | awk '{print $4}'`
       result_gitupdate=`gitUpdateScript $client_tmp $rama_tmp $hash_tmp`
       if [ $result_gitupdate -eq 0 ] ; then
           ruta_filetmp=`modifyMessages $ruta_gitupdate_good`   
       else
           ruta_filetmp=`modifyMessages $ruta_gitupdate_bad`
       fi       
       sendMessageBot $id_chat `cat $ruta_filetmp`
       rm $ruta_filetmp
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/make"` ] ; then
       logsInfo
       if [ `makeValidation` -eq 0 ] ; then
           continue
       fi
       client_tmp=`echo $textMessage | awk '{print $2}'`
       rama_tmp=`echo $textMessage | awk '{print $3}'`
       port_tmp=`echo $textMessage | awk '{print $4}'`
       result_make=`makeScript $client_tmp $rama_tmp $port_tmp`
       echo "Este es el resultado: $result_make"
       if [ $result_make -eq 0 ] ; then
           ruta_filetmp=`modifyMessages $ruta_make_good`
       else
           ruta_filetmp=`modifyMessages $ruta_make_bad`
       fi
       sendMessageBot $id_chat `cat $ruta_filetmp`
       rm $ruta_filetmp
       echo "Si hay make"
   elif [ `echo $textMessage | awk '{print $1}' | grep -w "/make_schematool"` ] ; then
       logsInfo
       if [ `makeValidation` -eq 0 ] ; then
           continue
       fi
       client_tmp=`echo $textMessage | awk '{print $2}'`
       rama_tmp=`echo $textMessage | awk '{print $3}'`
       port_tmp=`echo $textMessage | awk '{print $4}'`
       result_make=`makeSchemaToolScript $client_tmp $rama_tmp $port_tmp`
       echo "Este es el resultado: $result_make"
       if [ $result_make -eq 0 ] ; then
           ruta_filetmp=`modifyMessages $ruta_make_good`
       else
           ruta_filetmp=`modifyMessages $ruta_make_bad`
       fi
       sendMessageBot $id_chat `cat $ruta_filetmp`
       rm $ruta_filetmp
       echo "Si hay make"

   else
       echo "No es ninguna de las opciones validas para el bot"
       logsWarn
       ruta_filetmp=`modifyMessages $ruta_helperror`
       sendMessageBot $id_chat `cat $ruta_filetmp`
   fi
fi
done
