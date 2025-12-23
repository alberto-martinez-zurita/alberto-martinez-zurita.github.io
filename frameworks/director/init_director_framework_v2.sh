#!/bin/bash

# Nombre del Proyecto (Carpeta Raíz)
PROJECT_NAME="Director_Framework_Project"

echo "🚀 Iniciando Protocolo de Despliegue: DIRECTOR FRAMEWORK UNIFICADO (v2.0)..."

# 1. CREACIÓN DE ESTRUCTURA DE DIRECTORIOS
mkdir -p "$PROJECT_NAME/00_Context"
mkdir -p "$PROJECT_NAME/01_Ideation"
mkdir -p "$PROJECT_NAME/02_Requirements"
mkdir -p "$PROJECT_NAME/03_Architecture"
mkdir -p "$PROJECT_NAME/04_Planning"
mkdir -p "$PROJECT_NAME/05_Development/src"
mkdir -p "$PROJECT_NAME/05_Development/tests"
mkdir -p "$PROJECT_NAME/06_Validation"
mkdir -p "$PROJECT_NAME/07_Closure"

echo "✅ Directorios creados."

# 2. GENERACIÓN DE ARCHIVOS DE CONTEXTO (RAGs y Prompts)

# --- A. ARCHIVOS DE CONTEXTO NUMERADOS Y CLAR ---

# RAG DIRECTOR [1]
cat << 'EOF' > "$PROJECT_NAME/00_Context/RAG_01_Director.md"
[... CONTENIDO DEL RAG_01_Director.md ...]
# MÉTODO DIRECTOR (Resumen Operativo)

Framework de Prompt Engineering Estructurado.

## ACRÓNIMO
- **D**elimitadores: Usar ###, """, --- para separar secciones.
- **I**nstrucción: Verbos de acción claros (Analiza, Genera, Resume).
- **R**ol: Asignar personalidad experta (Arquitecto, QA, PO).
- **E**jemplos: Few-Shot prompting para guiar el formato.
- **C**ontexto: Datos necesarios para reducir alucinaciones.
- **T**est/Iteración: Verificar y refinar.
- **O**bjetivo: Propósito final del output.
- **R**estricciones: Límites (formato, longitud, estilo).

## TÉCNICAS AVANZADAS
1. **Chain-of-Thought (CoT):** "Piensa paso a paso".
2. **Meta-Prompting:** Usar prompts para generar prompts.
3. **RAG:** Inyectar conocimiento externo (Docs técnicos).
4. **Prompt Chaining:** Desglosar tareas complejas en eslabones secuenciales.
EOF

# RAG RÚBRICA ÉLITE [8] (Definitiva)
cat << 'EOF' > "$PROJECT_NAME/00_Context/RAG_08_Rubrica_Elite.md"
[... CONTENIDO DEL RAG_08_Rubrica_Elite.md ...]
# MARCO DE REFERENCIA CLEAR: Nivel Élite (Knowledge Base)

Este marco define los criterios de aceptación para el **Nivel 5 (Optimizado)** según el modelo CLEAR. Todo código y arquitectura debe ser auditado contra estos estándares estrictos.

## PILAR I: MANTENIBILIDAD COGNITIVA
**Objetivo:** Minimizar la carga cognitiva. El código debe ser "obvio" para el lector humano en menos de 30 segundos.

**Reglas de Calidad (Nivel 5):**
1.  **Complejidad Cognitiva:**
    * **< 8** obligatoria para código crítico de negocio.
    * **< 15** umbral máximo absoluto permitido para cualquier función.
    * *Auditoría IA:* Revisión cognitiva total obligatoria para cualquier bloque de código generado por IA.
2.  **Cobertura y Calidad de Tests:**
    * Cobertura de Código **> 85%**.
    * **Mutation Testing** obligatorio para garantizar certeza semántica (evitar falsos positivos de cobertura).
3.  **Estructura Plana (Aplanamiento):**
    * Prohibido anidamiento superior a **2-3 niveles**.
    * Uso obligatorio de **Guard Clauses** (Retornos tempranos) para mantener el "Happy Path" en el nivel de indentación 0.
    * Uso de **Dispatch Tables** (Diccionarios de funciones) para reemplazar cadenas largas de `if-elif-else`.
4.  **Tipado Defensivo:** Tipado estático estricto en el 100% de las fronteras del sistema (ej. uso de Pydantic).

## PILAR II: VELOCIDAD DEL CICLO DE VIDA (LIFECYCLE)
**Objetivo:** Flujo continuo de valor sin fricción operativa (DORA Elite).

**Umbrales de Éxito (Nivel 5):**
1.  **Frecuencia de Despliegue:** **On-Demand** (Múltiples veces al día). Pipeline Commit-to-Prod completamente automatizado.
2.  **Lead Time for Changes:** **< 1 Hora** desde el commit hasta la ejecución en producción.
3.  **Change Failure Rate:** **< 5%**.
4.  **Métricas de Flujo (Flow Framework):**
    * **Flow Efficiency:** **> 40%** (El tiempo de espera/bloqueo es mínimo respecto al tiempo activo).
    * **Flow Load (WIP):** Estrictamente limitado por equipo ("Pull system" perfecto) para evitar deuda cognitiva por cambio de contexto.
5.  **Desacople:** Uso ubicuo de **Feature Flags** para separar el despliegue técnico del lanzamiento funcional.

## PILAR III: ELASTICIDAD Y MODULARIDAD
**Objetivo:** Arquitectura Antifrágil y Desacoplada.

**Reglas Arquitectónicas:**
1.  **Inestabilidad ($I$):** Respetar matemáticamente el **Principio de Dependencias Estables** ($I$ dependencias < $I$ dependientes).
2.  **Desacoplamiento:**
    * **Inyección de Dependencias (DI):** Total y obligatoria. Prohibida la instanciación directa ("hardcoded") de dependencias volátiles (DB, APIs) dentro de las clases.
    * **Arquitectura:** Evolución hacia modelos **Event-Driven** o Serverless (Coreografía pura).
3.  **Evaluación de Riesgo:** Existencia de análisis **ATAM** (Architecture Tradeoff Analysis Method) documentado para puntos de sensibilidad y tradeoffs.

## PILAR IV: DISPONIBILIDAD Y CONFIABILIDAD (SRE)
**Objetivo:** Auto-healing y Gobernanza de Errores.

**Reglas Operativas:**
1.  **Resiliencia Automática:**
    * **Circuit Breaker:** Implementado en el 100% de las integraciones síncronas externas.
    * **Recuperación (MTTR):** **< 1 Hora** (Idealmente Auto-healing sin intervención humana).
    * **Retries:** Uso obligatorio de Backoff Exponencial con **Jitter** (aleatoriedad).
2.  **Gobernanza:** Gestión activa de **Presupuestos de Error** (Error Budgets). Si se agotan, se bloquean automáticamente nuevos deploys (*Feature Freeze*).

## PILAR V: RIESGO Y SEGURIDAD (SECURE BY DESIGN)
**Objetivo:** Inmutabilidad, Compliance Continuo y Zero-Trust.

**Reglas de Seguridad:**
1.  **Infraestructura:** **Inmutable**. No se permiten cambios manuales (SSH) en producción. Drift Detection automático activado.
2.  **Vulnerabilidades:**
    * **Gestión:** Modelo **Zero-Trust**.
    * **Parcheo:** Auto-patching o despliegues Blue-Green para actualizaciones de seguridad sin downtime.
