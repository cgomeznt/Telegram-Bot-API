Estructura y funcionamiento lógico de botAPI
============================================

La carpeta "botAPI" tiene el siguiente contenido::
	bin  
	botAPI.sh	
	conf  
	logs  
	messages  
	metadata	
	scripts
	tmp

A continuación se explica cada uno de los directorios:
botAPI.sh:	Es el script principal.

bin:	Directorio en donde se encuentran todas las funciones utilizadas por el script principal y estas funciones están almacenadas en archivos con nombres que hacen referencia a la acciones que corresponde esas funciones.

conf:	Directorio en donde se encuentra el archivo principal de configuración, en el tendrá todas las variables que tienen información del bot y de las rutas que serán utilizadas por el script principal.

logs:	Directorio en donde se encontrara los LOGs de la aplicación.

messages:	Directorio que almacena los archivos con la información que se utilizara para enviar al bot, en estos archivos tendremos todos los mensajes y así evitaremos editar el script principal.

metadata:	Directorio que contiene metadata de la aplicación.

scripts:	Directorio que contiene los scripts externos de la aplicación, con esto evitamos editar el script principal.

tmp:	Directorio que almacena los archivos temporales del script principal.


La carpeta "botAPI" debera ser copiada en "/usr/local/bin"
La carpeta "botAPI" debe tener los derechos de propietario del usuario que lo estará ejecutando.

Dentro del mismo script principal "botAPI.sh" se encuentra toda la documentación.


