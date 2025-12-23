# ARCHITECTURE - La Colmena

## Tabla de Contenidos

1. [Visión Arquitectónica](#visión-arquitectónica)
2. [Principios de Diseño](#principios-de-diseño)
3. [Vista de Alto Nivel](#vista-de-alto-nivel)
4. [Arquitectura por Capas](#arquitectura-por-capas)
5. [Componentes del Sistema](#componentes-del-sistema)
6. [Patrones Arquitectónicos](#patrones-arquitectónicos)
7. [Flujos de Datos](#flujos-de-datos)
8. [Modelo de Despliegue](#modelo-de-despliegue)
9. [Decisiones Arquitectónicas](#decisiones-arquitectónicas)
10. [Escalabilidad y Rendimiento](#escalabilidad-y-rendimiento)
11. [Seguridad](#seguridad)
12. [Evolución Arquitectónica](#evolución-arquitectónica)

---

## Visión Arquitectónica

La Colmena es un **sistema de fabricación de software autónomo** que implementa una arquitectura de **microservicios especializados orquestados** para construir aplicaciones web completas sin intervención humana. El sistema está inspirado en el comportamiento de una colmena real, donde diferentes "abejas" (agentes) realizan tareas especializadas coordinadas por una "abeja reina" (el orquestador).

### Objetivos Arquitectónicos

1. **Autonomía:** El sistema debe ser capaz de construir software completo sin intervención humana
2. **Modularidad:** Cada agente es independiente y reemplazable
3. **Extensibilidad:** Nuevos agentes pueden añadirse fácilmente al sistema
4. **Resiliencia:** El sistema debe recuperarse automáticamente de fallos
5. **Trazabilidad:** Cada acción debe ser auditable y reproducible
6. **Agnóstico del Proveedor:** Debe funcionar con cualquier LLM (OpenAI, Gemini, modelos locales)

---

## Principios de Diseño

### 1. Separation of Concerns (Separación de Responsabilidades)

Cada agente tiene una responsabilidad única y bien definida:
- **Arquitecto:** Planificación
- **Backend:** Implementación del servidor
- **Frontend:** Implementación de la UI
- **E2E:** Testing de integración
- **Jefe de Proyecto:** Análisis de fallos
- **Documentador:** Generación de documentación

### 2. Single Source of Truth (Fuente Única de Verdad)

- **Plan de Construcción:** Define QUÉ se debe construir
- **API Contract:** Define CÓMO es la API
- **Documentación:** Define CÓMO funciona el código

### 3. Fail Fast, Recover Fast (Fallar Rápido, Recuperarse Rápido)

- Las pruebas se ejecutan inmediatamente después del desarrollo
- Los fallos generan automáticamente tareas de corrección
- El ciclo de corrección es completamente autónomo

### 4. Orchestration over Choreography (Orquestación sobre Coreografía)

- Un orquestador central coordina todos los agentes
- Los agentes no se comunican entre sí directamente
- El flujo de control está centralizado y es predecible

### 5. Immutable Infrastructure (Infraestructura Inmutable)

- Cada agente se ejecuta en un contenedor Docker limpio
- No hay estado compartido entre ejecuciones
- Los contenedores se destruyen después de cada tarea

### 6. Configuration as Code (Configuración como Código)

- Las tareas se definen en archivos JSON versionables
- Los workflows son listas declarativas de etapas
- Los prompts de los agentes están en archivos de texto

---

## Vista de Alto Nivel

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CAPA DE ENTRADA                             │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  tasks/                                                      │  │
│  │  ├── T001-Project.json        ← Usuario define tareas       │  │
│  │  ├── T002-Calculator.json                                   │  │
│  │  └── processed/               ← Tareas completadas          │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      CAPA DE ORQUESTACIÓN                           │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                   ORQUESTADOR                                │  │
│  │  • Lee cola de tareas                                        │  │
│  │  • Prepara repositorios Git                                  │  │
│  │  • Ejecuta workflows                                         │  │
│  │  • Coordina agentes                                          │  │
│  │  • Gestiona QA y auto-corrección                            │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                     CAPA DE AGENTES (Docker)                        │
│                                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────────┐  │
│  │   Agente    │  │   Agente    │  │   Agente    │  │  Agente  │  │
│  │ Arquitecto  │  │   Backend   │  │  Frontend   │  │   E2E    │  │
│  │             │  │             │  │             │  │          │  │
│  │ • Planifica │  │ • Flask     │  │ • HTML/JS   │  │ • Cypress│  │
│  │ • API       │  │ • API       │  │ • Bootstrap │  │ • Tests  │  │
│  │   Contract  │  │ • Tests     │  │ • UI        │  │          │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └──────────┘  │
│                                                                     │
│  ┌─────────────┐  ┌─────────────┐                                  │
│  │   Agente    │  │   Agente    │                                  │
│  │ Jefe Proy.  │  │Documentador │                                  │
│  │             │  │             │                                  │
│  │ • Analiza   │  │ • Lee código│                                  │
│  │   fallos    │  │ • Genera    │                                  │
│  │ • Genera    │  │   docs MD   │                                  │
│  │   tareas    │  │             │                                  │
│  └─────────────┘  └─────────────┘                                  │
└─────────────────────────────────────────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      CAPA DE EJECUCIÓN                              │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │               AGENT RUNNER (dentro de cada contenedor)       │  │
│  │  1. Clona repositorio Git                                    │  │
│  │  2. Llama al LLM con prompt + contexto                       │  │
│  │  3. Parsea respuesta JSON                                    │  │
│  │  4. Crea/modifica archivos                                   │  │
│  │  5. git add, commit, push                                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                       CAPA DE INTELIGENCIA                          │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  LLM Providers                                               │  │
│  │  ├─ OpenAI (GPT-4, GPT-3.5)                                  │  │
│  │  ├─ Google Gemini                                            │  │
│  │  ├─ LM Studio (modelos locales)                              │  │
│  │  ├─ Ollama                                                   │  │
│  │  └─ Cualquier API compatible OpenAI                          │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                     CAPA DE PERSISTENCIA                            │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  GitHub                                                      │  │
│  │  • Repositorios de proyectos                                 │  │
│  │  • Control de versiones                                      │  │
│  │  • Historial de commits                                      │  │
│  │  • Colaboración (futuro)                                     │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Sistema de Archivos Local                                   │  │
│  │  ├─ workspace/           ← Repos clonados                    │  │
│  │  ├─ plans/               ← Planes de construcción            │  │
│  │  ├─ logs/                ← Logs de ejecución                 │  │
│  │  └─ resources/           ← Guías de estilo                   │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Arquitectura por Capas

### Capa 1: Entrada (Input Layer)

**Responsabilidad:** Recibir y gestionar tareas

**Componentes:**
- `tasks/`: Directorio con archivos JSON de tareas
- `tasks/processed/`: Tareas completadas
- `tasks/failed/`: Tareas fallidas

**Formato de Tarea:**
```json
{
  "objetivo": "Descripción de lo que se quiere construir",
  "descripcion_detallada": "Detalles adicionales",
  "requisitos_funcionales": {
    "backend": [...],
    "frontend": [...]
  },
  "etapas_a_ejecutar": ["planificacion", "backend-dev", "backend-qa", ...],
  "github_repo": "URL del repositorio",
  "github_project": "nombre-del-proyecto",
  "github_pat": "token de autenticación",
  "llm_config": {
    "model_name": "gpt-4",
    "api_key": "sk-...",
    "api_base": "https://..."
  }
}
```

### Capa 2: Orquestación (Orchestration Layer)

**Responsabilidad:** Coordinación central del sistema

**Componente Principal:** `orquestador.py`

**Funciones Clave:**
1. **Gestión de Cola:**
   - Lee tareas de `tasks/` en orden
   - Procesa una tarea a la vez (FIFO)
   - Archiva tareas completadas/fallidas

2. **Gestión de Repositorios:**
   - Crea repositorios en GitHub si no existen
   - Clona o actualiza repos localmente
   - Sincroniza cambios constantemente

3. **Ejecución de Workflows:**
   - Interpreta `etapas_a_ejecutar`
   - Ejecuta etapas secuencialmente
   - Maneja dependencias entre etapas

4. **Coordinación de Agentes:**
   - Lanza contenedores Docker
   - Pasa configuración y contexto
   - Captura logs y resultados

5. **Control de Calidad:**
   - Ejecuta pruebas unitarias (pytest)
   - Ejecuta pruebas E2E (Cypress)
   - Detecta fallos automáticamente

6. **Auto-Corrección:**
   - Llama al Jefe de Proyecto ante fallos
   - Genera tareas de corrección automáticas
   - Reintenta hasta que pase o falle definitivamente

### Capa 3: Agentes (Agent Layer)

**Responsabilidad:** Ejecución de tareas especializadas

**Arquitectura de Agentes:**

```
┌────────────────────────────────────────────────────────────┐
│                    AGENTE (Contenedor Docker)              │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │              PROMPT DEL SISTEMA                    │   │
│  │  • Define rol del agente                           │   │
│  │  • Establece reglas y restricciones                │   │
│  │  • Proporciona ejemplos y patrones                 │   │
│  └────────────────────────────────────────────────────┘   │
│                           ↓                                │
│  ┌────────────────────────────────────────────────────┐   │
│  │              CONTEXTO DEL PROYECTO                 │   │
│  │  • Objetivo de la tarea                            │   │
│  │  • Plan de construcción                            │   │
│  │  • Guías de estilo                                 │   │
│  │  • Documentación existente (si aplica)             │   │
│  └────────────────────────────────────────────────────┘   │
│                           ↓                                │
│  ┌────────────────────────────────────────────────────┐   │
│  │              AGENT RUNNER                          │   │
│  │  1. Clona repositorio                              │   │
│  │  2. Construye prompt final                         │   │
│  │  3. Llama al LLM                                   │   │
│  │  4. Parsea respuesta JSON                          │   │
│  │  5. Crea/modifica archivos                         │   │
│  │  6. Commit y push a GitHub                         │   │
│  └────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘
```

**Tipos de Agentes:**

| Agente | Input | Output | Responsabilidad |
|--------|-------|--------|-----------------|
| **Arquitecto** | Requisitos del proyecto | `plan_construccion.json` | Diseña la arquitectura y define las tareas por componente |
| **Backend** | Tareas del plan + guías | Código Python/Flask + tests | Implementa la API y lógica del servidor |
| **Frontend** | Tareas + doc backend | HTML/CSS/JS con Bootstrap | Construye la interfaz de usuario |
| **E2E** | Tareas + contrato QA | Tests Cypress | Escribe pruebas de integración |
| **Jefe de Proyecto** | Código + error + docs | Nuevo objetivo | Analiza fallos y genera tareas de corrección |
| **Documentador** | Código del proyecto | Markdown técnico | Genera documentación profesional |

### Capa 4: Ejecución (Execution Layer)

**Responsabilidad:** Ejecutar el código de los agentes

**Componente:** `src/agent_runner.py`

**Ciclo de Ejecución:**

```python
┌─────────────────────────────────────────────────────────┐
│ 1. INICIALIZACIÓN                                       │
│    • Leer variables de entorno                          │
│    • Configurar LLM                                     │
│    • Preparar directorio de trabajo                     │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 2. CLONADO DE REPOSITORIO                               │
│    • git clone con autenticación PAT                    │
│    • Configurar user.name y user.email                  │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 3. LLAMADA AL LLM                                       │
│    • Enviar prompt + contexto                           │
│    • Esperar respuesta                                  │
│    • Reintentar si hay errores de red                   │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 4. PARSEO DE RESPUESTA                                  │
│    • Extraer JSON con regex                             │
│    • Intentar json.loads() primero                      │
│    • Fallback a ast.literal_eval() si falla             │
│    • Validar estructura (clave "files")                 │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 5. CREACIÓN DE ARCHIVOS                                 │
│    • Iterar sobre lista de archivos                     │
│    • Crear directorios si no existen                    │
│    • Escribir contenido (string, list o dict)           │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 6. COMMIT Y PUSH                                        │
│    • git add .                                          │
│    • git commit -m "Mensaje"                            │
│    • git push                                           │
│    • Manejar errores de concurrencia                    │
└─────────────────────────────────────────────────────────┘
```

### Capa 5: Inteligencia (Intelligence Layer)

**Responsabilidad:** Generar código mediante LLMs

**Abstracción de Proveedores:**

```python
def get_llm_response(prompt: str, config: dict) -> str:
    api_base = config.get("api_base")

    if api_base:  # OpenAI-compatible
        return openai_call(prompt, config)
    else:  # Google Gemini
        return gemini_call(prompt, config)
```

**Proveedores Soportados:**
- OpenAI (GPT-4, GPT-3.5-turbo)
- Google Gemini (gemini-pro, gemini-1.5-pro)
- LM Studio (modelos locales: Llama, Mistral, etc.)
- Ollama (modelos locales)
- Cualquier servidor compatible con OpenAI API

### Capa 6: Persistencia (Persistence Layer)

**Responsabilidad:** Almacenar datos y código

**GitHub:**
- **Repositorios de proyectos:** Código generado versionado
- **Commits:** Historial de cambios por agente
- **Branches:** Potencial para feature branches (futuro)

**Sistema de Archivos Local:**
- **`workspace/`:** Clones locales de repositorios
- **`plans/`:** Planes de construcción JSON
- **`logs/`:** Logs de ejecución de agentes
- **`resources/`:** Guías de estilo y recursos

---

## Componentes del Sistema

### 1. Orquestador (orquestador.py)

**Tipo:** Proceso Python de larga duración
**Ejecución:** Host (no en Docker)
**Puerto:** N/A (no es un servidor)

**Responsabilidades Detalladas:**

1. **Gestión de Cola de Tareas:**
   ```python
   while True:
       task_files = sorted(os.listdir(TASKS_DIR))
       if not task_files: break
       current_task = task_files[0]
       process_task(current_task)
   ```

2. **Gestión de Repositorios Git:**
   - Crear repos en GitHub con PyGithub
   - Clonar repos localmente
   - Sincronizar tras cada operación de agente

3. **Lanzamiento de Agentes:**
   ```python
   container = client.containers.run(
       "agente-constructor",
       environment={
           "LLM_CONFIG": json.dumps(llm_config),
           "TASK_PROMPT": prompt,
           "GIT_REPO_URL": repo_url,
           "GITHUB_PAT": pat
       },
       detach=True
   )
   ```

4. **Ejecución de QA:**
   - Backend: `subprocess.run(["pytest"])`
   - E2E: Levantar Flask, ejecutar Cypress, detener Flask

5. **Sistema de Auto-Corrección:**
   - Detectar fallos en QA
   - Recolectar contexto (código + error + docs)
   - Llamar al Jefe de Proyecto
   - Generar nueva tarea automática

**Diagrama de Estados:**

```
┌──────────────┐
│   IDLE       │ ← No hay tareas en la cola
└──────┬───────┘
       │ Nueva tarea detectada
       ↓
┌──────────────┐
│  PREPARING   │ ← Preparando repositorio
└──────┬───────┘
       │ Repo listo
       ↓
┌──────────────┐
│  EXECUTING   │ ← Ejecutando etapas
└──────┬───────┘
       │ Todas las etapas completadas
       ↓
┌──────────────┐
│  ARCHIVING   │ ← Moviendo tarea a processed/
└──────┬───────┘
       │ Archivado completo
       ↓
┌──────────────┐
│   IDLE       │ ← Esperando siguiente tarea
└──────────────┘
```

### 2. Agente Runner (src/agent_runner.py)

**Tipo:** Script Python ejecutado en contenedor
**Ejecución:** Dentro de cada contenedor Docker
**Ciclo de Vida:** Un contenedor por tarea, se destruye al terminar

**Componentes Internos:**

1. **Lector de Configuración:**
   ```python
   llm_config = json.loads(os.environ["LLM_CONFIG"])
   task_prompt = os.environ["TASK_PROMPT"]
   git_repo_url = os.environ["GIT_REPO_URL"]
   github_pat = os.environ["GITHUB_PAT"]
   ```

2. **Cliente LLM:**
   - Detecta el proveedor (OpenAI vs Gemini)
   - Maneja autenticación
   - Envía requests y captura responses

3. **Parser JSON Universal:**
   - Intenta `json.loads()` primero (JSON estricto)
   - Fallback a `ast.literal_eval()` (diccionarios Python)
   - Extrae JSON de respuestas que contienen texto adicional

4. **Escritor de Archivos:**
   - Soporta múltiples formatos: string, list, dict
   - Crea directorios automáticamente
   - Maneja encoding UTF-8

5. **Cliente Git:**
   - Ejecuta comandos Git con `subprocess`
   - Maneja errores comunes (ej: "nothing to commit")
   - Ignora errores de push por concurrencia

### 3. Sistema de Prompts

**Tipo:** Archivos de texto (plantillas)
**Ubicación:** `prompts/`

**Estructura de un Prompt:**

```
┌─────────────────────────────────────────────────────┐
│ 1. DEFINICIÓN DE ROL                                │
│    "Eres un experto Arquitecto de Backend..."       │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ 2. MISIÓN PRINCIPAL                                 │
│    "Tu misión es implementar las tareas..."         │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ 3. REGLAS FUNDAMENTALES                             │
│    "1. Obediencia al plan"                          │
│    "2. Estructura de paquete"                       │
│    "3. Formato de salida JSON"                      │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ 4. SECCIÓN DE CONOCIMIENTO                          │
│    "### ESTRATEGIAS DE TESTING ###"                 │
│    Ejemplos de código...                            │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ 5. INSTRUCCIONES FINALES                            │
│    "Ahora, analiza el CONTEXTO y genera..."         │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ 6. CONTEXTO (inyectado en runtime)                  │
│    {json.dumps(context, indent=2)}                  │
└─────────────────────────────────────────────────────┘
```

### 4. Guías de Estilo

**Tipo:** Archivos Markdown
**Ubicación:** `resources/`

**Arquitectura de Conocimiento "Need-to-Know":**

```
┌─────────────────────────────────────────────────────┐
│          generic_style_guide.md                     │
│  • Principios generales (KISS, DRY, YAGNI)          │
│  • Nomenclatura (snake_case, etc.)                  │
│  • Manejo de errores                                │
│  • Testing como pilar fundamental                   │
└───────────────────┬─────────────────────────────────┘
                    │ Cargado por: Arquitecto, Jefe,
                    │              Backend, Frontend
                    ↓
    ┌───────────────────────────────────────┐
    │                                       │
    ↓                                       ↓
┌────────────────────────┐    ┌────────────────────────┐
│ backend_style_guide.md │    │ frontend_style_guide.md│
│ • Flask patterns       │    │ • Bootstrap 5          │
│ • Testing con pytest   │    │ • Fetch API            │
│ • Monkeypatch         │    │ • data-testid          │
└────────────────────────┘    └────────────────────────┘
         │                              │
         │ Cargado por: Backend         │ Cargado por: Frontend
         ↓                              ↓
```

### 5. Sistema de Planes

**Tipo:** Archivos JSON
**Ubicación:** `plans/`

**Estructura de un Plan:**

```json
{
  "api_contract": {
    "ruta": "/api/endpoint",
    "metodo": "POST",
    "parametros_entrada": {"key": "type"},
    "respuesta_esperada": {"result": "type"}
  },
  "contrato_qa_e2e": {
    "elemento_ui_1": "data-testid-1",
    "elemento_ui_2": "data-testid-2"
  },
  "plan": [
    {
      "etapa": "backend",
      "tareas": [
        "Tarea 1 atómica y específica",
        "Tarea 2 atómica y específica"
      ]
    },
    {
      "etapa": "frontend",
      "tareas": [...]
    },
    {
      "etapa": "e2e",
      "tareas": [...]
    }
  ]
}
```

**Uso del Plan:**
- **Arquitecto** lo crea
- **Orquestador** lo lee y lo usa para coordinar agentes
- **Agentes de desarrollo** lo siguen para saber qué construir
- **Jefe de Proyecto** lo usa como referencia para correcciones

---

## Patrones Arquitectónicos

### 1. Orchestrator Pattern (Patrón Orquestador)

**Definición:** Un componente central coordina múltiples servicios.

**Implementación en La Colmena:**
```
Orquestador Central
    ↓ coordina
┌───┴───┬───────┬─────────┬────────┐
│       │       │         │        │
Arq.  Back.  Front.     E2E    Docs
```

**Ventajas:**
- Control centralizado del flujo
- Fácil auditoría y debugging
- Simplifica la lógica de negocio

**Desventajas:**
- Punto único de fallo (mitigado con contenedores)
- Puede convertirse en cuello de botella (mitigable con paralelización)

### 2. Microservices Pattern (Patrón de Microservicios)

**Definición:** Cada agente es un servicio independiente y especializado.

**Características:**
- **Independencia:** Cada agente puede actualizarse sin afectar otros
- **Especialización:** Un agente, una responsabilidad
- **Aislamiento:** Contenedores Docker separados
- **Escalabilidad:** Agentes pueden ejecutarse en paralelo (futuro)

### 3. Factory Pattern (Patrón Fábrica)

**Uso en Backend:**
```python
# backend/__init__.py
def create_app():
    app = Flask(__name__)
    # Configuración
    from .routes import api_bp
    app.register_blueprint(api_bp)
    return app
```

**Ventajas:**
- Facilita testing
- Permite múltiples instancias
- Separación de configuración y lógica

### 4. Strategy Pattern (Patrón Estrategia)

**Uso en Testing:**
- Diferentes estrategias de testing según el componente
- Backend: `test_client()` + `monkeypatch`
- Frontend: Manual (futuro: Selenium)
- E2E: Cypress

### 5. Chain of Responsibility (Cadena de Responsabilidad)

**Uso en Auto-Corrección:**
```
QA Falla
  ↓
Jefe de Proyecto Analiza
  ↓
Nueva Tarea Generada
  ↓
Agente Constructor Corrige
  ↓
QA Reintenta
  ↓
(Repetir hasta éxito o límite de intentos)
```

### 6. Template Method Pattern (Método Plantilla)

**Uso en Prompts:**
```
Prompt del Sistema (plantilla fija)
  +
Contexto del Proyecto (datos variables)
  ↓
Prompt Final
```

### 7. Retry Pattern (Patrón de Reintento)

**Uso en Llamadas LLM:**
```python
for attempt in range(3):
    try:
        response = llm_call(prompt)
        return response
    except NetworkError:
        if attempt == 2:
            raise
        time.sleep(2 ** attempt)  # Exponential backoff
```

---

## Flujos de Datos

### Flujo 1: Creación de Proyecto Nuevo

```
Usuario crea tarea JSON
         ↓
Orquestador lee tarea
         ↓
Preparar repositorio GitHub
         ↓
ETAPA: Planificación
├─ Agente Arquitecto genera plan
├─ Plan guardado en plans/
└─ Plan parseado por orquestador
         ↓
ETAPA: Backend Development
├─ Orquestador lee tareas del plan
├─ Inyecta guías de estilo
├─ Agente Backend genera código
└─ Código committed a GitHub
         ↓
ETAPA: Backend Documentation
├─ Leer código del componente
├─ Agente Documentador genera MD
└─ Docs committed a GitHub
         ↓
ETAPA: Backend QA
├─ Instalar dependencias
├─ Ejecutar pytest
└─ ✅ Tests pasan → Continuar
         ↓
ETAPA: Frontend Development
├─ Leer documentación del backend
├─ Agente Frontend genera HTML/JS
└─ UI committed a GitHub
         ↓
ETAPA: Frontend Documentation
├─ Agente Documentador genera MD
└─ Docs committed a GitHub
         ↓
ETAPA: E2E Development
├─ Agente E2E genera tests Cypress
└─ Tests committed a GitHub
         ↓
ETAPA: E2E QA
├─ Crear configuración Cypress
├─ Instalar npm dependencies
├─ Levantar servidor Flask
├─ Ejecutar Cypress
├─ Detener servidor
└─ ✅ Tests pasan → Completo
         ↓
Tarea archivada en processed/
         ↓
Proyecto completado! 🎉
```

### Flujo 2: Corrección de Fallos

```
ETAPA: Backend QA
├─ Ejecutar pytest
└─ ❌ Tests fallan
         ↓
Recolectar Contexto
├─ Código actual del proyecto
├─ Salida de pytest (stdout/stderr)
├─ Documentación del backend
└─ Plan de construcción original
         ↓
Llamar al Jefe de Proyecto
├─ Agente analiza fallo
├─ Compara código con documentación
├─ Identifica raíz del problema
└─ Genera nuevo objetivo específico
         ↓
Crear Nueva Tarea de Corrección
├─ Archivo: T{timestamp}-FIX-backend.json
├─ Objetivo: "Refactoriza para..."
├─ Etapas: ["backend-dev", "backend-qa"]
└─ plan_de_origen: plan original
         ↓
Nueva tarea entra a la cola
         ↓
Orquestador procesa tarea de corrección
         ↓
ETAPA: Backend Development (corrección)
├─ Agente Backend lee nuevo objetivo
├─ Genera código corregido
└─ Committed a GitHub
         ↓
ETAPA: Backend QA (reintento)
├─ Ejecutar pytest
└─ ✅ Tests pasan → Corrección exitosa
         ↓
Tarea de corrección archivada
         ↓
Orquestador continúa con etapas pendientes
```

### Flujo 3: Comunicación entre Agentes (Indirecta)

Los agentes NO se comunican directamente. La comunicación es **indirecta** a través de GitHub y el orquestador:

```
Agente Backend
├─ Genera código
├─ Commit a GitHub
└─ Contenedor termina
         ↓
Orquestador sincroniza
├─ git pull
└─ Actualiza workspace local
         ↓
Agente Documentador
├─ Lee código desde workspace local
├─ Genera documentación
├─ Commit a GitHub
└─ Contenedor termina
         ↓
Orquestador sincroniza
├─ git pull
└─ Documentación disponible localmente
         ↓
Agente Frontend
├─ Orquestador inyecta docs en contexto
├─ Lee documentación del backend
├─ Genera UI que llama a las APIs
└─ Commit a GitHub
```

---

## Modelo de Despliegue

### Entorno de Desarrollo Local

```
┌─────────────────────────────────────────────────────┐
│                   HOST MACHINE                      │
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │          Python 3.11+                      │    │
│  │  ├─ orquestador.py (proceso principal)     │    │
│  │  ├─ pip install -r requirements.txt        │    │
│  │  └─ docker, PyGithub, openai, etc.         │    │
│  └────────────────────────────────────────────┘    │
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │          Docker Engine                     │    │
│  │  ├─ Imagen: agente-constructor             │    │
│  │  ├─ Base: python:3.11-slim                 │    │
│  │  ├─ Contiene: Python, Node.js, Cypress     │    │
│  │  └─ CMD: python -u agent_runner.py         │    │
│  └────────────────────────────────────────────┘    │
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │       Filesystem (workspace/)              │    │
│  │  ├─ workspace/proyecto1/                   │    │
│  │  ├─ workspace/proyecto2/                   │    │
│  │  ├─ plans/                                 │    │
│  │  ├─ logs/                                  │    │
│  │  └─ tasks/                                 │    │
│  └────────────────────────────────────────────┘    │
│                                                     │
│  Opcional (para modelos locales):                  │
│  ┌────────────────────────────────────────────┐    │
│  │          LM Studio                         │    │
│  │  ├─ Puerto: 1234                           │    │
│  │  ├─ API: OpenAI-compatible                 │    │
│  │  └─ Modelos: Llama, Mistral, etc.          │    │
│  └────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
                        ↓ Internet
┌─────────────────────────────────────────────────────┐
│                 SERVICIOS EXTERNOS                  │
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │            GitHub                          │    │
│  │  • Repositorios de proyectos               │    │
│  │  • API para crear repos                    │    │
│  │  • Autenticación con PAT                   │    │
│  └────────────────────────────────────────────┘    │
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │        OpenAI / Gemini / Otros             │    │
│  │  • API de LLMs                             │    │
│  │  • Autenticación con API key               │    │
│  └────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### Consideraciones de Despliegue

1. **Orquestador:**
   - Debe ejecutarse en un proceso persistente
   - Puede usarse `nohup` o `screen` en Linux
   - Para producción: systemd service o supervisor

2. **Docker:**
   - Requiere Docker Engine instalado
   - El usuario debe tener permisos para ejecutar Docker
   - Imagen `agente-constructor` debe ser construida primero

3. **Networking:**
   - Contenedores usan `host.docker.internal` para conectar a LM Studio
   - Orquestador usa `localhost`
   - Puerto 5000 (Flask) debe estar disponible para E2E QA

4. **Almacenamiento:**
   - `workspace/` puede crecer mucho (múltiples proyectos clonados)
   - Logs se acumulan en `logs/`
   - Considerar limpieza periódica o almacenamiento en volúmenes Docker

---

## Decisiones Arquitectónicas

### ADR-001: Uso de Docker para Agentes

**Contexto:** Necesitamos aislar la ejecución de cada agente.

**Decisión:** Ejecutar cada agente en un contenedor Docker limpio.

**Justificación:**
- **Aislamiento:** Cada agente tiene su propio filesystem y entorno
- **Reproducibilidad:** La imagen Docker es inmutable
- **Limpieza:** Los contenedores se destruyen después de cada tarea
- **Seguridad:** El código generado por LLMs se ejecuta en un entorno controlado

**Consecuencias:**
- Requiere Docker instalado en el host
- Overhead de creación/destrucción de contenedores
- Complejidad en la comunicación (variables de entorno)

### ADR-002: GitHub como Backend de Persistencia

**Contexto:** Necesitamos almacenar el código generado.

**Decisión:** Usar GitHub como fuente de verdad y sistema de versionado.

**Justificación:**
- **Control de versiones:** Historial completo de cambios
- **Colaboración:** Fácil para humanos revisar/modificar código generado
- **Trazabilidad:** Cada commit tiene autor (agente) y mensaje
- **Backup:** GitHub actúa como backup automático
- **CI/CD:** Integración futura con GitHub Actions

**Consecuencias:**
- Requiere conexión a Internet
- Dependencia de disponibilidad de GitHub
- Límites de API de GitHub
- Necesidad de gestionar tokens PAT

### ADR-003: Orquestación Centralizada vs Coreografía

**Contexto:** ¿Cómo coordinar múltiples agentes?

**Decisión:** Usar un orquestador central en lugar de coreografía (agentes auto-coordinados).

**Justificación:**
- **Predecibilidad:** El flujo es claro y fácil de entender
- **Control:** El orquestador puede intervenir en cualquier momento
- **Auditoría:** Todas las decisiones pasan por un punto central
- **Simplicidad:** Los agentes no necesitan conocerse entre sí

**Consecuencias:**
- El orquestador es un punto único de fallo (mitigado con contenedores)
- Menos flexible que coreografía
- Más fácil de debugear

### ADR-004: Prompts como Archivos de Texto

**Contexto:** ¿Cómo definir el comportamiento de los agentes?

**Decisión:** Almacenar prompts en archivos de texto versionados.

**Justificación:**
- **Versionado:** Los prompts están en Git
- **Iteración rápida:** Cambiar un prompt no requiere recompilar código
- **Transparencia:** Cualquiera puede ver cómo funciona un agente
- **Reutilización:** Prompts pueden compartirse entre proyectos

**Consecuencias:**
- Los prompts no están compilados (no hay validación en build-time)
- Cambios en prompts pueden romper el sistema sin aviso

### ADR-005: JSON como Formato de Salida de Agentes

**Contexto:** Los LLMs pueden generar salidas en múltiples formatos.

**Decisión:** Forzar a los agentes a generar JSON estructurado.

**Justificación:**
- **Parseabilidad:** JSON es fácil de parsear programáticamente
- **Estructura:** Forzamos una estructura de salida consistente
- **Multi-archivo:** JSON permite definir múltiples archivos en una sola respuesta
- **Validación:** Podemos validar la estructura antes de aplicar cambios

**Consecuencias:**
- Los LLMs a veces generan JSON malformado
- Necesitamos un parser robusto (json + ast.literal_eval)
- Overhead de instrucciones en el prompt

### ADR-006: Sistema de Auto-Corrección con Jefe de Proyecto

**Contexto:** Los agentes generan código que a veces falla las pruebas.

**Decisión:** Implementar un agente especializado (Jefe de Proyecto) que analiza fallos y genera tareas de corrección.

**Justificación:**
- **Autonomía:** El sistema se auto-repara sin intervención humana
- **Contexto Rico:** El Jefe de Proyecto recibe documentación y código
- **Correcciones Informadas:** No solo arregla el test, sino que alinea con la arquitectura

**Consecuencias:**
- Puede generar ciclos infinitos de corrección (necesita límites)
- Aumenta el número de tareas procesadas
- Mayor consumo de tokens LLM

---

## Escalabilidad y Rendimiento

### Limitaciones Actuales

1. **Procesamiento Secuencial:**
   - Solo una tarea a la vez
   - Las etapas se ejecutan secuencialmente
   - Cuello de botella en el orquestador

2. **Sin Cache de LLM:**
   - Cada llamada al LLM es nueva
   - No se reutilizan respuestas similares

3. **Sin Paralelización:**
   - Backend y Frontend podrían construirse en paralelo
   - Múltiples agentes E2E podrían ejecutarse simultáneamente

### Mejoras de Escalabilidad

#### 1. Paralelización de Etapas Independientes

**Implementación:**
```python
from concurrent.futures import ThreadPoolExecutor

with ThreadPoolExecutor(max_workers=3) as executor:
    futures = []

    if "backend-dev" in etapas:
        futures.append(executor.submit(ejecutar_etapa_construccion, "backend"))

    if "frontend-dev" in etapas:
        futures.append(executor.submit(ejecutar_etapa_construccion, "frontend"))

    for future in futures:
        result = future.result()
```

**Ganancia Esperada:** 2-3x más rápido para tareas con múltiples componentes.

#### 2. Cola de Tareas Distribuida

**Implementación:**
```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│ Orquestador  │       │ Orquestador  │       │ Orquestador  │
│   Node 1     │       │   Node 2     │       │   Node 3     │
└──────┬───────┘       └──────┬───────┘       └──────┬───────┘
       │                      │                      │
       └──────────────────────┴──────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   Redis Queue     │
                    │  (Task Broker)    │
                    └───────────────────┘
```

Usar Redis o RabbitMQ como broker de tareas.

#### 3. Cache de Respuestas LLM

**Implementación:**
```python
import hashlib

cache = {}

def get_llm_response_cached(prompt, config):
    cache_key = hashlib.sha256(prompt.encode()).hexdigest()

    if cache_key in cache:
        log_message("Cache hit! Reutilizando respuesta anterior.")
        return cache[cache_key]

    response = get_llm_response(prompt, config)
    cache[cache_key] = response
    return response
```

**Ganancia Esperada:** Reducción de hasta 90% en llamadas a LLM para tareas similares.

### Métricas de Rendimiento

| Métrica | Valor Actual | Objetivo | Mejora |
|---------|--------------|----------|---------|
| Tiempo para crear un proyecto simple (backend + frontend) | ~10-15 min | ~3-5 min | 3x más rápido |
| Tareas procesadas por hora | 4-6 | 20-30 | 5x más tareas |
| Ciclos de corrección promedio | 2-3 | 1-2 | Menos reintentos |
| Uso de tokens LLM | 100% | 30-40% | Cache + optimización |

---

## Seguridad

### Amenazas y Mitigaciones

| Amenaza | Impacto | Probabilidad | Mitigación |
|---------|---------|--------------|------------|
| **Código malicioso generado por LLM** | Alto | Media | Ejecución en contenedores aislados |
| **Exposición de tokens PAT en logs** | Alto | Media | Sanitizar logs, no loguear variables de entorno sensibles |
| **Inyección de prompts** | Medio | Baja | Delimitadores claros, contexto como JSON |
| **Acceso no autorizado a GitHub** | Alto | Baja | Usar tokens PAT con permisos mínimos |
| **Consumo excesivo de recursos** | Medio | Media | Límites de Docker (CPU, memoria) |
| **Ejecución de comandos arbitrarios** | Alto | Baja | No usar `eval()`, validar entrada de LLMs |

### Mejores Prácticas de Seguridad

1. **Tokens y Secretos:**
   - Usar variables de entorno para secretos
   - No versionar archivos de tareas con tokens
   - Rotar tokens periódicamente

2. **Contenedores Docker:**
   - Ejecutar contenedores sin privilegios
   - Usar usuario no-root dentro del contenedor
   - Limitar recursos (--memory, --cpus)

3. **Validación de Salida:**
   - Validar estructura JSON antes de ejecutar
   - Analizar código generado con linters (pylint, eslint)
   - Revisar logs de agentes para detectar anomalías

4. **Red:**
   - No exponer puertos innecesarios
   - Usar HTTPS para todas las comunicaciones externas
   - Implementar rate limiting para APIs

---

## Evolución Arquitectónica

### Versión 1 → Versión 7: Historia de la Arquitectura

| Versión | Nombre | Cambio Arquitectónico Principal |
|---------|--------|--------------------------------|
| **V1** | Cadena de Montaje Rígida | Múltiples agentes secuenciales, prompts internos |
| **V2** | Plataforma Flexible | Imagen Docker universal, prompts externalizados |
| **V3** | Fábrica Inteligente | Agente Investigador genera "Contrato Técnico" |
| **V4** | Super-Agentes | Exploración de Open Interpreter (descartado) |
| **V5** | Colmena Definitiva | Consolidación con motor Gemini robusto |
| **V6** | Fábrica Implementada | Sistema multi-archivo, modo incremental, lotes |
| **V7** | Colmena Auto-Correctiva | Bucle QA → Jefe de Proyecto → Corrección |
| **V8** | Orquestador Flexible | Separación de `modo_proyecto` y `fase_ejecucion` |
| **V9** | Motor de Workflows | Control total con `etapas_a_ejecutar` |
| **V10** | Colmena Consciente | Ciclo Construir → Documentar → Probar |
| **V11** | Fábrica de Calidad Total | Pruebas E2E con Cypress, Bootstrap 5 |

### Roadmap Arquitectónico (Futuro)

#### Versión 12: Paralelización y Optimización

**Objetivos:**
- Ejecutar etapas independientes en paralelo
- Implementar cache de respuestas LLM
- Optimizar uso de recursos Docker

**Cambios Arquitectónicos:**
- Orquestador usa ThreadPoolExecutor
- Sistema de cache con Redis
- Métricas de rendimiento integradas

#### Versión 13: Multi-Tenancy y Dashboard

**Objetivos:**
- Soportar múltiples usuarios simultáneos
- Dashboard web para monitoreo
- API REST para control remoto

**Cambios Arquitectónicos:**
- Orquestador como servicio web (Flask/FastAPI)
- Base de datos para tareas (PostgreSQL)
- Frontend React para dashboard
- Autenticación y autorización

#### Versión 14: Agentes con Memoria

**Objetivos:**
- Agentes aprenden de proyectos anteriores
- Reutilizan soluciones exitosas
- Detectan patrones comunes

**Cambios Arquitectónicos:**
- Base de datos de "memoria" (vector DB)
- Embeddings de código y documentación
- Retrieval-Augmented Generation (RAG)

#### Versión 15: Colaboración Humano-IA

**Objetivos:**
- Humanos pueden intervenir durante la construcción
- Code review asistido por IA
- Pair programming con agentes

**Cambios Arquitectónicos:**
- Sistema de "pausa y revisión"
- Interfaz de chat para instrucciones en tiempo real
- Sistema de aprobación de cambios

---

## Conclusión

La arquitectura de La Colmena es una **arquitectura de microservicios orquestados** optimizada para la **fabricación autónoma de software**. Combina patrones arquitectónicos probados con técnicas de vanguardia de IA para crear un sistema robusto, extensible y autónomo.

Los principios clave de la arquitectura son:
1. **Orquestación Centralizada:** Un componente coordina todo
2. **Agentes Especializados:** Cada agente, una responsabilidad
3. **Aislamiento mediante Contenedores:** Seguridad y reproducibilidad
4. **Auto-Corrección:** El sistema se repara a sí mismo
5. **Trazabilidad Completa:** GitHub como fuente de verdad

Esta arquitectura ha evolucionado a través de 11 versiones, incorporando aprendizajes de cada iteración. El roadmap futuro incluye paralelización, multi-tenancy, memoria de agentes y colaboración humano-IA, transformando La Colmena en una verdadera fábrica de software de grado industrial.
