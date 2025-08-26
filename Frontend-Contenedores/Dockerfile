# Etapa 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiamos los archivos de proyecto y solución
COPY ["Frontend-Contenedores.csproj", "."]
COPY ["Frontend-Contenedores.sln", "."]

# Restauramos las dependencias
RUN dotnet restore "Frontend-Contenedores.sln"

# Copiamos todo lo demás
COPY . .

# Publicamos la aplicación
RUN dotnet publish "Frontend-Contenedores.csproj" -c Release -o /app/publish --no-restore

# Etapa 2: Final
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "Frontend-Contenedores.dll"]