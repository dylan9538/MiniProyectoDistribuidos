# MiniProyectoDistribuidos
<b>Autores:</b><br>
Andrés Felipe Piñeros<br>
Dylan Torres<br>
Johan David Ballesteros<br>
<b>Códigos:</b> A00273344 - ? - A00309824 <br>
<b>Repositorio:</b> https://github.com/DavidPDP/MiniProyectoDistribuidos

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

<a href="https://github.com/DavidPDP/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/Mirror/Dockerfile"><b>Mirror Dockerfile</b></a>

Para poder publicar el snapshot, Aptly pide la contraseña de la llave privada. Para esto se instaló la herramienta Expect la cual permite autimatizar las respuestas de las preguntas que se generan en el bash.
<a href="https://github.com/DavidPDP/MiniProyectoDistribuidos/edit/master/solucion/sol_sin_healthcheck/Mirror/conf/publish_snapshot.sh"><b>Publish Snapshot File</b></a>

<a href="https://github.com/DavidPDP/sd-docker-assignment/blob/master/codigo_estudiante/A00309824/Dockerfile"><b>Dockerfile Utilizado</b></a>

## Cliente

<a href="https://github.com/DavidPDP/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/Mirror/Dockerfile"><b>Mirror Dockerfile</b></a>

<a href="https://github.com/DavidPDP/MiniProyectoDistribuidos/blob/master/solucion/sol_sin_healthcheck/Mirror/Dockerfile"><b>Mirror Dockerfile</b></a>

# Pruebas Del Funcionamiento

# Dificultades

