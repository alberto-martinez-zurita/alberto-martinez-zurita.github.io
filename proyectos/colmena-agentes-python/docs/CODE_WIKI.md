# CODE WIKI - La Colmena v7+

## Tabla de Contenidos

1. [Visión General del Sistema](#visión-general-del-sistema)
2. [Arquitectura del Código](#arquitectura-del-código)
3. [Componente Principal: Orquestador](#componente-principal-orquestador)
4. [Sistema de Agentes](#sistema-de-agentes)
5. [Runners y Ejecutores](#runners-y-ejecutores)
6. [Sistema de Prompts](#sistema-de-prompts)
7. [Integración con LLMs](#integración-con-llms)
8. [Gestión de Git y GitHub](#gestión-de-git-y-github)
9. [Sistema de QA y Auto-Corrección](#sistema-de-qa-y-auto-corrección)
10. [Sistema de Workflows y Etapas](#sistema-de-workflows-y-etapas)
11. [Guías de Estilo](#guías-de-estilo)
12. [Flujo de Datos Completo](#flujo-de-datos-completo)

---

## Visión General del Sistema

La Colmena es un **sistema de fabricación de software completamente autónomo** que utiliza agentes de IA especializados para construir aplicaciones web completas desde cero. El sistema se basa en una arquitectura de **orquestación distribuida** donde un componente central (el Orquestador) coordina múltiples agentes especializados que se ejecutan en contenedores Docker aislados.

### Componentes Clave

```
┌─────────────────────────────────────────────────────────────┐
│                      ORQUESTADOR                            │
│  (orquestador.py - Cerebro del sistema)                     │
└────────────┬────────────────────────────────────────────────┘
             │
             ├──→ [Docker Container] Agente Arquitecto
             ├──→ [Docker Container] Agente Backend
             ├──→ [Docker Container] Agente Frontend
             ├──→ [Docker Container] Agente E2E
             ├──→ [Docker Container] Agente Jefe de Proyecto
             └──→ [Docker Container] Agente Documentador
```

---

## Arquitectura del Código

### Estructura de Directorios

```
colmena-v7/
│
├── orquestador.py           # Componente principal de coordinación
│
├── src/                     # Código fuente de los agentes
│   ├── agent_runner.py      # Ejecutor universal de agentes
│   ├── contextualizador.py  # Lectura de código de proyectos
│   └── documenter_runner.py # Runner especializado (legacy)
│
├── prompts/                 # Prompts del sistema para cada agente
│   ├── arquitecto.txt       # Prompt del agente arquitecto
│   ├── backend.txt          # Prompt del agente backend
│   ├── frontend.txt         # Prompt del agente frontend
│   ├── e2e_tester.txt       # Prompt del agente E2E
│   ├── jefe_de_proyecto.txt # Prompt del agente corrector
│   ├── documentador.txt     # Prompt del agente documentador
│   ├── qa.txt               # Prompt del agente QA
│   ├── analista.txt         # Prompt del agente analista
│   └── investigador.txt     # Prompt del agente investigador
│
├── resources/               # Guías de estilo y recursos
│   ├── generic_style_guide.md
│   ├── backend_style_guide.md
│   └── frontend_style_guide.md
│
├── tasks/                   # Cola de tareas a procesar
│   ├── processed/           # Tareas completadas
│   └── failed/              # Tareas fallidas
│
├── plans/                   # Planes de construcción generados
│
├── workspace/               # Repositorios clonados de proyectos
│
├── logs/                    # Logs de ejecución de agentes
│
├── Dockerfile               # Imagen Docker universal de agentes
│
└── requirements.txt         # Dependencias Python del orquestador
```

---

## Componente Principal: Orquestador

**Archivo:** `orquestador.py`
**Líneas:** ~792
**Versión:** V11 (Workflows por Etapas)

### Responsabilidades

El orquestador es el **cerebro central** del sistema. Sus responsabilidades principales son:

1. **Gestión de Cola de Tareas:** Lee archivos JSON de la carpeta `tasks/` y los procesa secuencialmente
2. **Coordinación de Agentes:** Lanza agentes en contenedores Docker y gestiona su ciclo de vida
3. **Gestión de Repositorios:** Clona, actualiza y sincroniza repositorios de GitHub
4. **Ejecución de Workflows:** Ejecuta secuencias de etapas configurables
5. **Control de Calidad:** Ejecuta pruebas unitarias y E2E
6. **Auto-Corrección:** Detecta fallos y genera tareas de corrección automáticas

### Configuración Principal

```python
# orquestador.py:16-34
AGENT_IMAGE = "agente-constructor"
WORKSPACE_DIR_NAME = "workspace"
TASKS_DIR = "tasks"
PROCESSED_TASKS_DIR = os.path.join(TASKS_DIR, "processed")
FAILED_TASKS_DIR = os.path.join(TASKS_DIR, "failed")
PLANS_DIR = "plans"

AGENT_INFO = {
    "investigador": {"prompt": "prompts/investigador.txt", "output_file": "api_data.json"},
    "arquitecto":   {"prompt": "prompts/arquitecto.txt", "output_file": "plan_construccion.json"},
    "analista":     {"prompt": "prompts/analista.txt"},
    "backend":      {"prompt": "prompts/backend.txt", "output_file": "backend.py"},
    "frontend":     {"prompt": "prompts/frontend.txt", "output_file": "static/index.html"},
    "qa":           {"prompt": "prompts/qa.txt"},
    "e2e":          {"prompt": "prompts/e2e_tester.txt"},
    "jefe_de_proyecto": {"prompt": "prompts/jefe_de_proyecto.txt"},
    "documentador": {"prompt": "prompts/documentador.txt"}
}
```

Esta configuración define:
- La **imagen Docker** que se usará para todos los agentes
- Las **rutas de los directorios** de trabajo
- El **mapeo de agentes** a sus prompts correspondientes

### Funciones Clave

#### 1. `main(args)` - Bucle Principal

**Ubicación:** `orquestador.py:665-792`

```python
def main(args):
    log_message("🧠 Orquestador V12 (Workflows por Etapas): Iniciando colmena...", "SYSTEM")
    client = docker.from_env()

    while True:
        task_files = sorted([f for f in os.listdir(TASKS_DIR) if f.endswith('.json')])

        if not task_files:
            log_message("No hay más tareas en la cola. La Colmena finaliza su trabajo.", "SYSTEM")
            break

        current_task_file = task_files[0]
        # ... procesar tarea ...
```

**Funcionamiento:**
1. Inicializa el cliente Docker
2. Entra en un **bucle infinito** que procesa tareas
3. Para cada tarea:
   - Lee el archivo JSON de configuración
   - Prepara el repositorio de GitHub
   - Ejecuta las etapas definidas en `etapas_a_ejecutar`
   - Archiva la tarea en `processed/` o `failed/`

#### 2. `preparar_repositorio(config, repo_local_path)` - Gestión Git

**Ubicación:** `orquestador.py:97-130`

```python
def preparar_repositorio(config: dict, repo_local_path: str):
    github_pat = config.get("github_pat")
    repo_name = config.get("github_project")
    repo_url_auth = config["github_repo"].replace("https://", f"https://{github_pat}@")

    g = Github(github_pat)
    user = g.get_user()

    try:
        user.create_repo(repo_name, private=True)
        log_message(f"Repositorio '{repo_name}' creado con éxito.", "SUCCESS")
    except GithubException as e:
        if e.status == 422:
            log_message(f"El repositorio '{repo_name}' ya existe.", "INFO")
```

**Funcionamiento:**
1. Conecta a la API de GitHub usando PyGithub
2. Intenta crear el repositorio (si no existe)
3. Clona el repositorio o hace `git pull` si ya existe localmente
4. Maneja errores de duplicados con elegancia

#### 3. `run_agent_mission(client, role, context)` - Lanzador de Agentes

**Ubicación:** `orquestador.py:323-403`

```python
def run_agent_mission(client, role: str, context: dict):
    log_message(f"🚀 Despachando Agente: {role.upper()}...")

    prompt_path = AGENT_INFO[role]["prompt"]
    with open(prompt_path, 'r', encoding='utf-8') as f:
        system_prompt = f.read()

    mission_prompt = f"{system_prompt}\n\nCONTEXTO:\n{json.dumps(context, indent=2)}"

    json_format_instruction = f"""
Tu respuesta DEBE ser un único objeto JSON válido que describa una lista de operaciones de fichero.
La estructura del JSON debe ser la siguiente:
{{
  "files": [
    {{
      "filename": "ruta/al/fichero_a_crear.py",
      "action": "create_or_update",
      "code": "..."
    }}
  ]
}}
"""
    mission_prompt += json_format_instruction
```

**Funcionamiento:**
1. Lee el **prompt del sistema** del archivo correspondiente
2. Construye el **prompt final** combinando:
   - El prompt del sistema (rol del agente)
   - El contexto del proyecto (JSON)
   - Instrucciones de formato de salida
3. Lanza un contenedor Docker con variables de entorno:
   - `LLM_CONFIG`: Configuración del modelo
   - `TASK_PROMPT`: Prompt completo
   - `GIT_REPO_URL`: URL del repositorio
   - `GITHUB_PAT`: Token de autenticación
4. Espera a que el contenedor termine y captura los logs
5. Retorna `True` si fue exitoso, `False` si falló

#### 4. `ejecutar_etapa_construccion(...)` - Etapa de Desarrollo

**Ubicación:** `orquestador.py:556-595`

```python
def ejecutar_etapa_construccion(client, etapa_info, repo_local_path, contexto_global):
    etapa = etapa_info.get("etapa")
    tareas = etapa_info.get("tareas", [])
    requisito_completo = f"Construir la etapa de '{etapa}' cumpliendo con TODOS los siguientes requisitos:\n- " + "\n- ".join(tareas)

    log_message(f"--- 👷 Fase de Construcción para: [{etapa.upper()}] ---", "STAGE")
    rol_obrero = etapa
    contexto_obrero = {**contexto_global, "tarea_especifica": requisito_completo}
    inyectar_guias_de_estilo(rol_obrero, contexto_obrero)

    if etapa == "frontend":
        doc_backend_path = os.path.join(repo_local_path, "docs", "backend_documentation.md")
        if os.path.exists(doc_backend_path):
            with open(doc_backend_path, 'r', encoding='utf-8') as f:
                contexto_obrero["DOCUMENTACION_BACKEND"] = f.read()
```

**Funcionamiento:**
1. Extrae las **tareas** de la etapa del plan de construcción
2. Crea un **requisito completo** concatenando todas las tareas
3. **Inyecta guías de estilo** relevantes al contexto
4. **Caso especial Frontend:** Si existe documentación del backend, la incluye en el contexto
5. Lanza el agente constructor correspondiente
6. Sincroniza con Git: `add`, `commit`, `push`, `pull`

#### 5. `ejecutar_etapa_qa(...)` - Etapa de Pruebas

**Ubicación:** `orquestador.py:597-662`

```python
def ejecutar_etapa_qa(client, etapa_info, repo_local_path, contexto_global, no_qa, plan_path):
    if no_qa:
        log_message("Modo rápido activado (--no-qa). Saltando todas las fases de QA.", "INFO")
        return True

    etapa = etapa_info.get("etapa")
    log_message(f"--- 🧐 Fase de QA para la Etapa [{etapa.upper()}] ---", "STAGE")

    if etapa == "backend":
        requirements_path = os.path.join(repo_local_path, "requirements.txt")
        if os.path.exists(requirements_path):
            subprocess.run([sys.executable, "-m", "pip", "install", "-r", requirements_path], check=True)

        try:
            resultado_tests = subprocess.run(["pytest"], cwd=repo_local_path, check=True)
            return True
        except subprocess.CalledProcessError as e:
            # Si fallan los tests, llama al Jefe de Proyecto
            doc_path = os.path.join(repo_local_path, "docs", f"{etapa}_documentation.md")
            if os.path.exists(doc_path):
                with open(doc_path, 'r', encoding='utf-8') as f:
                    doc_content = f.read()

            run_jefe_de_proyecto_agent(contexto_global, requisito_completo, codigo_actual, razon_fallo, plan_path, doc_content)
```

**Funcionamiento:**
1. **Backend QA:**
   - Instala dependencias de `requirements.txt`
   - Ejecuta `pytest` en el repositorio
   - Si pasa: retorna `True`
   - Si falla: busca documentación del componente y llama al Jefe de Proyecto
2. **Frontend QA:** Aún no implementado (retorna `True`)
3. El Jefe de Proyecto analiza el fallo y genera una **nueva tarea de corrección**

#### 6. `ejecutar_etapa_e2e_qa(...)` - Pruebas End-to-End

**Ubicación:** `orquestador.py:238-295`

```python
def ejecutar_etapa_e2e_qa(repo_local_path, contexto_global):
    server_process = None
    try:
        # Crear package.json para Cypress
        package_json_content = {
            "name": os.path.basename(repo_local_path),
            "version": "1.0.0",
            "scripts": { "cypress:run": "cypress run" },
            "devDependencies": { "cypress": "^13.0.0" }
        }
        with open(os.path.join(repo_local_path, "package.json"), "w") as f:
            json.dump(package_json_content, f, indent=2)

        # Crear cypress.config.js
        cypress_config_content = """
const { defineConfig } = require('cypress');
module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:5000',
    supportFile: false,
    setupNodeEvents(on, config) {},
  },
});
"""
        with open(os.path.join(repo_local_path, "cypress.config.js"), "w") as f:
            f.write(cypress_config_content)

        # Instalar dependencias de Node.js
        subprocess.run(["npm", "install"], cwd=repo_local_path, check=True)

        # Levantar el servidor Flask en segundo plano
        server_process = subprocess.Popen([sys.executable, "app.py"], cwd=repo_local_path)
        time.sleep(5)

        # Ejecutar las pruebas de Cypress
        subprocess.run(["npx", "cypress", "run"], cwd=repo_local_path, check=True)

        return True
    finally:
        if server_process:
            server_process.terminate()
```

**Funcionamiento:**
1. **Configuración de Cypress:**
   - Crea `package.json` con Cypress como dependencia
   - Crea `cypress.config.js` con configuración base
2. **Instalación:** Ejecuta `npm install`
3. **Servidor:** Levanta Flask en segundo plano con `subprocess.Popen`
4. **Pruebas:** Ejecuta `npx cypress run`
5. **Cleanup:** Asegura que el servidor se detenga con `finally`

#### 7. `run_jefe_de_proyecto_agent(...)` - Sistema de Auto-Corrección

**Ubicación:** `orquestador.py:405-450`

```python
def run_jefe_de_proyecto_agent(contexto_global: dict, requisito: str, codigo_fallido: str, razon_fallo: str, plan_path: str, doc_content: str = ""):
    log_message("Despachando Agente [JEFE DE PROYECTO] para crear tarea de corrección...", "AGENT")

    prompt_path = AGENT_INFO['jefe_de_proyecto']['prompt']
    with open(prompt_path, 'r', encoding='utf-8') as f:
        prompt_template = f.read()

    prompt_final = prompt_template.replace("{REQUISITO}", requisito)
    prompt_final = prompt_final.replace("{CODIGO_FALLIDO}", codigo_fallido)
    prompt_final = prompt_final.replace("{RAZON_FALLO}", razon_fallo)
    prompt_final = prompt_final.replace("{DOCUMENTACION_EXISTENTE}", doc_content)

    respuesta_str = get_llm_response_directo(prompt_final, contexto_global.get("llm_config"))

    # Extraer JSON de la respuesta
    json_extraido = re.search(r'\{.*\}', respuesta_str, re.DOTALL).group(0)
    respuesta_json = json.loads(json_extraido)

    nuevo_objetivo = respuesta_json.get("nuevo_objetivo")

    # Crear nueva tarea de corrección
    nueva_tarea_config = contexto_global.copy()
    etapa_fallida = contexto_global.get('etapa_actual')
    nueva_tarea_config["objetivo"] = nuevo_objetivo
    nueva_tarea_config["etapas_a_ejecutar"] = [f"{etapa_fallida}-dev", f"{etapa_fallida}-qa"]
    nueva_tarea_config["plan_de_origen"] = os.path.basename(plan_path)

    timestamp = time.strftime('%Y%m%d-%H%M%S')
    nuevo_fichero_tarea = os.path.join(TASKS_DIR, f"T{timestamp}-FIX-{etapa_fallida}.json")

    with open(nuevo_fichero_tarea, 'w', encoding='utf-8') as f:
        json.dump(nueva_tarea_config, f, indent=2, ensure_ascii=False)
```

**Funcionamiento del Ciclo de Auto-Corrección:**

1. **Detección de Fallo:** `ejecutar_etapa_qa` detecta que pytest falló
2. **Recolección de Contexto:**
   - Código actual del proyecto
   - Salida de pytest (stdout y stderr)
   - Documentación técnica del componente
   - Plan de construcción original
3. **Análisis:** El Jefe de Proyecto recibe todo el contexto y analiza el fallo
4. **Generación de Tarea:** Crea un nuevo archivo JSON en `tasks/` con:
   - Objetivo específico de corrección
   - Etapas a ejecutar: `{componente}-dev` + `{componente}-qa`
   - Referencia al plan original
5. **Re-procesamiento:** El orquestador procesará automáticamente la nueva tarea en el siguiente ciclo

#### 8. `inyectar_guias_de_estilo(rol_agente, contexto)` - Sistema de Conocimiento

**Ubicación:** `orquestador.py:132-162`

```python
def inyectar_guias_de_estilo(rol_agente: str, contexto: dict):
    guias = {}

    # La guía genérica se carga para casi todos los agentes clave
    if rol_agente in ["arquitecto", "jefe_de_proyecto", "backend", "frontend"]:
        try:
            with open("resources/generic_style_guide.md", 'r', encoding='utf-8') as f:
                guias["GUIA_ESTILO_GENERICA"] = f.read()
        except FileNotFoundError:
            log_message("Advertencia: No se encontró 'resources/generic_style_guide.md'.", "WARNING")

    # Las guías específicas se cargan solo para el rol correspondiente
    if rol_agente == "backend":
        try:
            with open("resources/backend_style_guide.md", 'r', encoding='utf-8') as f:
                guias["GUIA_ESTILO_BACKEND"] = f.read()
        except FileNotFoundError:
            pass

    if rol_agente == "frontend":
        try:
            with open("resources/frontend_style_guide.md", 'r', encoding='utf-8') as f:
                guias["GUIA_ESTILO_FRONTEND"] = f.read()
        except FileNotFoundError:
            pass

    if guias:
        contexto.update(guias)
```

**Arquitectura de Conocimiento "Need-to-Know":**
- Cada agente recibe **solo la información que necesita**
- Guía genérica: principios comunes (KISS, DRY, nomenclatura)
- Guías específicas: reglas de tecnología (Flask, Bootstrap, etc.)
- Minimiza el contexto y maximiza la eficiencia

---

## Sistema de Agentes

Los agentes son **programas especializados** que se ejecutan en contenedores Docker aislados. Cada agente tiene:
- Un **rol específico** (arquitecto, backend, frontend, etc.)
- Un **prompt del sistema** que define su comportamiento
- Un **formato de salida** estandarizado (JSON con lista de archivos)

### Agente Arquitecto

**Prompt:** `prompts/arquitecto.txt`
**Responsabilidad:** Crear planes de construcción técnicos

**Entrada:**
```json
{
  "objetivo": "Crear una calculadora web",
  "descripcion_detallada": "...",
  "requisitos_funcionales": {
    "backend": [...],
    "frontend": [...]
  },
  "tecnologias": ["Python", "Flask", "HTML5"]
}
```

**Salida:**
```json
{
  "files": [
    {
      "filename": "plan_construccion.json",
      "action": "create_or_update",
      "code": {
        "api_contract": {
          "ruta": "/api/calculate",
          "metodo": "POST",
          "parametros_entrada": {"numero1": "float", "numero2": "float"},
          "respuesta_esperada": {"resultado": "float"}
        },
        "contrato_qa_e2e": {
          "pantalla_display": "display",
          "boton_numero_1": "btn-1"
        },
        "plan": [
          {
            "etapa": "backend",
            "tareas": [...]
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
    }
  ]
}
```

**Características del Plan:**
- **API Contract:** Define exactamente cómo son las APIs (rutas, métodos, esquemas)
- **Contrato QA E2E:** Define los `data-testid` que usarán frontend y E2E para sincronizarse
- **Plan de Etapas:** Lista de tareas atómicas y específicas por componente
- **Sin código de ejemplo:** Solo descripciones de qué hacer, no cómo hacerlo

### Agente Backend

**Prompt:** `prompts/backend.txt`
**Responsabilidad:** Implementar la lógica del servidor y la API

**Entrada:**
- Plan de construcción (tareas de la etapa backend)
- Guía de estilo genérica
- Guía de estilo de backend
- Contexto del proyecto

**Salida:**
```json
{
  "files": [
    {
      "filename": "backend/__init__.py",
      "action": "create_or_update",
      "code": ["from flask import Flask", "...", "app = Flask(__name__)"]
    },
    {
      "filename": "backend/routes.py",
      "action": "create_or_update",
      "code": ["from flask import Blueprint", "..."]
    },
    {
      "filename": "app.py",
      "action": "create_or_update",
      "code": ["from backend import create_app", "..."]
    },
    {
      "filename": "tests/test_backend.py",
      "action": "create_or_update",
      "code": ["import pytest", "..."]
    },
    {
      "filename": "requirements.txt",
      "action": "create_or_update",
      "code": ["Flask", "pytest", "Flask-Cors"]
    }
  ]
}
```

**Reglas de Implementación:**
- **Estructura de paquete:** Usa `backend/__init__.py` con factory pattern
- **Doble función:** El servidor sirve el frontend Y expone la API
- **Tests obligatorios:** Siempre genera `tests/test_*.py` con pytest
- **Adherencia al contrato:** Las rutas y esquemas JSON deben coincidir exactamente con el `api_contract`

### Agente Frontend

**Prompt:** `prompts/frontend.txt`
**Responsabilidad:** Construir la interfaz de usuario

**Entrada:**
- Plan de construcción (tareas de la etapa frontend)
- Guía de estilo genérica
- Guía de estilo de frontend (Bootstrap 5)
- **Documentación del backend** (si existe)
- Contrato QA E2E

**Salida:**
```json
{
  "files": [
    {
      "filename": "frontend/index.html",
      "action": "create_or_update",
      "code": [
        "<!DOCTYPE html>",
        "<html lang=\"es\">",
        "...",
        "<button data-testid=\"btn-1\" class=\"btn btn-primary\">1</button>",
        "..."
      ]
    }
  ]
}
```

**Reglas de Implementación:**
- **Bootstrap 5:** Usa clases de Bootstrap para un diseño profesional
- **Data-testid:** Añade atributos según el `contrato_qa_e2e`
- **Fetch API:** Las llamadas al backend deben coincidir con la documentación
- **Single Page:** Todo en un único `index.html` (HTML + CSS + JS)

### Agente E2E

**Prompt:** `prompts/e2e_tester.txt`
**Responsabilidad:** Escribir pruebas Cypress

**Entrada:**
- Tareas de la etapa E2E
- Contrato QA E2E

**Salida:**
```javascript
describe('Prueba E2E de la Calculadora', () => {
  it('debe calcular 12+7 y mostrar 19', () => {
    cy.visit('/');
    cy.get('[data-testid="btn-1"]').click();
    cy.get('[data-testid="btn-2"]').click();
    cy.get('[data-testid="btn-plus"]').click();
    cy.get('[data-testid="btn-7"]').click();
    cy.get('[data-testid="btn-equals"]').click();
    cy.get('[data-testid="display"]').should('contain.text', '19');
  });
});
```

**Características:**
- Usa **selectores de data-testid** para robustez
- Estructura estándar: `describe` → `it` → comandos
- Verifica el **flujo completo del usuario**

### Agente Jefe de Proyecto

**Prompt:** `prompts/jefe_de_proyecto.txt`
**Responsabilidad:** Analizar fallos y crear objetivos de corrección

**Entrada:**
- Requisito que falló
- Código actual del proyecto
- Salida de pytest (razón del fallo)
- Documentación del componente
- Guía de estilo genérica

**Salida:**
```json
{
  "analisis_del_fallo": "El error de Pytest es un ModuleNotFoundError. La documentación confirma que la arquitectura requiere un paquete 'backend' con una factory create_app. El código actual no sigue esta estructura.",
  "nuevo_objetivo": "Refactoriza el código para que se alinee con la arquitectura descrita en la documentación. Genera un JSON con operaciones de fichero que: 1. Crear backend/__init__.py con factory create_app. 2. Mover rutas a backend/routes.py. 3. Actualizar tests para importar desde backend."
}
```

**Lógica de Corrección:**
1. Compara el **código actual** con la **documentación** (fuente de verdad)
2. Identifica la **raíz del problema** (no solo el síntoma)
3. Genera un objetivo **específico y accionable** con pasos exactos
4. El orquestador convierte esto en una **nueva tarea automática**

### Agente Documentador

**Prompt:** `prompts/documentador.txt`
**Responsabilidad:** Generar documentación técnica profesional

**Entrada:**
- Contexto completo del código del proyecto (función `leer_codigo_proyecto`)

**Salida:**
```markdown
# Documentación Técnica del Proyecto

## Visión General del Proyecto
...

## Arquitectura del Sistema
...

## Endpoints de la API
...
```

**Características:**
- Estilo **narrativo** para visión general
- Estilo **técnico** con tablas y diagramas Mermaid para arquitectura
- Secciones: Visión, Arquitectura, APIs, Instalación, Flujo de Datos, Extensiones

---

## Runners y Ejecutores

### agent_runner.py - El Ejecutor Universal

**Archivo:** `src/agent_runner.py`
**Líneas:** ~130
**Responsabilidad:** Código que se ejecuta **dentro** de cada contenedor Docker

#### Flujo de Ejecución

```python
def main():
    # 1. Leer variables de entorno
    llm_config = json.loads(os.environ.get("LLM_CONFIG", "{}"))
    task_prompt = os.environ.get("TASK_PROMPT")
    git_repo_url = os.environ.get("GIT_REPO_URL")
    github_pat = os.environ.get("GITHUB_PAT")

    # 2. Clonar repositorio
    auth_url = git_repo_url.replace("https://", f"https://{github_pat}@")
    run_command(["git", "clone", auth_url, repo_dir], cwd="/app")
    run_command(["git", "config", "user.email", "agente@colmena.ai"], cwd=repo_dir)
    run_command(["git", "config", "user.name", "Agente Autónomo"], cwd=repo_dir)

    # 3. Llamar al LLM
    llm_response_text = get_llm_response(task_prompt, llm_config)

    # 4. Parsear respuesta (JSON o diccionario Python)
    json_extraido_str = re.search(r'\{.*\}', llm_response_text, re.DOTALL).group(0)
    try:
        respuesta_json = json.loads(json_extraido_str)
    except json.JSONDecodeError:
        respuesta_json = ast.literal_eval(json_extraido_str)

    # 5. Crear/actualizar archivos
    files_to_create = respuesta_json.get("files")
    for file_info in files_to_create:
        filename = file_info.get('filename')
        code_content = file_info.get('code', '')

        # Ensamblar contenido (puede ser lista, dict o string)
        if isinstance(code_content, list):
            content_to_write = "\n".join(code_content)
        elif isinstance(code_content, dict):
            content_to_write = json.dumps(code_content, indent=2)
        else:
            content_to_write = str(code_content)

        file_path = os.path.join(repo_dir, filename)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content_to_write)

    # 6. Commit y push
    run_command(["git", "add", "."], cwd=repo_dir)
    run_command(["git", "commit", "-m", f"Agente completa tarea"], cwd=repo_dir)
    run_command(["git", "push"], cwd=repo_dir)
```

#### Parser "Traductor Universal"

**Ubicación:** `agent_runner.py:73-92`

El parser maneja dos formatos de JSON que los LLMs pueden generar:

1. **JSON estricto:** `{"key": "value"}` (estándar RFC 8259)
2. **Diccionario Python:** `{'key': 'value'}` (comillas simples, etc.)

```python
try:
    # Intento 1: Parseo estricto de JSON
    respuesta_json = json.loads(json_extraido_str)
except json.JSONDecodeError as e:
    print(f"Fallo el parseo JSON estricto: {e}. Intentando parseo flexible...")
    try:
        # Intento 2: Parseo flexible con ast.literal_eval
        respuesta_json = ast.literal_eval(json_extraido_str)
    except Exception as ast_error:
        raise ValueError("La respuesta del LLM no es ni JSON válido ni un diccionario de Python.")
```

Esto hace el sistema **robusto** ante variaciones en la salida del LLM.

#### Integración con LLMs

**Ubicación:** `agent_runner.py:10-36`

```python
def get_llm_response(prompt: str, config: dict) -> str:
    api_base = config.get("api_base")

    if api_base:  # OpenAI-compatible (LM Studio, Ollama, etc.)
        from openai import OpenAI
        client = OpenAI(base_url=api_base, api_key=config.get("api_key"))

        response = client.chat.completions.create(
            model=config.get("model_name"),
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
        )
        return response.choices[0].message.content

    else:  # Google Gemini
        import google.generativeai as genai
        genai.configure(api_key=config.get("api_key"))
        model = genai.GenerativeModel(config.get("model_name"))

        response = model.generate_content(prompt)
        return response.text
```

**Soporte de Proveedores:**
- **LM Studio:** Modelos locales con API compatible OpenAI
- **Ollama:** Modelos locales
- **OpenAI:** GPT-4, GPT-3.5, etc.
- **Google Gemini:** Gemini Pro, etc.
- **Cualquier API compatible con OpenAI**

### contextualizador.py - Lector de Proyectos

**Archivo:** `src/contextualizador.py`
**Líneas:** ~44
**Responsabilidad:** Leer todo el código de un proyecto y consolidarlo en un único string

```python
def crear_contexto_del_proyecto(directorio_proyecto, fichero_salida):
    contenido_completo = ""
    directorios_a_ignorar = {'.git', '__pycache__', 'docs', '.venv', 'node_modules'}
    extensiones_relevantes = ('.py', '.js', '.html', '.css', '.json', '.md', 'requirements.txt', 'Dockerfile')

    for root, dirs, files in os.walk(directorio_proyecto):
        dirs[:] = [d for d in dirs if d not in directorios_a_ignorar]

        for file in files:
            if file.endswith(extensiones_relevantes):
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, directorio_proyecto)

                contenido_completo += f"\n{'='*20}\n"
                contenido_completo += f"--- INICIO DEL FICHERO: {rel_path} ---\n"
                contenido_completo += f"{'='*20}\n\n"

                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    contenido_completo += f.read()
```

**Uso:**
- Usado por el agente **Documentador** para obtener todo el contexto
- Usado por el **Jefe de Proyecto** para analizar el código al detectar fallos
- Usado en el orquestador con la función `leer_codigo_proyecto()`

---

## Sistema de Prompts

Los prompts son el **corazón del comportamiento** de los agentes. Cada prompt define:
- El **rol** del agente
- Sus **responsabilidades**
- Las **reglas** que debe seguir
- El **formato de salida** esperado

### Anatomía de un Prompt

Tomemos como ejemplo el prompt del Agente Backend (`prompts/backend.txt`):

```
Eres un experto 'Arquitecto de Backend' con una década de experiencia...
Tu misión principal es implementar fielmente las tareas de backend definidas en el 'plan' del arquitecto.

**REGLAS FUNDAMENTALES:**
1. Obediencia Ciega al Plan: Implementa FIELMENTE y ÚNICAMENTE los ficheros solicitados en las tareas.
2. Estructura de Paquete: El código debe funcionar dentro de la estructura de paquete indicada.
3. Calidad del Código: Debe ser limpio, eficiente y seguir buenas prácticas.
4. Formato de Salida: Tu respuesta DEBE ser un único objeto JSON con una clave "files"...

### ESTRATEGIAS DE TESTING QUE DEBES CONOCER ###

#### 1. TEST DE API CON FLASK TEST CLIENT:
...ejemplo de código...

#### 2. TEST DE LÓGICA DE ARCHIVOS CON MONKEYPATCH:
...ejemplo de código...

TAREA FINAL Y REGLAS:
1. Obedece al Arquitecto: Implementa todas las tareas de la etapa backend.
2. Doble Función: Asegúrate de que backend.py sirva el index.html y los endpoints de la API.
3. Tests de Alta Calidad: Aplica las ESTRATEGIAS DE TESTING.
...
```

**Estructura:**
1. **Rol y Experiencia:** Establece la identidad del agente
2. **Misión Principal:** Define claramente qué debe hacer
3. **Reglas Fundamentales:** Restricciones no negociables
4. **Sección de Conocimiento:** Ejemplos de código y patrones
5. **Instrucciones Finales:** Checklist de lo que debe hacer

### Prompt Engineering - Técnicas Aplicadas

#### 1. Role-Playing
```
Eres un experto 'Arquitecto de Backend' con una década de experiencia...
```
Le da al LLM un "personaje" que imitar, mejorando la calidad de las respuestas.

#### 2. Few-Shot Learning
```
### ESTRATEGIAS DE TESTING QUE DEBES CONOCER ###

#### 1. TEST DE API CON FLASK TEST CLIENT:
# EJEMPLO para test_backend.py:
import pytest
from backend import app as flask_app
...
```
Proporciona ejemplos concretos de lo que se espera.

#### 3. Chain-of-Thought
```
**TAREA FINAL Y REGLAS:**
Ahora, analiza el CONTEXTO y genera el JSON con la lista de archivos. Sigue estas reglas en orden:
1. Obedece al Arquitecto: ...
2. Doble Función: ...
3. Tests de Alta Calidad: ...
```
Guía al LLM para que "piense" paso a paso.

#### 4. Constraint Specification
```
Tu respuesta DEBE ser un único objeto JSON con una clave "files".
La clave "code" debe ser una lista de strings, donde cada string es una línea del código.
```
Define exactamente el formato esperado, reduciendo errores de parseo.

#### 5. Context Injection
```
CONTEXTO:
{json.dumps(context, indent=2)}
```
El orquestador inyecta el contexto del proyecto en el prompt en tiempo de ejecución.

---

## Integración con LLMs

El sistema está diseñado para ser **agnóstico del proveedor de LLM**. Soporta:

### Configuración en Tareas

**Archivo de tarea:** `tasks/T004-Calculator-v1.json`

```json
{
  "objetivo": "Crear una calculadora web",
  "llm_config": {
    "model_name": "openai/gpt-oss-20b",
    "api_key": "lm-studio",
    "api_base": "http://host.docker.internal:1234/v1"
  }
}
```

**Campos:**
- `model_name`: Identificador del modelo
- `api_key`: Clave API (o placeholder para modelos locales)
- `api_base`: URL base de la API (opcional, si existe usa OpenAI-compatible)

### Dos Contextos de Ejecución

#### 1. Dentro del Contenedor (agent_runner.py)
```python
api_base = config.get("api_base")  # "http://host.docker.internal:1234/v1"
```
Usa `host.docker.internal` para conectar desde el contenedor a LM Studio en el host.

#### 2. En el Orquestador (orquestador.py)
```python
api_base = config.get("api_base", "").replace("host.docker.internal", "localhost")
```
Reemplaza `host.docker.internal` por `localhost` porque está en el host.

### Ejemplos de Configuración

#### LM Studio (local)
```json
{
  "model_name": "openai/gpt-oss-20b",
  "api_key": "lm-studio",
  "api_base": "http://host.docker.internal:1234/v1"
}
```

#### OpenAI (remoto)
```json
{
  "model_name": "gpt-4",
  "api_key": "sk-...",
  "api_base": "https://api.openai.com/v1"
}
```

#### Google Gemini (remoto)
```json
{
  "model_name": "gemini-pro",
  "api_key": "AIza..."
}
```
*Nota: Sin `api_base`, se usa el cliente de Google.*

---

## Gestión de Git y GitHub

### Flujo de Git

Cada agente y el orquestador siguen un flujo Git estricto:

```
1. CLONAR/ACTUALIZAR
   ↓
2. MODIFICAR CÓDIGO
   ↓
3. git add .
   ↓
4. git commit -m "Mensaje"
   ↓
5. git push
   ↓
6. git pull (sincronización)
```

### Funciones Git en el Orquestador

**Ubicación:** `orquestador.py:43-48`

```python
def run_git_command(command, cwd):
    try:
        subprocess.run(command, check=True, cwd=cwd, capture_output=True, text=True, encoding='utf-8')
    except subprocess.CalledProcessError as e:
        if "nothing to commit" in e.stdout or "no changes added to commit" in e.stdout:
            log_message("No hay nuevos cambios que guardar.", "GIT")
        else:
            log_message(f"Error ejecutando Git: {e.stderr}", "ERROR")
            raise
```

Maneja errores comunes de forma elegante (ej: "nothing to commit").

### Autenticación con PAT

**Personal Access Token (PAT):**
```python
github_pat = config.get("github_pat")
repo_url_auth = config["github_repo"].replace("https://", f"https://{github_pat}@")
```

Inyecta el PAT en la URL para autenticación HTTPS:
```
https://ghp_TOKEN@github.com/user/repo.git
```

### Configuración del Usuario Git

**En el contenedor:**
```python
run_command(["git", "config", "user.email", "agente@colmena.ai"], cwd=repo_dir)
run_command(["git", "config", "user.name", "Agente Autónomo"], cwd=repo_dir)
```

Esto asegura que los commits tengan un autor identificable.

### Sincronización Post-Agente

**Regla de oro:**
> Después de cada acción de un agente que modifica el repositorio, el orquestador realiza un `git pull` para mantener su workspace local siempre actualizado.

```python
# orquestador.py:583-592
run_git_command(["git", "add", "."], repo_local_path)
run_git_command(["git", "commit", "-m", f"Agente [{etapa.upper()}]: Completa la construcción"], repo_local_path)
run_git_command(["git", "push"], repo_local_path)

# --- SINCRONIZACIÓN ---
run_git_command(["git", "pull"], repo_local_path)
```

Esto previene conflictos cuando múltiples agentes trabajan en el mismo repo.

---

## Sistema de QA y Auto-Corrección

### Ciclo de Vida de una Tarea con Fallos

```
┌─────────────────────────────────────┐
│  1. DESARROLLO                      │
│     Agente Backend genera código    │
│     Git: commit + push              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  2. QA                              │
│     Ejecutar pytest                 │
│     ├─ PASS → Continuar             │
│     └─ FAIL → Analizar              │
└──────────────┬──────────────────────┘
               │ (FAIL)
               ▼
┌─────────────────────────────────────┐
│  3. RECOLECCIÓN DE CONTEXTO         │
│     - Código actual del proyecto    │
│     - Salida de pytest              │
│     - Documentación del componente  │
│     - Plan de construcción original │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  4. JEFE DE PROYECTO                │
│     Analiza el fallo                │
│     Genera nuevo objetivo           │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  5. NUEVA TAREA                     │
│     Crea T{timestamp}-FIX-backend.json│
│     - Objetivo: corregir el fallo   │
│     - Etapas: backend-dev + backend-qa│
│     - plan_de_origen: plan original │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  6. RE-PROCESAMIENTO                │
│     La nueva tarea entra a la cola  │
│     El ciclo se repite              │
└─────────────────────────────────────┘
```

### Estructura de una Tarea de Corrección

**Archivo:** `tasks/T20250812-180348-FIX-backend.json`

```json
{
  "objetivo": "Refactoriza el código para que se alinee con la arquitectura. Crea backend/__init__.py con factory create_app...",
  "etapas_a_ejecutar": ["backend-dev", "backend-qa"],
  "plan_de_origen": "T004-Calculator-v1_plan_construccion.json",
  "github_repo": "https://github.com/user/calculator.git",
  "github_project": "calculator",
  "github_pat": "ghp_...",
  "llm_config": {...}
}
```

**Campos clave:**
- `objetivo`: Instrucción específica de corrección (generada por el Jefe de Proyecto)
- `etapas_a_ejecutar`: Solo desarrollo + QA del componente fallido
- `plan_de_origen`: Referencia al plan original para mantener el contexto

### Limitador de Intentos

**Problema:** ¿Qué pasa si el agente sigue fallando en un bucle infinito?

**Solución actual:** Los fallos recurrentes eventualmente generan tantas tareas de corrección que el usuario puede intervenir manualmente moviendo tareas a `failed/`.

**Mejora futura:** Implementar un contador de intentos en el nombre de la tarea:
```
T{timestamp}-FIX-backend-ATTEMPT-2.json
```

Y limitar a N intentos antes de mover automáticamente a `failed/`.

---

## Sistema de Workflows y Etapas

### Etapas Atómicas

El sistema define un vocabulario de etapas claras:

| Etapa | Descripción | Ejecutor |
|-------|-------------|----------|
| `planificacion` | Genera el plan de construcción | Agente Arquitecto |
| `backend-dev` | Desarrolla el código del backend | Agente Backend |
| `backend-qa` | Prueba unitarias del backend | pytest |
| `backend-doc` | Documenta el backend | Agente Documentador |
| `frontend-dev` | Desarrolla el código del frontend | Agente Frontend |
| `frontend-qa` | Prueba del frontend (no implementado) | - |
| `frontend-doc` | Documenta el frontend | Agente Documentador |
| `e2e-dev` | Genera tests Cypress | Agente E2E |
| `e2e-qa` | Ejecuta tests Cypress | Cypress |
| `documentacion` | Documenta el proyecto completo | Agente Documentador |

### Workflows Predefinidos

#### Workflow Completo (CI/CD Full)
```json
{
  "etapas_a_ejecutar": [
    "planificacion",
    "backend-dev",
    "backend-doc",
    "backend-qa",
    "frontend-dev",
    "frontend-doc",
    "frontend-qa",
    "e2e-dev",
    "e2e-qa",
    "documentacion"
  ]
}
```

#### Workflow de Corrección
```json
{
  "etapas_a_ejecutar": [
    "backend-dev",
    "backend-qa"
  ]
}
```

#### Workflow Solo Documentación
```json
{
  "etapas_a_ejecutar": [
    "backend-doc",
    "frontend-doc",
    "documentacion"
  ]
}
```

### Parser de Etapas en el Orquestador

**Ubicación:** `orquestador.py:717-768`

```python
for etapa_actual in etapas_a_ejecutar:
    log_message(f"--- Ejecutando Etapa: [{etapa_actual.upper()}] ---", "SYSTEM")

    if etapa_actual == "planificacion":
        # Limpiar workspace y generar plan
        limpiar_workspace(repo_local_path)
        if not run_agent_mission(client, "arquitecto", contexto_arquitecto):
            exito_mision = False
            break

    elif etapa_actual.endswith("-dev"):
        componente, fase = etapa_actual.split('-')
        etapa_info = next((e for e in plan.get('plan', []) if e.get("etapa") == componente), None)

        if componente == 'e2e':
            if not ejecutar_etapa_e2e_dev(client, etapa_info, repo_local_path, contexto_global):
                exito_mision = False
                break
        else:
            if not ejecutar_etapa_construccion(client, etapa_info, repo_local_path, contexto_global):
                exito_mision = False
                break

    elif etapa_actual.endswith("-qa"):
        if etapa_actual == "e2e-qa":
            if not ejecutar_etapa_e2e_qa(repo_local_path, contexto_global):
                exito_mision = False
                break
        else:
            componente, fase = etapa_actual.split('-')
            etapa_info = next((e for e in plan.get('plan', []) if e.get("etapa") == componente), None)
            if not ejecutar_etapa_qa(client, etapa_info, repo_local_path, contexto_global, args.no_qa, plan_path):
                exito_mision = False
                break

    elif etapa_actual.endswith("-doc"):
        componente = etapa_actual.split('-')[0]
        if not ejecutar_etapa_documentacion(client, contexto_global, repo_local_path, componente):
            exito_mision = False
            break
```

**Lógica:**
1. **Planificación:** Caso especial que limpia el workspace
2. **Sufijo `-dev`:** Extrae el componente y busca las tareas en el plan
3. **Sufijo `-qa`:** Ejecuta las pruebas correspondientes
4. **Sufijo `-doc`:** Genera documentación del componente

---

## Guías de Estilo

### Propósito

Las guías de estilo aseguran:
- **Consistencia:** Todo el código generado sigue las mismas convenciones
- **Calidad:** Se aplican buenas prácticas automáticamente
- **Mantenibilidad:** El código es legible y fácil de modificar

### Guía Genérica

**Archivo:** `resources/generic_style_guide.md`

**Contenido:**
- Principios KISS, YAGNI, DRY
- Nomenclatura: `snake_case` para funciones, `UPPER_SNAKE_CASE` para constantes
- Manejo de errores con `try...except` específicos
- Testing riguroso como pilar fundamental
- Uso de Git para control de versiones

### Guía de Backend

**Archivo:** `resources/backend_style_guide.md`

**Contenido:**
- Estructura de paquete con factory pattern
- Uso de Blueprints de Flask
- Testing con `pytest` y `app.test_client()`
- Monkeypatch para tests con archivos
- Gestión de dependencias en `requirements.txt`

### Guía de Frontend

**Archivo:** `resources/frontend_style_guide.md`

**Contenido:**
- Uso obligatorio de **Bootstrap 5**
- Sistema de grid: `.container`, `.row`, `.col-*`
- Componentes: `.btn`, `.card`, `.alert`, `.form-control`
- JavaScript con Fetch API
- Atributos `data-testid` para testing

### Inyección Selectiva

**Arquitectura "Need-to-Know":**
```python
if rol_agente in ["arquitecto", "jefe_de_proyecto", "backend", "frontend"]:
    # Guía genérica
    guias["GUIA_ESTILO_GENERICA"] = leer("generic_style_guide.md")

if rol_agente == "backend":
    guias["GUIA_ESTILO_BACKEND"] = leer("backend_style_guide.md")

if rol_agente == "frontend":
    guias["GUIA_ESTILO_FRONTEND"] = leer("frontend_style_guide.md")

contexto.update(guias)
```

Cada agente recibe **solo** las guías relevantes para su rol, minimizando el contexto.

---

## Flujo de Datos Completo

### Ejemplo: Tarea "Crear una Calculadora Web"

#### 1. Preparación de la Tarea

**Usuario crea:** `tasks/T004-Calculator-v1.json`

```json
{
  "objetivo": "Crear una calculadora web funcional",
  "descripcion_detallada": "La aplicación debe replicar la apariencia y funcionalidad de una calculadora estándar...",
  "requisitos_funcionales": {
    "backend": ["Servidor Flask", "API POST /api/calculate", ...],
    "frontend": ["SPA en index.html", "Botones 0-9", "Operadores +,-,*,/", ...]
  },
  "tecnologias": ["Python", "Flask", "HTML5", "CSS3", "JavaScript"],
  "etapas_a_ejecutar": [
    "planificacion",
    "backend-dev",
    "backend-doc",
    "backend-qa",
    "frontend-dev",
    "frontend-doc",
    "e2e-dev",
    "e2e-qa"
  ],
  "github_repo": "https://github.com/user/calculator.git",
  "github_project": "calculator",
  "github_pat": "ghp_...",
  "llm_config": {
    "model_name": "gpt-4",
    "api_key": "sk-...",
    "api_base": "https://api.openai.com/v1"
  }
}
```

#### 2. Orquestador: Bucle Principal

```python
# orquestador.py:main()
while True:
    task_files = [f for f in os.listdir(TASKS_DIR) if f.endswith('.json')]
    if not task_files: break

    current_task_file = task_files[0]  # "T004-Calculator-v1.json"
    config = json.load(open(task_path))
```

#### 3. Preparación del Repositorio

```python
# orquestador.py:preparar_repositorio()
g = Github(github_pat)
user.create_repo("calculator", private=True)  # Crea repo si no existe
run_git_command(["git", "clone", repo_url_auth, repo_local_path])
```

**Resultado:** Repositorio clonado en `workspace/calculator/`

#### 4. Etapa: Planificación

```python
# orquestador.py:main() - etapa "planificacion"
if etapa_actual == "planificacion":
    limpiar_workspace(repo_local_path)
    contexto_arquitecto = {
        **contexto_global,
        "tarea_especifica": "Generar plan de construcción."
    }
    run_agent_mission(client, "arquitecto", contexto_arquitecto)
```

**Agente Arquitecto se lanza en Docker:**

```python
# src/agent_runner.py
# 1. Clona el repo dentro del contenedor
# 2. Llama al LLM con el prompt de arquitecto + contexto
llm_response = get_llm_response(prompt, llm_config)

# 3. Parsea la respuesta JSON
{
  "files": [
    {
      "filename": "plan_construccion.json",
      "code": {
        "api_contract": {...},
        "contrato_qa_e2e": {...},
        "plan": [
          {"etapa": "backend", "tareas": [...]},
          {"etapa": "frontend", "tareas": [...]},
          {"etapa": "e2e", "tareas": [...]}
        ]
      }
    }
  ]
}

# 4. Crea el archivo plan_construccion.json
# 5. git add, commit, push
```

**Orquestador sincroniza:**
```python
run_git_command(["git", "pull"], repo_local_path)
plan_path = os.path.join(PLANS_DIR, "T004-Calculator-v1_plan_construccion.json")
shutil.move("repo/plan_construccion.json", plan_path)
plan = json.load(open(plan_path))
```

**Resultado:** Plan guardado en `plans/T004-Calculator-v1_plan_construccion.json`

#### 5. Etapa: Backend Development

```python
# orquestador.py:ejecutar_etapa_construccion()
etapa_info = plan['plan'][0]  # {"etapa": "backend", "tareas": [...]}
tareas = etapa_info.get("tareas")
requisito = "Construir la etapa de 'backend' cumpliendo con:\n- " + "\n- ".join(tareas)

contexto_obrero = {
    **contexto_global,
    "tarea_especifica": requisito
}

# Inyectar guías de estilo
inyectar_guias_de_estilo("backend", contexto_obrero)
# Añade: GUIA_ESTILO_GENERICA, GUIA_ESTILO_BACKEND

# Lanzar agente
run_agent_mission(client, "backend", contexto_obrero)
```

**Agente Backend genera:**
- `backend/__init__.py` (factory pattern)
- `backend/routes.py` (endpoints con Blueprint)
- `app.py` (punto de entrada)
- `tests/test_backend.py` (pruebas pytest)
- `requirements.txt` (Flask, pytest, etc.)
- `pytest.ini`

**Commit:**
```
git add .
git commit -m "Agente [BACKEND]: Completa la construcción de la etapa"
git push
```

**Orquestador sincroniza:**
```python
run_git_command(["git", "pull"], repo_local_path)
```

#### 6. Etapa: Backend Documentation

```python
# orquestador.py:ejecutar_etapa_documentacion()
ruta_codigo = os.path.join(repo_path, "backend")
codigo_del_proyecto = leer_codigo_proyecto(ruta_codigo)

contexto_documentador = {
    **contexto_global,
    "CONTEXTO_DEL_CODIGO": codigo_del_proyecto,
    "FICHERO_A_GENERAR": "docs/backend_documentation.md"
}

run_agent_mission(client, "documentador", contexto_documentador)
```

**Agente Documentador genera:**
- `docs/backend_documentation.md`

Contenido incluye:
- Visión general del backend
- Arquitectura (diagrama Mermaid)
- Tabla de endpoints de la API
- Esquemas de datos
- Instrucciones de instalación

**Commit:**
```
git add docs/backend_documentation.md
git commit -m "Agente [Documentador]: Genera/actualiza documentación para backend"
git push
```

#### 7. Etapa: Backend QA

```python
# orquestador.py:ejecutar_etapa_qa()
requirements_path = os.path.join(repo_local_path, "requirements.txt")
subprocess.run([sys.executable, "-m", "pip", "install", "-r", requirements_path], check=True)

try:
    resultado_tests = subprocess.run(["pytest"], cwd=repo_local_path, check=True)
    log_message("Todas las pruebas para [BACKEND] han pasado.", "SUCCESS")
    return True
except subprocess.CalledProcessError as e:
    # LOS TESTS FALLARON
    log_message("Las pruebas para [BACKEND] han fallado.", "FAIL")

    # Recolectar contexto
    codigo_actual = leer_codigo_proyecto(repo_local_path)
    razon_fallo = f"PYTEST FALLÓ:\n{e.stdout}\n{e.stderr}"

    # Buscar documentación
    doc_path = os.path.join(repo_local_path, "docs", "backend_documentation.md")
    doc_content = open(doc_path).read()

    # Llamar al Jefe de Proyecto
    run_jefe_de_proyecto_agent(
        contexto_global,
        "Corregir la etapa de 'backend' que falló las pruebas de QA.",
        codigo_actual,
        razon_fallo,
        plan_path,
        doc_content
    )
```

##### Caso A: Tests Pasan

```
✅ Todas las pruebas para [BACKEND] han pasado.
```

Continuar a la siguiente etapa.

##### Caso B: Tests Fallan

**Jefe de Proyecto analiza:**

```python
# Prompt del Jefe de Proyecto recibe:
# - REQUISITO: "Corregir la etapa de 'backend' que falló las pruebas de QA."
# - CODIGO_FALLIDO: (contenido de todos los archivos)
# - RAZON_FALLO: "ModuleNotFoundError: No module named 'backend'"
# - DOCUMENTACION_EXISTENTE: (contenido de backend_documentation.md)

llm_response = get_llm_response_directo(prompt_final, llm_config)

# LLM retorna:
{
  "analisis_del_fallo": "El error es un ModuleNotFoundError. La documentación describe que debe existir un paquete 'backend' con __init__.py. El código actual tiene la lógica en un solo archivo backend.py, no en un paquete.",
  "nuevo_objetivo": "Refactoriza para crear el paquete backend/. Pasos: 1. Crear backend/__init__.py con la factory create_app(). 2. Mover las rutas a backend/routes.py usando Blueprint. 3. Actualizar app.py para importar desde backend. 4. Actualizar tests para importar desde backend."
}
```

**Crear nueva tarea:**
```python
nueva_tarea_config = {
    "objetivo": "Refactoriza para crear el paquete backend/...",
    "etapas_a_ejecutar": ["backend-dev", "backend-qa"],
    "plan_de_origen": "T004-Calculator-v1_plan_construccion.json",
    "github_repo": "https://github.com/user/calculator.git",
    "github_project": "calculator",
    "github_pat": "ghp_...",
    "llm_config": {...}
}

timestamp = "20250812-180348"
nuevo_fichero = "tasks/T20250812-180348-FIX-backend.json"
json.dump(nueva_tarea_config, open(nuevo_fichero, 'w'))
```

**Resultado:**
- Nueva tarea en la cola: `T20250812-180348-FIX-backend.json`
- La tarea original se mueve a `tasks/failed/`
- En el siguiente ciclo, la tarea de corrección se procesará

#### 8. Ciclo de Corrección

```python
# Siguiente iteración del while True en main()
current_task_file = "T20250812-180348-FIX-backend.json"
config = json.load(...)

etapas_a_ejecutar = ["backend-dev", "backend-qa"]

# No carga plan desde archivo, usa plan_de_origen
plan_de_origen = config.get("plan_de_origen")  # "T004-Calculator-v1_plan_construccion.json"
plan_path = os.path.join(PLANS_DIR, plan_de_origen)
plan = json.load(open(plan_path))

# ETAPA: backend-dev (con nuevo objetivo)
objetivo = config["objetivo"]  # "Refactoriza para crear el paquete backend/..."
contexto_obrero = {
    "tarea_especifica": objetivo,
    "GUIA_ESTILO_GENERICA": "...",
    "GUIA_ESTILO_BACKEND": "..."
}
run_agent_mission(client, "backend", contexto_obrero)
```

**Agente Backend refactoriza:**
- Crea `backend/__init__.py` con factory
- Crea `backend/routes.py` con Blueprint
- Actualiza `app.py`
- Actualiza `tests/test_backend.py`

**Commit y push.**

**ETAPA: backend-qa**
```python
subprocess.run(["pytest"], check=True)
# ✅ Tests pasan esta vez
```

**Resultado:**
- Tarea de corrección se mueve a `tasks/processed/`
- Orquestador continúa con las etapas pendientes de la tarea original

#### 9. Etapas Restantes

**Frontend Development:**
```python
etapa_info = plan['plan'][1]  # {"etapa": "frontend", "tareas": [...]}
contexto_obrero = {
    "tarea_especifica": requisito_completo,
    "GUIA_ESTILO_GENERICA": "...",
    "GUIA_ESTILO_FRONTEND": "...",
    "DOCUMENTACION_BACKEND": open("docs/backend_documentation.md").read()
}
run_agent_mission(client, "frontend", contexto_obrero)
```

**Agente Frontend genera:**
- `frontend/index.html` (con Bootstrap 5, fetch API, data-testid)

**Frontend Documentation:**
- `docs/frontend_documentation.md`

**E2E Development:**
```python
etapa_info = plan['plan'][2]  # {"etapa": "e2e", "tareas": [...]}
ejecutar_etapa_e2e_dev(client, etapa_info, repo_local_path, contexto_global)
```

**Agente E2E genera:**
- `cypress/e2e/test_spec.cy.js`

**E2E QA:**
```python
ejecutar_etapa_e2e_qa(repo_local_path, contexto_global)
# 1. Crear package.json, cypress.config.js
# 2. npm install
# 3. Levantar servidor Flask
# 4. npx cypress run
# 5. Detener servidor
```

#### 10. Resultado Final

**Repositorio en GitHub:**
```
calculator/
├── backend/
│   ├── __init__.py
│   └── routes.py
├── frontend/
│   └── index.html
├── tests/
│   └── test_backend.py
├── cypress/
│   └── e2e/
│       └── test_spec.cy.js
├── docs/
│   ├── backend_documentation.md
│   └── frontend_documentation.md
├── app.py
├── requirements.txt
├── pytest.ini
├── package.json
└── cypress.config.js
```

**Estado de tareas:**
- `tasks/processed/T004-Calculator-v1.json` ✅
- `tasks/processed/T20250812-180348-FIX-backend.json` ✅

**Plan guardado:**
- `plans/T004-Calculator-v1_plan_construccion.json`

---

## Patrones de Diseño Aplicados

### 1. Factory Pattern (Backend)
```python
# backend/__init__.py
def create_app():
    app = Flask(__name__)
    from .routes import api_bp
    app.register_blueprint(api_bp)
    return app

# app.py
from backend import create_app
app = create_app()
if __name__ == '__main__':
    app.run()
```

### 2. Blueprint Pattern (Flask)
```python
# backend/routes.py
from flask import Blueprint
api_bp = Blueprint('api', __name__)

@api_bp.route('/api/calculate', methods=['POST'])
def calculate():
    return jsonify({"result": 42})
```

### 3. Orchestrator Pattern
El orquestador coordina múltiples servicios (agentes) sin que estos se conozcan entre sí.

### 4. Chain of Responsibility
Ciclo QA → Jefe de Proyecto → Nueva Tarea → QA (hasta que pase)

### 5. Strategy Pattern
Diferentes estrategias de testing inyectadas mediante prompts (test client, monkeypatch, etc.)

### 6. Template Method
Los prompts actúan como "plantillas" con huecos que se rellenan con el contexto.

---

## Consideraciones de Seguridad

### 1. Tokens de GitHub

**Problema:** Los tokens PAT se almacenan en los archivos de tareas.

**Mitigación:**
- Los archivos de tareas no deberían estar en Git
- Usar variables de entorno para almacenar PATs
- Implementar un sistema de gestión de secretos (ej: HashiCorp Vault)

### 2. Ejecución de Código LLM

**Problema:** El código generado por el LLM se ejecuta sin revisión humana.

**Mitigación:**
- El código se ejecuta en **contenedores Docker aislados**
- Los contenedores no tienen acceso a recursos sensibles del host
- Se podría implementar análisis estático de seguridad (ej: Bandit para Python)

### 3. Inyección de Prompts

**Problema:** Un usuario malicioso podría manipular el prompt para hacer que el agente haga cosas no deseadas.

**Mitigación:**
- Los prompts del sistema están en archivos de solo lectura
- El contexto del usuario se pasa como datos JSON, no como texto directo en el prompt
- Usar delimitadores claros en los prompts (ej: "CONTEXTO:\n{json}")

---

## Optimizaciones y Mejoras Futuras

### 1. Paralelización de Etapas

**Problema:** Actualmente, las etapas se ejecutan secuencialmente.

**Mejora:** Etapas independientes podrían ejecutarse en paralelo:
```python
with ThreadPoolExecutor() as executor:
    future_backend = executor.submit(ejecutar_etapa_construccion, "backend")
    future_frontend = executor.submit(ejecutar_etapa_construccion, "frontend")

    backend_result = future_backend.result()
    frontend_result = future_frontend.result()
```

### 2. Cache de Modelos LLM

**Problema:** Cada llamada al LLM es lenta y costosa.

**Mejora:** Implementar cache de respuestas:
```python
cache_key = hashlib.sha256(prompt.encode()).hexdigest()
if cache_key in cache:
    return cache[cache_key]
else:
    response = llm_call(prompt)
    cache[cache_key] = response
    return response
```

### 3. Streaming de Logs

**Problema:** Los logs de los agentes solo se ven al final.

**Mejora:** Usar `container.logs(stream=True)` para ver logs en tiempo real:
```python
for line in container.logs(stream=True):
    print(line.decode('utf-8'), end='')
```

### 4. Dashboard Web

**Problema:** Todo se gestiona por línea de comandos.

**Mejora:** Crear una interfaz web (Flask + React) para:
- Ver el estado de las tareas en la cola
- Ver logs en tiempo real
- Pausar/reanudar tareas
- Ver el contenido de los repositorios

### 5. Análisis de Coste

**Problema:** No se sabe cuánto cuestan las llamadas al LLM.

**Mejora:** Trackear tokens y calcular costes:
```python
total_tokens = response.usage.total_tokens
cost = calculate_cost(model_name, total_tokens)
log_message(f"Coste de esta llamada: ${cost:.4f}")
```

---

## Glosario de Términos

- **Orquestador:** Componente central que coordina los agentes
- **Agente:** Programa especializado que realiza una tarea específica
- **Prompt del Sistema:** Instrucciones que definen el comportamiento de un agente
- **Plan de Construcción:** Documento JSON que define las tareas por componente
- **Etapa:** Unidad atómica de trabajo (ej: backend-dev, frontend-qa)
- **Workflow:** Secuencia de etapas a ejecutar
- **API Contract:** Especificación exacta de los endpoints de la API
- **Contrato QA E2E:** Mapeo de elementos HTML a data-testid para testing
- **Guía de Estilo:** Documento con reglas de codificación
- **Jefe de Proyecto:** Agente que analiza fallos y crea tareas de corrección
- **Workspace:** Directorio local donde se clonan los repositorios
- **PAT:** Personal Access Token de GitHub para autenticación
- **LLM:** Large Language Model (modelo de lenguaje grande)

---

## Referencias de Código

### Funciones Principales del Orquestador

| Función | Líneas | Descripción |
|---------|--------|-------------|
| `main(args)` | 665-792 | Bucle principal de procesamiento de tareas |
| `preparar_repositorio()` | 97-130 | Crea/clona el repositorio de GitHub |
| `run_agent_mission()` | 323-403 | Lanza un agente en Docker |
| `ejecutar_etapa_construccion()` | 556-595 | Ejecuta la fase de desarrollo de una etapa |
| `ejecutar_etapa_qa()` | 597-662 | Ejecuta pruebas unitarias |
| `ejecutar_etapa_e2e_qa()` | 238-295 | Ejecuta pruebas Cypress |
| `run_jefe_de_proyecto_agent()` | 405-450 | Analiza fallos y crea tareas de corrección |
| `ejecutar_etapa_documentacion()` | 493-554 | Genera documentación técnica |
| `inyectar_guias_de_estilo()` | 132-162 | Inyecta guías de estilo en el contexto |
| `leer_codigo_proyecto()` | 58-73 | Lee todo el código de un proyecto |
| `limpiar_workspace()` | 75-95 | Borra el contenido del workspace (excepto .git) |

### Variables de Configuración

| Variable | Línea | Valor | Descripción |
|----------|-------|-------|-------------|
| `AGENT_IMAGE` | 17 | "agente-constructor" | Imagen Docker de los agentes |
| `WORKSPACE_DIR_NAME` | 18 | "workspace" | Directorio de workspaces |
| `TASKS_DIR` | 19 | "tasks" | Directorio de tareas |
| `PLANS_DIR` | 22 | "plans" | Directorio de planes |
| `AGENT_INFO` | 24-34 | dict | Mapeo de agentes a prompts |

---

Esta documentación CODE_WIKI cubre exhaustivamente todos los aspectos técnicos del sistema La Colmena, desde la arquitectura de alto nivel hasta los detalles de implementación más finos. Es una guía de referencia completa para desarrolladores que quieran entender, modificar o extender el sistema.
