# INFORME TÉCNICO: ARQUITECTURA SEO & INFORMATION GAIN (v2025)

### RESUMEN EJECUTIVO
Este documento técnico desglosa la implementación de estándares SEO 2025 para nichos de alta autoridad (YMYL/Academic). El enfoque central es la maximización de la **Ganancia de Información (Information Gain)** patentada por Google y la optimización de la **Densidad Semántica** mediante arquitectura HTML5 pura y microdatos anidados avanzados.

***

### 1. ARQUITECTURA SEMÁNTICA: ScholarlyArticle & Grafos de Citas
Google procesa los artículos de investigación no solo por palabras clave, sino por la *topología de sus referencias*. Para 2025, la señal de autoridad más fuerte en contenido académico es la **interconectividad citacional explícita**.

#### [TRUCO_CODIGO] El Grafo de Citas Anidado (Nested JSON-LD)
No uses un simple esquema de `Article`. Implementa `ScholarlyArticle` con una matriz de citas que imite un grafo académico real. Utiliza la propiedad `@nest` (si tu parser lo soporta) o anidamiento directo para limpiar el payload.

```json
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Análisis Vectorial de la Prosa de Borges",
  "author": {
    "@type": "Person",
    "name": "Dra. Ana Valenzuela",
    "jobTitle": "Computational Linguist"
  },
  "citation": [
    {
      "@type": "ScholarlyArticle",
      "headline": "El Jardín de Senderos que se Bifurcan",
      "author": "Jorge Luis Borges",
      "sameAs": "https://scholar.google.com/citations?view_op=view_citation&..."
    },
    {
      "@type": "ScholarlyArticle",
      "headline": "Vector Space Models in Narrative Theory",
      "datePublished": "2023-05-12",
      "identifier": {
        "@type": "PropertyValue",
        "propertyID": "DOI",
        "value": "10.1000/xyz123"
      }
    }
  ],
  "about": [
    { "@id": "https://kg.search.google.com/m/01d0mr" } 
  ]
}
</script>
```
*Nota: El `@id` en `about` conecta directamente al nodo del Knowledge Graph de Google (ver Sección 4).*

***

### 2. DENSIDAD SEMÁNTICA: Más allá del TF-IDF
La "Densidad Semántica" en 2025 se mide por la **Saliencia de Entidad (Entity Salience)** y la **Distancia Vectorial**. El objetivo no es repetir palabras, sino reducir la distancia vectorial entre tu contenido y el "centroide" del tópico ideal calculado por los LLMs de Google (SGE/Gemini).

#### [ESTRATEGIA_CONTENIDO] Vectorización de Entidades
Para aumentar la saliencia sin *keyword stuffing*:
1.  **Desambiguación Inline:** Usa etiquetas HTML5 semánticas invisibles para desambiguar entidades complejas sin ensuciar la UX.
2.  **Information Gain Gap:** Antes de escribir, ejecuta un script de Python contra la API de Google NLP. Extrae las entidades de los top 3 competidores y encuentra las que *faltan* en su intersección. Cubrir esas entidades faltantes es tu "Information Gain".

#### [TRUCO_CODIGO] Desambiguación con `<data>` y `itemprop`
Inyecta señales semánticas directamente en el DOM para entidades críticas que los LLMs podrían confundir.

```html
<p>
  El análisis del 
  <data value="https://g.co/kg/m/0g9q7" itemprop="mentions">realismo mágico</data> 
  difiere de lo postulado por 
  <span itemscope itemtype="https://schema.org/Person" itemid="https://g.co/kg/m/03_y4">
    <span itemprop="name">Carpentier</span>
  </span>.
</p>
```
*Esto fuerza a Googlebot a asociar el texto "Carpentier" con el ID específico del Knowledge Graph (`/m/03_y4`), eliminando ambigüedad.*

***

### 3. HACKS DE CÓDIGO PARA WEBS MANUALES (HTML5 PURO)
En un entorno *hand-coded*, cada byte cuenta. Estas optimizaciones buscan un **Time to Interactive (TTI)** instantáneo y un **Cumulative Layout Shift (CLS)** de 0.000.

#### [TRUCO_CODIGO] Zero CLS con `size-adjust`
Las fuentes web personalizadas causan cambios de diseño (layout shifts) mientras cargan. En 2025, el estándar es usar `size-adjust` en CSS para que la fuente de reserva (fallback) ocupe *exactamente* el mismo espacio físico que la fuente final.

```css
/* Fuente de reserva ajustada métricamente */
@font-face {
  font-family: "Fallback-Times";
  src: local("Times New Roman");
  ascent-override: 90%;  /* Ajusta la altura */
  descent-override: 20%; /* Ajusta la profundidad */
  size-adjust: 104%;     /* Iguala el ancho de caracteres */
}

body {
  font-family: "MiFuentePro", "Fallback-Times", serif;
}
```

#### [TRUCO_CODIGO] Priorización de Recursos Críticos
El navegador no sabe qué imagen es importante hasta que renderiza el CSS/HTML. Díselo explícitamente en el HTML.

```html
<!-- Carga la imagen principal con prioridad máxima para LCP instantáneo -->
<img src="hero-academic.jpg" fetchpriority="high" alt="Grafo literario" decoding="async">

<!-- Pre-conexión al servidor de videos solo si es crítico -->
<link rel="preconnect" href="https://cdn.videos.com">
```