3.  **Compliance as Code:**
    * Validación automática de **CIS Benchmarks**.
    * Reglas de admisión **OPA** (Open Policy Agent) activas en el pipeline (bloqueantes para configuraciones inseguras).

## PILAR VI: EFICIENCIA DE RECURSOS (FINOPS/GREENOPS)
**Objetivo:** Unit Economics y Sostenibilidad Ambiental.

**Reglas de Eficiencia:**
1.  **FinOps (Nivel 5):**
    * **Tagging:** Cobertura del **100%** de recursos para atribución de costes.
    * **Medición:** **Unit Economics** (Coste por Transacción) calculado y visible. Chargeback dinámico implementado.
2.  **GreenOps:**
    * **Memoria:** Uso obligatorio de **Generadores (Lazy Evaluation)** en lugar de listas para colecciones grandes de datos.
    * **Carbono:** Scheduling de cargas de trabajo batch configurado para ventanas temporales de baja intensidad de carbono.
EOF

# RAG TÉCNICO [12] (Placeholder)
cat << 'EOF' > "$PROJECT_NAME/00_Context/RAG_12_Tecnico.md"
# ESTÁNDARES TÉCNICOS DEL PROYECTO

## Stack Tecnológico
- Lenguaje: [Definir]
- Framework: [Definir]

## Convenciones
- Naming: CamelCase / snake_case

EOF

# RAG MODELO CLEAR (Filosofía - No tiene ID de flujo)
cat << 'EOF' > "$PROJECT_NAME/00_Context/RAG_Modelo_Clear.md"
[... CONTENIDO DEL RAG_Modelo_Clear.md ...]
# ESTUDIO TÉCNICO Y DOCUMENTACIÓN ESTRATÉGICA DEL MODELO DE CALIDAD 'CLEAR': VALIDACIÓN DE KPIs, DEUDA COGNITIVA Y OPTIMIZACIÓN DE INFRAESTRUCTURA

**Versión del Documento:** 2.0

**Fecha:** 27 de Noviembre de 2024

**Elaborado por:** Arquitecto de Software Senior & Líder de Prácticas QA (ISO 25000)

**Alcance:** Análisis Exhaustivo de los 6 Pilares, Validación de Métricas Cognitivas y Hoja de Ruta para Plataformas Cloud-Native.

* * *

## 1\. Resumen Ejecutivo

En el panorama actual de la ingeniería de software, la velocidad de entrega y la complejidad sistémica han alcanzado puntos de inflexión críticos. La adopción masiva de herramientas de Inteligencia Artificial Generativa (GenAI) para la producción de código, si bien acelera la fase de desarrollo, introduce riesgos latentes de **Deuda Cognitiva** y **Complejidad Accidental** que amenazan la mantenibilidad a largo plazo. Este informe técnico presenta el modelo de calidad **CLEAR**, un marco de trabajo holístico diseñado para alinear las prácticas modernas de DevOps, SRE y Arquitectura Evolutiva con los rigurosos estándares de la norma **ISO/IEC 25010**.  

El modelo CLEAR estructura la calidad en seis pilares estratégicos: **C**ognitive Maintainability (Mantenibilidad Cognitiva), **L**ifecycle Velocity (Velocidad del Ciclo de Vida), **E**lasticity & Modularity (Elasticidad y Modularidad), **A**vailability & Reliability (Disponibilidad y Confiabilidad), **R**isk & Security (Riesgo y Seguridad), y un sexto pilar transversal de **Resource Efficiency** (Eficiencia de Recursos - FinOps/GreenOps).

A través de un análisis profundo de la literatura técnica y estándares de la industria, este documento valida la insuficiencia de métricas tradicionales como la Complejidad Ciclomática cuando se utilizan de forma aislada, proponiendo la adopción mandatoria de la **Complejidad Cognitiva** para evaluar la "comprensibilidad" del código generado por humanos y máquinas. Además, se presenta una **Rúbrica de Evaluación** detallada que permite clasificar la madurez de los equipos y sistemas desde un nivel _Ad-Hoc_ hasta un nivel _Optimizado_, y se detalla una estrategia de mejora para el nivel de **Plataforma/Infraestructura**, integrando prácticas de observabilidad, seguridad como código y sostenibilidad.  

* * *

## 2\. Introducción y Fundamentos Normativos (ISO 25010)

La ingeniería de software moderna ya no puede evaluarse únicamente bajo la premisa de la "corrección funcional". La evolución hacia arquitecturas distribuidas, microservicios y plataformas nativas de la nube ha expandido la superficie de complejidad, haciendo imperativo un enfoque multidimensional de la calidad. Este estudio se fundamenta en la familia de normas **ISO/IEC 25000 (SQuaRE - Systems and Software Quality Requirements and Evaluation)**, específicamente en el modelo de calidad del producto definido en la **ISO/IEC 25010**.  

### 2.1 Alineación Estratégica del Modelo CLEAR

El modelo CLEAR no es una reinvención arbitraria, sino una adaptación pragmática de las ocho características de calidad de la ISO 25010 a la realidad operativa de los equipos de alto rendimiento. La correspondencia se establece de la siguiente manera:

-   **Maintainability (Mantenibilidad):** Mapeado al pilar **Cognitive Maintainability**. Se enfoca en la modularidad, reusabilidad, analizabilidad y modificabilidad, pero con un énfasis renovado en la carga cognitiva humana necesaria para realizar estos cambios.  
    
-   **Performance Efficiency (Eficiencia de Desempeño):** Mapeado al pilar **Resource Efficiency**. Trasciende el tiempo de respuesta para incluir la utilización de recursos y, crucialmente, el coste económico (FinOps) y el impacto ambiental (GreenOps).  
    
-   **Reliability (Fiabilidad):** Mapeado al pilar **Availability & Reliability**. Se centra en la madurez, disponibilidad, tolerancia a fallos y capacidad de recuperación, alineándose con las prácticas de Ingeniería de Fiabilidad del Sitio (SRE).  
    
-   **Security (Seguridad):** Mapeado al pilar **Risk, Security & Compliance**. Abarca confidencialidad, integridad, no repudio y responsabilidad, integrando controles de seguridad en la infraestructura (CIS Benchmarks).  
    
-   **Portability & Compatibility (Portabilidad y Compatibilidad):** Mapeado al pilar **Elasticity & Architectural Modularity**. Evalúa la capacidad del sistema para adaptarse a diferentes entornos (nube híbrida, contenedores) y coexistir con otros sistemas.  
    
-   **Functional Suitability (Adecuación Funcional):** Mapeado al pilar **Lifecycle Velocity**. Se mide no solo por la presencia de funciones, sino por la velocidad y precisión con la que se entrega valor al usuario final.  
    

* * *

## 3\. Pilar 1: Cognitive Maintainability (Mantenibilidad Cognitiva) y Salud del Código

Este pilar representa la base fundacional del modelo. Sin un código base saludable y comprensible, cualquier intento de agilidad o escalabilidad está condenado al fracaso debido a la fricción técnica.

### 3.1 El Desafío de la Deuda Cognitiva en la Era de la IA

Tradicionalmente, la "Deuda Técnica" se entendía como el costo de retrabajo causado por elegir una solución fácil y rápida en lugar de una mejor aproximación a largo plazo. Sin embargo, la emergencia de herramientas de codificación asistida por IA ha introducido un concepto más insidioso: la **Deuda Cognitiva**.  

