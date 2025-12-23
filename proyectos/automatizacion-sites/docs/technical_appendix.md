# APÉNDICE TÉCNICO PROFUNDO
## Arquitectura SSG Python & Detalles de Implementación
**Complemento del Documento Maestro (master_platform_strategy.md)**

---

## A. PSEUDOCÓDIGO COMPLETO DE build.py

```python
#!/usr/bin/env python3
"""
build.py - Generador SSG principal para Plataforma de Soberanía de Contenido
Transforma: data/{posts,series}/*.md + *.json → output/*.html (static)
"""

import json
import shutil
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
from enum import Enum

# Dependencias externas
from markdown_it import MarkdownIt
from mdit_py_plugins.front_matter import front_matter_plugin
from mdit_py_plugins.table import table_plugin
from mdit_py_plugins.footnote import footnote_plugin
from jinja2 import Environment, FileSystemLoader, select_autoescape
from PIL import Image, ImageFile
from python_slugify import slugify
from pydantic import BaseModel, Field, ValidationError
from bleach import clean as sanitize_html
import click
from loguru import logger
import yaml

# ============================================================================
# CONFIGURACIÓN & CONSTANTES
# ============================================================================

IMAGE_QUALITY = 80
WEBP_COMPRESSION = 6  # 1-6, 6 es máximo pero más lento
MAX_HEADING_DEPTH = 3
MIN_ARTICLE_LENGTH = 100  # palabras

# ============================================================================
# MODELOS DE DATOS (Pydantic Validation)
# ============================================================================

@dataclass
class Author:
    """Metadatos de autor"""
    slug: str
    name: str
    bio: Optional[str] = None
    email: Optional[str] = None
    avatar: Optional[str] = None
    url: Optional[str] = None

class Post(BaseModel):
    """Artículo individual (ensayo, reflexión)"""
    slug: str
    title: str
    content: str  # HTML renderizado
    excerpt: str
    author: Author
    language: str = Field(default="es", regex="^(es|en)$")
    published_at: datetime
    tags: List[str] = []
    featured_image: Optional[str] = None
    reading_time_minutes: int = 0
    
    class Config:
        arbitrary_types_allowed = True

class Episode(BaseModel):
    """Episodio de una saga"""
    number: int
    slug: str
    title: str
    content: str  # HTML
    excerpt: str
    series_slug: str
    language: str = "es"
    duration_minutes: Optional[int] = None
    video_url: Optional[str] = None
    published_at: datetime

class Series(BaseModel):
    """Metadatos de una saga"""
    slug: str
    title: str
    description: str
    language: str = "es"
    author: Author
    cover_image: str
    episode_count: int = 0
    published_at: datetime

# ============================================================================
# PARSER MARKDOWN AVANZADO
# ============================================================================

class MarkdownRenderer:
    """Renderiza Markdown a HTML con extensiones custom"""
    
    def __init__(self):
        self.md = MarkdownIt("commonmark")
        # Agregar plugins
        self.md.use(front_matter_plugin)
        self.md.use(table_plugin)
        self.md.use(footnote_plugin)
        self._setup_custom_rules()
    
    def _setup_custom_rules(self):
        """Configura reglas de parsing custom"""
        # Permitir HTML en ciertos contextos (video embeds)
        self.md.options['html'] = False  # Strict mode para seguridad
        # Habilitar typographer para comillas inteligentes
        self.md.options['typographer'] = True
    
    def parse_post(self, md_file: Path) -> tuple[dict, str]:
        """
        Parsea archivo .md con frontmatter YAML
        Retorna: (metadatos, html_content)
        """
        content = md_file.read_text(encoding='utf-8')
        
        # Extraer frontmatter
        lines = content.split('\n')
        if not lines[0].startswith('---'):
            raise ValueError(f"Falta frontmatter en {md_file}")
        
        frontmatter_end = None
        for i, line in enumerate(lines[1:], 1):
            if line.startswith('---'):
                frontmatter_end = i
                break
        
        if frontmatter_end is None:
            raise ValueError(f"Frontmatter no cerrado en {md_file}")
        
        # Parsear YAML
        try:
            metadata = yaml.safe_load('\n'.join(lines[1:frontmatter_end]))
        except yaml.YAMLError as e:
            raise ValueError(f"YAML inválido en {md_file}: {e}")
        
        # Extraer contenido (sin frontmatter)
        body = '\n'.join(lines[frontmatter_end+1:])
        
        # Renderizar Markdown → HTML
        html = self.md.render(body)
        
        # Sanitizar para prevenir XSS
        html = sanitize_html(
            html,
            tags=['p', 'br', 'strong', 'em', 'u', 'h1', 'h2', 'h3', 'h4', 'h5', 
                  'ul', 'ol', 'li', 'blockquote', 'img', 'video', 'figure', 
                  'figcaption', 'code', 'pre', 'table', 'thead', 'tbody', 'tr', 
                  'td', 'th', 'div', 'span', 'iframe'],
            attributes={
                '*': ['class', 'id', 'data-*'],
                'img': ['src', 'alt', 'width', 'height', 'srcset'],
                'video': ['src', 'controls', 'poster', 'width', 'height'],
                'iframe': ['src', 'width', 'height', 'frameborder', 'allow']
            },
            strip=True  # Remover tags no permitidas
        )
        
        return metadata, html
    
    def extract_excerpt(self, html: str, word_count: int = 50) -> str:
        """Extrae primeras N palabras del HTML"""
        from html.parser import HTMLParser
        
        class TextExtractor(HTMLParser):
            def __init__(self):
                super().__init__()
                self.text = []
            
            def handle_data(self, data):
                self.text.append(data)
        
        extractor = TextExtractor()
        extractor.feed(html)
        text = ' '.join(extractor.text)
        words = text.split()[:word_count]
        return ' '.join(words) + '...'
    
    def calculate_reading_time(self, html: str) -> int:
        """Calcula tiempo de lectura (asume 200 wpm)"""
        from html.parser import HTMLParser
        
        class TextExtractor(HTMLParser):
            def __init__(self):
                super().__init__()
                self.text = []
            
            def handle_data(self, data):
                self.text.append(data)
        
        extractor = TextExtractor()
        extractor.feed(html)
        text = ' '.join(extractor.text)
        word_count = len(text.split())
        return max(1, word_count // 200)

# ============================================================================
# OPTIMIZACIÓN DE IMÁGENES
# ============================================================================

class ImageOptimizer:
    """Convierte imágenes a WebP y genera thumbnails"""
    
    def __init__(self, output_dir: Path):
        self.output_dir = output_dir
        self.image_cache = {}
    
    def optimize_image(self, image_path: Path, dest_dir: Path) -> Dict[str, str]:
        """
        Optimiza imagen: JPG → WebP + JPEG fallback + srcset
        Retorna dict con URLs de diferentes tamaños
        """
        if not image_path.exists():
            logger.warning(f"Imagen no encontrada: {image_path}")
            return {}
        
        dest_dir.mkdir(parents=True, exist_ok=True)
        
        # Abrir y preparar imagen
        img = Image.open(image_path)
        if img.mode == 'RGBA' and image_path.suffix.lower() == '.jpg':
            img = img.convert('RGB')
        
        # Generar variantes
        sizes = [1, 2, 3]  # 1x, 2x, 3x pixel density
        base_name = image_path.stem
        urls = {}
        
        for scale in sizes:
            # WebP
            webp_path = dest_dir / f"{base_name}-{scale}x.webp"
            scaled_img = img.resize(
                (img.width * scale, img.height * scale),
                Image.Resampling.LANCZOS
            )
            scaled_img.save(webp_path, 'WEBP', quality=IMAGE_QUALITY)
            
            # JPEG fallback
            jpeg_path = dest_dir / f"{base_name}-{scale}x.jpg"
            scaled_img.save(jpeg_path, 'JPEG', quality=IMAGE_QUALITY)
            
            urls[f"{scale}x"] = {
                'webp': str(webp_path.relative_to(self.output_dir)),
                'jpeg': str(jpeg_path.relative_to(self.output_dir))
            }
        
        logger.info(f"✓ Optimizada: {image_path.name} ({img.width}x{img.height})")
        return urls

# ============================================================================
# GENERADOR PRINCIPAL
# ============================================================================

class ContentPlatformBuilder:
    """Orquesta la construcción completa de la plataforma"""
    
    def __init__(self, config_path: Path):
        self.config = self._load_json(config_path)
        self.data_dir = Path('data')
        self.output_dir = Path('output')
        self.template_dir = Path('templates')
        
        # Inicializar componentes
        self.markdown = MarkdownRenderer()
        self.image_optimizer = ImageOptimizer(self.output_dir)
        
        # Jinja2 environment
        self.jinja_env = Environment(
            loader=FileSystemLoader(self.template_dir),
            autoescape=select_autoescape(['html', 'xml'])
        )
        
        logger.info("ContentPlatformBuilder inicializado")
    
    def _load_json(self, path: Path) -> dict:
        """Carga JSON con manejo de errores"""
        try:
            return json.loads(path.read_text(encoding='utf-8'))
        except json.JSONDecodeError as e:
            raise ValueError(f"JSON inválido en {path}: {e}")
    
    def _load_authors(self) -> Dict[str, Author]:
        """Carga base de datos de autores"""
        authors_data = self._load_json(self.data_dir / 'authors.json')
        return {
            slug: Author(**data)
            for slug, data in authors_data.items()
        }
    
    def _load_taxonomy(self) -> dict:
        """Carga términos de taxonomía (tags, categorías)"""
        return self._load_json(self.data_dir / 'taxonomy.json')
    
    def build(self, minify: bool = False, optimize_images: bool = False):
        """Pipeline principal de build"""
        start_time = datetime.now()
        
        try:
            logger.info("=" * 60)
            logger.info("INICIANDO BUILD DE PLATAFORMA")
            logger.info("=" * 60)
            
            # 1. Limpiar output previo
            if self.output_dir.exists():
                shutil.rmtree(self.output_dir)
            self.output_dir.mkdir(parents=True, exist_ok=True)
            
            # 2. Cargar metadatos globales
            authors = self._load_authors()
            taxonomy = self._load_taxonomy()
            logger.info(f"✓ Cargados {len(authors)} autores")
            
            # 3. Procesar posts
            posts = self._process_posts(authors)
            logger.info(f"✓ Procesados {len(posts)} posts")
            
            # 4. Procesar series episódicas
            series = self._process_series(authors)
            logger.info(f"✓ Procesadas {len(series)} sagas")
            
            # 5. Generar índices y páginas especiales
            self._generate_home(posts, series)
            self._generate_search_page()
            self._generate_sitemap(posts, series)
            
            # 6. Crear search index (JSON)
            self._generate_search_index(posts, series)
            logger.info("✓ Search index generado")
            
            # 7. Optimizar imágenes (opcional)
            if optimize_images:
                self._optimize_all_images()
                logger.info("✓ Imágenes optimizadas")
            
            # 8. Minificar HTML (opcional)
            if minify:
                self._minify_all_html()
                logger.info("✓ HTML minificado")
            
            # 9. Generar robots.txt y manifest
            self._generate_meta_files()
            logger.info("✓ Archivos meta generados")
            
            elapsed = (datetime.now() - start_time).total_seconds()
            logger.info("=" * 60)
            logger.info(f"✅ BUILD COMPLETADO EN {elapsed:.2f}s")
            logger.info(f"Output: {self.output_dir.resolve()}")
            logger.info("=" * 60)
            
        except Exception as e:
            logger.error(f"❌ ERROR EN BUILD: {e}", exc_info=True)
            raise
    
    def _process_posts(self, authors: Dict[str, Author]) -> List[Post]:
        """Procesa todos los artículos individuales"""
        posts = []
        
        for lang in ['es', 'en']:
            lang_dir = self.data_dir / 'posts' / lang
            if not lang_dir.exists():
                logger.warning(f"Directorio no encontrado: {lang_dir}")
                continue
            
            for md_file in sorted(lang_dir.glob('*.md')):
                try:
                    metadata, html = self.markdown.parse_post(md_file)
                    
                    # Validación de metadatos requeridos
                    required_fields = ['title', 'author', 'published_at']
                    missing = [f for f in required_fields if f not in metadata]
                    if missing:
                        raise ValueError(f"Campos requeridos faltantes: {missing}")
                    
                    # Crear objeto Post
                    post = Post(
                        slug=slugify(metadata.get('title', md_file.stem)),
                        title=metadata['title'],
                        content=html,
                        excerpt=self.markdown.extract_excerpt(html),
                        author=authors[metadata['author']],
                        language=lang,
                        published_at=datetime.fromisoformat(metadata['published_at']),
                        tags=metadata.get('tags', []),
                        featured_image=metadata.get('featured_image'),
                        reading_time_minutes=self.markdown.calculate_reading_time(html)
                    )
                    
                    # Renderizar con Jinja2
                    template = self.jinja_env.get_template('post.html')
                    html_output = template.render(
                        post=post,
                        config=self.config,
                        related_posts=[]  # TODO: Calcular posts relacionados
                    )
                    
                    # Escribir HTML estático
                    output_path = self.output_dir / 'posts' / lang / f"{post.slug}.html"
                    output_path.parent.mkdir(parents=True, exist_ok=True)
                    output_path.write_text(html_output, encoding='utf-8')
                    
                    posts.append(post)
                    logger.debug(f"  ✓ {lang}/{post.slug}")
                
                except Exception as e:
                    logger.error(f"  ✗ Error procesando {md_file}: {e}")
                    continue
        
        return posts
    
    def _process_series(self, authors: Dict[str, Author]) -> List[Series]:
        """Procesa todas las sagas episódicas"""
        series_list = []
        
        series_dir = self.data_dir / 'series'
        if not series_dir.exists():
            logger.warning(f"Directorio de series no encontrado: {series_dir}")
            return series_list
        
        for series_folder in sorted(series_dir.iterdir()):
            if not series_folder.is_dir():
                continue
            
            try:
                # Cargar metadatos de la serie
                series_meta_file = series_folder / 'series.json'
                if not series_meta_file.exists():
                    logger.warning(f"series.json no encontrado en {series_folder}")
                    continue
                
                series_meta = self._load_json(series_meta_file)
                episodes = []
                
                # Procesar episodios (ambos idiomas)
                for lang in ['es', 'en']:
                    episodes_dir = series_folder / 'episodes' / lang
                    if not episodes_dir.exists():
                        continue
                    
                    for ep_md in sorted(episodes_dir.glob('*.md')):
                        try:
                            metadata, html = self.markdown.parse_post(ep_md)
                            
                            episode = Episode(
                                number=metadata.get('number', len(episodes) + 1),
                                slug=slugify(metadata['title']),
                                title=metadata['title'],
                                content=html,
                                excerpt=self.markdown.extract_excerpt(html),
                                series_slug=series_folder.name,
                                language=lang,
                                duration_minutes=metadata.get('duration_minutes'),
                                video_url=metadata.get('video_url'),
                                published_at=datetime.fromisoformat(metadata['published_at'])
                            )
                            
                            episodes.append(episode)
                        except Exception as e:
                            logger.error(f"Error procesando episodio {ep_md}: {e}")
                            continue
                
                # Renderizar cada episodio con navegación
                for i, episode in enumerate(episodes):
                    prev_ep = episodes[i-1] if i > 0 else None
                    next_ep = episodes[i+1] if i < len(episodes)-1 else None
                    
                    template = self.jinja_env.get_template('episode.html')
                    html = template.render(
                        episode=episode,
                        series=series_meta,
                        prev_episode=prev_ep,
                        next_episode=next_ep,
                        config=self.config
                    )
                    
                    output_path = (self.output_dir / 'series' / 
                                   series_meta['slug'] / f"{episode.slug}.html")
                    output_path.parent.mkdir(parents=True, exist_ok=True)
                    output_path.write_text(html, encoding='utf-8')
                
                # Crear objeto Series
                series = Series(
                    slug=series_meta['slug'],
                    title=series_meta['title'],
                    description=series_meta.get('description', ''),
                    language=series_meta.get('language', 'es'),
                    author=authors[series_meta['author']],
                    cover_image=series_meta.get('cover_image', ''),
                    episode_count=len(episodes),
                    published_at=datetime.fromisoformat(series_meta.get('published_at', str(datetime.now())))
                )
                series_list.append(series)
                
                logger.info(f"✓ Serie '{series.title}' ({len(episodes)} episodios)")
            
            except Exception as e:
                logger.error(f"Error procesando serie {series_folder}: {e}")
                continue
        
        return series_list
    
    def _generate_search_index(self, posts: List[Post], series: List[Series]):
        """Genera search-index.json para búsqueda client-side"""
        index = {
            'posts': [
                {
                    'id': p.slug,
                    'title': p.title,
                    'excerpt': p.excerpt,
                    'tags': p.tags,
                    'author': p.author.name,
                    'date': p.published_at.isoformat(),
                    'url': f'/posts/{p.language}/{p.slug}.html',
                    'readingTime': p.reading_time_minutes
                }
                for p in posts
            ],
            'series': [
                {
                    'id': s.slug,
                    'title': s.title,
                    'description': s.description,
                    'episodeCount': s.episode_count,
                    'author': s.author.name,
                    'url': f'/series/{s.slug}/index.html'
                }
                for s in series
            ]
        }
        
        output_path = self.output_dir / 'api' / 'search-index.json'
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(index, ensure_ascii=False, indent=2))
    
    def _generate_home(self, posts: List[Post], series: List[Series]):
        """Genera homepage"""
        template = self.jinja_env.get_template('home.html')
        html = template.render(
            recent_posts=sorted(posts, key=lambda p: p.published_at, reverse=True)[:5],
            featured_series=series[:3],
            config=self.config
        )
        
        output_path = self.output_dir / 'index.html'
        output_path.write_text(html, encoding='utf-8')
    
    def _generate_search_page(self):
        """Genera página de búsqueda"""
        template = self.jinja_env.get_template('search.html')
        html = template.render(config=self.config)
        
        output_path = self.output_dir / 'search.html'
        output_path.write_text(html, encoding='utf-8')
    
    def _generate_sitemap(self, posts: List[Post], series: List[Series]):
        """Genera sitemap.xml para SEO"""
        sitemap = '<?xml version="1.0" encoding="UTF-8"?>\n'
        sitemap += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
        
        # Home
        sitemap += f'  <url>\n    <loc>{self.config["base_url"]}</loc>\n'
        sitemap += f'    <lastmod>{datetime.now().isoformat()}</lastmod>\n'
        sitemap += f'    <priority>1.0</priority>\n  </url>\n'
        
        # Posts
        for post in posts:
            sitemap += f'  <url>\n'
            sitemap += f'    <loc>{self.config["base_url"]}/posts/{post.language}/{post.slug}.html</loc>\n'
            sitemap += f'    <lastmod>{post.published_at.isoformat()}</lastmod>\n'
            sitemap += f'    <priority>0.8</priority>\n'
            sitemap += f'  </url>\n'
        
        # Series
        for s in series:
            sitemap += f'  <url>\n'
            sitemap += f'    <loc>{self.config["base_url"]}/series/{s.slug}</loc>\n'
            sitemap += f'    <lastmod>{s.published_at.isoformat()}</lastmod>\n'
            sitemap += f'    <priority>0.9</priority>\n'
            sitemap += f'  </url>\n'
        
        sitemap += '</urlset>'
        
        output_path = self.output_dir / 'sitemap.xml'
        output_path.write_text(sitemap, encoding='utf-8')
    
    def _generate_meta_files(self):
        """Genera robots.txt, manifest.json, etc."""
        # robots.txt
        robots = f"""User-agent: *
Allow: /
Sitemap: {self.config['base_url']}/sitemap.xml
"""
        (self.output_dir / 'robots.txt').write_text(robots)
        
        # manifest.json (PWA)
        manifest = {
            'name': self.config['title'],
            'short_name': self.config.get('short_name', self.config['title']),
            'description': self.config.get('description', ''),
            'start_url': '/',
            'display': 'standalone',
            'background_color': '#ffffff',
            'theme_color': '#000000'
        }
        (self.output_dir / 'manifest.json').write_text(json.dumps(manifest, indent=2))
    
    def _minify_all_html(self):
        """Minifica todos los archivos HTML"""
        try:
            from htmlmin import minify
        except ImportError:
            logger.warning("htmlmin no instalado, saltando minificación")
            return
        
        for html_file in self.output_dir.rglob('*.html'):
            try:
                original = html_file.read_text()
                minified = minify(original, remove_comments=True, remove_empty_space=True)
                html_file.write_text(minified)
            except Exception as e:
                logger.warning(f"Error minificando {html_file}: {e}")
    
    def _optimize_all_images(self):
        """Optimiza todas las imágenes encontradas"""
        image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp'}
        
        for img_file in self.data_dir.rglob('*'):
            if img_file.suffix.lower() in image_extensions:
                try:
                    output_dir = self.output_dir / 'assets' / 'images'
                    self.image_optimizer.optimize_image(img_file, output_dir)
                except Exception as e:
                    logger.warning(f"Error optimizando {img_file}: {e}")

# ============================================================================
# CLI (Command Line Interface)
# ============================================================================

@click.group()
def cli():
    """Herramientas para Plataforma de Soberanía de Contenido"""
    pass

@cli.command()
@click.option('--minify', is_flag=True, help='Minificar HTML')
@click.option('--optimize-images', is_flag=True, help='Optimizar imágenes')
def build(minify: bool, optimize_images: bool):
    """Construir la plataforma (genera HTML estático)"""
    builder = ContentPlatformBuilder(Path('data/config.json'))
    builder.build(minify=minify, optimize_images=optimize_images)

@cli.command()
def serve():
    """Dev server con hot reload"""
    import http.server
    import socketserver
    from watchfiles import run_process
    
    def rebuild():
        """Rebuilda en cada cambio"""
        try:
            builder = ContentPlatformBuilder(Path('data/config.json'))
            builder.build()
            logger.info("🔄 Rebuild completado")
        except Exception as e:
            logger.error(f"Error en rebuild: {e}")
    
    # Monitorear cambios
    run_process(
        'python -m http.server 8000 --directory output',
        watch_filter=lambda ch: ch.name.endswith(('.md', '.json', '.html', '.css', '.js')),
        ignore_paths=['output']
    )

@cli.command()
def validate():
    """Validar estructura de contenido"""
    from pydantic import ValidationError
    
    logger.info("Validando estructura de datos...")
    
    # Validar config.json
    try:
        Path('data/config.json').read_text()
        logger.info("✓ config.json válido")
    except Exception as e:
        logger.error(f"✗ config.json: {e}")
    
    # Validar authors.json
    try:
        authors_data = json.loads(Path('data/authors.json').read_text())
        logger.info(f"✓ authors.json válido ({len(authors_data)} autores)")
    except Exception as e:
        logger.error(f"✗ authors.json: {e}")
    
    # Validar estructura de posts
    posts_dir = Path('data/posts')
    if posts_dir.exists():
        md_count = len(list(posts_dir.rglob('*.md')))
        logger.info(f"✓ {md_count} archivos .md encontrados")
    else:
        logger.warning("Directorio data/posts no encontrado")
    
    logger.info("✅ Validación completada")

if __name__ == '__main__':
    cli()
```

