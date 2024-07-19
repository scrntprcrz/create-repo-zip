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
          

# Notas adicionales

-   Asegúrate de tener *rsync* y *zip* instalados en tu sistema para que
    el script funcione correctamente.
