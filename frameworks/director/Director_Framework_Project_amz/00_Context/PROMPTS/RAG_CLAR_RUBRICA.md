# MARCO DE REFERENCIA CLEAR (Knowledge Base)

## PILAR I: MANTENIBILIDAD COGNITIVA
**Objetivo:** Minimizar el esfuerzo mental para entender el código.
**Reglas:**
1.  **KPI Maestro:** Complejidad Cognitiva (Sonar) **< 15** por función (< 8 en código crítico).
2.  **No Anidamiento Profundo:** Máximo 2-3 niveles de indentación. Usar **Guard Clauses** (Retornos tempranos) para aplanar "Arrows of Code".
3.  **No if-elif Chains:** Reemplazar cadenas largas de `if/elif` con **Diccionarios (Dispatch Tables)** para complejidad O(1).
4.  **Validación de Tipos:** Uso obligatorio de tipado estático (ej. Pydantic en Python) en fronteras de entrada.

## PILAR II: VELOCIDAD DEL CICLO DE VIDA (LIFECYCLE VELOCITY)
**Objetivo:** Entrega continua y segura.
**Reglas:**
1.  **Desacople de Despliegue:** Uso obligatorio de **Feature Flags** (decoradores o clientes) para separar deploy de release.
2.  **Métricas DORA:** El código debe estar estructurado para facilitar despliegues pequeños y frecuentes.

## PILAR III: ELASTICIDAD Y MODULARIDAD
**Objetivo:** Bajo acoplamiento.
**Reglas:**
1.  **Inyección de Dependencias (DI):** Prohibido instanciar dependencias "hardcoded" dentro de clases (Anti-patrón: `self.db = PostgresDB()`). Usar inyección en constructor o contenedores de DI.
2.  **Principio de Dependencias Estables:** Los módulos inestables deben depender de los estables, nunca al revés.

## PILAR IV: DISPONIBILIDAD Y CONFIABILIDAD
**Objetivo:** Resiliencia ante fallos (SRE).
**Reglas:**
1.  **Circuit Breaker:** Obligatorio en llamadas a servicios externos (HTTP/DB) para evitar fallos en cascada.
2.  **Retries Inteligentes:** Uso de *Exponential Backoff* con *Jitter* en reintentos. Nunca reintentos inmediatos infinitos.

## PILAR V: RIESGO Y SEGURIDAD (SECURE BY DESIGN)
**Objetivo:** Compliance as Code.
**Reglas:**
1.  **Validación de Entradas:** No confiar en `raw_data`. Validar esquemas antes de procesar.
2.  **Infraestructura:** Bloqueo de recursos sin encriptación (ej. S3 buckets sin cifrado server-side).

## PILAR VI: EFICIENCIA DE RECURSOS (FINOPS/GREENOPS)
**Objetivo:** Código sostenible y económico.
**Reglas:**
1.  **GreenOps (Memoria):** Preferir **Generadores** (Lazy Evaluation) sobre Listas completas para procesamiento de datos grandes.
    * *Mal:* `[x*2 for x in range(1000000)]`
    * *Bien:* `(x*2 for x in range(1000000))`
2.  **FinOps (Tagging):** Todo recurso cloud creado programáticamente debe tener etiquetas de coste asociadas.