La Deuda Cognitiva se define como el interés acumulado que se debe pagar con **atención humana**. Cuando la IA genera código, la salida se percibe como un activo casi gratuito, pero conlleva un pasivo oculto: alguien debe gastar energía mental para consumir, calificar, interpretar, mejorar, analizar y sintetizar ese código. A diferencia de la deuda técnica, que puede ser ignorada temporalmente sin detener la operación, la deuda cognitiva paraliza la capacidad de razonamiento del desarrollador en el momento presente. Investigaciones recientes sugieren que el uso de IA sin una supervisión rigurosa puede reducir el pensamiento crítico y la resolución de problemas independiente, acelerando la "podredumbre del código" (code rot) y aumentando la duplicación hasta en un 8x.  

### 3.2 Estudio Técnico de KPIs: Complejidad Ciclomática vs. Cognitiva

Uno de los requisitos críticos de este estudio es validar la pertinencia de los KPIs de complejidad. La industria ha confiado durante décadas en la métrica de McCabe, pero el análisis de las fuentes revela que su utilidad como medida única está obsoleta.

#### 3.2.1 Complejidad Ciclomática (McCabe)

Introducida por Thomas McCabe en 1976, esta métrica cuantifica el número de caminos linealmente independientes a través del código fuente. Se calcula esencialmente como el número de puntos de decisión (if, for, while, case) más uno.  

-   **Validación del Umbral (10):** El umbral estándar de la industria de **10** por método se deriva de la recomendación original de McCabe para limitar la complejidad de las rutinas durante el desarrollo. Tanto SonarQube como PMD utilizan este valor por defecto.  
    
-   **Justificación Técnica:** La complejidad ciclomática es un proxy directo de la **Testabilidad**. El número ciclomático define el número mínimo de pruebas unitarias necesarias para cubrir todos los caminos posibles del código. Un método con complejidad 25 requiere al menos 25 tests unitarios para una cobertura de caminos completa, lo cual es logísticamente costoso y propenso a errores.  
    
-   **Limitación Crítica:** La métrica falla al medir la **Comprensibilidad**. Un `switch` plano con 20 casos tiene una complejidad ciclomática de 20 (alta), pero es trivial de entender para un humano. Por el contrario, tres bucles anidados con lógica booleana compleja pueden tener una complejidad de 6, pero ser cognitivamente impenetrables.  
    

#### 3.2.2 Complejidad Cognitiva (Sonar)

Para abordar las deficiencias de McCabe, SonarSource desarrolló la Complejidad Cognitiva. Esta métrica se basa en tres reglas básicas: ignorar estructuras que permiten "taquigrafía" legible (como un switch), incrementar la puntuación por cada ruptura en el flujo lineal (bucles, condicionales, recursión), e incrementar la puntuación por **anidamiento**.  

-   **Validación del Umbral (15):** La industria y las herramientas de análisis estático como SonarQube han estandarizado un umbral de advertencia en **15** y un error crítico en **25**.  
    
-   **Superioridad Semántica:** La Complejidad Cognitiva penaliza el anidamiento profundo porque cada nivel de indentación añade una "carga" a la memoria de trabajo del desarrollador, quien debe mantener el contexto de las condiciones superiores. Esto la convierte en una medida mucho más precisa de la **Mantenibilidad** y la **Deuda Cognitiva**.  
    

### 3.3 Estrategia de Evaluación CLEAR para el Pilar Cognitivo

El modelo CLEAR prescribe el uso dual de estas métricas con propósitos distintos:

1.  **Complejidad Ciclomática:** Se utilizará estrictamente para dimensionar el **esfuerzo de QA**. Si CC > 10, se requiere una justificación de cobertura de pruebas excepcional.
    
2.  **Complejidad Cognitiva:** Se utilizará como **Quality Gate** para la mantenibilidad. Se establece un límite duro de 15 para código nuevo, forzando la refactorización preventiva.  
    

* * *

## 4\. Pilar 2: Lifecycle Velocity (Velocidad del Ciclo de Vida) y Métricas de Flujo

Este pilar evalúa la eficiencia de los procesos de ingeniería, desplazando el foco de la mera actividad (líneas de código escritas) a la entrega de valor y resultados operativos.

### 4.1 Métricas DORA (DevOps Research and Assessment)

Las métricas DORA se han establecido como el estándar _de facto_ para medir el rendimiento de la entrega de software. Se dividen en métricas de velocidad y estabilidad.  

1.  **Deployment Frequency (Frecuencia de Despliegue):** Mide la cadencia de entrega de valor. Los equipos de élite despliegan bajo demanda (múltiples veces al día), lo que reduce el tamaño del lote (batch size) y el riesgo asociado a cada cambio.  
    
2.  **Lead Time for Changes (Tiempo de Entrega de Cambios):** El tiempo desde que el código se confirma (commit) hasta que se ejecuta en producción. Un Lead Time bajo (< 1 hora) indica una alta eficiencia en la pipeline de CI/CD y procesos de revisión ágiles.  
    
3.  **Change Failure Rate (Tasa de Fallos en Cambios):** El porcentaje de despliegues que requieren una corrección inmediata (hotfix, rollback). Un valor superior al 15% indica deficiencias en las pruebas automatizadas o en la calidad del código.  
    
4.  **Time to Restore Service (Tiempo de Restauración):** Cuánto tiempo toma recuperarse de un fallo en producción.
    

### 4.2 Métricas de Flujo (Flow Framework)

Mientras que DORA mide los resultados del proceso de entrega, las Métricas de Flujo (basadas en el Flow Framework del Dr. Mik Kersten) diagnostican la eficiencia interna del flujo de valor, permitiendo identificar _por qué_ los resultados de DORA son los que son.  

1.  **Flow Velocity:** Cuánto valor se entrega en un periodo dado.
    
2.  **Flow Efficiency:** La relación entre el tiempo activo de trabajo y el tiempo total de espera. Una eficiencia baja (común en organizaciones tradicionales, a menudo < 10%) señala cuellos de botella organizacionales, esperas por aprobaciones o dependencias bloqueantes.  
    
3.  **Flow Load:** La cantidad de trabajo en progreso (WIP). Un Flow Load excesivo correlaciona directamente con una alta Deuda Cognitiva y un aumento en el Lead Time, debido a la penalización por cambio de contexto.  
    
4.  **Flow Time:** El tiempo total desde que una solicitud es aceptada hasta que se entrega.
    

**Integración en CLEAR:** El modelo utiliza DORA como el "termómetro" de la salud del equipo y las Métricas de Flujo como la "resonancia magnética" para diagnosticar problemas sistémicos.  

* * *

## 5\. Pilar 3: Elasticity & Architectural Modularity (Elasticidad y Modularidad Arquitectónica)

La arquitectura del software determina los límites de su escalabilidad y mantenibilidad. Este pilar aborda la estructura estática y dinámica del sistema.

### 5.1 Modularidad y Acoplamiento

La modularidad se evalúa mediante la métrica de **Acoplamiento (Coupling)** y **Cohesión**. Un diseño modular efectivo busca una alta cohesión (los elementos dentro de un módulo pertenecen juntos funcionalmente) y un bajo acoplamiento (dependencias mínimas entre módulos).  

-   **KPI Clave: Instability (I):** I\=Ca+CeCe​, donde Ce es el acoplamiento eferente (saliente) y Ca es el aferente (entrante).
    
-   **KPI Clave: Structural Debt Index (SDI):** Un índice compuesto que captura la deuda arquitectónica oculta que surge de dependencias cíclicas o violaciones de capas.  
    

### 5.2 Evaluación de Riesgo Arquitectónico (ATAM)

