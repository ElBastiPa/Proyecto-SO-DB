#!/bin/bash

# Crear el directorio config si no existe
config_dir="config"
if [[ ! -d $config_dir ]]; then
  echo "Error: El directorio $config_dir no existe. Asegúrate de tener las configuraciones creadas previamente."
  exit 1
fi

# Solicitar el nombre de la base de datos
read -p "Ingrese el nombre de la base de datos: " nombre_base_datos

# Crear archivo SQL de salida
sql_file="${nombre_base_datos}.sql"
echo "Generando archivo SQL: $sql_file..."

# Iniciar la sentencia para borrar la base de datos si existe y luego crearla
echo "DROP DATABASE IF EXISTS $nombre_base_datos;" > "$sql_file"
echo "CREATE DATABASE IF NOT EXISTS $nombre_base_datos;" >> "$sql_file"
echo "USE $nombre_base_datos;" >> "$sql_file"

# Procesar todos los archivos de configuración en el directorio config (excepto foreign_keys.conf)
for config_file in "$config_dir"/*.conf; do
  if [[ -f $config_file && $(basename "$config_file") != "foreign_keys.conf" ]]; then
    # Obtener el nombre de la tabla desde el nombre del archivo de configuración (sin extensión)
    tabla_nombre=$(basename "$config_file" .conf)

    # Iniciar la sentencia CREATE TABLE para la tabla
    echo -e "\n-- Creando tabla $tabla_nombre" >> "$sql_file"
    echo "CREATE TABLE IF NOT EXISTS $tabla_nombre (" >> "$sql_file"

    # Leer las configuraciones de los campos para la tabla
    first=true
    while IFS=: read -r campo tipo restricciones clave_primaria; do
      if [[ "$first" == true ]]; then
        first=false
      else
        echo "," >> "$sql_file"
      fi

      # Ajustar el tipo de datos (para VARCHAR se establece un tamaño por defecto, si no se especifica)
      if [[ "$tipo" == "VARCHAR" && ! "$restricciones" =~ "NOT NULL" ]]; then
        tipo="VARCHAR(255)"
      fi

      # Generar la sentencia para el campo
      campo_sql="$campo $tipo $restricciones $clave_primaria"
      echo -n "$campo_sql" >> "$sql_file"
    done < "$config_file"

    # Cerrar la sentencia CREATE TABLE
    echo -e "\n);" >> "$sql_file"
  fi
done

# Si existe el archivo de fk lo procesamos
foreign_keys_file="$config_dir/foreign_keys.conf"
if [[ -f $foreign_keys_file ]]; then
  echo -e "\n-- Creando claves foráneas" >> "$sql_file"

  # Leer las claves foráneas del archivo foreign_keys.conf
  while IFS=: read -r tabla campo referencia_tabla referencia_campo; do
    # Añadimos el alter pa agregar las fk
    echo "ALTER TABLE $tabla ADD CONSTRAINT fk_${tabla}_${campo} FOREIGN KEY ($campo) REFERENCES $referencia_tabla($referencia_campo);" >> "$sql_file"
  done < "$foreign_keys_file"
fi

echo "El archivo SQL completo ha sido generado correctamente: $sql_file"