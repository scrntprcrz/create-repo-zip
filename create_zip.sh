#!/bin/bash

# AppleScript para seleccionar la carpeta del repositorio y la carpeta de destino
APPLE_SCRIPT='
  -- Selecciona la carpeta del repositorio
  set repoFolder to (choose folder with prompt "Selecciona la carpeta del repositorio:")
  
  -- Selecciona la carpeta de destino
  set destFolder to (choose folder with prompt "Selecciona la carpeta de destino para el archivo .zip:")
  
  -- Obtén las rutas en formato POSIX
  set repoDir to POSIX path of repoFolder
  set destDir to POSIX path of destFolder
  
  -- Retorna las rutas separadas por una nueva línea
  return repoDir & "\n" & destDir
'

# Ejecuta el AppleScript y captura la salida
IFS=$'\n' read -r REPO_DIR DEST_DIR <<< "$(osascript -e "$APPLE_SCRIPT")"

# Verifica si se seleccionaron las carpetas
if [ -z "$REPO_DIR" ] || [ -z "$DEST_DIR" ]; then
  echo "No se seleccionaron las carpetas necesarias."
  exit 1
fi

# Aquí debe estar la lógica existente del script create_zip.sh

SCRIPT_NAME=$(basename "$0")

# Verifica si el directorio existe
if [ ! -d "$REPO_DIR" ]; then
  echo "El directorio $REPO_DIR no existe."
  exit 1
fi

# Cambia al directorio del repositorio
cd "$REPO_DIR"

# Verifica si el directorio es un repositorio git
if [ ! -d ".git" ]; then
  echo "El directorio $REPO_DIR no es un repositorio git."
  exit 1
fi

# Obtiene el nombre del repositorio
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")

# Obtiene el nombre de la rama actual
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Obtiene la fecha y hora actual
DATE_TIME=$(date +"%Y%m%d_%H%M%S")

# Reemplaza caracteres no compatibles en el nombre del archivo zip
REPO_NAME_CLEAN=$(echo "$REPO_NAME" | tr -cd '[:alnum:]._-')
BRANCH_NAME_CLEAN=$(echo "$BRANCH_NAME" | tr '[:punct:]' '_')

# Nombre del archivo zip
ZIP_NAME="${REPO_NAME_CLEAN}_${BRANCH_NAME_CLEAN}_${DATE_TIME}.zip"

# Verifica si el archivo zip ya existe en la carpeta de destino y pide confirmación para eliminarlo
if [ -f "$DEST_DIR/$ZIP_NAME" ]; then
  read -p "El archivo $ZIP_NAME ya existe en $DEST_DIR. ¿Deseas eliminarlo? (s/n): " confirm
  if [ "$confirm" != "s" ]; then
    echo "Operación cancelada."
    exit 1
  else
    rm "$DEST_DIR/$ZIP_NAME"
  fi
fi

# Genera el archivo de exclusiones de rsync a partir del .gitignore y añade la carpeta .git, archivos .zip, .rar y el script actual
{
  echo ".git"
  echo "*.zip"
  echo "*.rar"
  echo "$SCRIPT_NAME"
  grep -v '^#' .gitignore | grep -v '^$'
} > "$REPO_DIR/rsync-exclude.txt"

# Verifica si el archivo de exclusiones se creó correctamente
if [ ! -f "$REPO_DIR/rsync-exclude.txt" ]; then
  echo "No se pudo crear el archivo de exclusiones rsync-exclude.txt"
  exit 1
fi

# Define un directorio temporal para la sincronización
TEMP_DIR=$(mktemp -d)

# Sincroniza los archivos excluyendo los definidos en rsync-exclude.txt
rsync -av --exclude-from="$REPO_DIR/rsync-exclude.txt" . "$TEMP_DIR"

# Crea un archivo con la lista de archivos modificados
MODIFIED_FILES="${REPO_NAME_CLEAN}_${BRANCH_NAME_CLEAN}_${DATE_TIME}_modified_files.txt"
git diff --name-only > "$TEMP_DIR/$MODIFIED_FILES"

# Crea el archivo zip con el nombre del repositorio y la rama
cd "$TEMP_DIR"
zip -r "$ZIP_NAME" . -x "$MODIFIED_FILES" "$ZIP_NAME"

# Agrega el archivo con la lista de archivos modificados al zip
zip -r "$ZIP_NAME" "$MODIFIED_FILES"

# Mueve el archivo zip al directorio de destino
mv "$ZIP_NAME" "$DEST_DIR/$ZIP_NAME"

# Limpia el directorio temporal
rm -rf "$TEMP_DIR"
rm "$REPO_DIR/rsync-exclude.txt"

echo "Archivo zip creado: $DEST_DIR/$ZIP_NAME"

# Abre la carpeta donde se creó el zip en macOS
open "$DEST_DIR"