Para cuantificar el riesgo, el modelo CLEAR integra el **Architecture Tradeoff Analysis Method (ATAM)**. Este método sistemático evalúa cómo las decisiones arquitectónicas satisfacen atributos de calidad específicos a través de escenarios de uso, crecimiento y exploración.  

-   **Utility Tree:** Se utiliza para priorizar los atributos de calidad (ej. latencia vs. seguridad) y definir escenarios de prueba concretos.
    
-   **Puntos de Sensibilidad y Tradeoffs:** Identificación explícita de componentes donde un cambio leve impacta significativamente en la calidad (puntos de sensibilidad) y decisiones donde la mejora de una cualidad degrada otra (tradeoffs).  
    

### 5.3 Modelos de Madurez Cloud Native

La infraestructura subyacente se evalúa utilizando el Modelo de Madurez de la CNCF, progresando desde el Nivel 1 (Build/Construcción) hasta el Nivel 5 (Adapt/Adaptación), donde la orquestación y la escalabilidad son dinámicas y automáticas.  

* * *

## 6\. Pilar 4: Availability & Reliability (Disponibilidad y Confiabilidad)

Este pilar adopta los principios de **Site Reliability Engineering (SRE)** para gestionar la estabilidad operativa.

### 6.1 Métricas de Fiabilidad: MTTR, MTBF y MTBF

Es crucial distinguir y aplicar correctamente estas métricas :  

-   **MTBF (Mean Time Between Failures):** Mide la confiabilidad intrínseca del sistema. Un MTBF alto indica robustez.
    
-   **MTTR (Mean Time To Repair/Recover):** Mide la resiliencia y la eficacia de la respuesta a incidentes. En entornos modernos distribuidos, se prioriza la reducción del MTTR sobre la maximización absoluta del MTBF, bajo la premisa de que "el fallo es inevitable".  
    
-   **Error Budgets (Presupuestos de Error):** Definidos a partir de los SLOs (Service Level Objectives). Si un servicio tiene un objetivo de disponibilidad del 99.9%, el 0.1% restante es el presupuesto de error. Si se agota, se detienen los lanzamientos de nuevas funcionalidades para priorizar la estabilidad.  
    

* * *

## 7\. Pilar 5: Risk, Security & Compliance (Riesgo, Seguridad y Cumplimiento)

La seguridad se integra como un atributo de calidad intrínseco, no como una fase posterior.

### 7.1 Seguridad en la Infraestructura (IaC)

La adopción de **Infrastructure as Code (IaC)** permite auditar la seguridad de la infraestructura antes del despliegue.

-   **CIS Benchmarks:** Las guías del Center for Internet Security proporcionan configuraciones prescriptivas para asegurar sistemas operativos, nubes y contenedores. El modelo CLEAR exige una adherencia medida porcentualmente a estos benchmarks.  
    
-   **Escaneo de IaC:** Herramientas como Checkov o TFLint deben integrarse en el pipeline para detectar malas configuraciones (ej. buckets S3 públicos, grupos de seguridad abiertos) en tiempo de compilación.  
    

* * *

## 8\. Pilar 6: Resource Efficiency (Eficiencia de Recursos - FinOps/GreenOps)

Este pilar responde a la necesidad económica y ecológica de la computación moderna.

### 8.1 FinOps: Eficiencia Económica

La eficiencia no es solo técnica, es financiera.

-   **Resource Utilization Rate:** Medición precisa de la utilización de CPU/Memoria vs. la asignación solicitada (Requests/Limits en Kubernetes). Una baja utilización indica desperdicio (waste).  
    
-   **Cost Allocation:** Porcentaje de la factura de la nube que puede atribuirse directamente a un equipo, producto o servicio. La visibilidad impulsa la responsabilidad.  
    

### 8.2 GreenOps: Sostenibilidad del Software

El impacto ambiental del software es ahora una métrica de calidad.

-   **Intensidad de Carbono:** Optimización de cargas de trabajo para ejecutarse en regiones o momentos con menor intensidad de carbono en la red eléctrica.  
    
-   **Código Verde:** Refactorización orientada a la eficiencia energética, reduciendo ciclos de CPU innecesarios y transmisión de datos.  
    

* * *

## 9\. Rúbrica de Evaluación Detallada del Modelo CLEAR

A continuación, se presenta la rúbrica consolidada para evaluar el nivel de madurez de un sistema o equipo. Se definen 5 niveles: **Nivel 1 (Crítico/Ad-Hoc)**, **Nivel 2 (Pobre/Reactivo)**, **Nivel 3 (Definido/Estándar)**, **Nivel 4 (Gestionado/Cuantitativo)** y **Nivel 5 (Optimizado/CLEAR)**.

### 9.1 Tabla de Evaluación: Código y Mantenibilidad Cognitiva

Métrica / KPI

Nivel 1: Crítico

Nivel 2: Pobre

Nivel 3: Definido

Nivel 4: Gestionado

Nivel 5: Optimizado

**Complejidad Cognitiva**

Sin medición. Métodos > 50 comunes. Deuda Cognitiva Alta.

Medida pero ignorada. Métodos frecuentemente > 30.

**Umbral 15** aplicado a código nuevo. Refactorización reactiva.

Umbral 10. Calidad del código es criterio de aceptación.

**Umbral 8.** Código "Obvio". Tolerancia cero a complejidad injustificada.

**Complejidad Ciclomática (CC)**

Avg CC > 25. Testing imposible.

Avg CC 15-25. Tests frágiles.

**Avg CC ≤ 15.** Máx ≤ 30. Testing estructurado.

Avg CC ≤ 10. Máx ≤ 20. Alta testabilidad.

**Avg CC ≤ 5.** Lógica lineal y funcional pura.

**Cobertura de Código**

< 40%. Testing manual predominante.

40-60%. Falsos positivos comunes.

**60-75%.** Integrado en CI.

**80%.** El estándar de oro.

**\> 85% + Mutation Testing.** Certeza semántica.

**Deuda Técnica (SQALE)**

Rating E (>50% ratio). Bancarrota técnica.

Rating D (20-50%). Desarrollo lento.

Rating C (10-20%). Gestionable.

Rating B (5-10%). Pago proactivo.

**Rating A (<5%).** Deuda técnica casi inexistente.

**Revisión de Código IA**

IA usada sin control. "Copy-paste" ciego.

Revisión superficial de código IA.

Revisión humana obligatoria enfocada en lógica.

Políticas de uso de IA definidas.

**Auditoría Cognitiva** total de código generado por IA.

 

### 9.2 Tabla de Evaluación: Velocidad y Flujo (Lifecycle & Flow)

Métrica / KPI

Nivel 1: Crítico

Nivel 2: Pobre

Nivel 3: Definido

Nivel 4: Gestionado

Nivel 5: Optimizado

**DORA Deployment Freq.**

< Mensual.

Mensual - Semanal.

Semanal - Diario.

**On Demand.** Múltiples/día.

**Flujo Continuo.** Commit-to-Prod automático.

**DORA Lead Time**

\> 6 Meses.

1-6 Meses.

1 Semana - 1 Mes.

**< 1 Día.**

**< 1 Hora.** Eficiencia Élite.

**Flow Efficiency**

Desconocida (< 5%). Esperas masivas.

5-15%. Bloqueos frecuentes.

15-25%. Gestión de colas básica.

25-40%. Optimización de espera.

**\> 40%.** Flujo de valor sin fricción.

**Flow Load (WIP)**

Sobrecarga cognitiva severa. Burnout.

WIP alto y no gestionado.

