#!/bin/bash

# Carga los archivos con las variables requeridas y todas las funciones
source ./conf/botAPI.conf
source ./bin/commands

function EjecutaportList {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/port_list+$2"
    grep -v \# $port_list | awk '{print $1}' > $ruta_port_list
    varPL=`cat $ruta_port_list`
    echo $varPL > $ruta_port_list
    sed -i -e 's/ /\%0A/g' $ruta_port_list
    msgtmps=`cat $ruta_port_list`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps"
}

function EjecutaportStatus {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/port_status+$2"
    puerto=`echo $textMessage | awk '{print $2}'`
    status=`netstat -nat | grep -i listen | grep $2 | wc -l`
    if [ $status -eq 0 ] ; then
        # echo "El puerto $puerto, es inaccesible"
        echo "El puerto $2, es inaccesible" > $ruta_port_status
        sed -i -e 's/ /\%20/g' $ruta_port_status
        msgtmps=`cat $ruta_port_status`
        curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps"
    else
        # echo "El puerto $puerto, esta operativo"
        echo "El puerto $2, esta operativo" > $ruta_port_status
        sed -i -e 's/ /\%20/g' $ruta_port_status
        msgtmps=`cat $ruta_port_status`
        curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps"
    fi
}

function EjecutalistClient {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/list_client"
    filetmp=`date +%Y%m%d%M%S`
    for i in `ls $ruta_workspace`
    do
       if [ -d $ruta_workspace/$i ] ; then echo $i >> "./tmp/.listclient$filetmp.tmp" ; fi
    done
    echo "./tmp/.listclient$filetmp.tmp"
    ruta_client_tmp="./tmp/.listclient$filetmp.tmp"
    ruta_filetmp=`modifyMessages $ruta_client_tmp`
    msgtmps=`cat $ruta_filetmp`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps"
    rm $ruta_client_tmp
    rm $ruta_filetmp
}

function EjecutaStart {
   msgtmp=`cat $ruta_espere_procesando`
   curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/port_start+$3"
   $ruta_scripts/port.sh $2 $3
   if [ $? -eq 0 ] ; then
       message_start=`cat $ruta_port_start | grep -v \# | head -1 | sed 's/ /%20/g'`
       message_start="$message_start%20$3"
       curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$message_start"
   else
       message_start=`cat $ruta_port_start | grep -v \# | tail -1 | sed 's/ /%20/g'`
       message_start="$message_start%20$3"
       curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$message_start"
   fi
}

function EjecutaStop {
   msgtmp=`cat $ruta_espere_procesando`
   curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/port_stop+$3"
   $ruta_scripts/port.sh $2 $3
      if [ $? -eq 0 ] ; then
       message_stop=`cat $ruta_port_stop | grep -v \# | head -1 | sed 's/ /%20/g'`
       message_stop="$message_stop%20$3"
       curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$message_stop"
   else
       message_stop=`cat $ruta_port_stop | grep -v \# | tail -1 | sed 's/ /%20/g'`
       message_stop="$message_stop%20$3"
       curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$message_stop"
   fi
}

function EjecutalistBranch {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/list_branch+$2"
    filetmp=`date +%Y%m%d%M%S`
    for i in `ls $ruta_workspace/$2`
    do
       if [ -d $ruta_workspace/$2/$i ] ; then echo $i >> "./tmp/.listclientdir$filetmp.tmp" ; fi
    done
    echo "./tmp/.listclientdir$filetmp.tmp"
    ruta_client_dir_tmp="./tmp/.listclientdir$filetmp.tmp"
    ruta_filetmp=`modifyMessages $ruta_client_dir_tmp`
    msgtmps=`cat $ruta_filetmp`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps"
    rm $ruta_client_dir_tmp
    rm $ruta_filetmp
}

function EjecutalistPort {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/list_port+$2+$3"
    filetmp=`date +%Y%m%d%M%S`
    for i in `ls $ruta_workspace/$2/$3/$ruta_branches`
    do
       if [ -d $ruta_workspace/$2/$3/$ruta_branches/$i ] ; then echo $i >> "./tmp/.listclientport$filetmp.tmp" ; fi
    done
    echo "./tmp/.listclientport$filetmp.tmp"
    ruta_client_port_tmp="./tmp/.listclientport$filetmp.tmp"
    ruta_filetmp=`modifyMessages $ruta_client_port_tmp`
    msgtmps=`cat $ruta_filetmp`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps"
    rm $ruta_client_port_tmp
    rm $ruta_filetmp
}


function EjecutagitInfoScript {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/git_info+$2+$3"
    filetmp=`date +%Y%m%d%M%S`
    cd $ruta_workspace/$2/$3
    echo "IMPRIME PWD"
    pwd
    git-info.sh >> "$ruta_botAPI/tmp/.gitinfo$filetmp.tmp"
    echo "./tmp/.gitinfo$filetmp.tmp"
    cd $ruta_botAPI
    ruta_gitinfo_tmp="./tmp/.gitinfo$filetmp.tmp"
    ruta_filetmp=`modifyMessages $ruta_gitinfo_tmp`
    echo "ruta_gitinfo_tmp $ruta_gitinfo_tmp"
    echo "ruta_filetmp $ruta_filetmp"
    msgtmps=`cat $ruta_filetmp`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps"
    rm $ruta_gitinfo_tmp
    rm $ruta_filetmp
}

