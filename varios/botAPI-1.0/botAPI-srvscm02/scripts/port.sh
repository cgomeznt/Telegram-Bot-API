#!/bin/bash
# hbarrios
# 29Oct2015 ver 1.0
# 04Nov2015 ver 2.0
#

#========================================================================
# Definicion de variables
 
#==================================

dir_act=`pwd`

#==================================
var1=$1
var2=$2
var3=$3
var4=0
var0=0
var666=0
varpid=$$

dir_wls_install=`lsof -u oracle | grep "D"$var2 | awk '{print$1"      "$2"     "$9}' | grep "D"$var2\/servers\/AdminServer | tail -1 | awk '{print$3}' | sed -e 's/app.*//g'`
tmp_dir_wls_install="/"`cat /scm/scripts/port_list.txt | grep $var2 | grep -v "\#" | awk '{print$2}'`"/"

if [ "$dir_wls_install" = "" ] ; then
        dir_wls_install="/"`cat /scm/scripts/port_list.txt | grep $var2 | grep -v "\#" | awk '{print$2}'`"/"
	var4=1
	echo " Puerto detenido, se procede a identificar domain a partir del port_list.txt"
        #echo "   -. "$dir_wls_install
fi

#==================================

home_web="/scm/apache/webapps/logs"
dir_domain_1="app/oracle/domain/D"

#==================================

#dir_domain="/u02/app/oracle/domain/D"
start="/bin/startWebLogic.sh"
stop="/bin/stopWebLogic.sh"
log="servers/AdminServer/logs/log_start.log"
cache="servers/AdminServer/cache"
tmp_cache="servers/AdminServer/tmp"
dir_log="servers/AdminServer/logs"
dir_external="/scm/external"

#==================================

var_men=`cat $dir_wls_install$dir_domain_1$var2/bin/setDomainEnv.sh | grep -v \# | grep -v "export" | grep -v "{WLS_MEM_ARGS_64BIT}" | grep WLS_MEM_ARGS_64BIT | tail -1`
var_cch=`cat $dir_wls_install$dir_domain_1$var2/bin/setDomainEnv.sh | grep -v \# | grep -v "export" | grep -v "{MEM_MAX_PERM_SIZE_64BIT}" | grep MEM_MAX_PERM_SIZE_64BIT`
#==================================

#funciones
function readLogs {
    # Importante declarar la variable al inicio varpid=$$
    # la cual obtiene el PID del script.
    echo "" 
    echo -e "Espere mientras inicia el proceso y pasa a RUNNING..!!!\n"
    tail -f "$dir_wls_install$dir_domain_1$var2/$log" | while read lineread
    do
        echo $lineread | grep "RUNNING" 1> /dev/null && kill -9 `ps -ef | grep -v grep | grep "$varpid" | grep tail | awk '{print $2}'` > /dev/null 2>&1 && echo -e "El proceso ya esta \e[32mRUNNING.\e[0m\n"
        echo $lineread | grep "SHUTTING_DOWN" 1> /dev/null && kill -9 `ps -ef | grep -v grep | grep "$varpid" | grep tail | awk '{print $2}'` > /dev/null 2>&1 && echo-e "El proceso paso a \e[31mSHUTTING_DOWN\e[0m\n" && exit 1
    done
}

