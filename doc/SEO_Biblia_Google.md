# Protocolo 2025: Arquitectura de Referencia para SEO Científico y Literario

## 1. Arquitectura de Código: El Esqueleto Semántico

En nichos de alta autoridad (YMYL - Your Money Your Life), la ambigüedad HTML es costosa. Google utiliza la estructura del DOM para asignar pesos de importancia (Salience Scores) a las entidades detectadas.

### Estructura HTML5 de Alta Definición

No utilice `<div>` para contenido textual. Utilice etiquetas que definan la ontología del documento.

**Patrón de Implementación:**

* **`<dfn>` para Entidades:** Envuelva la primera mención de un concepto clave en `<dfn>` con un `id` único. Esto señala al algoritmo que su documento es la *fuente de definición* de ese término.


* **`fetchpriority` en LCP:** El activo visual principal (LCP) debe tener prioridad de recuperación explícita para pasar los Core Web Vitals en el percentil 99.



```html
<!DOCTYPE html>
<html lang="es">
<head>
    <link rel="preload" as="image" href="/assets/hero-graph.svg" fetchpriority="high">
    <meta name="description" content="Análisis vectorial de la prosa de Borges.">
</head>
<body>
    <article itemscope itemtype="https://schema.org/ScholarlyArticle">
        <header>
            <h1 itemprop="headline">La Infinitud Semántica en Borges</h1>
            <figure>
                <img src="/assets/hero-graph.svg" 
                     alt="Grafo de conexiones en El Aleph" 
                     width="800" height="450" 
                     fetchpriority="high" 
                     decoding="async">
                <figcaption>Fig 1. Mapeo nodal de referencias.</figcaption>
            </figure>
        </header>

        <section itemprop="articleBody">
            <h2>Definición de Variables</h2>
            <p>
                El concepto de <dfn id="def-rizoma-literario">Rizoma Literario</dfn> se establece aquí como una estructura no jerárquica...
            </p>
            
            <aside aria-label="Notas al margen">
                <p>Nota: Comparar con la teoría de grafos de Euler.</p>
            </aside>
        </section>
    </article>
</body>
</html>

```

## 2. Señales de Autoridad (E-E-A-T): Grafos de Datos Anidados

El error más común en sitios académicos es usar Schema plano. Para dominar el nicho, debe construir un **Grafo de Citación** dentro de su JSON-LD. Google Scholar y el Knowledge Graph rastrean la propiedad `sameAs` para verificar credenciales.

### JSON-LD para `ScholarlyArticle` con Gestión de Paywall

Este script conecta su contenido con Wikidata, define explícitamente las citas (no solo texto, sino objetos creativos) y gestiona el contenido restringido sin riesgo de penalización por *cloaking*.

```json
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "La Infinitud Semántica en Borges",
  "image": "https://example.com/assets/hero-graph.svg",
  "author": {
    "@type": "Person",
    "name": "Dr. Elena Vance",
    "url": "https://example.com/author/elena-vance",
    "sameAs":,
    "jobTitle": "Investigadora Principal",
    "worksFor": {
      "@type": "Organization",
      "name": "Instituto de Letras Digitales",
      "sameAs": "https://www.wikidata.org/wiki/Q_INSTITUCION"
    }
  },
  "citation":,
  "isAccessibleForFree": false,
  "hasPart": {
    "@type": "WebPageElement",
    "isAccessibleForFree": false,
    "cssSelector": ".paywall-content"
  }
}
</script>

```

## 3. Multimedia de Alto Rendimiento: Imágenes como Datos

Para gráficos científicos, el formato SVG es superior a WebP porque es XML indexable. Puede inyectar metadatos directamente en el código de la imagen.

### Inyección de Metadatos RDFa en SVG

Copie este bloque dentro de sus archivos `.svg` antes de cerrarlos. Esto hace que el gráfico sea legible por máquinas independientemente del contexto HTML.