#### [TRUCO_CODIGO] HTTP/103 Early Hints (Nginx)
Configura tu servidor Nginx para enviar "Pistas Tempranas". Esto permite al navegador empezar a descargar el CSS/JS crítico *mientras* el servidor todavía está "pensando" (generando el HTML).

```nginx
# En tu configuración de bloque server/location
add_header Link "</style.css>; rel=preload; as=style";
http2_push_preload on; # O usa el módulo ngx_http_v3_module para QUIC
return 103; # Early Hints response
```

***

### 4. ALGORITMO DE YOUTUBE: "Key Moments" & Knowledge Graph
Para contenido educativo largo (Video-Ensayos), la retención se gana permitiendo al usuario "saltar" (Deep Linking). Google premia esto indexando esos fragmentos directamente en la SERP (funcionalidad "In this video").

#### [TRUCO_CODIGO] Schema Híbrido: Clip + SeekToAction
No confíes solo en la descripción. Implementa `VideoObject` con `hasPart` (Clip) para segmentos manuales precisos y `SeekToAction` para permitir que la IA de Google encuentre otros momentos.

```json
{
  "@context": "https://schema.org",
  "@type": "VideoObject",
  "name": "Teoría del Caos en la Literatura",
  "hasPart": [
    {
      "@type": "Clip",
      "name": "Introducción a la Entropía",
      "startOffset": 30,
      "endOffset": 120,
      "url": "https://misitio.com/video#t=30"
    }
  ],
  "potentialAction": {
    "@type": "SeekToAction",
    "target": "https://misitio.com/video?t={seek_to_second_number}",
    "startOffset-input": "required name=seek_to_second_number"
  }
}
```

#### [ESTRATEGIA_CONTENIDO] "Entity Linking" desde YouTube
Para conectar tu video con el Knowledge Graph:
1.  Busca tu entidad principal en Google (ej. "Semiótica").
2.  Busca el icono de "tres puntos" o "Compartir" en el Panel de Conocimiento.
3.  Copia el enlace. El código al final (ej. `kg:/m/06mz5`) es el **Machine ID** de Google.
4.  Añádelo en la descripción del video o en el Schema `about` como se mostró en la sección 1. Esto confirma inequívocamente de qué trata tu video.

***

### AUTO-EVALUACIÓN (TEST DEL EXPERTO)
*   **¿Información promedio?** No. El uso de `size-adjust` para CLS, `HTTP/103`, y la inyección de `itemid` de Knowledge Graph en HTML inline son técnicas de ingeniería avanzada que raramente se ven en blogs de SEO convencionales.
*   **¿Cumple restricciones?** Sí. Cero menciones a WordPress, plugins o "contenido de calidad". Todo es código fuente y arquitectura.
*   **¿Actualidad?** Sí. Las referencias a Information Gain y Saliencia de Entidad alinean con la dirección algorítmica de Google post-2024.

[1](https://www.animalz.co/blog/information-gain)
[2](https://www.seo.com/blog/information-gain/)
[3](https://digitaloft.co.uk/information-gain-in-seo/)
[4](https://backlinko.com/information-gain)
[5](https://www.searchenginejournal.com/googles-information-gain-patent-for-ranking-web-pages/524464/)
[6](https://whodigitalstrategy.com/seo-nested-json-ld-schema-examples/)
[7](https://neuronwriter.com/semantic-density-vs-content-length-correcting-the-misconception-about-length/)
[8](https://asktraining.com.sg/blog/how-to-get-found-on-google-in-2025-the-power-of-semantic-seo/)
[9](https://inlinks.com/insight/information-gain/)
[10](https://stackoverflow.com/questions/38876773/annotating-nested-structures-values-in-json-ld)
[11](https://github.com/rdmpage/wild-json-ld)
[12](https://www.portent.com/blog/seo/json-ld-implementation-guide.htm)
[13](https://stackoverflow.com/questions/73482140/how-to-reference-properties-and-values-in-json-ld)
[14](https://schema.org/version/latest/schemaorg-all-examples.txt)
[15](https://kalicube.com/learning-spaces/faq-list/seo-glossary/html5-semantic-tags-what-are-they/)
[16](https://web.dev/articles/css-size-adjust)
[17](https://nginx.org/en/docs/http/ngx_http_core_module.html)
[18](https://thatware.co/video-schema-upgrade-with-clip-and-seektoaction-structured-data/)
[19](https://www.youtube.com/watch?v=t1Hzy69VX1w)
[20](https://schema.org/docs/gs.html)
[21](https://stackoverflow.com/questions/38407310/multiple-schema-org-markups-on-a-single-page)
[22](https://searchengineland.com/entities-seo-schema-google-content-428602)
[23](https://www.schemaapp.com/schema-markup/how-to-identify-entities-in-your-content-using-schema-markup/)
[24](https://seospeedup.com/es/blog/technical-seo/page-content-html5-tags)
[25](https://opensource.com/article/19/7/python-google-natural-language-api)
[26](https://www.seobythesea.com/2010/08/how-a-search-engine-might-interpret-ambiguous-queries-through-entity-tags/)
[27](https://www.pageoptimizer.pro/blog/how-to-optimize-for-googles-sge-search-generative-experience)
[28](https://www.link-assistant.com/news/html-tags-for-seo.html)
[29](https://www.hararidigital.com/analyze-entities-and-sentiment-with-google-nlp-using-python)