clearLogs()
{
        sleep 3
	if [ ! -h "$home_web/$line/acsele.log" ] ; then
            ln -s "$dir_wls_install$dir_domain_1$line/acsele.log" "$home_web/$line/acsele.log"
	fi
	if [ ! -h "$home_web/$line/log_start.log" ] ; then
            ln -s "$dir_wls_install$dir_domain_1$line/$dir_log/log_start.log" "$home_web/$line/log_start.log"
	fi
	if [ ! -h "$home_web/$line/$line.log" ] ; then
            ln -s "$dir_wls_install$dir_domain_1$line/$dir_log/$line.log" "$home_web/$line/$line.log"
	fi
	if [ ! -h "$home_web/$line/AdminServer.log" ] ; then 
            ln -s "$dir_wls_install$dir_domain_1$line/$dir_log/AdminServer.log" "$home_web/$line/AdminServer.log"
	fi
        echo "" > "$dir_wls_install$dir_domain_1$line/acsele.log"
        echo "" > "$dir_wls_install$dir_domain_1$line/$dir_log/log_start.log"
        echo "" > "$dir_wls_install$dir_domain_1$line/$dir_log/$line.log"
        echo "" > "$dir_wls_install$dir_domain_1$line/$dir_log/AdminServer.log"
        chmod -R 777 $dir_wls_install$dir_domain_1$line

}

stopPort_1()
{
	rm $dir_wls_install$dir_domain_1""$line"/acsele.log"
	rm $dir_wls_install$dir_domain_1""$line"/"$dir_log"/"*

	sleep 3

	ln -s $home_web"/"$line"/acsele.log" $dir_wls_install$dir_domain_1""$line"/acsele.log"
	ln -s $home_web"/"$line"/log_start.log" $dir_wls_install$dir_domain_1""$line"/"$dir_log"/log_start.log"
	ln -s $home_web"/"$line"/"$line".log" $dir_wls_install$dir_domain_1""$line"/"$dir_log"/"$line".log"
	ln -s $home_web"/"$line"/AdminServer.log" $dir_wls_install$dir_domain_1""$line"/"$dir_log"/AdminServer.log"
	rm $home_web"/"$line"/backup/"*
	mv $home_web"/"$line"/acsele.log" $home_web"/"$line"/log_start.log" $home_web"/"$line"/"$line".log" $home_web"/"$line"/AdminServer.log" $home_web"/"$line"/backup"
	echo > $home_web"/"$line"/acsele.log"
	echo > $home_web"/"$line"/log_start.log"
	echo > $home_web"/"$line"/"$line".log"
	echo > $home_web"/"$line"/AdminServer.log"
	chmod -R 777 $home_web"/"$line"/"
}

stopPort_2()
{
	rm $dir_wls_install$dir_domain_1""$line"/acsele.log"
	rm $dir_wls_install$dir_domain_1""$line"/"$dir_log"/"*
	ln -s $home_web"/"$line"/acsele.log" $dir_wls_install$dir_domain_1""$line"/acsele.log"
	ln -s $home_web"/"$line"/log_start.log" $dir_wls_install$dir_domain_1""$line"/"$dir_log"/log_start.log"
	ln -s $home_web"/"$line"/"$line".log" $dir_wls_install$dir_domain_1""$line"/"$dir_log"/"$line".log"
	ln -s $home_web"/"$line"/AdminServer.log" $dir_wls_install$dir_domain_1""$line"/"$dir_log"/AdminServer.log"
}

limpia_home_web()
{
cd $home_web
ls | grep 70 | while read line ; do
	cd $line
	echo > $home_web"/"$line"/acsele.log"
	echo > $home_web"/"$line"/log_start.log"
	echo > $home_web"/"$line"/"$line".log"
	echo > $home_web"/"$line"/AdminServer.log"
	cd ..
done
}

limpia_cache()
{
  echo " "
  echo " ejecutando: rm -rf "$dir_wls_install$dir_domain_1""$var2"/"$cache 
  #rm -rf $dir_wls_install$dir_domain_1""$var2"/"$cache
	if [ -d $dir_wls_install$dir_domain_1""$var2"/"$cache ]
	then
		rm -r $dir_wls_install$dir_domain_1""$var2"/"$cache
	fi
  echo " "
  echo " ejecutando: rm -rf "$dir_wls_install$dir_domain_1""$var2"/"$tmp_cache
  #rm -rf $dir_wls_install$dir_domain_1""$var2"/"$tmp_cache
	if [ -d $dir_wls_install$dir_domain_1""$var2"/"$cache ]
	then
		rm -r $dir_wls_install$dir_domain_1""$var2"/"$tmp_cache
	fi
}

