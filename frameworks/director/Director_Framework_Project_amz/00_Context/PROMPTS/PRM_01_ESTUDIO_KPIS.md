<role>
  Actúa como un "Tech Lead" y Arquitecto de Soluciones con amplia experiencia en definir estándares de ingeniería de software (Coding Standards). Eres experto en traducir objetivos de negocio y calidad en reglas de codificación pragmáticas y ejecutables para equipos de desarrollo e IAs asistentes.
</role>

<objective>
  Tu objetivo es generar la **"Guía Maestra de Desarrollo Bajo el Modelo CLEAR"**.
  Esta guía servirá como BASE DE CONOCIMIENTO (Contexto) para futuras tareas de desarrollo. No debe ser teórica, sino un conjunto de **Reglas de Oro y Snippets de Código** diseñados específicamente para cumplir con los KPIs de la Rúbrica CLEAR.
</objective>

<input_context>
  Toma como base el siguiente "Estudio del Modelo CLEAR" que acabamos de generar:
  
  """
  [PEGAR AQUÍ EL RESULTADO COMPLETO DEL PROMPT 1]
  """
</input_context>

<instructions>
  Transforma cada uno de los 6 Pilares del estudio en una sección de la guía práctica.
  Para cada pilar, debes definir reglas que garanticen matemáticamente el cumplimiento de los KPIs mencionados en el input.

  Por ejemplo, si el KPI es "Complejidad Ciclomática < 10", la regla debe ser: "Las funciones no deben tener más de 10 caminos lógicos; extrae submétodos si usas más de 2 'if/else' anidados".
</instructions>

<special_focus>
  **DEUDA COGNITIVA:** En todas las secciones, instruye a la IA/Desarrollador para priorizar la legibilidad humana. "Código inteligente pero difícil de leer es un bug en potencia".
</special_focus>

<output_format>
  Estructura la respuesta en Markdown. Usa el siguiente formato para cada pilar:

  ## 1. [Nombre del Pilar, ej. Mantenibilidad]
  **KPIs a Cumplir:** [Listar los IDs relevantes, ej. KPI-C201, KPI-C402]

  **Directiva Principal:** [Frase imperativa]
  
  **Reglas de Codificación (Do's and Don'ts):**
  * **❌ Mal (Rompe KPI-C201):**
    ```python
    # Ejemplo de código con alta complejidad, nombres de variables oscuros (x, y) 
    # y lógica anidada profunda que genera Deuda Cognitiva.
    ```
  * **✅ Bien (Cumple Modelo CLEAR):**
    ```python
    # El mismo código refactorizado: funciones pequeñas, nombres descriptivos,
    # manejo de errores explícito.
    ```
  
  **Instrucción de Sistema para IA:**
  "Cuando generes código para este pilar, verifica paso a paso que la complejidad no exceda 10 y que las variables expliquen su propósito."
  ---
</output_format>