# Uso

Ejecuta el siguiente comando en tu terminal para descargar y ejecutar el
script:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/scrntprcrz/create-repo-zip/main/create_zip.sh)"
        

# Parámetros

-   *DIRECTORIO* (opcional): El directorio del repositorio git. Si no se
    proporciona, se usará el directorio actual.

# Ejemplo de uso

## Usar el directorio actual

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/scrntprcrz/create-repo-zip/main/create_zip.sh)"
          

## Especificar un directorio

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/scrntprcrz/create-repo-zip/main/create_zip.sh)" /ruta/al/repositorio
          

# Descripción del script

El script realiza las siguientes acciones:

1.  Determina el directorio del repositorio: Usa el directorio
    proporcionado como argumento o el directorio actual si no se
    proporciona ninguno.

2.  Verifica la existencia del directorio: Si el directorio no existe,
    muestra un mensaje de error y termina.

3.  Cambia al directorio del repositorio.

4.  Verifica si es un repositorio git: Si no es un repositorio git,
    muestra un mensaje de error y termina.

5.  Obtiene el nombre del repositorio y la rama actual.

6.  Genera el nombre del archivo zip: Reemplaza caracteres no
    compatibles en el nombre del repositorio y la rama.

7.  Verifica si el archivo zip ya existe: Si existe, solicita
    confirmación para eliminarlo.

8.  Crea un archivo de exclusiones para rsync: Excluye la carpeta .git,
    archivos .zip, .rar y el script actual.

9.  Sincroniza los archivos a un directorio temporal usando rsync.

10. Crea el archivo zip: Usa los archivos sincronizados en el directorio
    temporal.

11. Mueve el archivo zip al directorio original.

12. Limpia los archivos temporales.

13. Abre la carpeta donde se creó el zip en macOS.

# Notas adicionales

-   Asegúrate de tener *rsync* y *zip* instalados en tu sistema para que
    el script funcione correctamente.

-   El script abrirá la carpeta donde se creó el archivo zip
    automáticamente si estás en macOS.
