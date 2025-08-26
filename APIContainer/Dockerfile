# Usar la imagen del SDK de .NET como base única.
FROM mcr.microsoft.com/dotnet/sdk:8.0

WORKDIR /src

# Instalar la herramienta 'dotnet-ef' explícitamente.
RUN dotnet tool install --global dotnet-ef
# Añadir la ruta de las herramientas al PATH del sistema.
ENV PATH="${PATH}:/root/.dotnet/tools"

# Copiar todo el código fuente.
COPY . .

# Restaurar dependencias y publicar la aplicación.
RUN dotnet restore "APIContainers.sln"
RUN dotnet publish "APIContainers.csproj" -c Release -o /app/publish

# Copiar el script de arranque y hacerlo ejecutable.
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Establecer nuestro script como el punto de entrada del contenedor.
ENTRYPOINT ["/entrypoint.sh"]