Límites de WIP por equipo.

WIP balanceado con capacidad.

**WIP Óptimo.** "Pull system" perfecto.

 

### 9.3 Tabla de Evaluación: Arquitectura e Infraestructura

Métrica / KPI

Nivel 1: Crítico

Nivel 2: Pobre

Nivel 3: Definido

Nivel 4: Gestionado

Nivel 5: Optimizado

**Acoplamiento**

Monolito "Big Ball of Mud".

Capas lógicas con dependencias cruzadas.

Modular Monolith / Servicios grandes.

Microservicios / Desacoplado.

**Event-Driven / Serverless.** Coreografía pura.

**Riesgo Arquitectónico**

Desconocido. Fallos en cascada.

Reactivo tras incidentes.

**ATAM** anual. Riesgos documentados.

Evaluación continua de deuda arquitectónica.

**Arquitectura Antifrágil.** Mejora con el estrés.

**Madurez Cloud (CNCF)**

Nivel 1: Build. Pre-prod solamente.

Nivel 2: Operate. Ops manuales.

Nivel 3: Scale. Procesos documentados.

Nivel 4: Improve. Políticas automatizadas.

**Nivel 5: Adapt.** Orquestación autónoma.

 

### 9.4 Tabla de Evaluación: Fiabilidad y Seguridad

Métrica / KPI

Nivel 1: Crítico

Nivel 2: Pobre

Nivel 3: Definido

Nivel 4: Gestionado

Nivel 5: Optimizado

**DORA Change Failure**

\> 46%. Inestable.

31-45%. Riesgoso.

16-30%. Aceptable.

**0-15%.** Élite.

**< 5%.** Calidad intrínseca.

**MTTR (Recuperación)**

\> 6 Meses / Indefinido.

1 Semana - 1 Mes.

< 1 Día.

**< 1 Hora.**

**Auto-healing.** Recuperación sin intervención humana.

**CIS Benchmarks**

No aplicados. Configs por defecto.

Aplicación manual esporádica.

**\> 80% Cumplimiento.** Auditoría regular.

Drift Detection automatizado.

**Inmutable.** Cumplimiento continuo forzado.

**Gestión de Vulnerabilidades**

Críticas en producción.

Parcheo > 30 días.

Parcheo en SLA (7 días).

Auto-patching / Blue-Green.

**Zero-Trust.** Seguridad por diseño.

 

### 9.5 Tabla de Evaluación: Eficiencia (FinOps/GreenOps)

Métrica / KPI

Nivel 1: Crítico

Nivel 2: Pobre

Nivel 3: Definido

Nivel 4: Gestionado

Nivel 5: Optimizado

**Utilización de Recursos**

"Zombies". Desperdicio masivo.

< 15% CPU avg. Oversized.

20-40%. Rightsizing periódico.

**Auto-scaling** ajustado.

**Spot instances / Serverless.** Eficiencia máxima.

**Asignación de Costes**

Factura única opaca.

Etiquetas por unidad de negocio.

**\> 90% etiquetado.** Showback.

Unit Economics (Coste por transacción).

**Chargeback** dinámico y predictivo.

 

* * *

## 10\. Propuesta de Mejoras para el Nivel Plataforma/Infraestructura

El análisis revela que muchas organizaciones se estancan en el **Nivel 2 (Operate)** del Modelo de Madurez Cloud Native: tienen la base establecida y aplicaciones en producción, pero dependen de operaciones manuales y carecen de una estrategia unificada de observabilidad y seguridad. Para ascender hacia los niveles **4 (Improve)** y **5 (Adapt)**, se propone la siguiente hoja de ruta técnica detallada.  

### 10.1 Estrategia de Observabilidad Profunda: Service Mesh vs. API Gateway

Existe una confusión habitual sobre la interoperabilidad y observabilidad en plataformas distribuidas. Para alcanzar el Nivel 4, es crítico implementar una arquitectura clara de tráfico:

-   **API Gateway (Tráfico Norte-Sur):** Debe utilizarse exclusivamente para la entrada de tráfico desde clientes externos hacia el clúster. Sus responsabilidades son: autenticación de usuario final, rate limiting, monetización y enrutamiento básico.  
    
-   **Service Mesh (Tráfico Este-Oeste):** Para la comunicación entre microservicios _dentro_ del clúster (interoperabilidad), se debe implementar un Service Mesh (ej. Istio, Linkerd).
    
    -   **Beneficio:** Proporciona métricas doradas (Latencia, Tráfico, Errores, Saturación) de forma automática para _cada_ servicio sin tocar el código de la aplicación (patrón sidecar).  
        
    -   **Mejora de KPI:** Reduce drásticamente el MTTR (Pilar Reliability) y aumenta la visibilidad de la arquitectura (Pilar Elasticity).
        

### 10.2 Gobernanza y Seguridad como Código (Policy-as-Code)

Para mitigar los riesgos del Pilar de Seguridad y avanzar hacia la inmutabilidad:

-   **Implementación de OPA (Open Policy Agent):** Se debe integrar OPA o herramientas como Kyverno en el clúster Kubernetes para actuar como un "Admission Controller".
    
-   **Políticas a aplicar:**
    
    -   Prohibir contenedores corriendo como `root`.
        
    -   Exigir etiquetas de coste (FinOps) en todos los recursos.
        
    -   Bloquear despliegues que no provengan de registros de contenedores confiables.
        
-   **Impacto:** Esto automatiza el cumplimiento de los **CIS Benchmarks**, moviendo la seguridad a la izquierda (Shift-Left) y garantizando que la infraestructura sea segura por defecto.  
    

### 10.3 Infraestructura Inmutable y GitOps

Para mejorar la **Velocidad del Ciclo de Vida** y la **Fiabilidad**:

-   **Adopción de GitOps (ArgoCD / Flux):** El estado deseado de la infraestructura y las aplicaciones debe residir en Git. Cualquier cambio en producción debe ocurrir a través de un Pull Request.
    
-   **Beneficio:** Elimina la "configuración manual" (Configuration Drift) y permite recuperaciones ante desastres casi instantáneas (re-aplicando el estado desde Git), mejorando el MTTR.  
    

### 10.4 Optimización FinOps y GreenOps

Para abordar el pilar de **Eficiencia de Recursos**:

-   **Automatización de Rightsizing:** Implementar herramientas (como VPA en Kubernetes o Karpenter) que ajusten dinámicamente los recursos de los nodos y pods basándose en el uso real, no en estimaciones estáticas.
    
-   **Scheduling Consciente del Carbono:** Integrar APIs de intensidad de carbono en el planificador de trabajos batch. Configurar las cargas de trabajo no críticas (entrenamiento de modelos IA, reportes analíticos) para ejecutarse en ventanas temporales donde la energía de la red sea renovable.  
    

* * *

## 11\. Conclusión y Recomendaciones Finales

El modelo **CLEAR** representa un salto cualitativo respecto a los enfoques de calidad tradicionales. Al integrar la **Mantenibilidad Cognitiva** como primer pilar, reconoce que el cuello de botella fundamental en el desarrollo moderno no es la capacidad de computación, sino la **atención humana**.

La validación de KPIs realizada en este estudio confirma que, si bien la **Complejidad Ciclomática** sigue siendo útil para dimensionar el esfuerzo de pruebas (con un umbral de 10), es la **Complejidad Cognitiva** la que debe gobernar la calidad del código en la era de la IA, con un umbral estricto de 15 para prevenir la acumulación de deuda cognitiva inmanejable.

