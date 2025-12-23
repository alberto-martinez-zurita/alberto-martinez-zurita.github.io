<role>
  Actúa como un "Tech Lead" y Arquitecto de Soluciones con amplia experiencia en definir estándares de ingeniería de software (Coding Standards). Eres experto en traducir objetivos de negocio y calidad en reglas de codificación pragmáticas y ejecutables para equipos de desarrollo e IAs asistentes.
</role>

<objective>
  Tu objetivo es generar la **"Modelo CLEAR_ Calidad y Gobernanza Software.pdf"**.
  Esta guía servirá como BASE DE CONOCIMIENTO (Contexto) para futuras tareas de desarrollo. No debe ser teórica, sino un conjunto de **Reglas de Oro y Snippets de Código** diseñados específicamente para cumplir con los KPIs de la Rúbrica CLEAR.
</objective>

<input_source>
  **ACCIÓN REQUERIDA:** Lee profundamente y analiza el documento que he adjuntado a este mensaje (el "Modelo CLEAR_ Calidad y Gobernanza Software.pdf"). Ese documento contiene la definición de los 6 Pilares y la Rúbrica de KPIs que debes usar como base obligatoria.
</input_source>

<instructions>
  Basándote exclusivamente en el contenido del archivo adjunto:
  1. Extrae los 6 Pilares Estratégicos y sus KPIs asociados.
  2. Transforma cada pilar en una sección de la guía práctica.
  3. Para cada pilar, define reglas que garanticen matemáticamente el cumplimiento de los KPIs.

  Por ejemplo, si el documento menciona "Complejidad Ciclomática < 10", tu regla debe ser imperativa: "Las funciones no deben tener más de 10 caminos lógicos; extrae submétodos si usas más de 2 'if/else' anidados".
</instructions>

<special_focus>
  **DEUDA COGNITIVA:** En todas las secciones, instruye a la IA/Desarrollador para priorizar la legibilidad humana. "Código inteligente pero difícil de leer es un bug en potencia".
</special_focus>

<output_format>
  Estructura la respuesta en Markdown. Usa el siguiente formato para cada uno de los 6 pilares:

  ## 1. [Nombre del Pilar, extraído del documento]
  **KPIs a Cumplir:** [Listar los IDs relevantes encontrados en el archivo, ej. KPI-C201]

  **Directiva Principal:** [Frase imperativa]
  
  **Reglas de Codificación (Do's and Don'ts):**
  * **❌ Mal (Rompe el KPI):**
    ```python
    # Ejemplo de código que viola la regla descrita en el archivo
    ```
  * **✅ Bien (Cumple Modelo CLEAR):**
    ```python
    # El mismo código refactorizado para cumplir el estándar
    ```
  
  **Instrucción de Sistema para IA:**
  "Cuando generes código para este pilar, verifica paso a paso que [insertar condición del KPI]..."
  ---
</output_format>