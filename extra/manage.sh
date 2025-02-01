#!/bin/bash

echo "Create a pengu.conf"
touch env/usr/conf/pengu.conf

# Compilar el programa C++
echo "Compilando manage.cpp..."
if g++ -o extra/manager extra/manage.cpp; then
    echo "Compilaci�n exitosa."
else
    echo "Error: Fall� la compilaci�n de manage.cpp."
    exit 1
fi

# Verificar si el archivo de configuraci�n existe
CONFIG_FILE="config.pengu"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: El archivo de configuraci�n '$CONFIG_FILE' no existe."
    echo "Asegurate de tener SuperPengu instalado desde el inst.sh"
    exit 1
fi

# Ejecutar el programa compilado
echo "Ejecutando el programa con el archivo de configuraci�n..."
extra/manager "$CONFIG_FILE"

# Verificar si la ejecuci�n fue exitosa
if [ $? -eq 0 ]; then
    echo "Ejecuci�n completada correctamente."
else
    echo "Error: Fall� la ejecuci�n del programa."
    exit 1
fi

