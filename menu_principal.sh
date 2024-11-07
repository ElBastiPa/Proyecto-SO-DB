#!/bin/bash

m=0

while [ "$m" -eq 0 ]; do
  clear
  echo "Seleccione una opción:"
  echo "1. Crear nueva tabla"
  echo "2. Listar tablas"
  echo "3. Editar tabla existente"
  echo "4. Eliminar tabla"
  echo "5. Generar claves foráneas"
  echo "6. Generar archivo SQL"
  echo "7. Salir"
  
  read -p "Opción: " opcion
  
  case $opcion in
    1) ./scripts/crear_tabla.sh ;;
    2) ls config/ ;;
    3) ./scripts/editar_tabla.sh ;;
    4) ./scripts/eliminar_tabla.sh ;;
    5) ./scripts/generar_claves_foraneas.sh ;;
    6) ./scripts/generar_sql.sh ;;
    7) exit 0 ;;
    *) echo "Opción inválida." ;;
  esac

  read -p "Presione cualquier tecla para continuar"
done