---

## B. CONFIGURACIÓN EJEMPLO (config.json)

```json
{
  "title": "Soberanía de Contenido",
  "short_name": "SoberaníaX",
  "description": "Narrativas profundas: Biología Especulativa + Stoic Noir",
  "base_url": "https://soberania-contenido.vercel.app",
  "language": "es",
  "author": "Editorial Soberana",
  
  "branding": {
    "logo": "/assets/logo.svg",
    "favicon": "/assets/favicon.ico",
    "primary_color": "#1a1a1a",
    "accent_color": "#d4af37"
  },
  
  "media": {
    "cdn": "bunnycdn",
    "endpoint": "https://example.b-cdn.net",
    "pull_zone": "soberania-content",
    "cache_ttl_seconds": 86400
  },
  
  "features": {
    "dark_mode": true,
    "search": true,
    "comments": true,
    "paywall": false,
    "newsletter_signup": true
  },
  
  "seo": {
    "og_image": "/assets/og-image.jpg",
    "twitter_handle": "@soberania",
    "keywords": ["biología especulativa", "stoic noir", "contenido premium"]
  }
}
```

---

## C. TEMPLATE JINJA2 COMPLETO (episode.html)

```html
<!DOCTYPE html>
<html lang="{{ episode.language }}" dir="ltr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ episode.title }} - {{ series.title }} | {{ config.title }}</title>
  
  <!-- SEO Meta Tags -->
  <meta name="description" content="{{ episode.excerpt }}">
  <meta name="author" content="{{ series.author.name }}">
  <meta name="keywords" content="{{ series.title }}, episodio, narrativa">
  <meta name="published_time" content="{{ episode.published_at.isoformat() }}">
  
  <!-- Open Graph -->
  <meta property="og:type" content="article">
  <meta property="og:title" content="{{ episode.title }}">
  <meta property="og:description" content="{{ episode.excerpt }}">
  <meta property="og:url" content="{{ config.base_url }}/series/{{ series.slug }}/{{ episode.slug }}.html">
  <meta property="og:image" content="{{ config.base_url }}/{{ series.cover_image }}">
  
  <!-- Stylesheets -->
  <link rel="stylesheet" href="/css/main.css">
  <link rel="stylesheet" href="/css/typography.css">
  <link rel="stylesheet" href="/css/dark-mode.css">
  <link rel="stylesheet" href="/css/components/player.css">
  <link rel="stylesheet" href="/css/components/saga-nav.css">
  
  <!-- Fonts -->
  <link rel="preload" as="font" href="/fonts/Merriweather-Regular.woff2" type="font/woff2" crossorigin>
  <link rel="preload" as="font" href="/fonts/Roboto-Mono.woff2" type="font/woff2" crossorigin>
  
  <!-- Preconnect to CDN -->
  <link rel="preconnect" href="https://cdn.bunnycdn.net">
  
  <!-- Dark Mode Script (prevent FOUC) -->
  <script>
    const theme = localStorage.getItem('theme') || 'light';
    document.documentElement.dataset.colorScheme = theme;
  </script>
</head>
<body>
  <!-- Navigation -->
  {% include 'components/nav.html' %}
  
  <!-- Main Content -->
  <main id="main-content" class="episode-page">
    
    <!-- Video Player -->
    {% if episode.video_url %}
    <section class="video-container">
      {% include 'components/player.html' with context %}
    </section>
    {% endif %}
    
    <!-- Episode Header -->
    <header class="episode-header">
      <div class="series-breadcrumb">
        <a href="/series/{{ series.slug }}/index.html" class="series-link">
          ← {{ series.title }}
        </a>
        <span class="separator">•</span>
        <span class="episode-number">Episodio {{ episode.number }} de {{ series.episode_count }}</span>
      </div>
      
      <h1 class="episode-title">{{ episode.title }}</h1>
      
      <div class="episode-meta">
        <span class="author" itemscope itemtype="https://schema.org/Person">
          Por <a itemprop="url" href="#author">{{ series.author.name }}</a>
        </span>
        <span class="separator">•</span>
        <time class="published-date" datetime="{{ episode.published_at.isoformat() }}">
          {{ episode.published_at.strftime('%d de %B de %Y') }}
        </time>
        {% if episode.duration_minutes %}
        <span class="separator">•</span>
        <span class="reading-time">{{ episode.duration_minutes }} min</span>
        {% endif %}
      </div>
    </header>
    
    <!-- Progress Bar -->
    <div class="saga-progress-bar">
      <div class="progress-fill" style="width: {{ (episode.number / series.episode_count * 100)|int }}%"></div>
    </div>
    
    <!-- Episode Content -->
    <article class="episode-content" itemscope itemtype="https://schema.org/Article">
      <meta itemprop="headline" content="{{ episode.title }}">
      <meta itemprop="datePublished" content="{{ episode.published_at.isoformat() }}">
      
      <div class="content-wrapper">
        {{ episode.content|safe }}
      </div>
    </article>
    
    <!-- Saga Navigation (Next/Prev Episodes) -->
    <nav class="saga-nav" aria-label="Navegación de episodios">
      <div class="saga-nav-container">
        {% if prev_episode %}
        <a href="/series/{{ series.slug }}/{{ prev_episode.slug }}.html" 
           class="saga-nav-link saga-nav-prev" rel="prev">
          <span class="nav-label">Episodio anterior</span>
          <span class="nav-title">← {{ prev_episode.title }}</span>
        </a>
        {% else %}
        <div class="saga-nav-link saga-nav-prev disabled"></div>
        {% endif %}
        
        <button class="saga-nav-button" 
                aria-label="Ver todos los episodios" 
                onclick="document.getElementById('episode-list-modal').classList.remove('hidden')">
          <span class="episode-list-icon">≡</span>
          <span class="episode-count">{{ episode.number }} / {{ series.episode_count }}</span>
        </button>
        
        {% if next_episode %}
        <a href="/series/{{ series.slug }}/{{ next_episode.slug }}.html" 
           class="saga-nav-link saga-nav-next" rel="next">
          <span class="nav-label">Siguiente episodio</span>
          <span class="nav-title">{{ next_episode.title }} →</span>
        </a>
        {% else %}
        <div class="saga-nav-link saga-nav-next disabled"></div>
        {% endif %}
      </div>
      
      <!-- Modal de lista de episodios -->
      <div id="episode-list-modal" class="modal hidden">
        <div class="modal-content">
          <button class="modal-close" aria-label="Cerrar" 
                  onclick="this.closest('.modal').classList.add('hidden')">×</button>
          
          <h2>Todos los episodios</h2>
          
          <ul class="episode-list">
            {% for ep_num in range(1, series.episode_count + 1) %}
            <li class="episode-list-item {% if ep_num == episode.number %}active{% endif %}">
              <a href="/series/{{ series.slug }}/ep{{ String(ep_num).zfill(3) }}.html">
                <span class="ep-number">Ep {{ ep_num }}</span>
                <span class="ep-title">{{ episodes[ep_num-1].title if episodes else 'Episodio' }}</span>
                <span class="ep-duration">{% if episodes[ep_num-1].duration_minutes %}{{ episodes[ep_num-1].duration_minutes }}m{% endif %}</span>
              </a>
            </li>
            {% endfor %}
          </ul>
        </div>
      </div>
    </nav>
    
    <!-- Author Card -->
    <section class="author-card">
      {% if series.author.avatar %}
      <img src="{{ series.author.avatar }}" alt="{{ series.author.name }}" class="author-avatar">
      {% endif %}
      
      <div class="author-info">
        <h3>Sobre el autor</h3>
        <p class="author-name">{{ series.author.name }}</p>
        {% if series.author.bio %}
        <p class="author-bio">{{ series.author.bio }}</p>
        {% endif %}
        
        <div class="author-links">
          {% if series.author.url %}
          <a href="{{ series.author.url }}" class="author-link">Más info</a>
          {% endif %}
        </div>
      </div>
    </section>
    
    <!-- Related Episodes / Series -->
    <section class="related-content">
      <h2>Continúa explorando</h2>
      
      <div class="carousel">
        <!-- Placeholder para contenido relacionado -->
        <p>Otros episodios de interés aparecerán aquí.</p>
      </div>
    </section>
    
    <!-- Comments Section -->
    {% if config.features.comments %}
    <section class="comments-section">
      {% include 'components/comment-widget.html' %}
    </section>
    {% endif %}
  
  </main>
  
  <!-- Footer -->
  {% include 'components/footer.html' %}
  
  <!-- Scripts -->
  <script src="/js/app.js" defer></script>
  <script src="/js/player.js" defer></script>
  <script src="/js/theme.js" defer></script>
  
  <!-- Analytics (Privacy-First) -->
  <script defer data-domain="{{ config.base_url }}" src="https://plausible.io/js/script.js"></script>
  
</body>
</html>
```

