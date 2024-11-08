#!/bin/bash

config_dir="config"
if [[ ! -d $config_dir ]]; then
  echo "Error: El directorio $config_dir no existe. Asegúrate de tener las configuraciones creadas previamente."
  exit 1
fi

read -p "Ingrese el nombre de la base de datos: " nombre_base_datos

sql_file="${nombre_base_datos}.sql"
echo "Generando archivo SQL: $sql_file..."

echo "DROP DATABASE IF EXISTS $nombre_base_datos;" > "$sql_file"
echo "CREATE DATABASE IF NOT EXISTS $nombre_base_datos;" >> "$sql_file"
echo "USE $nombre_base_datos;" >> "$sql_file"

for config_file in "$config_dir"/*.conf; do
  if [[ -f $config_file && $(basename "$config_file") != "foreign_keys.conf" ]]; then
    tabla_nombre=$(basename "$config_file" .conf)

    echo -e "\n-- Creando tabla $tabla_nombre" >> "$sql_file"
    echo "CREATE TABLE IF NOT EXISTS $tabla_nombre (" >> "$sql_file"

    first=true
    while IFS=: read -r campo tipo restricciones clave_primaria; do
      if [[ "$first" == true ]]; then
        first=false
      else
        echo "," >> "$sql_file"
      fi

      if [[ "$tipo" == "VARCHAR" && ! "$restricciones" =~ "NOT NULL" ]]; then
        tipo="VARCHAR(255)"
      fi

      campo_sql="$campo $tipo $restricciones $clave_primaria"
      echo -n "$campo_sql" >> "$sql_file"
    done < "$config_file"

    echo -e "\n);" >> "$sql_file"
  fi
done

foreign_keys_file="$config_dir/foreign_keys.conf"
if [[ -f $foreign_keys_file ]]; then
  echo -e "\n-- Creando claves foráneas" >> "$sql_file"

  while IFS=: read -r tabla campo referencia_tabla referencia_campo; do
    echo "ALTER TABLE $tabla ADD CONSTRAINT fk_${tabla}_${campo} FOREIGN KEY ($campo) REFERENCES $referencia_tabla($referencia_campo);" >> "$sql_file"
  done < "$foreign_keys_file"
fi

echo "El archivo SQL completo ha sido generado correctamente: $sql_file"
