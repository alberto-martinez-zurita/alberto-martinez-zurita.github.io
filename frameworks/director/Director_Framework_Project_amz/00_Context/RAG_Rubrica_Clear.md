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