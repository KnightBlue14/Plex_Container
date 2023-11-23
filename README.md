
# Plex Container

An automated Docker project that creates two containers - one for MySQL, and one for Python. The Python container extracts information from Plex libraries, and exports it into the SQL container for command line viewing.


## Description
Plex is a software package that allows users to locally host content for streaming to other devices. I have used it for some time now, and have a large collection stored on a home-media server. 

The goal of this project was to create an application that could be used to store the contents of Plex libraries separately from Plex itself, in a manner that can be viewed offline, with 3 intended use cases:
* In the event that the server drives fail, and no backups or redundant drives are available, there will be an image of what was present in the server, and I can begin rebuilding the collection
* Viewing the contents of the server remotely without using Plex (i.e. Poor internet or issues with the Plex client)
* Being able to check the contents of the library without needing to install and login to Plex on the machine

In the final version of this project, the only software needed (other than Plex itself) is Docker, to set up and run the containers, and store the data in a persistent volume. The Python files can be modified with a code editor, such as VSCode.
## Technologies used
* Python - Plex_update.py and plex_auth.py are both written in Python, and will need to be updated  with the relevant information for your use case, though this can be done with a number of editors
* MySQL - Some knowledge of basic SQL commands will be needed to navigate the database
* Docker - Docker will be needed to run the containers, and download the publicly available image
* Plex - You will need a Plex account, and internet access during setup
## How to use

### Plex_auth.py

This file is used to store authentication details. You will need to fill most of the fields in this file for your use case
* baseurl - use the address for your machine on your network (i.e. 192.168.x.xxx)
* token - use the instructions in the link below -
https://www.plexopedia.com/plex-media-server/general/plex-token/

The token is needed for authentication purposes, and will be tied to your account. This and the url are both needed to create the Plex server object and pull data from it.
* host - This is set by default to SQLDock. You can change it if you'd like, but you will need to update the docker-compose file accordingly
* user - set to root by default. I would not recommend changing this, as as MySQL will only have root access available when you set this up for the first time.
* passwd - the password for your MySQL instance, defined in the docker-compose file
* port - the port used to connect to MySQL, set by default to 3306

### docker-compose.yml

This can largely be left alone, apart from 2 variables -
* The environment variable 'MYSQL_ROOT_PASSWORD' - you will need to set your own password. Once set, it will be used as long as the persistent volume is not deleted
* The image - you will need to create a new image using the files provided. Steps for this will be included below
Also, if you opted to change the 'host' name in Plex_auth.py, you will need to change the 'container_name' variable for the sql-dock service. From here, it will be assumed that you stuck with SQLDock.

### Plex_update.py

All that needs to be changed here is the library_list variable, which the script will use to scan through each library. The name must appear as it does in your Plex server - any special characters, spaces, hyphens, etc., must be included, or it will not be able to find them. You are free to change the name of the database by changing the 'create_db' variable, just be sure to also update the 'use_db' variable.

### Dockerfile and requirements.txt

These can both be left alone. The .txt file adds the plexapi and mysqlconnector modules to the python container, and the Dockerfile adds the python files for building the image.

## Building an image

Once you have set up your variables appropriately, you will need to build a new image from the files provided. This can be done by entering the command line, then navigating to the directory where these files are stored. Once there, enter the command -

```
docker compose build -t {image-name}
```

This will use the Dockerfile to add the python files to your image, allowing you to use them every time you use docker-compose. For maximum utility, you will want to upload this to a public repository, allowing you to use it on multiple devices.

From here, you will want to update the docker-compose file to use your new image in the 'py-dock' service. Now if you use the command -

```
docker compose up
```

This will use both a normal mysql container, and your new image to complete the application.

If everything was set up correctly, the service will run automatically. First, the MySQL container will be built, leading to this output in your console - 

![alt text](https://github.com/KnightBlue14/Plex_Container/blob/main/Images/Setup%20-%20SQL.png)

This means that the SQL container is ready to recieve connections. From here, docker-compose runs a healthcheck service, to see if it is listening on port 3306. Once this is confirmed, it will then run the Plex_update script, resulting in this output -

![alt text](https://github.com/KnightBlue14/Plex_Container/blob/main/Images/Setup%20-%20Python.png)

From here, you will need to close the terminal, stopping both containers.

## Using the service

If you want to check the results, re-open the terminal and use the following commands -

```
docker exec -it SQLDock bin/bash
```

```
mysql -u root -p
```

Then enter the password you setup in the docker-compose file to enter the MySQL container terminal. From here, type -

```
use Plex_db;
```

to use the database you just created, then -

```
select * from {library_name}
```

You will then see every item from your library, stored in the SQL database.

## Example

In my library, I have a collection of films from Studio Ghibli. To use this service, I update the python and docker files with my details, as described above, create the new image, update the docker-compose file to use the new image, and then run the service. Once setup, I can then check my Ghibli library, as shown in the image below -

![alt text](https://github.com/KnightBlue14/Plex_Container/blob/main/Images/Setup%20-%20Database.png)
