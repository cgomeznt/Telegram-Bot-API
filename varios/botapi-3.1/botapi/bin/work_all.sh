#!/bin/bash

SCRIPT_PATH=$(dirname $(readlink -f $0))
workspace="/home/scm/svn/workspace"
botID="546115327:AAGbcHH4AfEpstsKfq2D6e65TykZvJd00To"
chatID="-286060095"
datetmp=`date +%d%m%Y%M%S`
dir_scripts="/home/oracle/scm"

# Si no le pasan el botID y el chatID el utilizara los que tiene cargados por defecto
if [ ! -z $5 ] && [ ! -z $6 ] ; then
	botID="$5"
	chatID="$6"
fi

clear

function modifyMessages {
	cp  $1 $SCRIPT_PATH/filebot$datetmp.tmp
	sed -i -e 's/ /%20/g' $SCRIPT_PATH/filebot$datetmp.tmp
	for i in `cat $SCRIPT_PATH/filebot$datetmp.tmp | grep -v \#`
	do
		varMM=$varMM`echo -e "$i%0A"`
	done
	echo $varMM > $SCRIPT_PATH/filebot$datetmp.tmp
	echo "$SCRIPT_PATH/filebot$datetmp.tmp"
}

checkPort()
{
	# Esta funcion es encargada de chequear si el puerto es de WebLogic o de WAS
        if [ `grep $1 $dir_scripts/port_list_was.txt | wc -l` -ne 0 ] ; then
                echo "0"
	else
		echo "1"
        fi
}

#####################################
# Select para los clientes
#####################################
cliente="$1"
if [ -z $cliente ] ; then
        echo -e "\e[31mDebe colocar un cliente\e[0m"
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+Debe+colocar+un+cliente" &> /dev/null
        exit 1
fi

echo -e "\nEl Cliente seleccionado: \e[32m$cliente\e[0m\n"

ls $workspace/$cliente &> /dev/null
if [ $? -ne 0 ] ; then 
	echo -e "\e[31mNo existe el cliente $cliente\e[0m"
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+NO+existe+el+cliente" &> /dev/null
	exit 1
fi

#####################################
# Select para los Branchs
#####################################
branch="$2"
if [ -z $branch ] ; then
        echo -e "\e[31mDebe colocar un branch\e[0m"
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+Debe+colocar+un+branck" &> /dev/null
        exit 1
fi

echo -e "\nEl Branch seleccionado: \e[32m$branch\e[0m\n"

ls $workspace/$cliente/$branch &> /dev/null
if [ $? -ne 0  ] ; then
        echo -e "\e[31mNo existe el branch $branch\e[0m"
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+NO+existe+el+branch" &> /dev/null
	exit 1
fi


#####################################
# Select para los Puertos
#####################################
puerto="$3"
if [ -z $puerto ] ; then
        echo -e "\e[31mDebe colocar un puerto\e[0m"
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+Debe+colocar+un+puerto" &> /dev/null
        exit 1
fi

echo -e "\nEl Puerto seleccionado: \e[32m$puerto\e[0m\n"