function EjecutagitUpdateScript {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/git_update+$2+$3"
    filetmp=`date +%Y%m%d%M%S`
    cd $ruta_workspace/$2/$3
    git-update.sh > /dev/null
    if [ $? -eq 0 ] ; then
        sw="0"
        cd $ruta_botAPI
        ruta_filetmp=`modifyMessages $ruta_gitupdate_good`
    else
        sw="1"
        cd $ruta_botAPI
        ruta_filetmp=`modifyMessages $ruta_gitupdate_bad`
    fi
    echo "$sw"
    msgtmps=`cat $ruta_filetmp`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps"
    rm $ruta_filetmp
}

function EjecutamakeScript {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/make+$2+$3+$4+Esto+Puede+Demorar+de+20+a+30+min"
    cd $ruta_workspace/$2/$3/scm/Make_EAR/*$4
    if [ $? -eq 0 ] ; then
        ./make.sh $4 > 2&>1 /dev/null
        if [ $? -eq 0 ] ; then
           sw="0"
           cd $ruta_botAPI
           ruta_filetmp=`modifyMessages $ruta_make_good`
        else
           sw="1"
           cd $ruta_botAPI
           ruta_filetmp=`modifyMessages $ruta_make_bad`
       fi
    else
      sw="1"
    fi
    echo "$sw"
    msgtmps=`cat $ruta_filetmp`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps+de+$2+$3+$4"
    rm $ruta_filetmp
}

function EjecutamakeSchematoolScript {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/make+$2+$3+$4+Esto+Puede+Demorar+de+20+a+30+min"
    cd $ruta_workspace/$2/$3/scm/Make_EAR/*$4
    if [ $? -eq 0 ] ; then
        ./make.sh $4 s > 2&>1 /dev/null
        if [ $? -eq 0 ] ; then
           sw="0"
           cd $ruta_botAPI
           ruta_filetmp=`modifyMessages $ruta_make_good`
        else
           sw="1"
           cd $ruta_botAPI
           ruta_filetmp=`modifyMessages $ruta_make_bad`
       fi
    else
      sw="1"
    fi
    echo "$sw"
    msgtmps=`cat $ruta_filetmp`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmps+de+$2+$3+$4"
    rm $ruta_filetmp
}

function EjecutaassignTicket {
    msgtmp=`cat $ruta_espere_procesando`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=$msgtmp+/assing_ticket+$2+$3"
    curl \
        -D- \
        -u 'cgomez':'America21' \
        -X PUT \
        --data {\"fields\":{\"customfield_10171\":{\"name\":\"$3\"}}} \
        -H "Content-Type: application/json" \
        "https://consisint.atlassian.net/rest/api/2/issue/$2"
    msgtmps=`cat $ruta_filetmp`
    curl -k -s -X POST "https://api.telegram.org/bot$tokenbot/sendmessage?chat_id=$1&text=Se+asigno+el+ticket+$2+a+$3"
    rm $ruta_filetmp
}


read id
read escript
read argumento
read puerto
read adicional

if [ $escript == "port.sh" ] && [ $argumento == "stop" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutaStop  $id $argumento $puerto
   unset -f EjecutaStop
fi
if [ $escript == "port.sh" ] && [ $argumento == "start" ] ; then
   echo "El id_chat es $1, El script es $2 y el argumento es $3 y el puerto es $4"
   EjecutaStart  $id $argumento $puerto
   unset -f EjecutaStart
fi
if [ $escript == "port_list.sh" ] ; then

   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutaportList $id $puerto
   unset -f EjecutaportList
fi
if [ $escript == "port_status.sh" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutaportStatus $id $puerto
   unset -f EjecutaportStatus
fi
if [ $escript == "list_client.sh" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutalistClient $id
   unset -f EjecutalistClient
fi
if [ $escript == "list_branch.sh" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutalistBranch $id $puerto
   unset -f EjecutalistBranch
fi
if [ $escript == "list_port.sh" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutalistPort $id $argumento $puerto
   unset -f EjecutalistPort
fi
if [ $escript == "git_info.sh" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutagitInfoScript $id $argumento $puerto
   unset -f EjecutagitInfoScript
fi
if [ $escript == "git_update.sh" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutagitUpdateScript $id $argumento $puerto
   unset -f EjecutagitUpdateScript
fi
if [ $escript == "make.sh" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutamakeScript $id $argumento $adicional $puerto
   unset -f EjecutamakeScript
fi
if [ $escript == "make_schematool.sh" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutamakeSchematoolScript  $id $argumento $adicional $puerto
   unset -f EjecutamakeSchematoolScript
fi
if [ $escript == "assign_ticket.sh" ] ; then
   echo "El id_chat es $id, El script es $escript y el argumento es $argumento y el puerto es $puerto"
   EjecutaassignTicket  $id $argumento $puerto
   unset -f EjecutaassignTicket
fi