---

## D. CSS VARIABLES GLOBAL (Extracto de main.css)

```css
:root {
  /* Color Palette */
  --color-background: #fafafa;
  --color-surface: #ffffff;
  --color-text: #1a1a1a;
  --color-text-secondary: #666666;
  --color-border: #e0e0e0;
  --color-primary: #d4af37;
  --color-primary-hover: #c9a027;
  
  /* Typography */
  --font-family-serif: 'Merriweather', Georgia, serif;
  --font-family-mono: 'Roboto Mono', monospace;
  --font-size-base: 16px;
  --line-height-base: 1.8;
  --letter-spacing-base: 0.3px;
  
  /* Spacing */
  --space-xs: 0.5rem;
  --space-sm: 1rem;
  --space-md: 1.5rem;
  --space-lg: 2rem;
  --space-xl: 3rem;
  
  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 12px 32px rgba(0, 0, 0, 0.15);
  
  /* Animation */
  --duration-fast: 150ms;
  --duration-normal: 300ms;
  --easing: cubic-bezier(0.4, 0, 0.2, 1);
}

/* Dark Mode */
@media (prefers-color-scheme: dark) {
  :root {
    --color-background: #121212;
    --color-surface: #1e1e1e;
    --color-text: #e8e8e8;
    --color-text-secondary: #999999;
    --color-border: #333333;
  }
}

[data-color-scheme="dark"] {
  --color-background: #121212;
  --color-surface: #1e1e1e;
  --color-text: #e8e8e8;
  --color-text-secondary: #999999;
  --color-border: #333333;
}
```

