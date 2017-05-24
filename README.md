# MiniProyectoDistribuidos
<b>Autores:</b><br>
Andrés Felipe Piñeros<br>
Dylan Torres<br>
Johan David Ballesteros<br>
<b>Códigos:</b> A00273344 - A00265772 - A00309824 <br>
<b>Repositorio:</b> https://github.com/AndresPineros/MiniProyectoDistribuidos

# Objetivos
* Emplear herramientas de aprovisionamiento automático para la realización de tareas en infraestructura.
* Instalar y configurar espejos de sistemas operativos en forma automática para el soporte al aprovisionamiento de máquinas virtuales en clústers de computo.
* Especificar y desplegar ambientes conformados por contenedores virtuales para la realización de tareas específicas.

# Pasos Para Automatizar
<p align='justify'>El problema inicial se basa en poder desplegar una infraestructura de contenedores virtuales que cuente con un mirror, el cual pueda almacenar paquetes que defina el usuario y un contenedor cliente que pueda descargar esos paquetes. Para dar solución al problema se decidió utilizar la tecnología Aptly, una herramienta que permite administrar repositorios Debian, reflejar repositorios remotos y crear snapshots.</p>

## Instalar Aptly
<p align='justify'>Primero se inicia con la creación de las llaves RSA que se utilizaran para la transferencia de archivos de manera segura. Se ejecutan los siguientes comandos. El primer comando se encarga de generar la llave y el segundo de generar la entropía para la llave. Los anteriores pasos no se tendrán en cuenta durante la automatización puesto que se pueden generar y compartir las llaves en el contenedor.</p>

```sh
$ gpg --gen-key
$ cat /dev/urandom
```
<p align='justify'> Una vez generadas las llaves procedemos a importar la llave privada a la máquina que contendrá el mirror. Con el primer comando importamos una llave externa a la máquina del mirror y con el segundo importamos las llaves que tiene la máquina a la base de trustedkeys.</p>

```sh
$ gpg --import [namePrivateKey].asc
$ gpg --no-default-keyring --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg --export | gpg --no-default-keyring --keyring trustedkeys.gpg --import
```
<p align='justify'>Procedemos ahora agregar el repositorio de Aptly al archivo sources list de la máquina, que es el archivo donde Apt guarda la lista de repositorios o canales de software, para esto empleamos el siguiente comando.</p>

```sh
$ echo deb http://repo.aptly.info/ squeeze main > /etc/apt/sources.list
```
Importamos la llave pública del servidor Aptly para poder descargarlo.

```sh
$ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460
```
Por último actualizamos Apt e instalamos Aptly.

```sh
$ apt-get update
$ apt-get install aptly
```
## Configurar Mirror
<p align='justify'>Con Aptly instalado se puede proceder a crear el mirror, para esto se ejecuta el siguiente comando. Este comando se compone de un filtro en el cual se especifíca los paquetes a instalar (es aquí donde se deberá posteriormente ingresar los paquetes que el usuario defina sin proceder a dejar el comando en hardcode), seguido de esto se coloca la opción "filter-with-deps" para que se pueda descargar las dependencias de los paquetes definidos si tienen. Luego se asigna un nombre al mirror y una URL donde se descargarán los paquetes. El segundo comando actualiza el mirror.</p>

```sh
$ aptly mirror create -architectures=amd64 -filter='Priority (required) | Priority (important) | Priority (standard) | postgresql' -filter-with-deps mirror-xenial http://mirror.upb.edu.co/ubuntu/ xenial main
$ aptly mirror update mirror-xenial
```
Para poder publicar los paquetes del mirror se necesita primero realizar un snapshot del mismo.

```sh
$ aptly snapshot create mirror-snap-xenial from mirror mirror-xenial
```
Finalmente se publica el snapshot y se incia el mirror.

```sh
$ aptly publish snapshot mirror-snap-xenial
$ aptly serve
```

## Cliente
Debido a que la comunicación se establece por medio de llaves RSA, lo primero a realizar en el lado del cliente es la importación de la llave pública generada por el mirror.

```sh
$ apt-key add [namePublicKey].asc
```
Se procede apuntar a la URL del mirror publicado para poder descargar los paquetes desde ese repositorio.

```sh
$ echo "deb http://[hostMirror]:8080/ xenial main" > /etc/apt/sources.list
```
Se actualiza el Apt para que consigne los cambios realizados.

```sh
$ apt-get update -y
```

# Automatización

