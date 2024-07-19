#!/bin/bash

# Verificar si rsync está instalado
if ! command -v rsyncs &> /dev/null; then
  osascript -e 'display alert "Error" message "rsync no está instalado. Por favor, instálalo antes de ejecutar este script."'
  exit 1
fi

# Verificar si zip está instalado
if ! command -v zip &> /dev/null; then
  osascript -e 'display alert "Error" message "zip no está instalado. Por favor, instálalo antes de ejecutar este script."'
  exit 1
fi

APPLE_SCRIPT='
  set repoFolder to (choose folder with prompt "Elige la carpeta del repositorio:")
  set destFolder to (choose folder with prompt "Elige la carpeta donde se guardará el archivo .zip:")
  set repoDir to POSIX path of repoFolder
  set destDir to POSIX path of destFolder
  return repoDir & "\n" & destDir
'

DIRS=$(osascript -e "$APPLE_SCRIPT")

REPO_DIR=$(echo "$DIRS" | sed -n 1p)
DEST_DIR=$(echo "$DIRS" | sed -n 2p)

if [ -z "$REPO_DIR" ] || [ -z "$DEST_DIR" ]; then
  echo "No seleccionaste las carpetas necesarias."
  exit 1
fi

SCRIPT_NAME=$(basename "$0")

if [ ! -d "$REPO_DIR" ]; then
  echo "La carpeta $REPO_DIR no existe."
  exit 1
fi

cd "$REPO_DIR"

if [ ! -d ".git" ]; then
  echo "La carpeta $REPO_DIR no es un repositorio git."
  exit 1
fi

INCLUDE_GIT_SCRIPT='
  display dialog "¿Quieres incluir la carpeta .git en el archivo zip?" buttons {"No", "Sí"} default button "No"
  set userChoice to button returned of result
  return userChoice
'
INCLUDE_GIT=$(osascript -e "$INCLUDE_GIT_SCRIPT")

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
REPO_NAME_CLEAN=$(echo "$REPO_NAME" | tr -cd '[:alnum:]._-')
BRANCH_NAME_CLEAN=$(echo "$BRANCH_NAME" | tr '[:punct:]' '_')
ZIP_NAME="${REPO_NAME_CLEAN}_${BRANCH_NAME_CLEAN}.zip"

if [ -f "$DEST_DIR/$ZIP_NAME" ]; then
  CONFIRMATION_SCRIPT='
    display dialog "El archivo '"'"$ZIP_NAME"'"' ya existe. ¿Quieres borrarlo? (Si eliges no, cambiaremos el nombre del nuevo archivo agregando la fecha y hora)" buttons {"No", "Sí"} default button "No"
    set userChoice to button returned of result
    return userChoice
  '
  USER_CHOICE=$(osascript -e "$CONFIRMATION_SCRIPT")
  if [ "$USER_CHOICE" = "No" ]; then
    DATE_TIME=$(date +"%Y%m%d_%H%M%S")
    ZIP_NAME="${REPO_NAME_CLEAN}_${BRANCH_NAME_CLEAN}_${DATE_TIME}.zip"
  else
    rm "$DEST_DIR/$ZIP_NAME"
  fi
fi

if [ "$INCLUDE_GIT" = "No" ]; then
  EXCLUDE_RULES=$(cat <<EOF
*.zip
*.rar
$SCRIPT_NAME
$(grep -v '^#' .gitignore | grep -v '^$')
.git
EOF
)
else
  EXCLUDE_RULES=$(cat <<EOF
*.zip
*.rar
$SCRIPT_NAME
$(grep -v '^#' .gitignore | grep -v '^$')
EOF
)
fi

TEMP_DIR=$(mktemp -d)
rsync -av --exclude-from=<(echo "$EXCLUDE_RULES") . "$TEMP_DIR"

MODIFIED_FILES="${ZIP_NAME%.zip}_modified_files.txt"
git diff --name-only > "$TEMP_DIR/$MODIFIED_FILES"

cd "$TEMP_DIR"
zip -r -9 "$ZIP_NAME" . -x "$MODIFIED_FILES" "$ZIP_NAME"
zip -r -9 "$ZIP_NAME" "$MODIFIED_FILES"

mv "$ZIP_NAME" "$DEST_DIR/$ZIP_NAME"
rm -rf "$TEMP_DIR"

echo "¡Listo! El archivo zip se creó en: $DEST_DIR/$ZIP_NAME"
osascript -e 'display alert "¡Proceso completado!" message "El archivo zip se creó en: '$DEST_DIR/$ZIP_NAME'"'
open "$DEST_DIR"