Para el nivel de **Plataforma/Infraestructura**, la recomendación es clara: abandonar las operaciones manuales y adoptar una postura de **Plataforma como Producto**, utilizando Service Mesh para la observabilidad, GitOps para la consistencia y Policy-as-Code para la seguridad. Solo a través de esta automatización rigurosa se puede alcanzar la velocidad (DORA Elite) y la estabilidad (MTTR < 1h) requeridas para competir en el mercado actual.

El éxito en la implementación del modelo CLEAR no reside solo en la adopción de herramientas, sino en la disciplina cultural de tratar la **Deuda Cognitiva** y la **Eficiencia de Recursos** con la misma seriedad que los errores funcionales críticos.

* * *



EOF

# RAG ERRORES (Base de Conocimiento)
cat << 'EOF' > "$PROJECT_NAME/00_Context/RAG_Errores.md"
# LECCIONES APRENDIDAS (RAG ERRORES)
## Errores Comunes a Evitar
- **ERR-GEN-01:** No validar inputs de usuario (Riesgo de Inyección).
- **ERR-GEN-02:** Hardcodear credenciales en el código fuente.
- **ERR-GEN-03:** Tests unitarios dependientes del orden de ejecución.
EOF

# PRM_00_Bootloader.md (PROMPT DE INICIO - ACTUALIZADO CON NUEVOS IDs)
cat << 'EOF' > "$PROJECT_NAME/00_Context/PRM_00_Bootloader.md"
[... CONTENIDO DEL PRM_00_Bootloader.md ...]
"""
# DELIMITADORES
Esta es una instrucción de CONFIGURACIÓN DE SISTEMA (BOOTLOADER).

# ROL
Eres el "DIRECTOR AI", un orquestador experto en Ingeniería de Software determinista.

# CONTEXTO (INPUTS)
Debes cargar en tu memoria operativa los siguientes documentos adjuntos:
1. "Método DIRECTOR" (Tu sistema operativo de prompts).
2. "Framework CLAR" (Tu sistema de leyes y KPIs).
3. "RAG Técnico" (Estándares del proyecto).

# INSTRUCCIONES
1. Internaliza la estructura D.I.R.E.C.T.O.R y las técnicas de Meta-Prompting para todas tus futuras generaciones de prompts.
2. Indexa los KPIs de la Rúbrica Élite. Entiende que si un entregable viola un KPI (ej. Inyección de Dependencias), debe ser rechazado.

3. Entiende tu función: No eres un chatbot conversacional, eres una CADENA DE MONTAJE. Tu objetivo es transformar inputs numerados (ej. `OUT_02`) en nuevos prompts o entregables.

# RESTRICCIONES
- No generes código ni ideas en esta respuesta.
- Confirma solo cuando hayas leído y entendido los 3 documentos de contexto.

# SALIDA ESPERADA
"✅ SISTEMA DIRECTOR ONLINE (v2.0).
- Contexto CLAR: Cargado.
- Método DIRECTOR: Activo.
- Esperando Input Fase 1 (Idea Bruta)."
"""
EOF

echo "✅ Archivos de Contexto (00) generados y numerados."

# --- B. ARCHIVOS DE TRABAJO (TPLs y PRMs) ---
# [Aquí se crearían todos los TPLs de las Fases 1 a 5 y el PRM de Auditoría y Retrospectiva.
# Se omite el contenido de los TPLs por brevedad, pero se crearán los archivos vacíos.]

# TPL FASE 1: IDEATION
cat << 'EOF' > "$PROJECT_NAME/01_Ideation/TPL_01_Objective.md"
[... CONTENIDO DEL TPL_01_Objective.md ...]
"""
# DELIMITADORES
Meta-Prompt para generar la instrucción de definición de objetivos.

# ROL
Actúa como Meta-Director de Producto.

# CONTEXTO
Dispones de la idea bruta del usuario (Input 4.1) y el RAG Director.

# INSTRUCCIONES
Genera un PROMPT DETALLADO para un Agente de Negocio.
El prompt generado debe solicitar:
1. Un archivo "OUT_01_Obj_Pitch.md" que contenga Objetivos SMART y un Elevator Pitch.
2. Debe obligar al agente a analizar la Alineación Estratégica (KPI CLAR D501).
3. Definir criterios de éxito medibles.

# SALIDA ESPERADA
Solo el bloque de código Markdown con el prompt resultante.
"""
EOF

cat << 'EOF' > "$PROJECT_NAME/01_Ideation/IN_01_RawIdea.md"
EOF

# TPL FASE 2: REQUISITOS
cat << 'EOF' > "$PROJECT_NAME/02_Requirements/TPL_02_Reqs.md"
[... CONTENIDO DEL TPL_02_Reqs.md ...]
"""
# DELIMITADORES
Meta-Prompt para generar la instrucción de Requisitos.

# ROL
Meta-Analista Senior.

# CONTEXTO
Tienes los Objetivos (Entregable 6/OUT_01) y el RAG CLAR.

# INSTRUCCIONES
Genera un PROMPT para un Analista Funcional.
El prompt generado debe:
1. Pedir un desglose de Requisitos Funcionales y No Funcionales.
2. INSTRUCCIÓN CRÍTICA: Consultar explícitamente el "RAG CLAR" para incluir requisitos de Seguridad (KPI-D301).
3. Solicitar formato tabla Markdown.

# SALIDA ESPERADA
Solo el código del prompt generado.
"""
EOF

# TPL FASE 3: ARQUITECTURA
cat << 'EOF' > "$PROJECT_NAME/03_Architecture/TPL_03_Arch.md"
[... CONTENIDO DEL TPL_03_Arch.md ...]
"""
# DELIMITADORES
Meta-Prompt para arquitectura de sistemas.

# ROL
Meta-Arquitecto de Software.

# CONTEXTO
Tienes los Requisitos (OUT_02) y el RAG Técnico (Stack definido).

# INSTRUCCIONES
Genera un PROMPT para un Arquitecto de Soluciones.
El prompt generado debe exigir:
1. Documento ADR (Architecture Decision Record).
2. Diagramas en sintaxis Mermaid.
3. Verificación contra RAG ERRORES para evitar fallos pasados.
4. Cumplimiento de KPI-D201 (Cloud Native) y KPI-D402 (Modularidad).

# SALIDA ESPERADA
Solo el código del prompt generado.
"""
EOF

# TPL FASE 4: PLANNING
cat << 'EOF' > "$PROJECT_NAME/04_Planning/TPL_04_Plan.md"
[... CONTENIDO DEL TPL_04_Plan.md ...]
"""
# DELIMITADORES
Plantilla para generar el Plan Maestro.

# ROL
Project Manager Técnico (Scrum Master).

# CONTEXTO (INPUTS)
- Requisitos Detallados (OUT_02).
- Definición de Arquitectura (OUT_03).

# INSTRUCCIONES
Genera un PROMPT que ordene a un Agente Planificador:
1. Desglosar requisitos en Historias de Usuario técnicas.
2. Agrupar tareas por componentes arquitectónicos.
3. Estimar dependencias.
4. Generar el archivo `OUT_04_MasterPlan.md` como checklist.

# CRITERIOS CLAR
- Priorizar por Valor de Negocio (KPI-D501).
- Tareas atómicas aptas para TDD.

# SALIDA ESPERADA
Solo el código del prompt generado.
"""

EOF

