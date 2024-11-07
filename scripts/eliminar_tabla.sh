#!/bin/bash

read -p "Ingrese el nombre de la tabla a eliminar: " nombre_tabla
archivo="config/${nombre_tabla}.conf"

if [[ -f $archivo ]]; then
  rm $archivo
  echo "Tabla $nombre_tabla eliminada."
else
  echo "La tabla $nombre_tabla no existe."
fi