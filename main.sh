#!/bin/bash

## Autor: Markisich Emiliano
## mail: emiliano@markisich.com.ar
## creado:  2022-02-07
####################################################
## Script que ejecuta script de backup en vps     ##
## y se trae el backup para luego pasarlo al ftp  ##
####################################################

LANG=C

# Para debug 
#set -x

### FTP login credentials below ###
FTPU="user"
FTPP="password"
FTPS="ip-ftp"

USERDIR="/home/s2wbackup"
BASE_DIR=$USERDIR"/s2wbackup/backup"
TMP_DIR=$BASE_DIR"/tmp"

FTP_DIR="/FTP"

# recorro las MV para hacer el backup
while IFS= read -r line
do

  if [[ "$line" != "Database" ]]
  then
    echo "$line"
    # Obtengo el nombre o la ip del vps
    VPS=$line

    # ejecuto script para backup db
    ssh  $line db-backup.sh
    # bajo del vps el backup
    scp  $line:$BASE_DIR/*.tar.bzip2 $FTP_DIR

  fi

done < listaVPS.txt
 
### local directory to backup ###

 
### Login to remote server ###
### No need to edit any of the fields below #
### Default DIR is backup ###
lftp -u $FTPU,$FTPP -e "cd ideea;mv ideea.img ideea.img.old;put $FTP_DIR;quit" $FTPS

