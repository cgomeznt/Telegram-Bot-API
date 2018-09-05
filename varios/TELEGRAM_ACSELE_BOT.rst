Como instalar y configurar TELEGRAM-ACSELE-BOT
==============================================

Los desarrolladores en especifico el señor "Juan Pablo Jimenez Esclusa", debe suministra el paquete "TELEGRAM_ACSELE_BOT_V#.rar"

En el servidor ir a la ruta:

	$ cd /usr/local/bin

Crear el directorio y entrar en el:

	$ mkdir TELEGRAM_ACSELE_BOT_V# && cd TELEGRAM_ACSELE_BOT_V#

Descargar el paquete "TELEGRAM_ACSELE_BOT_V#.rar" y descomprimirlo:

	$ unrar x -r TELEGRAM_ACSELE_BOT_V#.rar

Tendremos la siguiente estructura:

	$ ls 
	AcseleBots.jar		      config.properties  log4j-acsele-bots.log	READEME.txt
	ACSELE-TELEGRAM-BOT-TEST.mp4  dependency-jars	 log4j.properties	TELEGRAM_ACSELE_BOT_V2.rar

En el archivo README.txt tenemos el manual suministrado por el desarrollador.

En el archivo "config.properties" debemos configurar la ruta del ambiente que el TELEGRAM_ACSELE_BOT utilizara:

	la linea en donde aparece
	ACSELE_SERVER = http://localhost:7030

	La cambiamos por el ambiente que requerimos, por ejemplo en CCS seria en el server srvscm04 y el puerto 7021
	ACSELE_SERVER = http://localhost:7021


Verificamos la versión del JAVA, se puede iniciar con java 1.8.0_92 o superior:

	$ java -version
	java version "1.8.0_92"
	Java(TM) SE Runtime Environment (build 1.8.0_92-b14)
	Java HotSpot(TM) 64-Bit Server VM (build 25.92-b14, mixed mode)

Iniciamos el TELEGRAM_ACSELE_BOT:

	$ nohup java -jar -Dlog4j.configuration=file:log4j.properties AcseleBots.jar &

Listo....!!!!


Ahora para realizar las pruebas desde Telegram
+++++++++++++++++++++++++++++++++++++++++++++++

Desde una cuenta valida en Telegram buscamos el siguiente bot:

	@ConsisInternationalBot

Luego cuando ubiquemos el bot, le ejecutamos el comando:

	/start

Ahora ya podemos utilizar el TELEGRAM_ACSELE_BOT, ejecutamos los siguientes pasos.

	hola
	El bot nos responde saludando.

	consultar
	El bot nos responde haciéndonos una pregunta.

	poliza
	El bot nos responde solicitando la póliza.

	09-01-0301-00004632
	El bot nos suministra los datos de la póliza.

