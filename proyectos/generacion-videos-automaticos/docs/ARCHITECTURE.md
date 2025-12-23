# Z-Image-Turbo Architecture

## Table of Contents
1. [System Overview](#system-overview)
2. [Architectural Principles](#architectural-principles)
3. [High-Level Architecture](#high-level-architecture)
4. [Component Architecture](#component-architecture)
5. [Data Architecture](#data-architecture)
6. [Processing Pipeline](#processing-pipeline)
7. [Deployment Architecture](#deployment-architecture)
8. [Security Architecture](#security-architecture)
9. [Performance Architecture](#performance-architecture)
10. [Integration Architecture](#integration-architecture)

---

## System Overview

### Purpose
Z-Image-Turbo is an **AI-Powered Automated Video Production Factory** designed to transform JSON-based scripts into professional, multi-language video content with automatic distribution to YouTube and web platforms.

### System Type
**Batch Processing Pipeline** with orchestrated AI model execution and media assembly.

### Key Characteristics
- **Deterministic**: Same input JSON produces identical output (modulo AI randomness seeds)
- **Resumable**: Failed executions can resume from cached intermediates
- **Scalable**: Processes single videos or large batches with error isolation
- **Multi-tenant**: Supports multiple projects and languages simultaneously

---

## Architectural Principles

### 1. Separation of Concerns
Each module has a single, well-defined responsibility:
- **Generators**: Create content (images, audio, music)
- **Editors**: Assemble and transform media
- **Uploaders**: Distribute content to platforms
- **Utils**: Cross-cutting services (logging, caching, file management)
- **Workflows**: Orchestrate multi-step processes

### 2. Dependency Injection
All dependencies are injected through constructors:
```python
class VideoFactory:
    def __init__(self, script_path, project_name, ...):
        self.logger = setup_logger(...)
        self.img_gen = ImageGenerator(self.logger)
        self.tts_gen = TTSGenerator(self.logger, config.GOOGLE_API_KEY)
        self.assembler = VideoAssembler(self.logger)
        # ...
```

**Benefits**:
- Testability (mock dependencies)
- Flexibility (swap implementations)
- Clear dependency graph

### 3. Fail-Safe Defaults
System never fails silently:
- Missing API keys → Log warning, skip optional features
- Failed uploads → Log error, continue processing
- Cache misses → Regenerate content transparently

### 4. Immutability Where Possible
Source files are never modified:
- JSON scripts are read-only
- Generated assets are additive (never overwrite unless intentional)
- Clean start requires explicit `--clean` flag

### 5. Idempotency
Running the pipeline multiple times produces same result:
- Cache checks prevent redundant work
- Deterministic file naming
- Timestamp-based invalidation

---

## High-Level Architecture

### Layered Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                          │
│  ┌──────────────┐              ┌──────────────┐                │
│  │ main.py      │              │batch_runner  │                │
│  │ (CLI)        │              │.py (CLI)     │                │
│  └──────────────┘              └──────────────┘                │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION LAYER                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              VideoFactory (main.py)                     │   │
│  │  - Phase 0: Preparation                                 │   │
│  │  - Phase 1: Thumbnails                                  │   │
│  │  - Phase 2: Scene Processing                            │   │
│  │  - Phase 3: Music Generation                            │   │
│  │  - Phase 4: Assembly & Distribution                     │   │
│  │  - Phase 5: Web Publishing                              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      WORKFLOW LAYER                             │
│  ┌──────────────────────┐                                       │
│  │ ThumbnailWorkflow    │  (Complex multi-step operations)      │
│  └──────────────────────┘                                       │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐               │
│  │ Generators │  │  Editors   │  │ Uploaders  │               │
│  ├────────────┤  ├────────────┤  ├────────────┤               │
│  │ ImageGen   │  │ Assembler  │  │ YouTube    │               │
│  │ TTSGen     │  │ Sanitizer  │  │ Uploader   │               │
│  │ MusicGen   │  │            │  │ Web        │               │
│  │ SubtitleGen│  │            │  │ Publisher  │               │
│  └────────────┘  └────────────┘  └────────────┘               │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                   INFRASTRUCTURE LAYER                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Logger  │  │  Files   │  │  Media   │  │  Config  │       │
│  │          │  │  Cache   │  │  Tools   │  │          │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SYSTEMS                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ HuggingF │  │ Google   │  │ YouTube  │  │ FFmpeg   │       │
│  │ ace      │  │ Cloud    │  │ API      │  │          │       │
│  │ Models   │  │ TTS      │  │          │  │          │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow Overview

```
[JSON Script] → [VideoFactory] → [Assets] → [Video Files] → [YouTube/Web]
                      ↓
                [AI Models]
                      ↓
                [Cache Layer]
```

---

## Component Architecture

### 1. Core Orchestrator: VideoFactory

**Location**: `main.py`

**Responsibility**: End-to-end video production orchestration

**Architecture Pattern**: **Facade + Template Method**

```python
class VideoFactory:
    # Facade: Provides simple interface to complex subsystem
    def __init__(self, ...):
        # Aggregate all subsystems
        self.img_gen = ImageGenerator(...)
        self.tts_gen = TTSGenerator(...)
        self.music_gen = MusicGenerator(...)
        self.assembler = VideoAssembler(...)
        self.uploader = YoutubeUploader()
        self.web_publisher = WebPublisher(...)

    # Template Method: Defines algorithm structure
    def run(self):
        self._fase_preparacion()
        self._fase_thumbnails()
        self._procesar_escenas()      # Extensible
        self._gestionar_musica()
        self._fase_final()
        self._publicar_web()
```

**Key Design Decisions**:
- **Why Facade?**: Hides complexity of 10+ subsystems behind single interface
- **Why Template Method?**: Allows customization of steps without changing algorithm
- **Trade-offs**: Centralized control (single point of failure) vs. simplicity

### 2. Generator Components

#### Architecture Pattern: **Strategy Pattern**

**Example: TTSGenerator**

```python
class TTSGenerator:
    def generar_kokoro(self, ...): pass
    def generar_google(self, ...): pass
    def generar_melo(self, ...): pass

# Selection logic in main.py:
if lang == "es":
    self.tts_gen.generar_kokoro(...)
elif lang == "ca":
    self.tts_gen.generar_google(...)
```

**Benefits**:
- Easy to add new TTS engines
- Runtime engine selection
- Isolated engine-specific code

#### Lazy Loading Pattern

**Example: ImageGenerator**

```python
class ImageGenerator:
    def __init__(self, logger):
        self.pipe = None  # Not loaded yet

    def _cargar_modelo(self):
        if self.pipe is None:
            # Load expensive model only when needed
            self.pipe = DiffusionPipeline.from_pretrained(...)
```

**Why**:
- Models consume 8GB+ memory
- Batch mode might not need all modules
- Faster startup time

### 3. Editor Components

#### Architecture Pattern: **Command Pattern** (Implicit)

Each method in `VideoAssembler` is a reusable command:

```python
class VideoAssembler:
    def crear_clip(self, imagen, audio, salida):
        # Command: Create video clip
        cmd = [self.ffmpeg, '-loop', '1', '-i', imagen, ...]
        subprocess.run(cmd)

    def unir_clips(self, lista_videos, salida):
        # Command: Concatenate clips
        cmd = [self.ffmpeg, '-f', 'concat', ...]
        subprocess.run(cmd)

    def mezclar_audio_fondo(self, ...):
        # Command: Mix audio tracks
        cmd = [self.ffmpeg, '-filter_complex', ...]
        subprocess.run(cmd)
```

**Benefits**:
- Each operation is atomic and reusable
- Easy to test individual commands
- Clear failure boundaries

### 4. Uploader Components

#### Architecture Pattern: **Adapter Pattern**

`YoutubeUploader` adapts Google API to domain model:

```python
class YoutubeUploader:
    def upload_video(self, video_path, metadata, channel_type, ...):
        # Adapt domain metadata to YouTube API format
        body = {
            'snippet': {
                'title': metadata['title'],
                'description': metadata['description'],
                'defaultLanguage': self._map_language(channel_type)
            }
        }
        # Call external API
        youtube.videos().insert(body=body, ...)
```

**Why Adapter**:
- Isolates YouTube API changes
- Domain logic uses simple dicts, not API objects
- Easy to add other platforms (Vimeo, etc.)

### 5. Workflow Components

#### Architecture Pattern: **Workflow Pattern**

`ThumbnailWorkflow` orchestrates thumbnail generation:

```python
class ThumbnailWorkflow:
    def ejecutar(self, idiomas, data, titulo):
        for lang in idiomas:
            # Step 1: Generate base image
            self.img_gen.generar(prompt, raw_path)

            # Step 2: Create text variants
            self._crear_variantes(raw_path, seo_data)

    def _crear_variantes(self, raw_path, seo_data):
        for variant in seo_data.get("variants"):
            # Render text on image
            self.text_renderer.render_text(raw_path, texto, output)
```

**Benefits**:
- Encapsulates complex multi-step logic
- Reusable across projects
- Testable as unit

---

## Data Architecture

### Input Data Structure

**Primary Input**: JSON script files

**Schema** (conceptual):
```json
{
  "project_title": "Episode Title",
  "saga": 1,
  "episode": 22,
  "date_published": "2025-01-15T18:00:00Z",
  "global_music_prompt": "Cinematic orchestral ambient",

  "scenes": [
    {
      "scene_id": 0,
      "image_prompt": "Alien forest, bioluminescent plants, 4K",
      "script_es": "En un planeta lejano...",
      "script_en": "On a distant planet...",
      "chapter_es": "Introducción",
      "chapter_en": "Introduction"
    }
  ],

  "seo": {
    "es": {
      "variants": [
        {
          "title": "El Bosque que te Mataría",
          "thumb_text": "EL BOSQUE MÁS PELIGROSO"
        }
      ],
      "description": "...",
      "tags": ["biología", "ciencia"],
      "thumbnail_prompt": "Dangerous alien forest"
    },
    "en": { ... }
  }
}
```

### Output Data Structure

**Directory Structure**:
```
outputs/
└── {project_name}/
    └── {episode_name}/
        ├── S01E22-ES-Título.mp4          # Final Spanish video
        ├── S01E22-EN-Title.mp4           # Final English video
        ├── thumbnail_es.png              # Official thumbnails
        ├── thumbnail_en.png
        ├── subtitles_es.srt              # Subtitle files
        ├── subtitles_en.srt
        ├── logs/                         # Execution logs
        │   └── Episode_Title_20250115_143022.log
        └── assets/
            ├── common/                   # Shared across languages
            │   ├── img_0.png
            │   ├── img_1.png
            │   └── bg_music_common_abc123_600s.wav
            ├── es/
            │   ├── raw/
            │   │   └── audio_es_0_hash_raw.wav
            │   └── padding/
            │       └── audio_es_0_hash.wav
            ├── en/
            │   ├── raw/
            │   └── padding/
            ├── tmp/                      # Intermediate clips
            │   ├── temp_voz_es.mp4
            │   └── temp_mix_es.mp4
            └── thumbnails/
                ├── thumbnail_raw_es.png
                ├── thumbnail_es_v1.png
                └── thumbnail_es_v2.png
```

### Data Flow Diagram

```
┌──────────────┐
│  JSON Script │
└──────┬───────┘
       │
       ├─────────────────────────┐
       │                         │
       ▼                         ▼
┌──────────────┐         ┌──────────────┐
│ Scene Prompts│         │ SEO Metadata │
└──────┬───────┘         └──────┬───────┘
       │                         │
       ▼                         ▼
┌──────────────┐         ┌──────────────┐
│  AI Models   │         │  Thumbnails  │
│  - Images    │         │  - Base Gen  │
│  - TTS       │         │  - Text Ovly │
│  - Music     │         └──────┬───────┘
└──────┬───────┘                │
       │                         │
       ▼                         │
┌──────────────┐                │
│ Media Assets │                │
│  - PNGs      │                │
│  - WAVs      │                │
└──────┬───────┘                │
       │                         │
       │       ┌─────────────────┘
       │       │
       ▼       ▼
┌──────────────────────┐
│   Video Assembler    │
│   - Clip Creation    │
│   - Concatenation    │
│   - Audio Mixing     │
│   - Intro Attachment │
└──────┬───────────────┘
       │
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│   YouTube    │  │ Web Platform │
│   Upload     │  │  Publishing  │
└──────────────┘  └──────────────┘
```

---

## Processing Pipeline

### Phase 0: Preparation

**Objective**: Setup execution context

**Operations**:
1. Parse JSON metadata
2. Extract saga/episode from filename
3. Create directory structure
4. Initialize logging
5. Organize existing audio files (migration)
6. Calculate intro video duration

**Output**: Initialized VideoFactory instance

### Phase 1: Thumbnail Generation

**Objective**: Create video thumbnails with text overlays

**Workflow**:
```
For each language:
  1. Load SEO metadata
  2. Determine thumbnail prompt (fallback to scene[0])
  3. Generate base image (1280x720) via ImageGenerator
  4. For each text variant:
     a. Calculate text layout
     b. Render text with PIL (TextRenderer)
     c. Save variant
  5. Copy variant #1 as official thumbnail
```

**Output**:
- `thumbnail_{lang}.png` (official)
- `thumbnail_{lang}_v{n}.png` (variants)

### Phase 2: Scene Processing (Core Loop)

**Objective**: Generate and synchronize all media assets

**Algorithm**:
```python
assets_por_idioma = {lang: [] for lang in languages}
max_duration = 0

for scene in scenes:
    # A. Generate shared image (cached)
    if not exists(image_path):
        ImageGenerator.generar(scene.image_prompt, image_path)

    # B. Process per language
    for lang in languages:
        # 1. Generate raw TTS audio
        text = scene[f"script_{lang}"]
        if not exists(raw_audio_path):
            TTSGenerator.generar(text, raw_audio_path, lang)

        # 2. Process audio (fades + padding)
        if not exists(final_audio_path):
            data = load_audio(raw_audio_path)

            # Apply fade-in (20ms)
            data[:fade_in_samples] *= np.linspace(0, 1, fade_in_samples)

            # Apply fade-out (50ms)
            data[-fade_out_samples:] *= np.linspace(1, 0, fade_out_samples)

            # Calculate frame-perfect duration
            current_duration = len(data) / samplerate
            target_frames = ceil(current_duration * FPS) + 1
            target_samples = (target_frames / FPS) * samplerate

            # Pad with silence
            padding = target_samples - len(data)
            data = concatenate([data, zeros(padding)])

            save_audio(final_audio_path, data)

        # 3. Record asset metadata
        duration = get_duration(final_audio_path)
        assets_por_idioma[lang].append({
            "img_path": image_path,
            "audio_path": final_audio_path,
            "duration": duration
        })

        # 4. Generate subtitle fragment
        srt_fragment = SubtitleGenerator.generar_fragmentado(
            text, time_cursor, duration
        )
        datos_seg[lang]["srt"] += srt_fragment

        # 5. Track chapters
        if scene.chapter != last_chapter:
            datos_seg[lang]["caps"] += f"{timestamp} {scene.chapter}\n"

        # 6. Update time cursor
        datos_seg[lang]["time"] += duration
        max_duration = max(max_duration, datos_seg[lang]["time"])
```

**Output**:
- Image files: `assets/common/img_{id}.png`
- Audio files: `assets/{lang}/padding/audio_{lang}_{id}_hash.wav`
- Metadata: `assets_por_idioma` dict with all asset paths
- Subtitle data: SRT fragments
- Chapter markers: Timestamp list

**Critical Feature**: Frame-perfect audio padding ensures no drift

### Phase 3: Music Generation

**Objective**: Create loopable background music

**Flow**:
```
1. Calculate required duration:
   duration_needed = max_duration * 1.05 + margin

2. Generate prompt hash:
   prompt_hash = md5(music_prompt)[:8]

3. Check cache:
   pattern = f"bg_music_common_{prompt_hash}_*.wav"
   if cached_file exists and duration >= needed:
       return cached_file

4. Generate via subprocess:
   subprocess.run([
       music_venv_python,
       music_gen_script,
       "--prompt", music_prompt,
       "--duracion", duration_needed,
       "--calidad", "ultra"
   ])

5. Return path to generated WAV
```

**Output**: `assets/common/bg_music_common_{hash}_{duration}s.wav`

**Architecture Note**: Isolated subprocess prevents dependency conflicts

### Phase 4: Assembly & Distribution

**Objective**: Create final videos and upload

**Per-Language Workflow**:
```
1. Save subtitle file:
   subtitles_{lang}.srt

2. Assemble video (Synchronized Method):
   a. For each asset:
      - Load audio clip
      - Create image clip with EXACT audio duration
      - Append to clips list

   b. Concatenate all video clips
   c. Concatenate all audio clips

   d. Mix audio:
      - Load music
      - Loop music to match audio length
      - Reduce music volume to 8%
      - Composite voice + music

   e. Attach mixed audio to video
   f. Prepend intro video

   g. Export to MP4:
      - fps=24
      - codec=libx264
      - preset=medium
      - crf=18 (high quality)

3. [Optional] Sanitize video:
   - Apply speed variation (±2%)
   - Add visual noise
   - Strip metadata

4. Upload to YouTube:
   a. Authenticate (OAuth 2.0)
   b. Upload video with metadata
   c. Upload thumbnail
   d. Upload subtitles

   Return: video_id
```

**Output**:
- Final video: `S01E22-{LANG}-Title.mp4`
- YouTube video ID (if uploaded)

### Phase 5: Web Publishing

**Objective**: Export content to web platform

**Workflow**:
```
1. Determine saga and episode numbers from filename

2. Update saga metadata:
   - Create/update meta.en.yaml and meta.es.yaml
   - Set is_complete=true if episode >= 10

3. For each language:
   a. Copy video file to web platform assets
   b. Copy thumbnail
   c. If episode 1: Update saga cover image

   d. Load markdown essay from source
   e. Clean frontmatter from markdown

   f. Generate new frontmatter:
      - Extract SEO metadata from JSON
      - Calculate video duration (rounded to minute)
      - Format tags and keywords
      - Set publication date

   g. Write content.{lang}.md:
      ---
      {YAML frontmatter}
      ---

      {Markdown body}

4. Log success
```

**Output**:
- Web platform directory structure populated
- Markdown files with frontmatter
- Assets copied and ready for deployment

---

## Deployment Architecture

### Local Development Setup

```
Project Root/
├── Z-Image-Turbo/              # Main project
│   ├── main.py
│   ├── batch_runner.py
│   ├── config.py
│   ├── .env                    # API keys
│   ├── client_secret.json      # YouTube OAuth
│   ├── modules/
│   ├── inputs/
│   │   ├── scripts/
│   │   │   └── beyondCarbon/
│   │   │       └── SAGA_01_Episode_*.json
│   │   └── assets/
│   │       └── beyondCarbon/
│   │           └── intro_1920x1072.mp4
│   └── outputs/
│
├── music_gen/                  # Isolated music module
│   ├── venv_music/             # Separate Python environment
│   │   └── Scripts/
│   │       └── python.exe
│   ├── generador.py
│   └── requirements.txt
│
└── Z-content-platform/         # Web publishing target
    └── data/sites/specbio/
```

### Environment Requirements

**Hardware**:
- GPU: NVIDIA RTX 3060 (12GB VRAM) or better
- RAM: 32GB recommended
- Storage: 50GB free space per project
- CPU: 8+ cores for FFmpeg encoding

**Software**:
- Python 3.10+
- CUDA 11.8+ (for PyTorch)
- Windows/Linux/macOS (tested on Windows)

### Configuration Management

**Environment Variables** (.env):
```
GOOGLE_API_KEY=your_google_cloud_api_key
```

**Python Configuration** (config.py):
- All paths use `pathlib.Path`
- Relative to project root
- Platform-independent

**External Configs**:
- `client_secret.json`: YouTube OAuth credentials
- `token_{project}_{lang}.pickle`: Cached OAuth tokens

---

## Security Architecture

### Authentication & Authorization

**YouTube OAuth 2.0 Flow**:
```
1. Check for cached token (token_{project}_{lang}.pickle)
2. If valid: Use cached credentials
3. If expired:
   a. Try refresh with refresh_token
   b. If refresh fails: Delete cache, restart OAuth
4. If no token:
   a. Launch local web server (random port)
   b. Open browser for user consent
   c. Receive authorization code
   d. Exchange for access token + refresh token
   e. Save to pickle file
```

**Credential Isolation**:
- Per-project tokens (prevents cross-contamination)
- Per-language tokens (separate YouTube channels)
- Local storage only (no cloud sync)

### API Key Management

**Google Cloud TTS**:
- API key stored in `.env` file
- File excluded from git (`.gitignore`)
- Fallback if key missing (skips Google TTS)

**Best Practices**:
- Never commit `.env` or `client_secret.json`
- Rotate keys regularly
- Use service accounts for production

### Content Security

**Anti-Fingerprinting** (video_security.py):
- Purpose: Prevent automated content ID matching
- Techniques:
  1. Speed modulation (imperceptible to humans)
  2. Visual noise injection
  3. Metadata stripping
- Ethical use: Only for original content protection

**File System Security**:
- No execution of user-provided code
- All subprocess calls use explicit argument lists (no shell=True)
- Path traversal protection (uses absolute paths)

---

## Performance Architecture

### Optimization Strategies

#### 1. Lazy Loading

**Models loaded only when needed**:
```python
# ImageGenerator
if self.pipe is None:  # Load on first use
    self.pipe = DiffusionPipeline.from_pretrained(...)

# TTSGenerator
if not self.model_kokoro:  # Load on first TTS call
    self.model_kokoro = Kokoro(...)
```

**Impact**: Saves 30+ seconds startup time if module not used

#### 2. Multi-Level Caching

**Cache Hierarchy**:

| Level | Invalidation | Example |
|-------|--------------|---------|
| Asset Cache | Manual (`--clean`) or source change | Generated images, audio |
| Video Clip Cache | Source audio/image change | Individual MP4 clips |
| Final Video Cache | Metadata change | Assembled videos |

**Cache Check Algorithm**:
```python
if output_exists and no_inputs_changed:
    return cached_output  # Skip expensive operation
```

**Impact**: Reduces re-generation time from 60min to 5min for metadata changes

#### 3. GPU Memory Management

**Techniques**:
```python
# Sequential CPU offloading
pipe.enable_sequential_cpu_offload()
# Keeps only active layer on GPU

# VAE tiling
pipe.vae.enable_tiling()
# Processes large images in tiles
```

**Impact**: Enables 1920x1072 generation on 12GB VRAM (vs. 24GB required without optimization)

#### 4. FFmpeg Preset Selection

**Development**:
```bash
-preset ultrafast    # 10x faster encoding
-crf 23             # Medium quality
```

**Production**:
```bash
-preset medium      # Balanced
-crf 18            # High quality (near-lossless)
```

**Impact**: Development renders 5x faster, production quality +30% better

#### 5. Subprocess Isolation

**MusicGen in separate process**:
- Prevents memory leaks
- Allows different PyTorch versions
- GPU memory is freed after generation

**Impact**: Enables coexistence of incompatible dependencies

### Scalability Considerations

**Horizontal Scaling** (future):
- Each video is independent
- Batch processing can be parallelized across machines
- Shared network storage for models

**Vertical Scaling** (current):
- Multi-language processing is sequential
- Could parallelize with threading (2x speedup potential)

**Bottlenecks**:
1. **Image Generation**: 10-15s per image (GPU-bound)
2. **TTS Generation**: 5-10s per scene (CPU-bound)
3. **Video Encoding**: 30-60s per video (CPU-bound)

**Estimated Processing Time**:
- 10-scene episode: 15-20 minutes per language
- Full batch (10 episodes): 3-4 hours

---

## Integration Architecture

### External System Integrations

#### 1. Hugging Face Hub

**Purpose**: Model downloading and caching

**Integration Point**: `image_gen.py`

**Architecture**:
```python
DiffusionPipeline.from_pretrained(
    "Tongyi-MAI/Z-Image-Turbo",
    torch_dtype=torch.bfloat16,
    trust_remote_code=True  # Downloads custom model code
)
```

**Caching**: Models cached in `~/.cache/huggingface/`

**Failure Handling**: Requires internet on first run, then works offline

#### 2. Google Cloud TTS API

**Purpose**: Catalan voice generation

**Integration Point**: `tts_gen.py`

**Architecture**: REST API via `requests`

```python
url = f"https://texttospeech.googleapis.com/v1/text:synthesize?key={api_key}"
payload = {
    "input": {"text": text},
    "voice": {"languageCode": "ca-ES", "name": "ca-ES-Standard-B"},
    "audioConfig": {"audioEncoding": "MP3"}
}
response = requests.post(url, json=payload)
audio_content = base64.b64decode(response.json()["audioContent"])
```

**Rate Limiting**: None implemented (API has generous limits)

**Error Handling**: Logs error, skips TTS for that scene

#### 3. YouTube Data API v3

**Purpose**: Video/thumbnail/caption upload

**Integration Point**: `uploader.py`

**Architecture**: Google API Client library

```python
youtube = build('youtube', 'v3', credentials=creds)

# Video upload (resumable)
request = youtube.videos().insert(
    part='snippet,status',
    body=body,
    media_body=MediaFileUpload(video_path, chunksize=-1, resumable=True)
)

# Thumbnail upload
youtube.thumbnails().set(
    videoId=video_id,
    media_body=thumbnail_path
).execute()

# Caption upload
youtube.captions().insert(
    part='snippet',
    body=caption_body,
    media_body=MediaFileUpload(srt_path, mimetype='application/x-subrip')
).execute()
```

**Quota Management**:
- Daily quota: 10,000 units
- Video upload: ~1,600 units
- Manual monitoring required

**Retry Logic**: None implemented (fails fast on errors)

#### 4. FFmpeg (Binary Integration)

**Purpose**: All video/audio processing

**Integration Point**: `video_assembler.py`

**Architecture**: Subprocess execution

```python
cmd = [config.FFMPEG_BINARY, '-y', '-i', input_file, ...]
subprocess.run(cmd, check=True, stdout=DEVNULL, stderr=PIPE)
```

**Error Handling**: Captures stderr, logs error message

**Performance**: All operations run with suppressed output for speed

#### 5. Web Platform (File System Integration)

**Purpose**: Export content to separate web project

**Integration Point**: `web_publisher.py`

**Architecture**: Direct file system operations

```python
# Copy video
shutil.copy2(source_video, target_dir / video_name)

# Copy thumbnail
shutil.copy2(source_thumb, target_dir / "thumbnail_en.png")

# Write markdown with frontmatter
with open(target_dir / "content.en.md", "w") as f:
    f.write("---\n")
    yaml.dump(frontmatter, f)
    f.write("---\n\n")
    f.write(markdown_body)
```

**Coupling**: Hardcoded paths (tight coupling)

**Future**: Could use REST API or message queue

---

## Technology Decisions

### Key Architectural Decisions

#### Decision 1: Monolithic vs. Microservices

**Choice**: **Monolithic (with modular design)**

**Rationale**:
- Single-machine deployment sufficient
- Shared GPU resources (can't split across services)
- Simplified dependency management
- Easier debugging and development

**Trade-off**: Limited horizontal scalability (acceptable for current scale)

#### Decision 2: Synchronous vs. Asynchronous Processing

**Choice**: **Synchronous pipeline**

**Rationale**:
- GPU operations can't run in parallel (single GPU)
- Deterministic execution order simplifies debugging
- Batch mode provides parallelism at episode level

**Trade-off**: Longer total execution time (acceptable for overnight batch jobs)

#### Decision 3: Database vs. File System

**Choice**: **File system for all persistence**

**Rationale**:
- Media files must be on disk anyway
- No complex queries needed
- Simplifies deployment (no DB server)
- File system is the cache

**Trade-off**: No ACID guarantees, manual cache management

#### Decision 4: REST API vs. CLI

**Choice**: **CLI with Python imports**

**Rationale**:
- Local execution model
- Direct Python object access (performance)
- Simpler error handling
- No network serialization overhead

**Trade-off**: Can't expose as web service (not needed)

#### Decision 5: Subprocess Isolation for MusicGen

**Choice**: **Separate Python environment via subprocess**

**Rationale**:
- Incompatible PyTorch versions (main: 2.x, MusicGen: 1.x)
- Transformers version conflicts
- GPU memory isolation

**Trade-off**: IPC overhead (acceptable for long-running music generation)

---

## Evolution & Extensibility

### Extension Points

**1. New TTS Engines**:
```python
# Add method to TTSGenerator
def generar_elevenlabs(self, texto, path, ...):
    # Implementation

# Update main.py dispatch logic
if lang == "en-premium":
    self.tts_gen.generar_elevenlabs(...)
```

**2. New Upload Targets**:
```python
# Create new uploader class
class VimeoUploader:
    def upload_video(self, ...):
        # Vimeo API implementation

# Add to VideoFactory
self.vimeo_uploader = VimeoUploader()
```

**3. New Processing Phases**:
```python
# In VideoFactory.run()
def run(self):
    # ...existing phases...
    self._fase_subtitulos_avanzados()  # New phase
    self._fase_analytics()             # New phase
```

### Migration Paths

**To Cloud Deployment**:
1. Replace local file paths with S3/GCS URLs
2. Add distributed task queue (Celery)
3. Separate GPU workers (image/music) from CPU workers (assembly)
4. Add database for job tracking

**To Real-Time Generation**:
1. Pre-generate asset library
2. Use faster models (SDXL-Turbo for images)
3. Streaming assembly (progressive video generation)
4. WebSocket for progress updates

---

## Conclusion

Z-Image-Turbo's architecture reflects pragmatic decisions for its use case:
- **Modular monolith**: Simple deployment, clear boundaries
- **File-based caching**: Optimal for media-heavy workflow
- **Subprocess isolation**: Solves incompatible dependency problem elegantly
- **Phase-based pipeline**: Clear progress tracking, resumable execution

The architecture prioritizes **developer productivity** and **execution reliability** over theoretical scalability, which aligns with the batch processing use case.

Future enhancements should maintain these principles while adding capabilities incrementally.

---

**Document Version**: 1.0
**Last Updated**: 2025-01-15
**Reviewed By**: Architecture Team
