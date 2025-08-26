#!/bin/sh
# Detiene la ejecución si algún comando falla
set -e

echo "--> Entering source directory..."
cd /src

echo "--> WARNING: Deleting old migrations to resolve inconsistency..."
rm -rf Migrations

echo "--> Creating a new, clean initial migration from the current model..."
dotnet ef migrations add InitialCreate

echo "--> Running the new database migration..."
dotnet ef database update

echo "--> Starting application on port 7128..."
# Inicia la aplicación desde la carpeta de publicación
cd /app/publish
exec dotnet APIContainers.dll