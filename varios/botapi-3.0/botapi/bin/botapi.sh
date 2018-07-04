#!/bin/bash

# last_message="0"
# Ciclo que hace que el script se este ejecutando cada 15, este script no depende del CRON

rm ./tmp/*
PIDactual=$$
echo $PIDactual > ./tmp/PID_actual.tmp
sw=0
while true
do

	# Carga los archivos con las variables requeridas y todas las funciones
	source ./conf/botToken.conf
	source ./conf/paths.conf
	source ./functions/webservices
	source ./functions/logs
	source ./functions/security
	source ./functions/validations
	source ./functions/commands
	source ./functions/clearing 

	# Ejecuta las Funciones de los WebServices para almacenari la salida en archivos locales.
	getMeBot
	getUpdatesBot
	getWebHookInfoBot


	# Ejecuta las Funciones de commands para cargar todas las variables requeridas por el sistema
	poblarVarBasic

	# Debemos obtener la cantidad de mensajes que estan pendientes por ejecutar y ver si tenemos varios poder procesarlos
	poblarVarWebhookInfo	

	
	# Validaciones, si no existe mensaje que continue para el poximo cliclo.
	if [ $update_id == "null" ] ; then
		# echo "There is not message"
		sleep 7
		continue
	fi

	# Cuando llegue cualquier mensaje lo debe registrar en el LOG
	logStart

	# Validacion, que el usuario tenga permisos de interactuar con el bot.
	# Estos permisos se otorgan en el archivo security/authorized.md
	# En dicho archivo se debe colocar el ID del usaurio y su nombre, separados por espacio en blanco
	if [ `userAuthorized` -eq 0 ] ; then
		logError "`cat $ruta_noAuthorized`"
		filetmp=`modifyMessages $ruta_noAuthorized`
		sendMessageBot $message_chat_id "$message_from_first_name,+ID: $message_from_id,+`cat $filetmp`"
		update_id=$((update_id+1))
		deletePendingUpdate $update_id
		rm $filetmp
		continue
	fi

	# Validacion, que el usuario tenga permisos sobre ciertos comandos o configuraciones
	# Estos permisos se otorgan creando un archivo con el ID del usuario en la ruta security/
	# y dentro de el colocamos los comando que NO queremos que ejecute el usuario
	# Un ejemplo de como se debe llamar el archifo 294405920.md y su contenido tendria /make
	# con el ejemplo anterior impedimos que el usuario pueda ejecutar el comando /make
	# Si queremos agregar mas comandos lo vamos haciendo en la siguiente linea.
	if [ `commandNoAuthorized` -eq 0 ] ; then
		logError "`cat $ruta_commandNoAuthorized`"
		filetmp=`modifyMessages $ruta_commandNoAuthorized`
		echo "$message_from_first_name, ID: $message_from_id `cat $filetmp`"
		sendMessageBot $message_chat_id "$message_from_first_name,+ID:+$message_from_id+`cat $filetmp`"
		update_id=$((update_id+1))
		deletePendingUpdate $update_id
		rm $filetmp
		continue
	fi

	# Captura la fecha actual y se manda a crear un archivo temporal para que el siguiente comando
	# que llama al script secundario tenga todos los datos obtenidos del bot.
	fechaNow=`date +%d%m%Y%M%S`
	showVar > ./tmp/command_$fechaNow.tmp


	# Con esta tecnica se llamara al script secundario se le suministraran argumentos y se ejecutara en backgraund 
	# con esto logramos que se ejecute en un PID distintos y asi no tendremos solapamiento de variables o funciones
	echo -e "$fechaNow\n" | ./bin/exec_command.sh&
	PIDbackgraund=$!	
	
	# Se procede a limpiar los WebHookInfo, auque se tiene el risgo que si no se ejecuta se pierde este comando
	# pero es debido que tenemos comandos que pueden durar mas de 20min y no podemos esperar tanto

	# Se almacena en archivo los PID que se estan ejecutando para controles de seguridad
	echo $PIDbackgraund > ./tmp/pid_$PIDbackgraund.tmp

	# Todos los mensaje se deben registrar en el LOG caundo se empiecen a procesar
	logSend $PIDbackgraund

        # Limpia todas las variables declaradas y todas las funciones creadas
        clearVar
        clearFunction
	sleep 7
done
