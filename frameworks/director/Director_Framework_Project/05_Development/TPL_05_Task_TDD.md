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