## Mirror
A continuación se encuentra los enlaces de los archivos utilizados para el aprovisionamiento automático del mirror, en cada uno se específica los pasos realizados.

<a href="https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/Mirror/Dockerfile"><b>Mirror Dockerfile</b></a>

Para poder publicar el snapshot, Aptly pide la contraseña de la llave privada. Para esto se instaló la herramienta Expect la cual permite autimatizar las respuestas de las preguntas que se generan en el bash.

<a href="https://github.com/AndresPineros/MiniProyectoDistribuidos/edit/master/solucion/sol_sin_healthcheck/Mirror/conf/publish_snapshot.sh"><b>Publish Snapshot File</b></a>

<a href="https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/Mirror/conf/Entrypoint.sh"><b>Entry Point</b></a>

## Cliente
A continuación se encuentra los enlances de los archivos utilizados para la prueba del mirror.

<a href="https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/Client/Dockerfile"><b>Mirror Dockerfile</b></a>

<a href="https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/Client/conf/Entrypoint.sh"><b>Entry Point</b></a>

<a href="https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/docker-compose.yml"><b>Docker Compose</b></a>

# Pruebas Del Funcionamiento
## Construcción
Para verificar el funcionamiento del mirror se procede a ejecutar el archivo docker-compose, el cual tiene la especificación para construir y desplegar el mirror y el cliente.

```sh
$ docker compose build 
```
Se puede comprobar la contrucción de los dos contenedores en las siguientes tres imagenes.

![alt text](https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/images/compose_build_a%20(1).PNG)

![alt text](https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/images/compose_build_b%20(1).PNG)

![alt text](https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/images/compose_build_c%20(1).PNG)

## Despliegue

```sh
$ docker compose up
```

En la primera imagen se puede observar que el filtro que se le pasa al mirror para que se actualice contiene las dependencias definidas por el usuario en el docker-compose (python3 y postgresql). También se puede observar como el cliente espera mientras el mirror termina de desplegarse.

![alt text](https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/images/compose_up_a.PNG)

En la segunda imagen se puede observar como el mirror pide la contraseña de la llave privada y posteriormente a esto publica con éxito el snapshot, lo que significa que efectivamente con la herramienta expect se pudo responder a las preguntas sobre el passphrase de la llave privada. También se puede observar que cuando incia el servicio del mirror, el cliente sale del estado de espara y entra en el estado de despliegue. 

![alt text](https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/images/compose_up_b.PNG)

En la tercera y cuarta imagen se puede observar como el cliente descarga las dependencias (paquetes) por medio del host mirror_c que hace referencia al contenedor del mirror previamente desplegado. Lo que significa que efectivamente está descargando los paquetes almacenados en ese mirror.

![alt text](https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/images/compose_up_c.PNG)

![alt text](https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/images/compose_up_d.PNG)

En la quinta imagen se puede observar que los contenedores quedarón desplegados correctamente. También se procede a ingresar dentro del contenedor del cliente comprobando que inició el servicio. 

![alt text](https://github.com/AndresPineros/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/images/compose_up_e.PNG)
# Dificultades

* Dependencias Del Contenedor: debido a que se busca hacer a los contenedores lo más ligeros posible, encontramos que algunos de los paquetes del sistema son eliminados. En este caso Aptly dependía de dos librerías (xz-utils y bzip2) que fueron eliminadas de la imagen del contenedor (ubuntu:16.04), por lo tanto debieron instalarse nuevamente.  
* Importación De Llaves: debido a que no se tenía en claro el concepto del manejo de las llaves RSA, no sabíamos como realizar la importación de las llaves a los contenedores. Finalmente, se investigó sobre el paquete de seguridad GPG el cual nos permitió generar e importar las llaves para poder auntenticar la fuente de los paquetes en la interacción mirror <---> cliente.
* Sincronización De Despliegue De Contenedores: debido a que el contenedor del cliente obtiene sus dependencias (paquetes) del mirror, es necesario desplegar completamente el servicio mirror antes de que el cliente inicie la descarga de dependencias. Para esto se investigó sobre dos posibles soluciones: la primera utilizando el comando de docker healthcheck, que es una función nativa de docker, la cual finalmente no se pudo utilizar debido a que no se pudo configurar correctamente el comando de este. La otra solución fue por medio de un script que verificara por medio de la herramienta curl, que permite diagnosticar si un servicio se encuentra iniciado, si el contenedor del mirror ya se había iniciado.
