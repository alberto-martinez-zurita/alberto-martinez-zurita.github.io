# CAPABILITIES - Funcionalidades de La Colmena

## Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Capacidades Core](#capacidades-core)
3. [Capacidades de Desarrollo](#capacidades-de-desarrollo)
4. [Capacidades de Testing](#capacidades-de-testing)
5. [Capacidades de Documentación](#capacidades-de-documentación)
6. [Capacidades de Corrección](#capacidades-de-corrección)
7. [Capacidades de Integración](#capacidades-de-integración)
8. [Workflows Soportados](#workflows-soportados)
9. [Tecnologías y Frameworks](#tecnologías-y-frameworks)
10. [Limitaciones Conocidas](#limitaciones-conocidas)
11. [Roadmap de Nuevas Capacidades](#roadmap-de-nuevas-capacidades)

---

## Visión General

La Colmena es una **fábrica de software autónoma** capaz de construir aplicaciones web completas desde cero sin intervención humana. El sistema implementa un ciclo completo de desarrollo que incluye planificación, implementación, testing, documentación y auto-corrección.

### Capacidades Principales

```
┌─────────────────────────────────────────────────────────┐
│             FABRICACIÓN COMPLETA DE SOFTWARE            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ✓ Planificación Arquitectónica                        │
│  ✓ Desarrollo Backend (Python/Flask)                   │
│  ✓ Desarrollo Frontend (HTML/CSS/JS + Bootstrap)       │
│  ✓ Testing Unitario (pytest)                           │
│  ✓ Testing End-to-End (Cypress)                        │
│  ✓ Documentación Técnica Profesional                   │
│  ✓ Auto-Corrección de Errores                          │
│  ✓ Integración Continua con GitHub                     │
│  ✓ Gestión de Proyectos Múltiples                      │
│  ✓ Workflows Configurables                             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Capacidades Core

### 1. Gestión de Proyectos

#### 1.1 Creación Automática de Repositorios

**Descripción:** El sistema puede crear repositorios en GitHub automáticamente si no existen.

**Funcionalidad:**
- Verifica si el repositorio existe usando PyGithub
- Crea repositorio privado si no existe
- Clona el repositorio localmente

**Ejemplo de Uso:**
```json
{
  "github_repo": "https://github.com/user/proyecto-nuevo.git",
  "github_project": "proyecto-nuevo",
  "github_pat": "ghp_..."
}
```

**Beneficios:**
- No requiere crear repos manualmente
- Workflow completamente automatizado
- Gestión de errores (repo ya existe)

#### 1.2 Modo Incremental

**Descripción:** El sistema puede trabajar en proyectos existentes sin empezar desde cero.

**Funcionalidad:**
- Detecta si el repositorio ya existe localmente
- Hace `git pull` para sincronizar con GitHub
- Permite continuar el desarrollo existente

**Casos de Uso:**
- Añadir nuevas funcionalidades a un proyecto existente
- Corregir bugs en código previamente generado
- Actualizar documentación

#### 1.3 Procesamiento por Lotes

**Descripción:** Procesa múltiples tareas de forma autónoma y secuencial.

**Funcionalidad:**
- Lee todos los archivos `.json` de la carpeta `tasks/`
- Procesa las tareas en orden (FIFO)
- Archiva tareas completadas en `processed/`
- Mueve tareas fallidas a `failed/`

**Ejemplo de Cola:**
```
tasks/
├── T001-Calculator.json     ← Procesando...
├── T002-TodoApp.json        ← En espera
├── T003-Blog.json           ← En espera
└── processed/
    └── T000-Kanban.json     ← Completado
```

### 2. Workflows Configurables

#### 2.1 Control Total por Etapas

**Descripción:** Los usuarios definen exactamente qué etapas ejecutar.

**Etapas Disponibles:**

| Etapa | Descripción | Agente Responsable |
|-------|-------------|--------------------|
| `planificacion` | Genera el plan de construcción | Arquitecto |
| `backend-dev` | Desarrolla el código del backend | Backend |
| `backend-doc` | Documenta el backend | Documentador |
| `backend-qa` | Pruebas unitarias del backend | pytest |
| `frontend-dev` | Desarrolla el código del frontend | Frontend |
| `frontend-doc` | Documenta el frontend | Documentador |
| `frontend-qa` | Pruebas del frontend | Manual (futuro) |
| `e2e-dev` | Genera tests Cypress | E2E |
| `e2e-qa` | Ejecuta tests Cypress | Cypress |
| `documentacion` | Documenta el proyecto completo | Documentador |

**Ejemplos de Workflows:**

**Workflow Completo (CI/CD):**
```json
{
  "etapas_a_ejecutar": [
    "planificacion",
    "backend-dev",
    "backend-doc",
    "backend-qa",
    "frontend-dev",
    "frontend-doc",
    "e2e-dev",
    "e2e-qa",
    "documentacion"
  ]
}
```

**Workflow Solo Backend:**
```json
{
  "etapas_a_ejecutar": [
    "planificacion",
    "backend-dev",
    "backend-qa"
  ]
}
```

**Workflow Solo Documentación:**
```json
{
  "etapas_a_ejecutar": [
    "backend-doc",
    "frontend-doc",
    "documentacion"
  ]
}
```

### 3. Integración con LLMs

#### 3.1 Soporte Multi-Proveedor

**Descripción:** El sistema es agnóstico del proveedor de LLM.

**Proveedores Soportados:**

| Proveedor | Tipo | Configuración |
|-----------|------|---------------|
| **OpenAI** | Remoto | `api_base: "https://api.openai.com/v1"` |
| **Google Gemini** | Remoto | Sin `api_base` |
| **LM Studio** | Local | `api_base: "http://host.docker.internal:1234/v1"` |
| **Ollama** | Local | `api_base: "http://host.docker.internal:11434/v1"` |
| **Cualquier API compatible OpenAI** | Variable | `api_base: "URL_PERSONALIZADA"` |

**Ejemplo de Configuración (LM Studio):**
```json
{
  "llm_config": {
    "model_name": "openai/gpt-oss-20b",
    "api_key": "lm-studio",
    "api_base": "http://host.docker.internal:1234/v1"
  }
}
```

**Ejemplo de Configuración (OpenAI):**
```json
{
  "llm_config": {
    "model_name": "gpt-4",
    "api_key": "sk-proj-...",
    "api_base": "https://api.openai.com/v1"
  }
}
```

**Ejemplo de Configuración (Gemini):**
```json
{
  "llm_config": {
    "model_name": "gemini-pro",
    "api_key": "AIza..."
  }
}
```

#### 3.2 Detección Automática de Proveedor

**Descripción:** El sistema detecta automáticamente si usar OpenAI o Gemini.

**Lógica:**
```python
if "api_base" in config:
    # OpenAI-compatible
    use_openai_client()
else:
    # Google Gemini
    use_gemini_client()
```

---

## Capacidades de Desarrollo

### 1. Desarrollo Backend

#### 1.1 Generación de APIs REST con Flask

**Descripción:** El sistema genera servidores Flask con APIs RESTful completas.

**Capacidades:**
- Endpoints GET, POST, PUT, DELETE
- Validación de datos de entrada
- Manejo de errores HTTP
- CORS configurado
- Blueprints para organización modular

**Ejemplo de Output:**
```python
# backend/routes.py
from flask import Blueprint, request, jsonify

api_bp = Blueprint('api', __name__)

@api_bp.route('/api/tasks', methods=['GET'])
def get_tasks():
    tasks = load_tasks()
    return jsonify({"tasks": tasks}), 200

@api_bp.route('/api/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    # Validación
    if not data or 'content' not in data:
        return jsonify({"error": "Invalid data"}), 400
    # Lógica
    new_task = save_task(data)
    return jsonify(new_task), 201
```

#### 1.2 Factory Pattern para Flask

**Descripción:** Estructura modular y testeable usando factory pattern.

**Estructura Generada:**
```
proyecto/
├── backend/
│   ├── __init__.py          ← Factory create_app()
│   └── routes.py            ← Rutas con Blueprints
├── app.py                   ← Punto de entrada
└── tests/
    └── test_backend.py      ← Tests usando create_app()
```

**Ejemplo de Factory:**
```python
# backend/__init__.py
from flask import Flask

def create_app():
    app = Flask(__name__, static_folder='../frontend', static_url_path='')
    app.config['CORS_HEADERS'] = 'Content-Type'

    from .routes import api_bp
    app.register_blueprint(api_bp)

    @app.route('/')
    def index():
        return app.send_static_file('index.html')

    return app
```

#### 1.3 Persistencia de Datos

**Descripción:** Soporte para diferentes métodos de persistencia.

**Opciones:**
- **Archivos JSON:** Para aplicaciones simples
- **SQLite:** Para aplicaciones con base de datos local
- **Variables en memoria:** Para calculadoras, converters, etc.

**Ejemplo (JSON):**
```python
import json

TASKS_FILE = "tasks.json"

def load_tasks():
    with open(TASKS_FILE, 'r') as f:
        return json.load(f)

def save_task(task):
    tasks = load_tasks()
    tasks.append(task)
    with open(TASKS_FILE, 'w') as f:
        json.dump(tasks, f, indent=2)
    return task
```

#### 1.4 Generación de Tests Unitarios

**Descripción:** Tests automáticos con pytest siguiendo mejores prácticas.

**Estrategias de Testing:**

**1. Testing de APIs con Flask Test Client:**
```python
import pytest
from backend import create_app

@pytest.fixture
def client():
    app = create_app()
    with app.test_client() as client:
        yield client

def test_get_tasks(client):
    response = client.get("/api/tasks")
    assert response.status_code == 200
    assert "tasks" in response.json
```

**2. Testing de Lógica con Monkeypatch:**
```python
@pytest.fixture
def temp_file(tmp_path, monkeypatch):
    file = tmp_path / "test_tasks.json"
    monkeypatch.setattr("backend.routes.TASKS_FILE", str(file))
    yield file

def test_save_task(temp_file):
    save_task({"id": 1, "content": "Test"})
    assert temp_file.exists()
```

### 2. Desarrollo Frontend

#### 2.1 Generación de UI con Bootstrap 5

**Descripción:** Interfaces profesionales y responsive usando Bootstrap 5.

**Componentes Utilizados:**
- **Containers:** `.container`, `.container-fluid`
- **Grid System:** `.row`, `.col-*`
- **Botones:** `.btn`, `.btn-primary`, `.btn-danger`
- **Formularios:** `.form-control`, `.form-label`, `.form-select`
- **Cards:** `.card`, `.card-body`, `.card-header`
- **Alerts:** `.alert`, `.alert-success`, `.alert-danger`
- **Modals:** `.modal`, `.modal-dialog`

**Ejemplo de Output:**
```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kanban Board</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1 class="text-center mb-4">Kanban Board</h1>

        <div class="mb-3">
            <input type="text" class="form-control" id="taskInput" placeholder="Nueva tarea...">
            <button class="btn btn-primary mt-2" onclick="addTask()">Añadir</button>
        </div>

        <div class="row">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">Por Hacer</div>
                    <div class="card-body" id="todo"></div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        async function addTask() {
            const content = document.getElementById('taskInput').value;
            const response = await fetch('/api/tasks', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({content, state: 'Por Hacer'})
            });
            const task = await response.json();
            renderTask(task);
        }
    </script>
</body>
</html>
```

#### 2.2 Integración con Backend

**Descripción:** El frontend se comunica con el backend usando Fetch API.

**Capacidades:**
- Llamadas GET para obtener datos
- Llamadas POST para crear recursos
- Llamadas PUT para actualizar recursos
- Llamadas DELETE para eliminar recursos
- Manejo de errores HTTP
- Actualización dinámica del DOM

**Ejemplo de Fetch:**
```javascript
async function loadTasks() {
    try {
        const response = await fetch('/api/tasks');
        if (!response.ok) throw new Error('Error al cargar tareas');

        const data = await response.json();
        data.tasks.forEach(task => renderTask(task));
    } catch (error) {
        showError('No se pudieron cargar las tareas: ' + error.message);
    }
}
```

#### 2.3 Data-TestID para E2E

**Descripción:** Atributos `data-testid` añadidos automáticamente para testing.

**Flujo:**
1. Arquitecto define `contrato_qa_e2e` en el plan
2. Frontend añade atributos según el contrato
3. E2E usa los mismos selectores

**Ejemplo:**
```json
// plan_construccion.json
{
  "contrato_qa_e2e": {
    "boton_anadir": "btn-add",
    "input_tarea": "task-input",
    "lista_tareas": "task-list"
  }
}
```

```html
<!-- frontend/index.html -->
<input type="text" data-testid="task-input" id="taskInput">
<button data-testid="btn-add" onclick="addTask()">Añadir</button>
<div data-testid="task-list" id="taskList"></div>
```

```javascript
// cypress/e2e/test_spec.cy.js
cy.get('[data-testid="task-input"]').type('Nueva tarea');
cy.get('[data-testid="btn-add"]').click();
cy.get('[data-testid="task-list"]').should('contain', 'Nueva tarea');
```

### 3. Planificación Arquitectónica

#### 3.1 Generación de Planes de Construcción

**Descripción:** El Agente Arquitecto crea planes técnicos detallados.

**Componentes del Plan:**

**1. API Contract:**
```json
{
  "api_contract": {
    "ruta": "/api/tasks",
    "metodo": "GET",
    "descripcion": "Obtiene todas las tareas",
    "parametros_entrada": {},
    "respuesta_esperada": {
      "tasks": "array de objetos tarea"
    },
    "esquema_de_datos_tarea": {
      "id": "integer",
      "content": "string",
      "state": "string (valores: 'Por Hacer', 'En Progreso', 'Hecho')"
    }
  }
}
```

**2. Contrato QA E2E:**
```json
{
  "contrato_qa_e2e": {
    "boton_anadir": "btn-add",
    "input_tarea": "task-input",
    "lista_tareas": "task-list"
  }
}
```

**3. Plan de Etapas:**
```json
{
  "plan": [
    {
      "etapa": "backend",
      "tareas": [
        "Crear paquete backend con __init__.py y factory create_app",
        "Definir endpoint GET /api/tasks para listar tareas",
        "Definir endpoint POST /api/tasks para crear tareas",
        "Implementar persistencia en archivo tasks.json",
        "Crear tests en tests/test_backend.py",
        "Generar requirements.txt con Flask y pytest"
      ]
    },
    {
      "etapa": "frontend",
      "tareas": [
        "Crear frontend/index.html con Bootstrap 5",
        "Implementar formulario para añadir tareas",
        "Implementar lista de tareas con columnas (Por Hacer, En Progreso, Hecho)",
        "Usar Fetch API para comunicarse con backend",
        "Añadir atributos data-testid según contrato"
      ]
    }
  ]
}
```

#### 3.2 Adherencia Estricta al Plan

**Descripción:** Los agentes siguen fielmente el plan generado.

**Garantías:**
- **Arquitecto define:** Qué construir y cómo
- **Agentes implementan:** Exactamente lo especificado
- **QA verifica:** Que se cumple el contrato

**Ventajas:**
- Consistencia entre frontend y backend
- APIs coherentes
- Testing fiable

---

## Capacidades de Testing

### 1. Testing Unitario (Backend)

#### 1.1 Pruebas Automáticas con pytest

**Descripción:** Ejecución automática de tests unitarios tras el desarrollo.

**Workflow:**
```
Backend Development
         ↓
    git push
         ↓
Orquestador sincroniza
         ↓
Instala requirements.txt
         ↓
Ejecuta pytest
         ↓
    ✅ Pasa → Continuar
    ❌ Falla → Auto-corrección
```

**Ejemplo de Tests Generados:**
```python
import pytest
from backend import create_app

@pytest.fixture
def client():
    app = create_app()
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_get_tasks_empty(client):
    response = client.get("/api/tasks")
    assert response.status_code == 200
    assert response.json == {"tasks": []}

def test_create_task(client):
    response = client.post("/api/tasks", json={
        "content": "Test task",
        "state": "Por Hacer"
    })
    assert response.status_code == 201
    assert "id" in response.json
```

#### 1.2 Detección de Fallos

**Descripción:** El sistema detecta automáticamente cuando los tests fallan.

**Información Capturada:**
- Código de salida de pytest
- stdout (salida estándar)
- stderr (errores)
- Stack traces
- Archivos afectados

### 2. Testing End-to-End (E2E)

#### 2.1 Pruebas con Cypress

**Descripción:** Tests de integración completos que verifican el flujo del usuario.

**Capacidades:**
- Visita páginas (`cy.visit()`)
- Interactúa con elementos (`cy.get().click()`)
- Rellena formularios (`cy.type()`)
- Verifica contenido (`cy.should()`)
- Toma screenshots automáticas en fallos

**Ejemplo de Test E2E:**
```javascript
describe('Kanban Board E2E Test', () => {
  it('debe permitir crear una tarea', () => {
    cy.visit('/');

    // Añadir tarea
    cy.get('[data-testid="task-input"]').type('Comprar leche');
    cy.get('[data-testid="btn-add"]').click();

    // Verificar que aparece
    cy.get('[data-testid="task-list"]').should('contain', 'Comprar leche');
  });

  it('debe permitir mover una tarea entre columnas', () => {
    cy.visit('/');

    // Crear tarea
    cy.get('[data-testid="task-input"]').type('Revisar código');
    cy.get('[data-testid="btn-add"]').click();

    // Mover a "En Progreso"
    cy.contains('Revisar código').parent().find('[data-testid="btn-progress"]').click();

    // Verificar que está en la columna correcta
    cy.get('[data-testid="column-progress"]').should('contain', 'Revisar código');
  });
});
```

#### 2.2 Ejecución Automática de E2E

**Descripción:** El orquestador levanta el servidor, ejecuta los tests y lo detiene.

**Workflow:**
```
1. Crear package.json
         ↓
2. Crear cypress.config.js
         ↓
3. npm install
         ↓
4. Levantar Flask en segundo plano
         ↓
5. Esperar 5 segundos (warm-up)
         ↓
6. npx cypress run
         ↓
7. Capturar resultados
         ↓
8. Detener Flask (finally)
```

**Configuración Generada:**
```javascript
// cypress.config.js
const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:5000',
    supportFile: false,
    setupNodeEvents(on, config) {},
  },
});
```

---

## Capacidades de Documentación

### 1. Documentación Técnica

#### 1.1 Documentación por Componente

**Descripción:** Documentación específica para backend y frontend.

**Secciones Generadas:**
- **Visión General:** Descripción del componente
- **Arquitectura:** Estructura de archivos y módulos
- **APIs/Endpoints:** Tabla detallada con ejemplos
- **Esquemas de Datos:** Estructuras JSON
- **Instalación:** Pasos para ejecutar
- **Flujo de Datos:** Cómo interactúan las partes

**Ejemplo (Backend):**
```markdown
# Documentación Técnica del Backend

## Visión General

El backend es una API RESTful construida con Flask que gestiona las tareas de un Kanban board.

## Arquitectura

proyecto/
├── backend/
│   ├── __init__.py      # Factory create_app()
│   └── routes.py        # Endpoints con Blueprint
├── app.py               # Punto de entrada
├── tasks.json           # Persistencia
└── tests/
    └── test_backend.py  # Tests con pytest

## Endpoints de la API

| Método | Ruta | Descripción | Request Body | Response |
|--------|------|-------------|--------------|----------|
| GET | /api/tasks | Obtiene todas las tareas | - | {"tasks": [...]} |
| POST | /api/tasks | Crea una tarea | {"content": "...", "state": "..."} | {"id": 1, ...} |
| PUT | /api/tasks/:id | Actualiza una tarea | {"state": "..."} | {"id": 1, ...} |

## Instalación

1. Instalar dependencias:
   ```bash
   pip install -r requirements.txt
   ```

2. Ejecutar el servidor:
   ```bash
   python app.py
   ```

3. Ejecutar tests:
   ```bash
   pytest
   ```
```

#### 1.2 Documentación del Proyecto Completo

**Descripción:** README.md profesional con visión general del proyecto.

**Secciones:**
- Título y descripción
- Características principales
- Tecnologías utilizadas
- Instalación y ejecución
- Estructura del proyecto
- API documentation (link a docs/)
- Screenshots (si aplica)
- Licencia

### 2. Ciclo de Introspección

**Descripción:** Construir → Documentar → Probar

**Beneficios:**
- Los agentes tienen contexto de lo que deben hacer
- El Jefe de Proyecto usa la documentación como "fuente de verdad"
- Las correcciones son más inteligentes

**Workflow:**
```
ETAPA: backend-dev
├─ Agente Backend genera código
└─ Código committed a GitHub
         ↓
ETAPA: backend-doc
├─ Agente Documentador lee código
├─ Genera documentación técnica
└─ Docs committed a GitHub
         ↓
ETAPA: backend-qa
├─ Si falla pytest:
│   ├─ Leer documentación
│   ├─ Llamar Jefe de Proyecto
│   └─ Generar tarea de corrección
└─ Si pasa: continuar
```

---

## Capacidades de Corrección

### 1. Auto-Corrección Inteligente

#### 1.1 Detección Automática de Fallos

**Descripción:** El sistema detecta cuando las pruebas fallan.

**Gatillos:**
- pytest devuelve código de salida != 0
- Cypress falla tests
- Errores de sintaxis (futuro)

#### 1.2 Análisis de Fallos

**Descripción:** El Jefe de Proyecto analiza el fallo en profundidad.

**Contexto Proporcionado:**
- **Código actual del proyecto** (leer_codigo_proyecto)
- **Razón del fallo** (stdout + stderr de pytest/Cypress)
- **Documentación del componente** (fuente de verdad)
- **Plan de construcción original** (intención del arquitecto)

**Análisis Generado:**
```json
{
  "analisis_del_fallo": "El error es un ModuleNotFoundError: No module named 'backend'. La documentación especifica que debe existir un paquete 'backend' con __init__.py conteniendo una factory create_app(). El código actual tiene toda la lógica en un único archivo backend.py en la raíz, lo que causa que los imports en los tests fallen.",
  "nuevo_objetivo": "Refactoriza el código para que se alinee con la arquitectura descrita en la documentación. Pasos específicos: 1. Crear el directorio 'backend/' y el archivo 'backend/__init__.py' con la factory create_app(). 2. Mover la lógica de las rutas a 'backend/routes.py' usando un Blueprint. 3. Actualizar 'app.py' para importar create_app desde el paquete backend. 4. Actualizar 'tests/test_backend.py' para importar desde el paquete backend."
}
```

#### 1.3 Generación Automática de Tareas de Corrección

**Descripción:** El sistema genera automáticamente una nueva tarea para corregir el fallo.

**Estructura de Tarea de Corrección:**
```json
{
  "objetivo": "Refactoriza el código para que se alinee con la arquitectura descrita en la documentación...",
  "etapas_a_ejecutar": ["backend-dev", "backend-qa"],
  "plan_de_origen": "T001-Kanban_plan_construccion.json",
  "github_repo": "https://github.com/user/kanban.git",
  "github_project": "kanban",
  "github_pat": "ghp_...",
  "llm_config": {...}
}
```

**Características:**
- Nombre de archivo: `T{timestamp}-FIX-{componente}.json`
- Solo ejecuta las etapas necesarias (dev + qa)
- Mantiene referencia al plan original
- Se procesa automáticamente en el siguiente ciclo

#### 1.4 Ciclo de Corrección Completo

**Descripción:** El sistema intenta corregir hasta que los tests pasen.

**Flujo:**
```
Tests Fallan (Intento 1)
         ↓
Jefe de Proyecto Analiza
         ↓
Nueva Tarea: T...-FIX-backend.json
         ↓
Agente Backend Corrige
         ↓
Tests Ejecutan (Intento 2)
         ↓
    ✅ Pasa → Éxito!
    ❌ Falla → Analizar de nuevo
         ↓
Nueva Tarea: T...-FIX-backend-2.json
         ↓
(Ciclo continúa...)
```

**Limitación Actual:** No hay límite de intentos (el usuario debe intervenir si hay ciclo infinito).

**Mejora Futura:** Limitar a N intentos y mover a `failed/` automáticamente.

### 2. Correcciones Basadas en Contexto

**Descripción:** Las correcciones no solo arreglan el test, sino que alinean el código con la arquitectura.

**Diferencia con Enfoques Simples:**

**Enfoque Simple (sin contexto):**
```
Error: ModuleNotFoundError: No module named 'backend'

Corrección: Renombrar backend.py a backend/__init__.py
```

**Enfoque de La Colmena (con contexto):**
```
Error: ModuleNotFoundError: No module named 'backend'

Contexto de la Documentación:
- Debe existir un paquete backend/
- backend/__init__.py debe tener create_app()
- backend/routes.py debe tener las rutas con Blueprint
- app.py debe importar create_app
- tests debe importar desde backend

Corrección:
1. Crear estructura de paquete completa
2. Refactorizar código para usar factory pattern
3. Actualizar todos los imports
4. Asegurar que tests usan create_app()
```

**Resultado:** Código que no solo pasa los tests, sino que sigue buenas prácticas arquitectónicas.

---

## Capacidades de Integración

### 1. Integración con GitHub

#### 1.1 Gestión de Repositorios

**Capacidades:**
- Crear repositorios vía API de GitHub
- Clonar repositorios con autenticación PAT
- Sincronización constante con `git pull`

#### 1.2 Control de Versiones

**Capacidades:**
- Commit automático tras cada etapa
- Mensajes de commit descriptivos
- Historial completo de cambios

**Ejemplos de Mensajes de Commit:**
```
Agente [ARQUITECTO]: Genera plan de construcción
Agente [BACKEND]: Completa la construcción de la etapa
Agente [Documentador]: Genera/actualiza documentación para backend
Agente [FRONTEND]: Completa la construcción de la etapa
Agente [E2E-Tester]: Genera ficheros de prueba
```

#### 1.3 Manejo de Conflictos

**Descripción:** El sistema maneja conflictos de concurrencia.

**Estrategia:**
- `git pull` después de cada `git push`
- Ignora errores de "fetch first"
- El orquestador siempre tiene la versión más reciente

### 2. Integración con Docker

#### 2.1 Ejecución Aislada de Agentes

**Capacidades:**
- Cada agente en su propio contenedor
- Sin estado compartido
- Destrucción automática tras finalizar

#### 2.2 Imagen Universal

**Descripción:** Una sola imagen Docker para todos los agentes.

**Contenido de la Imagen:**
```dockerfile
FROM python:3.11-slim

# Herramientas base
RUN apt-get update && apt-get install -y git curl

# Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Node.js y Cypress
RUN apt-get install -y nodejs npm
RUN npm install -g cypress

# Código del agente
COPY src/ .
CMD ["python", "-u", "agent_runner.py"]
```

**Ventajas:**
- Fácil de mantener (un solo Dockerfile)
- Rápida de construir (layers cacheadas)
- Contiene todo lo necesario (Python + Node)

---

## Workflows Soportados

### 1. Workflow Completo (CI/CD)

**Descripción:** Pipeline completo desde cero hasta aplicación desplegable.

**Etapas:**
```json
{
  "etapas_a_ejecutar": [
    "planificacion",      // ← Genera plan
    "backend-dev",        // ← Implementa backend
    "backend-doc",        // ← Documenta backend
    "backend-qa",         // ← Prueba backend
    "frontend-dev",       // ← Implementa frontend
    "frontend-doc",       // ← Documenta frontend
    "e2e-dev",            // ← Crea tests E2E
    "e2e-qa",             // ← Ejecuta tests E2E
    "documentacion"       // ← README del proyecto
  ]
}
```

**Tiempo Estimado:** 10-15 minutos (proyecto simple)

**Resultado:** Aplicación web completa con código, tests y documentación.

### 2. Workflow de Desarrollo Iterativo

**Descripción:** Añadir funcionalidad a un proyecto existente.

**Configuración:**
```json
{
  "objetivo": "Añadir funcionalidad de filtrado de tareas por estado",
  "etapas_a_ejecutar": [
    "backend-dev",
    "backend-qa",
    "frontend-dev",
    "e2e-dev",
    "e2e-qa"
  ],
  "plan_de_origen": "T001-Kanban_plan_construccion.json"
}
```

**No incluye:**
- Planificación (usa plan existente)
- Documentación (opcional)

### 3. Workflow Solo QA

**Descripción:** Ejecutar pruebas en código existente.

**Configuración:**
```json
{
  "etapas_a_ejecutar": [
    "backend-qa",
    "e2e-qa"
  ]
}
```

**Uso:** Verificar que el código sigue funcionando tras cambios manuales.

### 4. Workflow Solo Documentación

**Descripción:** Generar/actualizar documentación de un proyecto existente.

**Configuración:**
```json
{
  "etapas_a_ejecutar": [
    "backend-doc",
    "frontend-doc",
    "documentacion"
  ]
}
```

**Uso:** Documentar código legado o código modificado manualmente.

### 5. Workflow Rápido (Sin QA)

**Descripción:** Desarrollo rápido sin ejecutar pruebas.

**Comando:**
```bash
python orquestador.py --no-qa
```

**Configuración:**
```json
{
  "etapas_a_ejecutar": [
    "planificacion",
    "backend-dev",
    "frontend-dev"
  ]
}
```

**Uso:** Prototipado rápido o cuando los tests no son críticos.

---

## Tecnologías y Frameworks

### Backend

| Tecnología | Versión | Uso |
|------------|---------|-----|
| **Python** | 3.11+ | Lenguaje principal |
| **Flask** | Latest | Framework web |
| **Flask-CORS** | Latest | Manejo de CORS |
| **pytest** | Latest | Framework de testing |
| **python-dotenv** | Latest | Variables de entorno (opcional) |
| **requests** | Latest | Llamadas HTTP (opcional) |

### Frontend

| Tecnología | Versión | Uso |
|------------|---------|-----|
| **HTML5** | - | Estructura |
| **CSS3** | - | Estilos base |
| **JavaScript ES6** | - | Lógica de la aplicación |
| **Bootstrap** | 5.3.3 | Framework CSS |
| **Fetch API** | - | Comunicación con backend |

### Testing

| Tecnología | Versión | Uso |
|------------|---------|-----|
| **pytest** | Latest | Tests unitarios backend |
| **Cypress** | 13.0.0 | Tests E2E |
| **Node.js** | Latest | Runtime para Cypress |
| **npm** | Latest | Gestor de paquetes |

### Infraestructura

| Tecnología | Versión | Uso |
|------------|---------|-----|
| **Docker** | Latest | Contenedores de agentes |
| **Git** | Latest | Control de versiones |
| **GitHub** | - | Repositorios remotos |
| **PyGithub** | Latest | API de GitHub |

### LLMs

| Proveedor | Modelos | Uso |
|-----------|---------|-----|
| **OpenAI** | GPT-4, GPT-3.5-turbo | Generación de código |
| **Google** | Gemini Pro, Gemini 1.5 Pro | Generación de código |
| **LM Studio** | Llama, Mistral, etc. | Modelos locales |
| **Ollama** | Llama, Mistral, etc. | Modelos locales |

---

## Limitaciones Conocidas

### 1. Limitaciones de Desarrollo

#### 1.1 Backend Solo Python/Flask

**Limitación:** El sistema solo genera backends en Python con Flask.

**No Soportado:**
- Node.js/Express
- Django
- FastAPI
- Java/Spring
- Go

**Workaround:** Los prompts pueden modificarse para soportar otros frameworks.

#### 1.2 Frontend Sin Framework JS

**Limitación:** El frontend es HTML/CSS/JS vanilla, sin frameworks como React/Vue/Angular.

**Razón:** Simplicidad y velocidad de generación.

**Workaround:** Para aplicaciones complejas, un humano puede migrar el código a un framework.

### 2. Limitaciones de Testing

#### 2.1 Frontend QA No Implementado

**Limitación:** No hay tests unitarios automáticos para el frontend.

**Estado:** La etapa `frontend-qa` retorna `True` sin hacer nada.

**Workaround:** Los tests E2E cubren parcialmente esta necesidad.

#### 2.2 Tests E2E Limitados

**Limitación:** Los tests E2E generados son básicos (flujo feliz).

**No Incluyen:**
- Casos de error
- Tests de performance
- Tests de accesibilidad
- Tests de seguridad

**Workaround:** Un humano puede añadir más tests manualmente.

### 3. Limitaciones de Corrección

#### 3.1 Sin Límite de Intentos

**Limitación:** El sistema puede entrar en ciclos infinitos de corrección.

**Ejemplo:**
```
Test falla → Corrección 1 → Test falla → Corrección 2 → ... (infinito)
```

**Workaround:** El usuario debe detener manualmente el orquestador y mover la tarea a `failed/`.

**Mejora Futura:** Implementar límite de 5 intentos.

#### 3.2 Correcciones Solo para Backend

**Limitación:** El Jefe de Proyecto solo corrige fallos de backend (pytest).

**No Soportado:**
- Corrección automática de fallos E2E
- Corrección de fallos de frontend

**Razón:** Complejidad de análisis de errores de Cypress.

### 4. Limitaciones de Escalabilidad

#### 4.1 Procesamiento Secuencial

**Limitación:** Solo una tarea a la vez, etapas ejecutadas secuencialmente.

**Impacto:** Si hay 10 tareas en la cola, toman 10x el tiempo de una tarea.

**Mejora Futura:** Paralelización (ver Roadmap).

#### 4.2 Sin Cache de LLM

**Limitación:** Cada llamada al LLM es nueva, aunque el prompt sea similar.

**Impacto:** Mayor coste y tiempo de ejecución.

**Mejora Futura:** Sistema de cache con Redis.

### 5. Limitaciones de Seguridad

#### 5.1 Tokens en Archivos de Tareas

**Limitación:** Los tokens PAT de GitHub están en archivos JSON en texto plano.

**Riesgo:** Si los archivos se filtran, el token está comprometido.

**Workaround:** No versionar archivos de tareas en Git.

**Mejora Futura:** Variables de entorno o gestor de secretos.

#### 5.2 Código Sin Revisar

**Limitación:** El código generado por LLMs se ejecuta sin revisión humana.

**Riesgo:** Potencial generación de código inseguro o malicioso.

**Mitigación:** Ejecución en contenedores aislados.

**Mejora Futura:** Análisis estático de seguridad (Bandit, ESLint).

---

## Roadmap de Nuevas Capacidades

### Corto Plazo (3-6 meses)

#### 1. Paralelización de Etapas

**Objetivo:** Ejecutar etapas independientes en paralelo.

**Impacto:** 2-3x más rápido.

**Implementación:**
```python
with ThreadPoolExecutor() as executor:
    future_backend = executor.submit(ejecutar_etapa, "backend-dev")
    future_frontend = executor.submit(ejecutar_etapa, "frontend-dev")
```

#### 2. Límite de Intentos de Corrección

**Objetivo:** Evitar ciclos infinitos.

**Implementación:**
- Contador en el nombre de la tarea: `T...-FIX-backend-ATTEMPT-2.json`
- Límite de 5 intentos
- Mover automáticamente a `failed/` si se excede

#### 3. Cache de Respuestas LLM

**Objetivo:** Reducir coste y tiempo de ejecución.

**Implementación:**
- Hash del prompt como clave
- Redis como storage
- TTL de 24 horas

**Ahorro Esperado:** 60-70% de llamadas a LLM.

#### 4. Tests de Frontend

**Objetivo:** Validación del código JavaScript.

**Implementación:**
- ESLint para linting
- Tests unitarios con Jest (futuro)

### Medio Plazo (6-12 meses)

#### 5. Dashboard Web

**Objetivo:** Interfaz gráfica para gestionar La Colmena.

**Características:**
- Ver tareas en la cola (pending, processing, completed, failed)
- Ver logs en tiempo real
- Pausar/reanudar/cancelar tareas
- Editar configuración de tareas
- Ver repositorios generados

**Stack Tecnológico:**
- Backend: Flask/FastAPI
- Frontend: React
- WebSockets: Para logs en tiempo real

#### 6. Multi-Tenancy

**Objetivo:** Múltiples usuarios usando La Colmena simultáneamente.

**Características:**
- Autenticación de usuarios
- Aislamiento de datos por usuario
- Cuotas y límites por usuario

**Implementación:**
- Base de datos (PostgreSQL)
- Orquestador como servicio web
- Cola de tareas por usuario

#### 7. Soporte para Más Frameworks

**Objetivo:** Generar código para otros stacks tecnológicos.

**Nuevos Agentes:**
- **agente-nodejs:** Backend con Express
- **agente-react:** Frontend con React
- **agente-django:** Backend con Django

**Implementación:**
- Nuevos prompts especializados
- Nuevas guías de estilo
- Validación de salida específica

### Largo Plazo (12-24 meses)

#### 8. Agentes con Memoria

**Objetivo:** Agentes que aprenden de proyectos anteriores.

**Características:**
- Base de datos de "patrones exitosos"
- Embeddings de código con vector DB
- Retrieval-Augmented Generation (RAG)

**Ejemplo:**
```
Usuario pide: "Crear un Kanban Board"

Sistema busca en memoria:
- Proyectos similares (similitud semántica)
- Patrones exitosos (tareas, persistencia JSON, etc.)
- Errores comunes (ModuleNotFoundError, etc.)

Agente Arquitecto genera plan:
- Reutiliza estructura exitosa de proyecto anterior
- Evita errores comunes detectados en memoria
```

**Ventajas:**
- Menos iteraciones de corrección
- Código de mayor calidad
- Aprendizaje continuo

#### 9. Colaboración Humano-IA

**Objetivo:** Humanos pueden intervenir durante la construcción.

**Características:**
- **Modo de Revisión:** Pausa antes de commit para revisión humana
- **Chat en Tiempo Real:** Dar instrucciones adicionales al agente activo
- **Code Review Asistido:** IA sugiere mejoras, humano aprueba
- **Pair Programming:** Humano y agente trabajan en conjunto

**Implementación:**
- WebSockets para comunicación en tiempo real
- Sistema de aprobación de cambios
- Interfaz de chat en el dashboard

#### 10. CI/CD Completo

**Objetivo:** Despliegue automático de aplicaciones generadas.

**Características:**
- Integración con GitHub Actions
- Tests automáticos en cada commit
- Despliegue a servicios cloud (Heroku, Vercel, AWS)
- Monitoreo de aplicaciones en producción

**Workflow:**
```
La Colmena genera código
         ↓
Commit a GitHub
         ↓
GitHub Actions triggers
         ↓
Tests automáticos
         ↓
Build de la aplicación
         ↓
Despliegue a staging
         ↓
Tests E2E en staging
         ↓
Despliegue a producción
         ↓
Monitoreo activo
```

---

## Conclusión

La Colmena es un **sistema de fabricación de software autónomo** con capacidades avanzadas de desarrollo, testing, documentación y auto-corrección. Las capacidades actuales cubren el ciclo completo de construcción de aplicaciones web simples a medianas, y el roadmap futuro expande estas capacidades hacia sistemas más complejos, aprendizaje continuo y colaboración humano-IA.

### Resumen de Capacidades

| Área | Capacidades |
|------|-------------|
| **Desarrollo** | Backend (Flask), Frontend (Bootstrap), Planificación |
| **Testing** | Unitario (pytest), E2E (Cypress) |
| **Documentación** | Por componente, Proyecto completo |
| **Corrección** | Auto-corrección inteligente basada en contexto |
| **Integración** | GitHub, Docker, Múltiples LLMs |
| **Workflows** | Completo (CI/CD), Iterativo, Solo QA, Solo Docs |

El sistema está en constante evolución, con cada versión añadiendo nuevas capacidades y refinando las existentes. La visión a largo plazo es transformar La Colmena en una **plataforma de desarrollo asistido por IA de grado industrial**.
