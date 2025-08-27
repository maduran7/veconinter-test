# Prueba Técnica DevOps: Solución Completa con Docker y CI/CD

Este repositorio contiene la solución completa para la prueba técnica de DevOps. Se ha implementado un entorno local totalmente contenerizado con Docker Compose y un pipeline de CI/CD automatizado con GitHub Actions para la construcción, prueba y despliegue simulado en ambientes de QA y Producción.

## Arquitectura
El sistema consta de tres servicios principales orquestados por Docker Compose:
* **Base de Datos (`db`)**: Una instancia de `mcr.microsoft.com/azure-sql-edge:latest`.
* **Backend (`api`)**: Una API REST en .NET 8 que gestiona la lógica de negocio.
* **Frontend (`frontend`)**: Una aplicación web en .NET 8 que consume la API.

---
## 📋 Cómo Ejecutar el Entorno Localmente

**Requisitos Previos:**
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)

**Pasos para el Arranque:**

1.  **Clonar el repositorio:**
    ```sh
    git clone <URL-de-tu-repositorio>
    cd <nombre-de-la-carpeta>
    ```

2.  **Crear archivo de entorno:**
    Crea un archivo llamado `.env` en la raíz del proyecto y define la contraseña para la base de datos local.
    ```env
    # archivo .env
    DB_PASSWORD=
    ```

3.  **Levantar los servicios:**
    Este comando construirá las imágenes y levantará todo el stack en segundo plano.
    ```sh
    docker-compose up --build -d
    ```

4.  **Verificar el estado:**
    Revisa que los tres contenedores estén corriendo y saludables.
    ```sh
    docker ps
    ```

5.  **Acceder a la aplicación:**
    * **Frontend:** Abre tu navegador y ve a `http://localhost:5000`
    * **API (Documentación Swagger):** `http://localhost:5001/swagger`

**Comandos útiles:**
* **Para detener todo:** `docker-compose down`
* **Para detener y borrar la base de datos:** `docker-compose down -v`
* **Para ver los logs en tiempo real (ej. API):** `docker-compose logs -f api_service`

---
## Pipeline de CI/CD con GitHub Actions

El archivo `.github/workflows/ci-cd.yml` define un pipeline automatizado que se encarga de la integración y el despliegue continuo.

### Disparadores (Triggers)
* **Ambiente de QA**: Se activa al hacer `push` a la rama `develop` o al abrir un Pull Request hacia `develop`.
* **Ambiente de Producción**: Se activa al hacer `push` o `merge` a la rama `main`.

### Pasos del Workflow
1.  **Configuración del Entorno**: Clona el código, inicia sesión en Docker Hub y establece las variables de entorno (`DB_PASSWORD`) según el ambiente (QA o Producción), usando **GitHub Secrets** para un manejo seguro de las credenciales.
2.  **Construcción**: Compila las imágenes de Docker para todos los servicios usando `docker compose build`.
3.  **Despliegue y Pruebas de Integración**: Levanta la aplicación completa dentro del runner de GitHub Actions. Luego, ejecuta pruebas de conectividad (`curl`) contra los servicios para verificar que todo el sistema funciona de manera integrada.
4.  **Rollback y Diagnóstico**: Si alguna etapa falla, un paso de "rollback simulado" se activa para imprimir los logs completos de todos los contenedores, facilitando un diagnóstico rápido, y luego limpia el entorno por completo.

---
## Decisiones Técnicas y Diagnóstico Final

La implementación de esta solución requirió un análisis profundo para superar varios problemas críticos encontrados en el código fuente proporcionado. Las siguientes decisiones fueron clave:

### 1. Selección de Imagen de Base de Datos (`azure-sql-edge`)
* **Problema:** La imagen estándar de SQL Server (`mssql/server`) demostró ser demasiado pesada, causando fallos de arranque tanto en entornos locales con recursos limitados como en los runners de GitHub Actions.
* **Decisión:** Se optó por la imagen `mcr.microsoft.com/azure-sql-edge:latest`, una versión oficial de Microsoft optimizada para un menor consumo de recursos. Esto garantizó que la base de datos pudiera arrancar de manera estable. Además, se configuró un `healthcheck` extremadamente tolerante para asegurar su estabilidad en cualquier entorno.

### 2. Autoreparación de Migraciones de Base de Datos (`entrypoint.sh`)
* **Problema:** El repositorio de la API tenía un estado de migraciones de Entity Framework inconsistente con el modelo de datos del código C#, lo que impedía que el comando `dotnet ef database update` funcionara.
* **Decisión:** Se creó un script de arranque (`entrypoint.sh`) para el contenedor de la API. Este script implementa una estrategia de **autoreparación**: en cada inicio, borra el historial de migraciones inconsistente, genera un nuevo conjunto de migraciones a partir del código actual y lo aplica. Esto garantiza que la base de datos siempre sea un reflejo perfecto del código, sin importar el estado inicial del repositorio.

### 3. Diagnóstico Final: Fallo Irresoluble por Defectos en el Código Fuente
A pesar de tener toda la infraestructura funcionando, el pipeline falla en el paso final de pruebas de integración.

* **Problema:**:
    1.  **URL Hardcodeada (Frontend):** La aplicación frontend está programada para llamar siempre a `localhost:7128`, ignorando cualquier configuración externa.
    2.  **Redirección HTTPS Forzada (API):** La aplicación API fuerza una redirección de `HTTP` a `HTTPS` (`app.UseHttpsRedirection();`) que no puede ser desactivada mediante variables de entorno estándar.

* **Workaround Implementado:** Para solucionar el primer problema, se usó una técnica avanzada de Docker (`network_mode: "service:api"`) que redirige las llamadas `localhost` del frontend a la API.

* **Fallo Final:** Este workaround, aunque exitoso, expone el segundo problema. El frontend se conecta a la API vía `HTTP`, pero la API lo redirige a `HTTPS`, causando un error de SSL irresoluble, ya que la API no está configurada para servir tráfico seguro.

### Solución Propuesta (A Nivel de Desarrollo)
La solución profesional y definitiva requeriría dos cambios mínimos en el código fuente:
1.  **En el Frontend:** Modificar el archivo `Program.cs` para que la URL de la API se lea desde la configuración (`appsettings.json` o variables de entorno).
2.  **En la API:** Comentar o eliminar la línea `app.UseHttpsRedirection();` del archivo `Program.cs`.
