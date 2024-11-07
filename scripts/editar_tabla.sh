#!/bin/bash

# Script para editar la configuración de una tabla

# Directorio de configuración
config_dir="config"

# Verificar si existe el directorio de configuración
if [[ ! -d $config_dir ]]; then
  echo "El directorio de configuración $config_dir no existe. Crea una tabla primero."
  exit 1
fi

# Solicitar el nombre de la tabla a editar
read -p "Ingrese el nombre de la tabla a editar: " nombre_tabla
config_file="$config_dir/${nombre_tabla}.conf"

# Verificar si el archivo de configuración de la tabla existe
if [[ ! -f $config_file ]]; then
  echo "La configuración de la tabla $nombre_tabla no existe. Crea la tabla primero."
  exit 1
fi

# Función para mostrar la configuración actual de la tabla
function mostrar_configuracion() {
  echo -e "\nConfiguración actual de la tabla $nombre_tabla:"
  cat "$config_file"
}

# Función para editar un campo
function editar_campo() {
  read -p "Ingrese el nombre del campo a editar: " campo_nombre
  if ! grep -q "^$campo_nombre:" "$config_file"; then
    echo "El campo $campo_nombre no existe en la tabla $nombre_tabla."
    return
  fi

  # Mostrar opciones de modificación
  echo "Seleccione el aspecto que desea modificar:"
  echo "1) Tipo de dato"
  echo "2) Permitir NULL"
  echo "3) Clave primaria (PK)"
  echo "4) Autoincrementar (solo si es PK)"
  read -p "Opción: " opcion

  # Extraer configuración actual del campo
  tipo=$(grep "^$campo_nombre:" "$config_file" | cut -d':' -f2)
  nulo=$(grep "^$campo_nombre:" "$config_file" | cut -d':' -f3)
  primary_key=$(grep "^$campo_nombre:" "$config_file" | cut -d':' -f4)

  case $opcion in
    1)
      echo "Seleccione el nuevo tipo de dato:"
      select new_tipo in "INT" "VARCHAR" "TEXT" "DATE"; do
        case $new_tipo in
          INT|VARCHAR|TEXT|DATE) 
            if [[ $new_tipo == "VARCHAR" ]]; then
              read -p "Especifique el tamaño (ej: 255): " tamano
              new_tipo="$new_tipo($tamano)"
            fi
            tipo=$new_tipo
            break
            ;;
          *) echo "Opción no válida." ;;
        esac
      done
      ;;
    2)
      read -p "¿Permitir valores NULL? (s/n): " permitir_nulo
      if [[ $permitir_nulo == "n" ]]; then
        nulo="NOT NULL"
      else
        nulo=""
      fi
      ;;
    3)
      if [[ $tipo == "INT" ]]; then
        read -p "¿Es clave primaria? (s/n): " es_pk
        if [[ $es_pk == "s" ]]; then
          primary_key="PRIMARY KEY"
        else
          primary_key=""
        fi
      else
        echo "La clave primaria solo puede aplicarse a campos de tipo INT."
      fi
      ;;
    4)
      if [[ $primary_key == "PRIMARY KEY" ]]; then
        read -p "¿Autoincrementar este campo? (s/n): " autoincrement
        if [[ $autoincrement == "s" ]]; then
          primary_key="PRIMARY KEY AUTOINCREMENT"
        fi
      else
        echo "Este campo no es clave primaria. No se puede aplicar autoincremento."
      fi
      ;;
    *)
      echo "Opción no válida."
      return
      ;;
  esac

  # Actualizar el archivo de configuración
  sed -i "/^$campo_nombre:/c\\$campo_nombre:$tipo:$nulo:$primary_key" "$config_file"
  echo "Campo $campo_nombre actualizado."
}

# Función para eliminar un campo
function eliminar_campo() {
  read -p "Ingrese el nombre del campo a eliminar: " campo_nombre
  if ! grep -q "^$campo_nombre:" "$config_file"; then
    echo "El campo $campo_nombre no existe en la tabla $nombre_tabla."
    return
  fi

  # Eliminar la línea del campo del archivo de configuración
  sed -i "/^$campo_nombre:/d" "$config_file"
  echo "Campo $campo_nombre eliminado."
}

# Menú de opciones para editar la tabla
while true; do
  mostrar_configuracion
  echo -e "\nSeleccione una opción:"
  echo "1) Editar campo"
  echo "2) Eliminar campo"
  echo "3) Salir"
  read -p "Opción: " opcion
  case $opcion in
    1) editar_campo ;;
    2) eliminar_campo ;;
    3) break ;;
    *) echo "Opción no válida, intente de nuevo." ;;
  esac
done