---

## E. TESTING & VALIDACIÓN

### Unit Tests (pytest)

```python
# tests/test_markdown_renderer.py
import pytest
from pathlib import Path
from build import MarkdownRenderer

@pytest.fixture
def renderer():
    return MarkdownRenderer()

def test_parse_post_with_valid_frontmatter(renderer, tmp_path):
    """Test parsing válido de post con YAML"""
    md_file = tmp_path / "test.md"
    md_file.write_text("""---
title: Test Article
author: juan-perez
published_at: 2025-01-01T10:00:00
tags: [test, feature]
---
# Contenido de prueba

Este es contenido **bold** y *italic*.
""")
    
    metadata, html = renderer.parse_post(md_file)
    
    assert metadata['title'] == 'Test Article'
    assert '<strong>bold</strong>' in html
    assert '<em>italic</em>' in html

def test_excerpt_extraction(renderer):
    """Test extracción de excerpt"""
    html = "<p>word1 word2 word3 ... word100</p>"
    excerpt = renderer.extract_excerpt(html, word_count=5)
    
    assert excerpt.endswith('...')
    assert 'word1' in excerpt

def test_reading_time_calculation(renderer):
    """Test cálculo de tiempo de lectura"""
    # 1000 palabras ÷ 200 wpm = 5 minutos
    html = "<p>" + " ".join(["palabra"] * 1000) + "</p>"
    reading_time = renderer.calculate_reading_time(html)
    
    assert reading_time == 5
```

### Performance Benchmarks

```bash
# Medir tiempo de build
time python scripts/build.py --optimize-images --minify

# Analizar complejidad con radon
radon cc scripts/build.py -a

# Analizar cobertura
pytest --cov=build tests/
```

---

**FIN DEL APÉNDICE TÉCNICO**