prog_inf()
{
echo " Opciones introducidas var1: "$var1" var2: "$var2" var3: "$var3
echo " Variables cargadas por conf var0: "$var0" - var666: "$var666
echo " "

case $dir_wls_install in
	"/u01/")
		echo " WLS_PRODUCT_VERSION=10.3.6.0"
	;;
	"/u02/")
		echo " WLS_PRODUCT_VERSION=12.1.3.0.0"
	;;
	"/u03/")
		echo " WLS_PRODUCT_VERSION=12.1.1.0"
	;;
esac
echo " ORACLE_HOME: "$dir_wls_install"app/product"
echo " Domain: D"$var2" PATH: "$dir_wls_install$dir_domain_1$var2
echo " Directorio de web/logs: "$home_web"/"$var2
echo " Direcotiro de logs del domain: "$dir_wls_install$dir_domain_1$var2"/servers/AdminServer/logs"

echo " Memoria asignada: "$var_men
echo " Cache asignado: "$var_cch
echo " Esquemas del ambiente: "
cat /scm/external/*$var2* | egrep '(userDB|passwDB|servidorDB=)' | grep -v \#

cache="servers/AdminServer/cache"
tmp_cache="servers/AdminServer/tmp"
dir_log="servers/AdminServer/logs"

}


#=======================================================================
# ejecucion programa


echo " "
echo " "
echo "=================================================================================="
echo " "

if [ "${var2}" = "" ] ; then
        echo "debe indicar puerto | all"
        exit 1
fi


case "$var1" in
	start|START|Start)
		var0=1
		echo " Programa de activacion/desactivacion de puertos Weblogic"
		echo " "
		prog_inf
		echo " "

	;;
	stop|STOP|Stop)
		var0=2
		echo " Programa de activacion/desactivacion de puertos Weblogic"
		echo " "
		prog_inf
		echo " "
	;;
	info|INFO|inf|INF)
		echo " Informacion de ambiente puerto: "$var2" del Weblogic"
		prog_inf 	
		echo " "
		echo " "
		echo "=================================================================================="
		exit 0
	;;
	#restart|RESTART|Restart)
	#	var0=3
	#;;
	*)
		echo "Debe ingresar una opcion valida"
		echo "ej: "
		echo " "
		#echo "	./port.sh [start|stop|restart] port [7001....|all] "
		echo "	./port.sh [start|stop] port [7001...] "
	;;
esac

#if [ "${var2}" = "all" ] || [ "${var2}" = "ALL" ] || [ "${var2}" = "All" ] ; then
#	var666=666
#fi

case "$var0" in
	1)
	# start port
	# start 
	if [ "${var4}" = "0" ] ; then
		process=`lsof -u oracle | grep "D"$var2 | awk '{print$1"      "$2"     "$9}' | grep "D"$var2"\/servers\/AdminServer" | tail -1 | awk '{print$2}'`
		echo " El puerto: "$var2" se encuentra activo, proceso: "$process
		echo " "
		echo "=================================================================================="
		echo " "
		echo " "
		exit 1	
	fi
	if [ $var666 -ne 666 ] ; then
		echo "Iniciando puerto: "$var2
		#nohup $dir_domain_1"/"$var2"/"$start >/dev/null 2>&1 &	
		sleep 5
		line=$var2
		clearLogs
		sleep 3
		#mv $dir_domain_1"/"$var2"/"$log"_"$date
		nohup $dir_wls_install$dir_domain_1""$var2""$start >$dir_wls_install$dir_domain_1""$var2"/"$log 2>&1 &	
		echo "$dir_wls_install$dir_domain_1""$var2""$start >$dir_wls_install$dir_domain_1""$var2"/"$log"
		echo "" 
		readLogs
		sed  -i  's/'$var2' 1 u02/'$var2' 0 u02/g' /scm/scripts/listado_puertos.txt
		sed  -i  's/'$var2' 1 u03/'$var2' 0 u03/g' /scm/scripts/listado_puertos.txt
	elif [ $var666 -eq 666 ] ; then
		echo "Iniciando todos los puertos"
		sleep3
		cd $dir_domain_1
		ls | grep 70 | while read line ; do
			echo "Inciando puerto: "$line
			#nohup $dir_domain_1"/"$line"/"$start >/dev/null 2>&1 &
			nohup $dir_wls_install$dir_domain_1""$line"/"$start >$dir_wls_install$dir_domain_1""$line"/"$log 2>&1 &	
			sleep 5
			clearLogs
		done
	fi
	;;
	2)
	# stop port
	if [ "${var3}" = "-c" ] ; then
      		echo " Seleccionada opcion de limpiar temporales y cache"
      		var_31="1"
	else
      		echo " No se limpia cache y temporal del dominio"
	fi
	if [ $var666 -ne 666 ] ; then
		echo " "
		echo " Deteniendo puerto: "$var2
		echo " "
            	sleep 3
		sed  -i  's/'$var2' 0 u02/'$var2' 1 u02/g' /scm/scripts/listado_puertos.txt
		sed  -i  's/'$var2' 0 u03/'$var2' 1 u03/g' /scm/scripts/listado_puertos.txt
		$dir_wls_install$dir_domain_1""$var2""$stop
		#process=`lsof -u oracle | awk '{print$1"      "$2"     "$9}' | grep "D"$var | awk '{print$2}'`
		echo " "
		echo "======== procesos activos del puerto "$var2" ==========="
		echo " "
		procesos_nro=`lsof -u oracle | awk '{print$1"      "$2"     "$9}' | grep "D"$var2| wc -l`
		if [ $procesos_nro -gt 0 ] ; then
			lsof -u oracle | awk '{print$1"      "$2"     "$9}' | grep "D"$var2
			echo " "
			echo " ------ Deteniendo procesos de puerto "$var2" ------ "
			echo " "
			process=`lsof -u oracle | grep "D"$var2 | awk '{print$1"      "$2"     "$9}' | grep "D"$var2"\/servers\/AdminServer" | tail -1 | awk '{print$2}'`
			kill -9 $process
			lsof -u oracle | awk '{print$1"      "$2"     "$9}' | grep "D"$var2
		else
			echo "          Puerto totalmente detenido "
		fi
		if [ "${var_31}" = "1" ] ; then
			limpia_cache	
		fi
		elif [ $var666 -eq 666 ] ; then
			echo "Iniciando todos los puertos"
			sleep 3
			#llamado a funcion limpiar debug en Home_Web
			dir_tmp=`pwd`
			limpia_home_web	
            		cd $dir_wls_install$dir_domain_1
			ls | grep 70 | while read line ; do
				echo "Deteniendo todos los puertos: "$line
				# llamado a funcion StopAllPort
				# stopPort_2
				$dir_wls_install$dir_domain_1""$line"/"$stop
				sleep 5
	           	done
	        fi
	;;
	#3)
	#	echo "Reiniciando puerto "$var2
	#	sleep 3
	#	$dir_wls_install$dir_domain_1""$var2"/"$stop
	#	sleep 2
	#	if [ "${var_31}" = "1" ] ; then
        #                limpia_cache
        #        fi
	#	sleep 5
	#	#nohup $dir_wls_install$dir_domain_1""$var2"/"$start >/dev/null 2>&1 &
	#	nohup $dir_wls_install$dir_domain_1""$var2"/"$start > $dir_wls_install$dir_domain_1""$var2"/"$log 2>&1 &
	#;;
esac
echo " "
echo "=================================================================================="
echo " "
echo " "

exit 0

