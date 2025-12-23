# Z-Image-Turbo Code Wiki

## Table of Contents
1. [Overview](#overview)
2. [Core Architecture](#core-architecture)
3. [Main Entry Points](#main-entry-points)
4. [Module Deep Dive](#module-deep-dive)
5. [Data Flow](#data-flow)
6. [Key Algorithms](#key-algorithms)
7. [Configuration System](#configuration-system)
8. [Error Handling & Logging](#error-handling--logging)
9. [Performance Optimizations](#performance-optimizations)
10. [External Dependencies](#external-dependencies)

---

## Overview

Z-Image-Turbo is an AI-powered video production factory that automates the entire pipeline from JSON scripts to published YouTube videos and web content. The system orchestrates multiple AI models (image generation, TTS, music composition) to create professional multimedia content in multiple languages.

### Technology Stack
- **Image Generation**: Tongyi-MAI/Z-Image-Turbo (Diffusion Model)
- **Text-to-Speech**: Kokoro ONNX (primary), Google Cloud TTS, MeloTTS
- **Music Generation**: MusicGen (isolated environment)
- **Video Processing**: FFmpeg, MoviePy
- **Audio Processing**: NumPy, SciPy, SoundFile
- **Publishing**: YouTube Data API v3, Custom Web Platform

---

## Core Architecture

### Design Pattern: Factory Pattern

The system implements a **Factory Pattern** through the `VideoFactory` class in `main.py`, which orchestrates the entire video production pipeline.

```
VideoFactory
    ├── Initialization (project setup, directory structure)
    ├── Phase 0: Preparation (folder organization)
    ├── Phase 1: Thumbnail Generation (workflow delegation)
    ├── Phase 2: Scene Processing (core loop)
    ├── Phase 3: Music Generation (BSO)
    ├── Phase 4: Assembly & Distribution
    └── Phase 5: Web Publishing (optional)
```

### Modular Organization

```
modules/
├── generators/          # Content creation modules
│   ├── image_gen.py    # Z-Image-Turbo diffusion model
│   ├── tts_gen.py      # Multi-engine TTS (Kokoro/Google/Melo)
│   ├── music_bridge.py # MusicGen subprocess bridge
│   └── subtitle_gen.py # SRT subtitle generation
├── editing/            # Video assembly & processing
│   ├── video_assembler.py   # FFmpeg video construction
│   └── video_security.py    # Anti-fingerprinting sanitization
├── uploading/          # Distribution layer
│   └── uploader.py     # YouTube API integration
├── utils/              # Cross-cutting concerns
│   ├── logger.py       # Logging infrastructure
│   ├── files.py        # Filesystem utilities & caching
│   ├── metadata_manager.py  # JSON metadata extraction
│   ├── media_tools.py  # Audio/video duration analysis
│   └── text_renderer.py     # PIL-based text overlay
├── workflows/          # Complex multi-step operations
│   └── thumbnail_workflow.py  # Thumbnail variant generation
└── publishing/         # Web platform integration
    └── web_publisher.py       # Markdown/YAML export
```

---

## Main Entry Points

### 1. main.py - Single Video Production

**Purpose**: Process a single JSON script file into complete video(s).

**Entry Point**: `VideoFactory` class

**Key Responsibilities**:
- Parse JSON script and metadata
- Initialize all generator modules
- Execute 5-phase production pipeline
- Handle multi-language parallel generation
- Optional upload & web publishing

**Usage**:
```bash
python main.py --project beyondCarbon --file SAGA_01_Episode_01.json --upload
```

**Supported Flags**:
- `--upload` / `--no-upload`: Force YouTube upload behavior
- `--sanitize`: Apply anti-fingerprinting transformations
- `--publish`: Auto-publish to web platform
- `--publish-only`: Skip video generation, regenerate web content only
- `--clean`: Delete cached audio/video before generation
- `--lang en es`: Process specific languages only

### 2. batch_runner.py - Batch Processing

**Purpose**: Execute the factory on multiple JSON scripts sequentially.

**Entry Point**: `run_batch()` function

**Key Features**:
- Automatic discovery of JSON files in project folder
- Single-file or full-batch mode
- Error isolation (one failure doesn't stop batch)
- Unified argument passing to VideoFactory
- Summary report of successes/failures

**Usage**:
```bash
# Process all JSON files in project
python batch_runner.py --project beyondCarbon --upload

# Process specific file
python batch_runner.py --project beyondCarbon --file SAGA_01_Episode_22.json --clean
```

---

## Module Deep Dive

### Generators Module

#### image_gen.py - AI Image Generation

**Model**: Tongyi-MAI/Z-Image-Turbo (Diffusion-based)

**Key Features**:
- Lazy loading (model loaded on first use)
- VRAM optimization for RTX 3060 (12GB)
  - `enable_sequential_cpu_offload()`: CPU offloading strategy
  - `vae.enable_tiling()`: Reduces memory peaks during VAE decoding
- Intelligent caching via `necesita_actualizacion()`

**Generation Parameters**:
```python
width=1920, height=1072  # Scene images (FHD)
width=1280, height=720   # Thumbnails
num_inference_steps=9    # Speed/quality tradeoff
guidance_scale=0.0       # Classifier-free guidance disabled (turbo model)
```

**Code Snippet** (main.py:193-197):
```python
f_img = self.common_assets_dir / f"img_{idx}.png"
if not f_img.exists():
    self.logger.info(f"   🎨 Generando Imagen {idx}...")
    self.img_gen.generar(item['image_prompt'], f_img)
```

---

#### tts_gen.py - Text-to-Speech Engine

**Multi-Engine Architecture**:
1. **Kokoro ONNX v1.0** (Primary) - Neural TTS
2. **Google Cloud TTS** (Fallback/Catalan)
3. **MeloTTS** (Alternative Spanish, optional)

**Audio Processing Pipeline**:
```
Raw TTS Output
    ↓
Text Cleaning ("... " prefix for breathing)
    ↓
Fade-In (20ms - eliminates click artifacts)
    ↓
Fade-Out (50ms - smooth ending)
    ↓
Silence Padding (scene boundaries)
    ↓
Final WAV Export
```

**Critical Code** (tts_gen.py:219-243):
```python
# Fade-In to eliminate click at start
fade_in_samples = int(0.02 * samplerate)  # 20ms
in_curve = np.linspace(0.0, 1.0, fade_in_samples)
data[:fade_in_samples] *= in_curve

# Fade-Out for smooth ending
fade_out_samples = int(0.05 * samplerate)  # 50ms
out_curve = np.linspace(1.0, 0.0, fade_out_samples)
data[-fade_out_samples:] *= out_curve
```

**Voice Mapping**:
- Spanish: `em_alex` (Kokoro)
- English: `am_michael` (Kokoro)
- Catalan: `ca-ES-Standard-B` (Google)

---

#### music_bridge.py - Background Music Generator

**Architecture**: Subprocess Bridge Pattern

**Why Isolated?**:
MusicGen requires incompatible dependencies with the main environment (PyTorch versions, transformers). Solution: Run in separate virtual environment via subprocess.

**Flow**:
```
Main Process (main.py)
    ↓
music_bridge.py (subprocess launcher)
    ↓
music_gen/venv_music/python.exe
    ↓
music_gen/generador.py (MusicGen model)
    ↓
Generated WAV file
    ↓
Main Process continues
```

**Cache Strategy**:
Music files are cached in `common_assets_dir` with hash-based filenames:
```
bg_music_common_{prompt_hash}_{duration}s.wav
```

**Code** (music_bridge.py:42-43):
```python
subprocess.run(cmd, check=True, cwd=str(config.MUSIC_GEN_DIR))
```

---

#### subtitle_gen.py - SRT Subtitle Generator

**Algorithm**: Proportional Word-Based Segmentation

**Logic**:
1. Split text into blocks (max 70 chars per screen)
2. Calculate duration proportion: `block_weight = len(block) / total_text_length`
3. Assign duration: `block_duration = total_audio_duration * block_weight`
4. Minimum duration: 1 second per block
5. Smart line breaking at 35 chars (finds nearest space)

**Output Format**: Standard SRT
```
1
00:00:05,000 --> 00:00:08,500
First subtitle line
Second subtitle line

2
00:00:08,500 --> 00:00:12,000
Next subtitle
```

---

### Editing Module

#### video_assembler.py - FFmpeg Video Constructor

**Core Operations**:

1. **crear_clip()**: Image + Audio → Static Video
```bash
ffmpeg -loop 1 -i image.png -i audio.wav -c:v libx264 -tune stillimage -shortest output.mp4
```

2. **unir_clips()**: Multiple MP4s → Single Video (concat demuxer)
```bash
ffmpeg -f concat -safe 0 -i filelist.txt -c copy output.mp4
```

3. **mezclar_audio_fondo()**: Voice + Music → Mixed Audio
```bash
ffmpeg -i video_voice.mp4 -stream_loop -1 -i music.wav \
  -filter_complex "[1:a]volume=0.08[bg];[0:a][bg]amix=inputs=2:duration=first[aout]" \
  -map 0:v -map "[aout]" output.mp4
```

4. **pegar_intro()**: Intro + Content → Final Video (with scaling)
```bash
ffmpeg -i intro.mp4 -i content.mp4 \
  -filter_complex "
    [0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2[v0];
    [1:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2[v1];
    [v0][0:a][v1][1:a]concat=n=2:v=1:a=1[v][a]
  " -map "[v]" -map "[a]" final.mp4
```

**Cache Optimization**:
Every operation checks `necesita_actualizacion()` before executing FFmpeg, skipping if output exists and inputs haven't changed.

---

#### video_security.py - Anti-Fingerprinting Sanitizer

**Purpose**: Break content ID matching by introducing imperceptible changes.

**Techniques Applied**:
1. **Speed Modulation** (±2%):
   - Video PTS adjustment: `setpts=1/speed_factor*PTS`
   - Audio tempo: `atempo=speed_factor`
2. **Visual Noise Injection**: `noise=alls=1:allf=t+u`
3. **Metadata Stripping**: `-map_metadata -1`
4. **Fixed + Random Offset**: Ensures different languages are mathematically distinct

**Code** (video_security.py:23-30):
```python
factor_aleatorio = random.uniform(0.98, 1.02)
factor_velocidad_final = fixed_speed_offset * factor_aleatorio

video_speed_pts = 1 / factor_velocidad_final
audio_tempo = factor_velocidad_final
```

**Usage**:
```python
# Spanish version: 1% faster
sanitizer.sanitizar(video_path, fixed_speed_offset=1.01)

# English version: 1% slower
sanitizer.sanitizar(video_path, fixed_speed_offset=0.99)
```

---

### Uploading Module

#### uploader.py - YouTube API Integration

**Authentication**: OAuth 2.0 with token persistence
- Token files: `token_{project}_{language}.pickle`
- Auto-refresh on expiration
- Per-language channel support

**Video Upload Flow**:
```python
1. Load credentials (or trigger OAuth flow)
2. Build YouTube service (Google API client)
3. Prepare metadata body (title, description, tags, language)
4. Create MediaFileUpload (resumable upload)
5. Execute chunked upload (progress reporting)
6. Upload thumbnail (separate API call)
7. Upload captions/subtitles
```

**Language Mapping** (uploader.py:48-57):
```python
lang_map = {
    "es": "es-ES",      # Spanish (Spain)
    "es_free": "es-ES",
    "en": "en-US",      # English (US)
    "ca": "ca-ES"       # Catalan
}
```

**Caption Upload** (uploader.py:97-128):
- Supports SRT format via `application/x-subrip` MIME type
- Auto-names tracks based on language
- Sets `isDraft=False` for immediate activation

---

### Utils Module

#### logger.py - Logging Infrastructure

**Features**:
- Dual output: Console + File
- Color-coded console logs
- Per-video log files: `logs/{project_title}_YYYYMMDD_HHMMSS.log`
- Automatic log directory creation

---

#### files.py - Filesystem Utilities

**Key Functions**:

1. **limpiar_nombre()**: Sanitize filenames
   - Removes special characters
   - Converts spaces to underscores
   - Ensures filesystem compatibility

2. **asegurar_directorio()**: Safe directory creation
   - Recursive `mkdir -p` equivalent
   - Handles Path objects and strings

3. **necesita_actualizacion()**: Smart caching logic
```python
def necesita_actualizacion(output_path, input_paths=None):
    if not os.path.exists(output_path):
        return True  # Output missing, needs generation

    if not input_paths:
        return False  # Output exists, no inputs to compare

    output_time = os.path.getmtime(output_path)
    for inp in input_paths:
        if os.path.getmtime(inp) > output_time:
            return True  # Input newer than output

    return False  # Output up-to-date
```

---

#### metadata_manager.py - JSON Metadata Extraction

**Purpose**: Auto-inject saga/episode numbers from filenames into JSON.

**Pattern Matching**:
```python
# Filename: SAGA_01_Episode_22.json
match = re.search(r"SAGA_(\d+)_Episode_(\d+)", filename)
# Extracts: saga=1, episode=22
```

**JSON Update**:
If `saga` or `episode` keys are missing, they're injected and the JSON is rewritten with proper formatting.

---

#### media_tools.py - Duration Analysis

**Functions**:

1. **obtener_duracion_audio()**: Uses `soundfile.SoundFile` metadata
```python
f = sf.SoundFile(path)
return f.frames / f.samplerate
```

2. **obtener_duracion_video()**: Uses `imageio` video reader
```python
reader = imageio.get_reader(path)
meta = reader.get_meta_data()
return float(meta['duration'])
```

3. **organizar_carpetas_audio()**: Migrates WAV files to `raw/` and `padding/` subdirectories

---

#### text_renderer.py - PIL Text Overlay

**Algorithm**: Mathematical Centering

**Process**:
1. Load image, create RGBA overlay
2. Calculate fixed line height (using standard character "Ay")
3. Wrap text to fit width (90% of image width)
4. Calculate total content height
5. Draw semi-transparent background box
6. Render text centered in box with stroke

**Configuration** (config.py):
```python
FONT_SIZE_PERCENT = 0.13       # 13% of image height
TEXT_COLOR = "#FFFFFF"         # White
STROKE_COLOR = "#000000"       # Black outline
STROKE_WIDTH = 3               # Outline thickness
BG_BOX_COLOR = (0, 0, 0, 160)  # Black 63% opacity
TEXT_ANCHOR = "BOTTOM"         # Position: TOP or BOTTOM
```

---

### Workflows Module

#### thumbnail_workflow.py - Thumbnail Generation Orchestration

**Multi-Variant System**:

1. Generate base image (1280x720) via `image_gen`
2. Create multiple text variants from SEO data
3. Render each variant using `text_renderer`
4. Copy variant #1 as official thumbnail

**Variant Sources** (priority order):
1. `seo.{lang}.variants[]` - Explicit thumbnail variants
2. `seo.{lang}.titles[]` - Legacy title list
3. Project default title

**Output Files**:
```
assets/thumbnails/
├── thumbnail_raw_es.png          # Base image (no text)
├── thumbnail_es_v1.png           # Variant 1
├── thumbnail_es_v2.png           # Variant 2
└── ...

video_root/
└── thumbnail_es.png              # Official (copy of v1)
```

---

### Publishing Module

#### web_publisher.py - Web Platform Integration

**Architecture**: Export to separate web platform repository

**Output Structure**:
```
Z-content-platform/data/sites/specbio/series/
└── saga-01/
    ├── meta.en.yaml              # Saga metadata (English)
    ├── meta.es.yaml              # Saga metadata (Spanish)
    ├── cover_en.png              # Saga cover (from Ep 1)
    ├── cover_es.png
    └── ep-01/
        ├── content.en.md         # Markdown with frontmatter
        ├── content.es.md
        └── assets/
            ├── S01E01-EN-Title.mp4
            ├── S01E01-ES-Título.mp4
            ├── thumbnail_en.png
            └── thumbnail_es.png
```

**Markdown Frontmatter** (content.en.md):
```yaml
---
title: "Episode Title"
slug: "episode-title"
episode_number: 1
season: 1
description: "..."
published_at: "2025-01-15T18:00:00Z"
visual_mode: "exo-natgeo"
tags: [slug-tag-1, slug-tag-2]
keywords: [Original Tag 1, Original Tag 2]
media:
  duration_seconds: 900
  youtube_id: ""
  site_video_id: "S01E01-EN-Title.mp4"
  thumbnail: "thumbnail_en.png"
recommended_products: []
---

# Episode Content Here...
```

**Saga Completion Logic** (web_publisher.py:92-93):
```python
is_now_complete = was_complete or (ep_id >= 10)
```
A saga is marked complete when episode 10 is published.

**Duration Calculation** (web_publisher.py:129-141):
```python
# Read actual video duration with ffprobe
duration_raw = get_video_duration(video_path)

# Apply 20% buffer for pacing
buffer_duration = duration_raw * 1.2

# Round to nearest minute
minutes = round(buffer_duration / 60)
final_duration_seconds = minutes * 60
```

---

## Data Flow

### Complete Pipeline Execution

```
[JSON Script Input]
        ↓
    VideoFactory.__init__()
    - Parse metadata (saga/episode)
    - Create directory structure
    - Initialize all modules
        ↓
    run() - Phase 0: Preparation
    - Organize audio folders (raw/padding)
    - Calculate intro duration
        ↓
    run() - Phase 1: Thumbnails
    - ThumbnailWorkflow.ejecutar()
      → ImageGenerator (base images)
      → TextRenderer (text variants)
        ↓
    run() - Phase 2: Scene Processing
    - _procesar_escenas() [CORE LOOP]
      For each scene:
        1. ImageGenerator → scene image (cached)
        2. For each language:
           a. TTSGenerator → raw audio
           b. Apply fade in/out + padding
           c. Calculate frame-perfect duration
           d. Store asset paths
           e. Generate SRT fragments
        3. Track maximum duration
        ↓
    run() - Phase 3: Music
    - _gestionar_musica()
      → MusicGenerator (subprocess bridge)
      → Returns cached or new WAV file
        ↓
    run() - Phase 4: Assembly
    - _fase_final() [Per Language]
      1. Write SRT subtitle file
      2. _ensamblar_sincronizado()
         a. Create ImageClips with exact audio duration
         b. Concatenate video clips
         c. Concatenate audio clips
         d. Mix voice + music (8% volume)
         e. Prepend intro
         f. Export to MP4
      3. [Optional] VideoSanitizer.sanitizar()
      4. _gestionar_subida()
         a. Prepare metadata
         b. YoutubeUploader.upload_video()
         c. YoutubeUploader.upload_caption()
        ↓
    run() - Phase 5: Web Publishing (if enabled)
    - WebPublisher.publish()
      1. Copy video files to web platform
      2. Copy thumbnails
      3. Update saga cover (if episode 1)
      4. Generate content.{lang}.md with frontmatter
      5. Update saga meta.{lang}.yaml
        ↓
[Final Output: YouTube Videos + Web Content]
```

---

## Key Algorithms

### Frame-Perfect Audio Synchronization

**Problem**: MoviePy concatenates clips without guaranteeing video/audio sync, causing drift over time.

**Solution** (main.py:214-266):

```python
# 1. Read raw audio
data, samplerate = sf.read(f_raw)

# 2. Apply fade-in (20ms) and fade-out (50ms)
fade_in_samples = int(0.02 * samplerate)
data[:fade_in_samples] *= np.linspace(0.0, 1.0, fade_in_samples)

fade_out_samples = int(0.05 * samplerate)
data[-fade_out_samples:] *= np.linspace(1.0, 0.0, fade_out_samples)

# 3. Calculate EXACT frame count needed
duracion_actual = len(data) / samplerate
frames_ocupados = duracion_actual * FPS_VIDEO  # FPS_VIDEO = 30

# Round up + 1 frame safety margin
frames_objetivo = math.ceil(frames_ocupados) + 1

# 4. Convert back to samples
samples_objetivo = int((frames_objetivo / FPS_VIDEO) * samplerate)

# 5. Pad with silence to reach exact sample count
samples_padding = max(0, samples_objetivo - len(data))
silencio = np.zeros(samples_padding, dtype=data.dtype)
final_data = np.concatenate((data, silencio))

# 6. Write padded audio
sf.write(f_final, final_data, samplerate)
```

**Result**: Every audio file's duration is an exact multiple of frame duration, eliminating accumulating drift.

---

### Synchronized Video Assembly

**Critical Code** (main.py:288-337):

```python
def _ensamblar_sincronizado(self, lang, lista_assets, musica, intro_path):
    clips_video = []
    clips_audio = []

    # Create clips with EXACT duration matching
    for asset in lista_assets:
        audioclip = AudioFileClip(asset["audio_path"])

        # Force image duration to match audio EXACTLY
        imgclip = ImageClip(asset["img_path"]).set_duration(audioclip.duration)
        imgclip.fps = 24

        clips_video.append(imgclip)
        clips_audio.append(audioclip)

    # Concatenate everything
    final_video_clip = concatenate_videoclips(clips_video, method="compose")
    final_audio_clip = concatenate_audioclips(clips_audio)

    # Mix music (loop if needed)
    if musica:
        music_clip = AudioFileClip(str(musica))
        if music_clip.duration < final_audio_clip.duration:
            music_clip = music_clip.loop(duration=final_audio_clip.duration + 5)
        music_clip = music_clip.volumex(0.08)
        final_audio_mix = CompositeAudioClip([music_clip, final_audio_clip])
    else:
        final_audio_mix = final_audio_clip

    # Assign mixed audio to video
    final_video_clip = final_video_clip.set_audio(final_audio_mix)

    # Prepend intro
    if intro_path and os.path.exists(intro_path):
        intro_clip = VideoFileClip(str(intro_path))
        final_video_clip = concatenate_videoclips([intro_clip, final_video_clip])

    # Export
    final_video_clip.write_videofile(str(output_path), fps=24, codec="libx264", ...)
```

**Why It Works**:
- Audio files are already frame-perfect padded
- Image clip durations are forced to match audio exactly
- `set_duration()` ensures no rounding errors in MoviePy
- All concatenations happen with aligned boundaries

---

### Intelligent Caching Strategy

**Implementation** (files.py):

```python
def necesita_actualizacion(output_path, input_paths=None):
    """
    Returns True if output needs regeneration, False if cached version is valid.

    Regeneration needed when:
    1. Output file doesn't exist
    2. Any input file is newer than output (modification time)
    """
    if not os.path.exists(output_path):
        return True

    if not input_paths:
        return False

    output_mtime = os.path.getmtime(output_path)

    for input_path in input_paths:
        if not os.path.exists(input_path):
            continue
        if os.path.getmtime(input_path) > output_mtime:
            return True  # Input modified after output was created

    return False
```

**Usage Throughout Codebase**:
- Image generation (image_gen.py:36)
- TTS generation (tts_gen.py:132)
- Video clip creation (video_assembler.py:23)
- Video concatenation (video_assembler.py:52)
- Music mixing (video_assembler.py:85)
- Intro attachment (video_assembler.py:124)

**Benefits**:
- Dramatically reduces regeneration time
- Safely resumes after failures
- Respects source changes (JSON edits trigger regeneration)

---

## Configuration System

### config.py - Central Configuration

**Path Management**:
```python
BASE_DIR = Path(__file__).parent.absolute()
INPUT_DIR = BASE_DIR / "inputs"
OUTPUT_DIR = BASE_DIR / "outputs"
SCRIPTS_DIR = INPUT_DIR / "scripts"
ASSETS_DIR = INPUT_DIR / "assets"
```

**External Module Isolation**:
```python
MUSIC_GEN_DIR = WORKSPACE_DIR / "music_gen"
MUSIC_VENV_PYTHON = MUSIC_GEN_DIR / "venv_music" / "Scripts" / "python.exe"
MUSIC_SCRIPT = MUSIC_GEN_DIR / "generador.py"
```

**API Keys** (via .env):
```python
load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
```

**FFmpeg Binary**:
```python
import imageio_ffmpeg
FFMPEG_BINARY = imageio_ffmpeg.get_ffmpeg_exe()
```
Uses bundled FFmpeg from imageio_ffmpeg package.

**Thumbnail Configuration**:
```python
MAX_THUMB_VARIANTS = 5
FONT_PATH = "C:/Windows/Fonts/impact.ttf"
FONT_SIZE_PERCENT = 0.13        # 13% of image height
TEXT_COLOR = "#FFFFFF"
STROKE_COLOR = "#000000"
STROKE_WIDTH = 3
TEXT_ANCHOR = "BOTTOM"          # TOP or BOTTOM
USE_BG_BOX = True
BG_BOX_COLOR = (0, 0, 0, 160)   # RGBA
BG_BOX_PADDING = 20             # pixels
```

---

## Error Handling & Logging

### Logging Architecture

**Setup** (utils/logger.py):
```python
def setup_logger(output_dir, title):
    logger = logging.getLogger(f"VideoFactory_{title}")
    logger.setLevel(logging.INFO)

    # Console handler (colored)
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(ColoredFormatter(...))

    # File handler
    log_file = output_dir / "logs" / f"{title}_{timestamp}.log"
    file_handler = logging.FileHandler(log_file, encoding='utf-8')
    file_handler.setFormatter(logging.Formatter(...))

    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

    return logger
```

**Usage Pattern**:
```python
self.logger.info("🚀 Starting generation...")
self.logger.warning("⚠️ Cache miss, regenerating...")
self.logger.error(f"❌ FFmpeg failed: {error}")
```

### Error Isolation in Batch Mode

**batch_runner.py** (lines 99-116):
```python
errores = []

for i, script_path in enumerate(archivos_a_procesar):
    try:
        factory = VideoFactory(script_path, ...)
        factory.run()
    except Exception as e:
        print(f"❌ FALLO CRÍTICO en {script_path.name}: {e}")
        errores.append((script_path.name, str(e)))

# Continue processing remaining files even after failure

# Final summary
if errores:
    print(f"⚠️ PROCESO TERMINADO CON {len(errores)} ERRORES:")
    for nombre, error in errores:
        print(f" - {nombre}: {error}")
```

**Benefit**: One corrupted JSON or API failure doesn't abort entire batch.

---

## Performance Optimizations

### 1. Memory Management for GPU

**Image Generation** (image_gen.py:25-29):
```python
# Sequential CPU offloading: Keep only active layer on GPU
self.pipe.enable_sequential_cpu_offload()

# VAE tiling: Process VAE in tiles to reduce memory peaks
if hasattr(self.pipe, "vae"):
    self.pipe.vae.enable_tiling()
```

**Effect**: Enables generation on 12GB VRAM (RTX 3060) instead of requiring 24GB+.

### 2. Subprocess Isolation for MusicGen

**music_bridge.py**: Runs MusicGen in separate Python environment.

**Why**:
- Avoids dependency conflicts (PyTorch versions)
- Isolates GPU memory allocation
- Enables different CUDA toolkit versions

**Code**:
```python
cmd = [
    str(config.MUSIC_VENV_PYTHON),  # Different interpreter
    str(config.MUSIC_SCRIPT),
    "--prompt", prompt,
    "--duracion", str(duracion),
    "--calidad", calidad
]
subprocess.run(cmd, check=True, cwd=str(config.MUSIC_GEN_DIR))
```

### 3. Smart Caching Layer

**Files Cached**:
- Generated images (by prompt hash)
- TTS audio files (by text hash)
- Background music (by prompt+duration hash)
- Video clips (by source timestamps)
- Assembled videos (by metadata)

**Cache Invalidation**:
- Manual: `--clean` flag deletes audio/video caches
- Automatic: `necesita_actualizacion()` checks mtimes

**Storage Locations**:
```
outputs/{project}/{episode}/assets/
├── common/                      # Shared across languages
│   ├── img_*.png               # Scene images (cached)
│   └── bg_music_*.wav          # Background music (cached)
├── en/
│   ├── raw/                    # Raw TTS output (cached)
│   └── padding/                # Processed audio (cached)
├── es/
│   ├── raw/
│   └── padding/
└── tmp/                        # Intermediate video clips (can be deleted)
```

### 4. FFmpeg Preset Selection

**Fast Development** (video_assembler.py:31):
```python
'-preset', 'ultrafast'  # Fastest encoding
```

**Production Quality** (main.py:368):
```python
preset="medium",        # Balanced speed/quality
ffmpeg_params=["-crf", "18"]  # High quality (lower = better)
```

**Intro Attachment** (video_assembler.py:139):
```python
'-preset', 'fast'       # Quick final encode
```

### 5. Parallel Language Processing

**Potential Optimization** (not implemented):
Could process ES/EN in parallel threads since they share images but generate separate audio/video.

**Current Architecture**: Sequential per-language loops for simplicity and resource control.

---

## External Dependencies

### Python Packages

**Core Libraries**:
```
torch>=2.0.0              # PyTorch for AI models
diffusers>=0.21.0         # Hugging Face Diffusion
transformers              # Model loading
```

**Media Processing**:
```
moviepy>=1.0.3            # Video editing
soundfile>=0.12.1         # Audio I/O
numpy>=1.24.0             # Numerical operations
scipy>=1.10.0             # Signal processing
imageio>=2.31.0           # Video reading
imageio-ffmpeg            # Bundled FFmpeg
Pillow>=9.5.0             # Image manipulation
```

**TTS Engines**:
```
kokoro-onnx>=1.0.0        # ONNX neural TTS
google-cloud-texttospeech # Google Cloud TTS
melo                      # MeloTTS (optional)
```

**YouTube Integration**:
```
google-auth>=2.16.0
google-auth-oauthlib
google-api-python-client>=2.70.0
```

**Utilities**:
```
python-dotenv             # Environment variables
pyyaml>=6.0               # YAML parsing
python-slugify            # URL slug generation
```

### External Binaries

**FFmpeg**: Via `imageio-ffmpeg` package
- Version: Bundled latest stable
- Used for: All video encoding, decoding, filtering operations

**FFprobe**: Bundled with FFmpeg
- Used for: Duration extraction in web publisher

### External Models

1. **Z-Image-Turbo**
   - Source: Tongyi-MAI/Z-Image-Turbo (Hugging Face)
   - Type: Diffusion-based image generation
   - Size: ~8GB model files
   - Downloaded on first run

2. **Kokoro ONNX v1.0**
   - Source: GitHub releases (thewh1teagle/kokoro-onnx)
   - Files:
     - `kokoro-v1.0.onnx` (model)
     - `voices-v1.0.bin` (voice embeddings)
   - Downloaded automatically by tts_gen.py

3. **MusicGen** (in separate environment)
   - Source: facebook/musicgen-large (Hugging Face)
   - Managed by: music_gen/generador.py
   - Isolated dependency tree

### API Services

**Google Cloud APIs**:
- Text-to-Speech API (Catalan voice)
- Requires: `GOOGLE_API_KEY` in .env

**YouTube Data API v3**:
- Video upload, thumbnail upload, caption upload
- OAuth 2.0 authentication
- Requires: `client_secret.json` (OAuth credentials)

---

## Advanced Topics

### Clean Start Mode

**Flag**: `--clean`

**Behavior** (main.py:69-86):
```python
if clean_start:
    # Delete TMP clips folder
    if self.tmp_compilados_dir.exists():
        shutil.rmtree(self.tmp_compilados_dir)

    # Delete language-specific folders (audio)
    for lang, path in self.lang_assets.items():
        if path.exists():
            shutil.rmtree(path)

    # Preserve common_assets_dir (images are expensive to regenerate)
```

**Use Cases**:
- Audio desync detected (regenerate all clips)
- Changed TTS engine or voice
- Testing audio processing algorithms

**What's Preserved**:
- Generated images (expensive, deterministic from prompts)
- Background music (expensive, cached by prompt hash)

### Publish-Only Mode

**Flag**: `--publish-only`

**Purpose**: Regenerate web content without video generation (fast metadata updates).

**Implementation** (main.py:114-136):
```python
if self.publish_only:
    self.logger.info("♻️ MODO PUBLISH-ONLY: Saltando generación...")

    # Try to recover duration from existing video
    final_path_es = self.video_dir / f"{prefix}{l_code.upper()}-{title}.mp4"
    if final_path_es.exists():
        duracion_real_es = self.media_tools.obtener_duracion_video(final_path_es)

    # Jump directly to web publishing
    self.web_publisher.publish(self.script_path, self.video_dir, duration_es_raw=duracion_real_es)
    return  # Exit early
```

**Use Cases**:
- Update SEO metadata in JSON
- Change thumbnail text variants
- Fix web platform YAML errors
- Bulk metadata refreshes

### Multi-Language Support Architecture

**Supported Languages**:
- `es`: Spanish (Kokoro or Google)
- `en`: English (Kokoro)
- `ca`: Catalan (Google Cloud TTS only)
- `es_free`: Spanish (MeloTTS if available, else Kokoro)

**Language Selection**:
```bash
# Process only English
python main.py --project beyondCarbon --file episode.json --lang en

# Process Spanish and English
python batch_runner.py --project beyondCarbon --lang es en
```

**Internal Handling**:
Each language gets:
- Separate asset folder: `assets/en/`, `assets/es/`
- Separate TTS audio files
- Separate video output
- Separate YouTube channel (via token files)
- Separate web content files

**Shared Resources**:
- Scene images (in `assets/common/`)
- Background music (in `assets/common/`)
- Thumbnails (separate but from shared base)

---

## Maintenance & Debugging

### Common Issues

**1. Out of Memory (CUDA)**
- **Symptom**: `CUDA out of memory` during image generation
- **Solution**:
  - Reduce image resolution in image_gen.py
  - Enable more aggressive CPU offloading
  - Close other GPU applications

**2. Audio Desync Over Time**
- **Symptom**: Audio drifts from video in long videos
- **Solution**:
  - Frame-perfect padding is already implemented
  - If still occurring, verify FPS_VIDEO matches export fps (both should be 24 or 30)

**3. Music Generation Timeout**
- **Symptom**: Subprocess hangs when generating music
- **Solution**:
  - Check music_gen environment is properly set up
  - Verify MUSIC_VENV_PYTHON path in config.py
  - Test music_gen/generador.py standalone

**4. YouTube Upload Fails**
- **Symptom**: OAuth errors or quota exceeded
- **Solution**:
  - Delete `token_{project}_{lang}.pickle` to refresh OAuth
  - Check Google Cloud Console quota limits
  - Verify `client_secret.json` is valid

**5. Web Publishing Path Errors**
- **Symptom**: Files not copied to web platform
- **Solution**:
  - Verify paths in web_publisher.py (lines 12-15)
  - Ensure Z-content-platform repo exists at expected location
  - Check filesystem permissions

### Debug Logging

**Enable Verbose FFmpeg Output**:
```python
# In video_assembler.py, remove stdout/stderr suppression:
subprocess.run(cmd, check=True)  # Remove DEVNULL arguments
```

**Log File Location**:
```
outputs/{project}/{episode}/logs/{title}_{timestamp}.log
```

**Inspect Intermediate Files**:
```
outputs/{project}/{episode}/assets/tmp/
├── temp_voz_es.mp4          # Voice-only video
├── temp_mix_es.mp4          # Voice + music mixed
└── *.txt                    # FFmpeg concat lists
```

---

## Future Enhancement Opportunities

### Potential Improvements

1. **Parallel Language Generation**
   - Process ES/EN simultaneously using threading
   - Would reduce total execution time by ~40%

2. **GPU Queue Management**
   - Batch image generation for entire episode
   - More efficient GPU utilization

3. **Incremental Scene Updates**
   - Regenerate only changed scenes
   - Requires scene-level dependency tracking

4. **Cloud Storage Integration**
   - Upload to S3/GCS instead of local files
   - Enable distributed processing

5. **Real-time Preview**
   - Generate low-quality preview first
   - Allow approval before full render

6. **A/B Testing Framework**
   - Generate multiple thumbnail variants
   - Track performance metrics
   - Auto-select best performers

7. **Automatic Retry Logic**
   - Retry failed API calls (TTS, image gen)
   - Exponential backoff
   - Fallback to alternative engines

---

## Conclusion

Z-Image-Turbo represents a mature, production-ready AI content pipeline with:
- **Modularity**: Clean separation of concerns
- **Robustness**: Comprehensive error handling and caching
- **Performance**: GPU optimization and smart resource management
- **Scalability**: Batch processing and multi-language support
- **Integration**: YouTube upload and web platform publishing

The codebase demonstrates advanced software engineering practices including factory patterns, subprocess isolation, frame-perfect synchronization, and intelligent caching strategies.

For implementation details, refer to the source code with this wiki as a conceptual guide.

---

**Document Version**: 1.0
**Last Updated**: 2025-01-15
**Maintainer**: Z-Image-Turbo Development Team
