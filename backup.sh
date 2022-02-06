#!/bin/bash

## Autor: Markisich Emiliano
## mail: emiliano@markisich.com.ar
## creado: 2021-01-12
## Actualizado 2021-02-20
## Actualizado 2022-02-06
##########################################
## Script para hacer backup de mysql    ##
##########################################

USERDIR="/home/s2wbackup"
BASE_DIR=$USERDIR"/s2wbackup/backup"
TMP_DIR=$BASE_DIR"/tmp"

#nombre del tar
DATE=$(date +%Y-%m-%d_%H%M%S)
BACKUP_TAR = $DATE.tar.bzip2

BACKUP_DIR=$BASE_DIR"/data"

# Credenciales de un usuario MySQL con acceso de sólo lectura
MYUSER=usersololectura
MYPASS=clave

if [ ! -d "$BASE_DIR" ]
then
   mkdir $BASE_DIR
   echo "se creo directorio "$BASE_DIR
fi

if [ ! -d "$TMP_DIR" ]
then
   mkdir $TMP_DIR
   echo "se creo directorio "$TMP_DIR
fi

# # si  existe  data2 lo borro

# if [ -d "$BACKUP_DIR2" ]
# then
#    rm -rf $BACKUP_DIR2
#    echo "se borro el directorio "$BACKUP_DIR2
# fi

# # si existe data1
# if [ -d "$BACKUP_DIR1" ]
# then
#    mv  $BACKUP_DIR1 $BACKUP_DIR2
#    echo "se movio el directorio a "$BACKUP_DIR2
# fi

# si existe data lo borro
if [ -d "$BACKUP_DIR" ]
then
  rm  -rf $BACKUP_DIR
  echo "se elimino el directorio a "$BACKUP_DIR1
fi

# creo data vacio
mkdir $BACKUP_DIR 
echo "se creo el directorio "$BACKUP_DIR

## extraer todas las bases de datos
mysql -u $MYUSER --password=$MYPASS -e 'show databases;' > $TMP_DIR/listadb.txt
echo "se creo listado de bases "$TMP_DIR/listadb.txt

# Parámetros y opciones para mysqldump
ARGS="-u$MYUSER -p$MYPASS --add-drop-database --add-locks \
--create-options --complete-insert --comments --disable-keys \
--dump-date --extended-insert --quick --routines --triggers"

# recorro las bases para hacer el dump
while IFS= read -r line
do

  if [[ "$line" != "Database" ]]
  then
    echo "$line"
    # Recuperar el nombre de base de datos pasado como parámetro
    DB=$line

    # Obtener un volcado de la base de datos
    mysqldump ${ARGS} $DB > $TMP_DIR/$DB.sql

    # Obtener la fecha y hora actual
    DATE=$(date +%Y-%m-%d_%H%M%S)

    # Comprimir y resguardar
    tar cjf $BACKUP_DIR/${DB}_$DATE.tar.bzip2 $TMP_DIR/$DB.sql 2>/dev/null

    # Eliminar el volcado
    rm $TMP_DIR/$DB.sql
  fi

done < $TMP_DIR/listadb.txt

#borro lista de bases
rm $TMP_DIR/listadb.txt
echo "se borro el listado de base "

## creo un tar
echo "######################"
echo "# creo un tar        #"
echo "######################"

tar -cjf $BACKUP_TAR $BACKUP_DIR
