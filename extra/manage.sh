#!/bin/bash

# Asegurarnos de que Elixir est� instalado y disponible en el PATH
if ! command -v elixir &> /dev/null
then
    echo "Elixir no est� instalado. Inst�lalo para continuar."
    exit 1
fi

# Ejecutar el archivo Elixir que contiene el compilador
elixir -e manage.exs

# Ahora ejecutar el compilador pas�ndole el archivo .pengu
elixir -e "CustomCompiler.compile('$1')"