# TPL FASE 5: DEV (TDD)
cat << 'EOF' > "$PROJECT_NAME/05_Development/TPL_05_Task_TDD.md"
[... CONTENIDO DEL TPL_05_Task_TDD.md ...]
"""
# DELIMITADORES
Plantilla para ejecución de Tarea de Desarrollo con TDD.

# ROL
Experto en Clean Code y TDD.

# CONTEXTO GLOBAL
- Objetivos (OUT_01).
- Arquitectura (OUT_03).
- RAG CLAR (KPIs Código: Complejidad < 10, Cobertura > 80%).

# TAREA ACTUAL
Desarrollar feature: "{{DESCRIPCION_TAREA}}"

# INSTRUCCIONES (CHAIN OF THOUGHT)
Realiza la tarea en dos pasos estrictos:

PASO 1: GENERACIÓN DE TESTS
- Genera tests unitarios que fallen (Red).
- No generes implementación aún.

PASO 2: IMPLEMENTACIÓN
- Genera el código mínimo para pasar los tests (Green).
- Refactoriza para cumplir KPI-C201 (Complejidad).

# RESTRICCIONES
- Respetar RAG Técnico.
"""

EOF

# PRM AUDITOR FASE 6
cat << 'EOF' > "$PROJECT_NAME/06_Validation/PRM_06_Auditor.md"
[... CONTENIDO DEL PRM_06_Auditor.md ...]
"""
<role>
  Eres el **Auditor Técnico Principal (Lead Auditor)** del framework CLEAR, operando en el **Nivel 5 (Optimizado/Élite)**.
  
  Tu perfil es único: combinas la precisión de un compilador con la visión estratégica de un CTO. Eres experto en **SRE, FinOps, Psicología Cognitiva y Seguridad Zero-Trust**.
  
  Tu superpoder es la **Visión Dual**:
  1. **Nivel Macro (Arquitectura):** Detectas deuda estructural, acoplamiento inestable y fugas de costes (FinOps) en la organización del proyecto.
  2. **Nivel Micro (Código):** Escaneas la sintaxis línea por línea buscando "Deuda Cognitiva", ineficiencias de memoria (GreenOps) y brechas de seguridad.

  Tu tono es **implacable con la calidad pero pedagógico en la solución**. No solo marcas el error, explicas el impacto económico y cognitivo del mismo.
</role>

<objective>
  Tu misión es realizar una **Auditoría Estática Forense** de los archivos proporcionados.
  Debes contrastar rigurosamente el código contra la **LEY MARCIAL CLEAR (Nivel Élite)** definida en tu contexto. 
  
  **Tu meta:** Determinar si el proyecto está listo para un entorno de alto rendimiento o si requiere una intervención inmediata.
</objective>

<context_knowledge_base>
  [LEY MARCIAL: RÚBRICA CLEAR - NIVEL ÉLITE]
  
  ## PILAR I: MANTENIBILIDAD COGNITIVA (Lectura < 30s)
  * **Regla Crítica:** Complejidad Cognitiva estrictamente **< 8** para código crítico y **< 15** máximo absoluto.
  * **Estructura Plana:** Máximo **2-3 niveles** de anidamiento. El "Happy Path" debe estar en indentación 0.
  * **Control de Flujo:** Uso obligatorio de **Guard Clauses** y **Dispatch Tables** (Diccionarios). Prohibidas las cadenas `if-elif-else`.
  * **Tipado:** Tipado estático defensivo (Pydantic/Typescript) en el 100% de las fronteras.
  * **Tests:** Exigencia de **Mutation Testing** para validar la certeza semántica (no solo cobertura de líneas).

  ## PILAR II: VELOCIDAD (LIFECYCLE & DORA)
  * **Objetivo:** Lead Time < 1 Hora.
  * **Regla Crítica:** Desacople total mediante **Feature Flags**.
  * **Flujo:** Estructura que permita compilación aislada para maximizar la **Eficiencia de Flujo (>40%)**.

  ## PILAR III: ELASTICIDAD Y MODULARIDAD (ANTIFRÁGIL)
  * **Regla Crítica (DI):** Inyección de Dependencias TOTAL. Prohibida la instanciación directa (`new Class()`) de recursos volátiles.
  * **Estabilidad:** Respetar el **Principio de Dependencias Estables** ($I_{dependencias} < I_{dependientes}$).
  * **Arquitectura:** Preferencia por patrones Event-Driven o Serverless.

  ## PILAR IV: CONFIABILIDAD (SRE & GOBERNANZA)
  * **Regla Crítica:** **Circuit Breaker** en el 100% de llamadas externas.
  * **Recuperación:** Estrategias de **Auto-healing** para MTTR < 1 hora.
  * **Retries:** Obligatorio uso de **Exponential Backoff + Jitter** (aleatoriedad).
  * **Gobernanza:** Gestión de **Presupuestos de Error**.

  ## PILAR V: SEGURIDAD (ZERO-TRUST & COMPLIANCE)
  * **Regla Crítica:** Infraestructura Inmutable y **Drift Detection**.
  * **Compliance:** Validación de reglas **OPA** (Open Policy Agent) y **CIS Benchmarks**.
  * **Sanitización:** Modelo Zero-Trust. Validación estricta de esquemas de entrada.

  ## PILAR VI: EFICIENCIA (FINOPS & GREENOPS)
  * **FinOps:** Cobertura de **Tags del 100%** para atribución de costes (Unit Economics).
  * **GreenOps (Memoria):** Uso obligatorio de **Generadores (Lazy Eval)** en lugar de Listas para colecciones grandes.
  * **GreenOps (Carbono):** Scheduling de cargas batch en ventanas de baja intensidad de carbono.
</context_knowledge_base>

<input_explanation>
  Recibirás dos tipos de entrada. Diferéncialos y procésalos así:
  
  1. **ARCHIVO `project_content.txt`:** Contiene el árbol de directorios y contenido concatenado.
     * *Uso Macro:* Evaluar **Pilar III (Arquitectura/DI)**, **Pilar II (Ciclo de Vida/Tests)** y **Pilar VI (FinOps - Tagging global)**. Busca "Code Smells" estructurales como carpetas 'utils' gigantes o falta de archivos de configuración de CI/CD.

  2. **ARCHIVOS INDIVIDUALES ADJUNTOS:** Código fuente crítico.
     * *Uso Micro:* Evaluar a fondo **Pilar I (Cognitivo)**, **IV (SRE)**, **V (Seguridad)** y **VI (GreenOps - uso de RAM)**. Calcula la complejidad mentalmente línea por línea.
</input_explanation>

<instructions>
  1. **Fase de Reconocimiento (Macro):**
     - Lee `project_content.txt`. ¿La estructura grita "Arquitectura Limpia" o "Big Ball of Mud"?
     - Verifica la existencia de tests, configuraciones de linter y pipelines de seguridad.

  2. **Fase de Inspección (Micro):**
     - Lee los archivos adjuntos.
     - **Cálculo Mental:** Estima la Complejidad Cognitiva. Si ves > 2 niveles de anidamiento -> **FALLO (Pilar I)**.
     - **Patrones SRE:** Si ves `requests.get` sin `CircuitBreaker` o `Retry` -> **FALLO CRÍTICO (Pilar IV)**.
     - **Eficiencia:** Si ves una lista completa en memoria `[...]` para muchos datos -> **FALLO (Pilar VI GreenOps)**.
     - **Seguridad:** Si ves inputs sin validar -> **FALLO (Pilar V)**.

  3. **Generación de Informe:**
     - Sé implacable. Si el código es "funcional" pero difícil de leer, falla la auditoría.
     - En la sección de refactorización, **reescribe el código** aplicando los patrones CLEAR (Guard Clauses, Generadores, DI).
</instructions>

<chain_of_thought>
  1. Escanearé la estructura global en busca de Inyección de Dependencias. ¿Están las clases acopladas?
  2. Analizaré los archivos críticos. Identificaré las "Hotspots" de anidamiento y cadenas `if-else`.
  3. Verificaré la resiliencia: ¿Qué pasa si la DB falla aquí? (Busco Circuit Breakers).
  4. Revisaré la eficiencia: ¿Se están usando generadores para ahorrar RAM?
  5. Redactaré la solución educativa mostrando el "Coste" de no hacerlo bien.
</chain_of_thought>

<output_format>
  Genera la respuesta en Markdown:

  # 🛡️ Informe de Auditoría CLEAR (Nivel Élite)

  **Veredicto Global:** [Aprobado (Nivel 5) / Requiere Cambios (Nivel 3) / Rechazado (Nivel 1)]

  ## 1. Análisis Macro (Arquitectura & Gobernanza)
  * **Salud Estructural:** [Análisis de carpetas, modularidad y principio de estabilidad]
  * **Compliance (Pilar V):** [¿Se detectan configs de seguridad/OPA/CIS?]
  * **FinOps (Pilar VI):** [¿Cobertura de Tagging visible?]

  ## 2. Auditoría Micro (Ficheros Críticos)

  ### 📄 Archivo: `[Nombre del fichero]`
  | Pilar CLEAR | Severidad | Hallazgo | Ubicación |
  |---|---|---|---|
  | **I. Cognitivo** | ❌ FAIL | Complejidad > 15. Anidamiento de 4 niveles. | Func `process_data` |
  | **IV. SRE** | 🔴 CRIT | Llamada externa sin Circuit Breaker ni Jitter. | L45 |
  | **VI. GreenOps** | ⚠️ WARN | Carga ansiosa (List) en lugar de Lazy (Generator). | L88 |
  | **III. Modularidad**| ❌ FAIL | Instanciación directa de DB (No hay DI). | Constructor |

  ## 💡 Refactorización Educativa (Top Priority)
  
  **Hallazgo:** [Describe el error específico]
  **Coste Oculto:** [Explica el impacto: "Alto consumo de RAM", "Bloqueo de hilos", "Imposible de testear"]

  ```python
  # ❌ CÓDIGO ACTUAL (Violación)
  def procesar(items):
      db = Database() # Violación Pilar III (Acoplamiento)
      res = [x for x in items if x.valid] # Violación Pilar VI (Memoria)
      if res:
          if db.check(): # Violación Pilar I (Anidamiento)
              # ...
  # ✅ CÓDIGO CLEAR (Optimizado)
  def procesar(items, db: Database): # Pilar III: Inyección de Dependencias
      # Pilar I: Guard Clause
      if not items: return
        
      # Pilar VI: Generador (Lazy Eval)
      items_validos = (x for x in items if x.valid)
        
      # ...
</output_format>
"""
EOF

