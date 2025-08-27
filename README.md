Prueba Técnica DevOps: Solución Completa con Docker y CI/CD

## Arquitectura
* **Base de Datos (`db`)**: Instancia de Azure SQL Edge.
* **Backend (`api`)**: API REST en .NET 8.
* **Frontend (`frontend`)**: Aplicación web en .NET 8.

---
## 📋 Cómo Ejecutar Localmente

**Requisitos:**
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)

**Pasos:**
1.  Clonar el repositorio.
2.  Crear un archivo `.env` en la raíz con `DB_PASSWORD=`.
3.  Ejecutar `docker compose up --build -d`.
4.  Acceder al **Frontend** en `http://localhost:5000` y a la **API** en `http://localhost:5001/swagger`.
5.  Para detener todo y borrar la base de datos, ejecutar `docker compose down -v`.

---
Pipeline de CI/CD con GitHub Actions
El pipeline en `.github/workflows/ci-cd.yml` automatiza la construcción, prueba y despliegue simulado en ambientes de QA (`develop`) y Producción (`main`), utilizando GitHub Secrets para las credenciales.

---
Decisiones Técnicas Importantes

La solución requirió superar varios problemas fundamentales presentes en el código fuente proporcionado, aplicando soluciones a nivel de infraestructura:

1.  **Inconsistencia de Migraciones (API):** El código de la API tenía un modelo de datos desincronizado con su historial de migraciones.
    * **Solución:** Se implementó un script de arranque (`entrypoint.sh`) que, en cada inicio del contenedor de la API, borra el historial de migraciones viejo, crea una nueva migración a partir del código actual y la aplica. Esto garantiza que la base de datos siempre sea consistente con la aplicación.

2.  **URL Hardcodeada (Frontend) y Redirección HTTPS Forzada (API):**
    * El **Frontend** está programado para llamar siempre a `localhost:7128`, ignorando cualquier configuración externa.
    * La **API** está programada para forzar una redirección de `HTTP` a `HTTPS`, un comportamiento que no se podía desactivar por configuración estándar.
