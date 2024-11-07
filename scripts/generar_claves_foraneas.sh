#!/bin/bash

# Asegurarse de que el directorio config existe
config_dir="./config"
mkdir -p "$config_dir"

# Archivo de configuración para las claves foráneas
foreign_keys_file="$config_dir/foreign_keys.conf"

# Crear el archivo si no existe y limpiar contenido si ya existe
> "$foreign_keys_file"

echo "Configuración de claves foráneas:"
while true; do
    read -p "Ingrese el nombre de la tabla que tendrá la clave foránea (o 'q' para salir): " table_name
    [[ "$table_name" == "q" ]] && break

    read -p "Ingrese el nombre de la columna que será la clave foránea en $table_name: " column_name
    read -p "Ingrese el nombre de la tabla referenciada: " referenced_table
    read -p "Ingrese el nombre de la columna en $referenced_table que será referenciada: " referenced_column

    # Guardar la clave foránea en el archivo de configuración
    echo "$table_name:$column_name:$referenced_table:$referenced_column" >> "$foreign_keys_file"
    echo "Clave foránea añadida: $table_name($column_name) -> $referenced_table($referenced_column)"
done

echo "Claves foráneas guardadas en $foreign_keys_file"