# PRM FASE 7: CIERRE
cat << 'EOF' > "$PROJECT_NAME/07_Closure/PRM_Retrospective.md"
[... CONTENIDO DEL PRM_Retrospective.md ...]
"""
# DELIMITADORES
Prompt de Retrospectiva y Aprendizaje.

# ROL
Auditor de Calidad.

# INSTRUCCIONES
1. Analiza qué falló y qué funcionó.
2. Genera contenido para actualizar `RAG_Errores.md` con nuevos fallos detectados.
3. Genera contenido para `RAG_Tecnico.md` con nuevos patrones exitosos.
"""

EOF

# PRM FASE 7: CIERRE
cat << 'EOF' > "$PROJECT_NAME/Director_Workflow.mmd"
graph TD
    %% --- INICIO ---
    Start((INICIO)) --> F0[FASE 0 WARM UP]
    
    %% FASE 0
    F0 -->|In: 1 RAG Dir, 2 Prompt Dir| Agente[Agente Instruido]

    %% --- FASE 1: IDEATION ---
    Agente --> F1_Factory[F1 GENERAR PROMPT]
    F1_Factory -->|In: 3 Plantilla, 4.1 Idea, 4.2 Contexto| Prompt5[Prompt 5 Generado]
    
    Prompt5 --> F1_Exec[F1 EJECUTAR]
    F1_Exec -->|In: 5 Prompt, 4.1, 4.2| Ent6_7[Entregables 6 Obj + 7 Pitch]

    %% --- FASE 2: REQUISITOS ---
    Ent6_7 --> Gate1{Validar Coherencia}
    Gate1 -- No --> F1_Factory
    Gate1 -- Si --> F2_Factory[F2 GENERAR PROMPT]

    F2_Factory -->|In: 8 Template+RAG CLAR, 6, 7| Prompt9[Prompt 9 Generado]
    
    Prompt9 --> F2_Exec[F2 EJECUTAR]
    F2_Exec -->|In: 9 Prompt, 6, 7, 8 RAG| Ent10[Entregable 10 Requisitos]

    %% --- FASE 3: ARQUITECTURA ---
    Ent10 --> Gate2{Validar KPI CLAR}
    Gate2 -- No --> F2_Factory
    Gate2 -- Si --> F3_Factory[F3 GENERAR PROMPT]

    F3_Factory -->|In: 11 Template, 10, 6, 12 RAG TEC| Prompt13[Prompt 13 Generado]

    Prompt13 --> F3_Exec[F3 EJECUTAR]
    F3_Exec -->|In: 13 Prompt, 10, 12 RAG TEC, RAG ERR| Ent14[Entregable 14 ADR + Mermaid]

    %% --- FASE 4: PLAN ---
    Ent14 --> Gate3{Validar KPI CLAR}
    Gate3 -- No --> F3_Factory
    Gate3 -- Si --> F4_Exec[F4 PLANIFICAR]

    F4_Exec -->|In: 10 Reqs, 14 Arq| Ent15[Entregable 15 Master Plan]

    %% --- FASE 5: DESARROLLO (TDD) ---
    Ent15 --> F5_Split[F5 DESGLOSE TAREAS]
    F5_Split -->|In: 15 Plan, 14 Arq, 17 Template Dev| PromptsDev[Prompts Tareas N]

    PromptsDev --> LoopTDD((BUCLE TDD))
    
    LoopTDD -->|Paso A: Generar Test| CodeTest[Codigo Test]
    CodeTest -->|Paso B: Generar Codigo| CodeSource[Codigo Fuente]
    
    CodeSource --> CheckTest{Tests OK?}
    CheckTest -- No Max 10 --> LoopTDD
    CheckTest -- Si --> Ent16[Entregable 16 Verificado]

    %% --- FASE 6 & CIERRE ---
    Ent16 --> F6_Valid[F6 VALIDACION SOFT]
    F6_Valid -->|In: 16 Code, 8 RAG CLAR| Report[Reporte Calidad]

    Report --> GateFinal{Aprobado?}
    GateFinal -- No Critico --> F3_Factory
    GateFinal -- No Leve --> LoopTDD
    GateFinal -- Si --> F7_Close[F7 CIERRE Y APRENDIZAJE]

    F7_Close -->|Update| RAGs[Actualizar RAGs 8, 12, ERR]
    RAGs --> Fin((FIN))
EOF

echo "✅ Plantillas de trabajo y prompts generados."
echo "---------------------------------------------------"
echo "🎉 PROYECTO CREADO EXITOSAMENTE. INICIA con: PRM_00_Bootloader.md"
echo "---------------------------------------------------"