```xml
<metadata>
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
           xmlns:dc="http://purl.org/dc/elements/1.1/">
    <rdf:Description>
      <dc:title>Grafo de conexiones en El Aleph</dc:title>
      <dc:creator>Dr. Elena Vance</dc:creator>
      <dc:subject>Análisis de Grafos</dc:subject>
      <dc:description>Visualización vectorial de las referencias cruzadas en la obra de Borges.</dc:description>
      <dc:rights>CC BY-NC 4.0</dc:rights>
    </rdf:Description>
  </rdf:RDF>
</metadata>

```

### Eliminación de CLS con `size-adjust`

Las fuentes académicas (Serif) suelen causar desplazamientos de diseño masivos al cargar. Utilice `size-adjust` para forzar a la fuente de reserva (Times New Roman/Arial) a ocupar el espacio exacto de su fuente web antes de que esta cargue.

```css
/* Fuente personalizada */
@font-face {
  font-family: 'AcademicSerif';
  src: url('/fonts/academic.woff2') format('woff2');
  font-display: swap;
}

/* Fuente de reserva ajustada matemáticamente */
@font-face {
  font-family: 'AcademicSerif-Fallback';
  src: local('Times New Roman');
  /* Ajuste estos valores hasta que el texto no se mueva al cambiar la fuente */
  size-adjust: 98.5%; 
  ascent-override: 95%;
  descent-override: 25%;
}

body {
  font-family: 'AcademicSerif', 'AcademicSerif-Fallback', serif;
}

```

## 4. YouTube Research Dominance: Schema de Video Profundo

Google indexa "Key Moments" (Momentos Clave). Para contenido educativo largo, no deje esto al azar. Defínalo explícitamente con `Clip` schema anidado en `VideoObject`.

### Estructura de Video-Ensayo Semántico

Use este JSON-LD para forzar la aparición de capítulos en la SERP, aumentando el CTR y la relevancia para consultas long-tail.

```json
{
  "@context": "https://schema.org",
  "@type": "VideoObject",
  "name": "Análisis Estructural de El Aleph",
  "description": "Video-ensayo sobre la topología matemática en la obra de Borges.",
  "thumbnailUrl": "https://example.com/thumb.jpg",
  "uploadDate": "2025-05-20",
  "contentUrl": "https://example.com/video.mp4",
  "hasPart":
}

```

## 5. Checklist "Zero Error": Protocolo de Despliegue

Antes de cada publicación, ejecute esta verificación técnica:

1. **Validación de Grafo:** Pase el JSON-LD por el([https://validator.schema.org/](https://validator.schema.org/)) (no solo el Rich Results Test). Verifique que no haya nodos "huérfanos"; todo debe estar conectado al nodo principal (`Article` o `WebPage`).


2. **Verificación de Encabezados HTTP:**
* Asegúrese de que su servidor envíe cabeceras `Link` para activos críticos si usa HTTP/2 o HTTP 103 Early Hints.
* Ejemplo Nginx: `add_header Link "</fonts/main.woff2>; rel=preload; as=font; crossorigin";`.




3. **Auditoría de Enlazado de Entidades:**
* Verifique que los enlaces salientes a fuentes de autoridad (Wikidata, Universidades) utilicen `rel="external"` o `rel="noreferrer"` según corresponda, pero nunca `nofollow` si son referencias bibliográficas que respaldan su autoridad (YMYL).




4. **Test de Inyección IPTC:**
* Descargue su imagen principal desde el navegador. Ábrala en un visor de metadatos. ¿Aparece el campo "Web Statement of Rights"? Si no, Google Images no mostrará la insignia de "Licenciable".





### Script Python para Inyección IPTC Masiva

Use este script en su proceso de *build* para garantizar que todas las imágenes de investigación tengan los metadatos de derechos requeridos por Google Images.

```python
import pyexiv2 # pip install py3exiv2

def inject_seo_metadata(image_path, author_url, license_url):
    with pyexiv2.Image(image_path) as img:
        xmp = img.read_xmp()
        # Campos críticos para la insignia "Licenciable" de Google
        xmp['Xmp.dc.creator'] =
        xmp = author_url
        xmp['Xmp.plus.Licensor'] =
        img.modify_xmp(xmp)
        print(f"Metadatos inyectados en {image_path}")

# Uso: inject_seo_metadata('figura1.jpg', 'https://misite.com/creditos', 'https://misite.com/licencia')

```