ls $workspace/$cliente/$branch/scm/Make_EAR/*$puerto &> /dev/null
if [ $? -ne 0  ] ; then
        echo -e "\e[31mNo existe el puerto $puerto\e[0m"e
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+NO+existe+el+puerto" &> /dev/null
        exit 1
fi

####################################
# Select para ejecutar los schematools
#####################################
runschematool=$4
if [ -z $runschematool ] ; then
        echo -e "\e[31mDebe colocar [s/n] para indicar si quiere que se ejecute el schematool\e[0m"
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+debe+colocar+s/n+para+el+schematool" &> /dev/null
        exit 1
fi

if [ $runschematool == "s" ] || [ $runschematool == "S" ] || [ $runschematool == "n" ] || [ $runschematool == "N" ] ; then
	echo -e "\nSelecciono para el Schematool: \e[32m$runschematool\e[0m\n"
else
        echo -e "\e[31mDebe colocar [s/n] para indicar si quiere que se ejecute el schematool\e[0m"
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+debe+colocar+s/n+para+el+schematool" &> /dev/null
        exit 1
fi

cd $workspace/$cliente/$branch
# pwd

echo -e "botID es: $botID, el chatID es: $chatID"
curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Inicia+$cliente+$branch+$puerto" &> /dev/null

echo -e ""
echo -e "Revision anterior" > $SCRIPT_PATH/file$datetmp.tmp
git-info.sh >> $SCRIPT_PATH/file$datetmp.tmp
git-update.sh &> /dev/null
if [ $? -eq 0 ] ; then
	echo -e "" >> $SCRIPT_PATH/file$datetmp.tmp
	echo -e "Se ejecuto con exito el git-update.sh" >> $SCRIPT_PATH/file$datetmp.tmp
	# Envia por telegram la actividad.
	# curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Listo+el+GIT+$cliente+$branch+$puerto" &> /dev/null
else
        echo -e "\n\e[31mSe sale porque hay errores en el git-update.sh\e[0m\n"
	# Envia por telegram la actividad.
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+el+GIT+$cliente+$branch+$puerto" &> /dev/null
	rm $SCRIPT_PATH/file$datetmp.tmp
	exit 1
fi
echo -e "" >> $SCRIPT_PATH/file$datetmp.tmp
echo -e "Ultima revision" >> $SCRIPT_PATH/file$datetmp.tmp
git-info.sh >> $SCRIPT_PATH/file$datetmp.tmp

msgtmp=`modifyMessages $SCRIPT_PATH/file$datetmp.tmp`
cat $SCRIPT_PATH/file$datetmp.tmp
rm $SCRIPT_PATH/file$datetmp.tmp
msgbot=`cat $msgtmp`
curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=$msgbot" &> /dev/null
rm $msgtmp

port=`grep port $workspace/$cliente/$branch/scm/Make_EAR/*$puerto/make.sh | head -1 | awk -F"=" '{print $2}'`
# echo "$port"

cd $workspace/$cliente/$branch/scm/Make_EAR/*$puerto
pwd

# Si la variable no tiene nada asumimos que se va ejecutar sin schematool
if [ $runschematool  == "n" ] || [ $runschematool  == "N" ] ; then
	echo -e "\nSelecciono: \e[32msolo el make.sh\e[0m\n"
	make.sh $port > $SCRIPT_PATH/file$datetmp.tmp
        if [ $? -eq 0 ] ; then
        	echo -e "\n\e[32mSe ejecuto con exito solo el make.sh \e[0m\n"
		msgtmp=`modifyMessages $SCRIPT_PATH/file$datetmp.tmp`
		cat $SCRIPT_PATH/file$datetmp.tmp
		rm $SCRIPT_PATH/file$datetmp.tmp
		msgbot=`cat $msgtmp`
		curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=$msgbot" &> /dev/null
		rm $msgtmp
        else
                echo -e "\n\e[31mSe sale porque hay errores en el make.sh\e[0m\n"
                # Envia por telegram la actividad.
                curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+el+make+$cliente+$branch+$puerto" &> /dev/null
		rm $SCRIPT_PATH/file$datetmp.tmp
		rm $msgtmp
                exit 1
        fi
else
	echo -e "\nSelecciono: \e[32mmake.sh con schematool\e[0m\n"
	make.sh $port s > $SCRIPT_PATH/file$datetmp.tmp
	if [ $? -eq 0 ] ; then
	        echo -e "\n\e[32mSe ejecuto con exito el make.sh con schematool\e[0m\n"
		msgtmp=`modifyMessages $SCRIPT_PATH/file$datetmp.tmp`
		cat $SCRIPT_PATH/file$datetmp.tmp
		rm $SCRIPT_PATH/file$datetmp.tmp
		msgbot=`cat $msgtmp`
		curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=$msgbot" &> /dev/null
		rm $msgtmp
	else
	        echo -e "\n\e[31mSe sale porque hay errores en el make.sh con schematool\e[0m\n"
		# Envia por telegram la actividad.
		curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+el+make+$cliente+$branch+$puerto" &> /dev/null
		rm $SCRIPT_PATH/file$datetmp.tmp
		rm $msgtmp
        	exit 1
	fi
fi

if [ $port == "CL" ] ; then
	echo -e "\n\e[32mCULMINO TODO EL PROCESO CON EXITO\e[0m\n"
	# Envia por telegram que culmino la actividad.
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Culmino+$cliente+$branch+$puerto" &> /dev/null
	# Manda a salir el script con exito...!!!
	exit 0
fi

ifWAS=`checkPort $port`

if [ $ifWAS -eq 0 ] ; then 
	# NO continuamos porque por alguna razon que aun no tengo idea el port_was.sh update no ejecuta la actualizacion
	# Envia por telegram que culmino la actividad.
       	echo -e "\n\e[32mCULMINO TODO EL PROCESO CON EXITO,recuerde ejecutar port_was.sh update\e[0m\n"
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=CULMINO+el+WAS+recuerde+ejecutar+port_was_update$cliente+$branch+$puerto" &> /dev/null
	exit 0
fi

port.sh stop $port -c &> /dev/null
if [ $? -eq 0 ] ; then
        echo -e "\n\e[32mSe ejecuto con exito el port.sh stop -c\e[0m\n"
	# Envia por telegram la actividad.
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Listo+el+port+stop+$cliente+$branch+$puerto" &> /dev/null
else
        echo -e "\n\e[31mSe sale porque hay errores en el port.sh stop -c\e[0m\n"
	# Envia por telegram la actividad.
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+el+port+stop+$cliente+$branch+$puerto" &> /dev/null
        exit 1
fi

port.sh start $port &> /dev/null
if [ $? -eq 0 ] ; then
        echo -e "\n\e[32mSe ejecuto con exito el port.sh start\e[0m\n"
	# Envia por telegram la actividad.
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Listo+el+port+start+$cliente+$branch+$puerto" &> /dev/null
else
        echo -e "\n\e[31mSe sale porque hay errores en el port.sh start\e[0m\n"
	# Envia por telegram la actividad.
	curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=Fallo+el+port+start+$cliente+$branch+$puerto" &> /dev/null
        exit 1
fi

# Envia por telegram que culmino la actividad.
curl "https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID=&text=CULMINO+$cliente+$branch+$puerto" &> /dev/null


echo -e "\n\e[32mCULMINO TODO EL PROCESO CON EXITO\e[0m\n"

# Manda a salir el script con exito...!!!
exit 0


