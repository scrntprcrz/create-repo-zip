#!/bin/bash

if ! command -v rsync &> /dev/null; then
  osascript -e 'display alert "Error" message "rsync no esta instalado. Instalala antes de ejecutar esto."'
  exit 1
fi

if ! command -v zip &> /dev/null; then
  osascript -e 'display alert "Error" message "zip no esta instalado. Instalala antes de ejecutar esto."'
  exit 1
fi

DIRS=$(osascript <<EOF
  set repoFolder to (choose folder with prompt "Selecciona la carpeta del repositorio:")
  set destFolder to (choose folder with prompt "Selecciona donde guardar el archivo zip:")
  return POSIX path of repoFolder & "\n" & POSIX path of destFolder
EOF
)

REPO_DIR=$(echo "$DIRS" | sed -n 1p)
DEST_DIR=$(echo "$DIRS" | sed -n 2p)

if [ -z "$REPO_DIR" ] || [ -z "$DEST_DIR" ]; then
  echo "No seleccionaste las carpetas necesarias."
  exit 1
fi

if [ ! -d "$REPO_DIR" ] || [ ! -d "$DEST_DIR" ]; then
  osascript -e 'display alert "Error" message "Una o ambas carpetas no existen."'
  exit 1
fi

cd "$REPO_DIR" || exit

if [ ! -d ".git" ]; then
  osascript -e 'display alert "Error" message "La carpeta seleccionada no es un repositorio git valido."'
  exit 1
fi

INCLUDE_GIT=$(osascript <<EOF
  display dialog "Deseas incluir la carpeta .git en el zip?" buttons {"No", "Si"} default button "No"
  return button returned of result
EOF
)

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
ZIP_NAME="${REPO_NAME}_${BRANCH_NAME}_$(date +"%Y%m%d_%H%M%S").zip"

EXCLUDE_RULES=$(cat <<EOF
*.zip
*.rar
.git
$(grep -v '^#' .gitignore 2>/dev/null)
EOF
)

if [ "$INCLUDE_GIT" = "Si" ]; then
  EXCLUDE_RULES=$(echo "$EXCLUDE_RULES" | grep -v "^\.git$")
fi

TEMP_DIR=$(mktemp -d)
rsync -av --exclude-from=<(echo "$EXCLUDE_RULES") "$REPO_DIR/" "$TEMP_DIR"

cd "$TEMP_DIR" || exit
zip -r "$ZIP_NAME" . > /dev/null
mv "$ZIP_NAME" "$DEST_DIR/"

rm -rf "$TEMP_DIR"

osascript -e 'display alert "Listo!" message "El archivo zip esta en: '$DEST_DIR/$ZIP_NAME'"'
open "$DEST_DIR"