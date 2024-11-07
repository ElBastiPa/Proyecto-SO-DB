#!/bin/bash

# Crear el directorio config si no existe
config_dir="config"
if [[ ! -d $config_dir ]]; then
  echo "Creando el directorio $config_dir..."
  mkdir "$config_dir"
fi

# Solicitar el nombre de la tabla y archivo de configuración
while true; do
  read -p "Ingrese el nombre de la tabla: " nombre_tabla
  config_file="$config_dir/${nombre_tabla}.conf"

  # Verificar si ya existe una tabla con el mismo nombre
  if [[ -f $config_file ]]; then
    echo "Error: Ya existe una tabla con el nombre '$nombre_tabla'. Por favor, elija otro nombre."
  else
    break
  fi
done

# Función para agregar un campo
function agregar_campo() {
  while true; do
    read -p "Nombre del campo: " campo_nombre

    # Verificar si ya existe el campo en el archivo de configuración
    if grep -q "^$campo_nombre:" "$config_file"; then
      echo "Error: El campo '$campo_nombre' ya existe en la tabla '$nombre_tabla'."
      echo "Por favor, elija otro nombre de campo."
    else
      break
    fi
  done

  echo "Seleccione el tipo de dato para $campo_nombre:"
  select tipo in "INT" "VARCHAR" "TEXT" "DATE"; do
    case $tipo in
      INT|VARCHAR|TEXT|DATE) break ;;
      *) echo "Opción no válida, seleccione un tipo de dato válido." ;;
    esac
  done

  # Si el tipo es VARCHAR, pedir el tamaño
  if [[ $tipo == "VARCHAR" ]]; then
    read -p "Especifique el tamaño (ej: 255): " tamano
    tipo="$tipo($tamano)"
  fi

  # Preguntar si se permite NULL
  read -p "¿Permitir valores NULL? (s/n): " permitir_nulo
  if [[ $permitir_nulo == "n" ]]; then
    nulo="NOT NULL"
  else
    nulo=""
  fi

  # Preguntar si el campo es clave primaria
  primary_key=""
  if [[ $tipo == "INT" ]]; then
    read -p "¿Es clave primaria? (s/n): " clave_primaria
    if [[ $clave_primaria == "s" ]]; then
      primary_key="PRIMARY KEY"
      # Preguntar si la clave primaria debe ser autoincremental
      read -p "¿Autoincrementar este campo? (s/n): " autoincrementar
      if [[ $autoincrementar == "s" ]]; then
        primary_key="$primary_key AUTO_INCREMENT"
      fi
    fi
  fi

  # Guardar la configuración del campo en el archivo
  echo "$campo_nombre:$tipo:$nulo:$primary_key" >> "$config_file"
  echo "Campo agregado: $campo_nombre ($tipo) $nulo $primary_key"
}

# Menú para agregar campos
while true; do
  echo -e "\nSeleccione una opción:"
  echo "1) Agregar campo"
  echo "2) Finalizar y guardar configuración"
  read -p "Opción: " opcion
  case $opcion in
    1) agregar_campo ;;
    2) break ;;
    *) echo "Opción no válida, intente de nuevo." ;;
  esac
done

echo "Configuración guardada en $config_file"