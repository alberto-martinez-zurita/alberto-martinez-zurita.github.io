# Z-Image-Turbo How-To Guide

## Table of Contents
1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [Project Setup](#project-setup)
4. [Creating Scripts](#creating-scripts)
5. [Running the Factory](#running-the-factory)
6. [Batch Processing](#batch-processing)
7. [YouTube Upload Setup](#youtube-upload-setup)
8. [Web Publishing Setup](#web-publishing-setup)
9. [Common Workflows](#common-workflows)
10. [Troubleshooting](#troubleshooting)
11. [Best Practices](#best-practices)
12. [Advanced Usage](#advanced-usage)

---

## Quick Start

**Goal**: Generate your first video in 5 minutes

### Prerequisites Check
```bash
# 1. Python version
python --version  # Should be 3.10+

# 2. GPU check (Windows)
nvidia-smi  # Should show your GPU

# 3. CUDA check
python -c "import torch; print(torch.cuda.is_available())"  # Should print True
```

### Minimal Example

**Step 1**: Create a simple script (`inputs/scripts/test/episode_01.json`):
```json
{
  "project_title": "My First Video",
  "saga": 1,
  "episode": 1,
  "global_music_prompt": "calm ambient music",
  "scenes": [
    {
      "scene_id": 0,
      "image_prompt": "Beautiful sunset over mountains, 4K, cinematic",
      "script_es": "Bienvenido a mi primer video generado por IA.",
      "script_en": "Welcome to my first AI-generated video."
    }
  ],
  "seo": {
    "es": {
      "variants": [{"title": "Mi Primer Video", "thumb_text": "MI PRIMER VIDEO"}],
      "description": "Este es mi primer video",
      "tags": ["test", "demo"]
    },
    "en": {
      "variants": [{"title": "My First Video", "thumb_text": "MY FIRST VIDEO"}],
      "description": "This is my first video",
      "tags": ["test", "demo"]
    }
  }
}
```

**Step 2**: Run the factory:
```bash
python main.py --project test --file episode_01.json --no-upload
```

**Step 3**: Find your video in `outputs/test/episode_01/`

---

## Installation

### System Requirements

**Hardware**:
- NVIDIA GPU with 12GB+ VRAM (RTX 3060 or better)
- 32GB RAM
- 50GB free disk space
- Windows 10/11 or Linux

**Software**:
- Python 3.10 or newer
- CUDA Toolkit 11.8+
- Git (for cloning)

### Step 1: Clone Repository

```bash
cd C:/Users/YourName/Documents/workspace/proyectos-ai/
git clone <repository-url> Z-Image-Turbo
cd Z-Image-Turbo
```

### Step 2: Create Virtual Environment

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install Dependencies

```bash
# Upgrade pip
python -m pip install --upgrade pip

# Install requirements
pip install -r requirements.txt

# Verify installation
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')"
```

**Expected Output**:
```
PyTorch: 2.0.1+cu118
CUDA: True
```

### Step 4: Configure API Keys

Create `.env` file in project root:
```bash
# .env
GOOGLE_API_KEY=your_google_cloud_api_key_here
```

**Optional**: If you don't have Google API key, the system will use Kokoro for all TTS (no Catalan support).

### Step 5: Set Up Music Generator (Separate Environment)

**Why separate?**: MusicGen requires incompatible PyTorch version.

```bash
# Navigate to parent directory
cd ..

# Create music_gen directory
mkdir music_gen
cd music_gen

# Create separate virtual environment
python -m venv venv_music
venv_music\Scripts\activate  # Windows
# source venv_music/bin/activate  # Linux/Mac

# Install music dependencies
pip install torch==1.13.1 torchvision torchaudio
pip install transformers scipy audiocraft

# Create generador.py (music generation script)
# Copy from music_gen example or create based on documentation

# Test
python generador.py --prompt "test music" --duracion 30 --filename test
```

### Step 6: Update config.py

Verify paths in `Z-Image-Turbo/config.py`:
```python
# Check these paths match your setup
MUSIC_GEN_DIR = WORKSPACE_DIR / "music_gen"
MUSIC_VENV_PYTHON = MUSIC_GEN_DIR / "venv_music" / "Scripts" / "python.exe"  # Windows
# MUSIC_VENV_PYTHON = MUSIC_GEN_DIR / "venv_music" / "bin" / "python"  # Linux/Mac
MUSIC_SCRIPT = MUSIC_GEN_DIR / "generador.py"
```

### Step 7: Verify Installation

```bash
cd Z-Image-Turbo
python main.py --help
```

**Expected Output**:
```
usage: main.py [-h] --project PROJECT [--file FILE] [--upload] [--no-upload]
               [--sanitize] [--publish] [--publish-only] [--clean]
               [--lang LANG [LANG ...]]
...
```

---

## Project Setup

### Creating a New Project

**Step 1**: Create project directories:
```bash
mkdir -p inputs/scripts/myproject
mkdir -p inputs/assets/myproject
```

**Step 2**: Add intro video (optional):
```bash
# Copy your intro video
cp path/to/intro.mp4 inputs/assets/myproject/intro_1920x1080.mp4
```

**Step 3**: Update config.py (optional):
```python
# Change intro path if needed
INTRO_FILE = ASSETS_DIR / "myproject/intro_1920x1080.mp4"
```

### Project Structure

```
inputs/
├── scripts/
│   └── myproject/
│       ├── SAGA_01_Episode_01.json
│       ├── SAGA_01_Episode_02.json
│       └── Ensayos/          # Optional: Markdown essays for web
│           ├── es/
│           │   ├── SAGA_01_Episode_01.md
│           │   └── SAGA_01_Episode_02.md
│           └── en/
│               ├── SAGA_01_Episode_01.md
│               └── SAGA_01_Episode_02.md
└── assets/
    └── myproject/
        └── intro_1920x1080.mp4
```

---

## Creating Scripts

### JSON Script Structure

**Full Template**:
```json
{
  "project_title": "Episode Title",
  "saga": 1,
  "episode": 1,
  "date_published": "2025-01-15T18:00:00Z",
  "global_music_prompt": "Cinematic orchestral, epic, suspenseful",

  "scenes": [
    {
      "scene_id": 0,
      "image_prompt": "Detailed description of image, 4K, cinematic style",
      "script_es": "Texto en español para esta escena.",
      "script_en": "English text for this scene.",
      "chapter_es": "Introducción",
      "chapter_en": "Introduction"
    },
    {
      "scene_id": 1,
      "image_prompt": "Another detailed image description",
      "script_es": "Segunda escena en español.",
      "script_en": "Second scene in English.",
      "chapter_es": "Introducción",
      "chapter_en": "Introduction"
    }
  ],

  "seo": {
    "es": {
      "variants": [
        {
          "title": "Título del Video",
          "thumb_text": "TEXTO EN MINIATURA"
        }
      ],
      "description": "Descripción del video para YouTube.\n\nIncluye información relevante.",
      "tags": ["etiqueta1", "etiqueta2", "ciencia"],
      "thumbnail_prompt": "Eye-catching thumbnail scene description"
    },
    "en": {
      "variants": [
        {
          "title": "Video Title",
          "thumb_text": "THUMBNAIL TEXT"
        }
      ],
      "description": "Video description for YouTube.\n\nInclude relevant information.",
      "tags": ["tag1", "tag2", "science"],
      "thumbnail_prompt": "Eye-catching thumbnail scene description"
    }
  }
}
```

### Field Descriptions

**Top Level**:
- `project_title`: Internal name (used for file naming)
- `saga`: Saga number (1-10+)
- `episode`: Episode number within saga
- `date_published`: ISO 8601 timestamp for web platform
- `global_music_prompt`: Description of background music style

**Scene Object**:
- `scene_id`: Unique numeric ID (sequential: 0, 1, 2...)
- `image_prompt`: Detailed description for AI image generation
- `script_es`: Spanish narration text
- `script_en`: English narration text
- `script_ca`: (Optional) Catalan narration text
- `chapter_es`: Spanish chapter name (for YouTube chapters)
- `chapter_en`: English chapter name

**SEO Object** (per language):
- `variants`: Array of title/thumbnail text variants
  - `title`: YouTube video title
  - `thumb_text`: Text to render on thumbnail
- `description`: YouTube video description (supports markdown)
- `tags`: Array of SEO keywords
- `thumbnail_prompt`: (Optional) Custom thumbnail image prompt (defaults to scene[0])

### Best Practices for Scripts

#### 1. Image Prompts

**Good**:
```json
"image_prompt": "Alien forest with bioluminescent plants, misty atmosphere, volumetric lighting, ultra-realistic, 4K, National Geographic style"
```

**Bad**:
```json
"image_prompt": "forest"  // Too vague
```

**Tips**:
- Include style reference (cinematic, photorealistic, artistic)
- Specify lighting (golden hour, dramatic, soft)
- Add quality markers (4K, ultra-realistic, highly detailed)
- Mention camera angle (aerial view, close-up, wide shot)

#### 2. Narration Text

**Good**:
```json
"script_es": "En un planeta lejano, a miles de años luz de la Tierra, la vida evolucionó de una forma completamente diferente. Aquí, los bosques no son verdes."
```

**Bad**:
```json
"script_es": "Planeta. Vida. Bosques."  // Too choppy
```

**Tips**:
- Write naturally (as you would speak)
- Use complete sentences
- Avoid excessive punctuation (AI TTS handles it)
- Keep scenes 20-60 seconds (2-5 sentences)
- End important sentences with period (helps intonation)

#### 3. Chapter Markers

**Rule**: Only add chapter marker when changing chapters.

**Example**:
```json
{
  "scenes": [
    {"scene_id": 0, "chapter_es": "Introducción"},
    {"scene_id": 1},  // Same chapter, omit field
    {"scene_id": 2},  // Same chapter, omit field
    {"scene_id": 3, "chapter_es": "El Bosque"}  // New chapter
  ]
}
```

#### 4. SEO Optimization

**Title Guidelines**:
- 60 characters max (YouTube cuts off)
- Front-load keywords
- Use numbers ("10 Hechos", "Top 5")
- Create curiosity ("No Creerás", "Secretos")

**Description Guidelines**:
- First 2 lines visible in search (hook!)
- Include keywords naturally
- Add timestamp chapter markers
- Include call-to-action
- Link to related videos

**Tags Guidelines**:
- 5-15 tags
- Mix broad and specific
- Include series name
- Add language tag ("español", "spanish")

---

## Running the Factory

### Basic Usage

**Single Video Generation**:
```bash
python main.py --project myproject --file SAGA_01_Episode_01.json
```

**What Happens**:
1. Loads JSON script
2. Generates images for each scene
3. Generates TTS audio for each language
4. Generates background music
5. Assembles videos
6. Creates thumbnails
7. Generates subtitles
8. (Optional) Uploads to YouTube
9. (Optional) Publishes to web platform

**Output Location**: `outputs/myproject/SAGA_01_Episode_01/`

### Command-Line Flags

#### Language Selection

```bash
# Generate only Spanish
python main.py --project myproject --file episode.json --lang es

# Generate Spanish and English
python main.py --project myproject --file episode.json --lang es en

# Generate all languages in JSON (default)
python main.py --project myproject --file episode.json
```

#### Upload Control

```bash
# Force upload to YouTube
python main.py --project myproject --file episode.json --upload

# Force NO upload (local generation only)
python main.py --project myproject --file episode.json --no-upload

# Use default from config.py (AUTO_UPLOAD)
python main.py --project myproject --file episode.json
```

#### Advanced Flags

```bash
# Clean start (delete cached audio/video)
python main.py --project myproject --file episode.json --clean

# Apply anti-fingerprinting sanitization
python main.py --project myproject --file episode.json --sanitize

# Auto-publish to web platform after generation
python main.py --project myproject --file episode.json --publish

# Regenerate web content only (skip video generation)
python main.py --project myproject --file episode.json --publish-only
```

### Combining Flags

```bash
# Clean start + Upload + Web publish
python main.py --project myproject --file episode.json --clean --upload --publish

# Spanish only + No upload + Sanitize
python main.py --project myproject --file episode.json --lang es --no-upload --sanitize
```

---

## Batch Processing

### Basic Batch

**Process all JSON files in project**:
```bash
python batch_runner.py --project myproject
```

**What Happens**:
1. Finds all `*.json` files in `inputs/scripts/myproject/`
2. Processes each file sequentially
3. Continues even if one fails
4. Prints summary at end

### Batch with Flags

```bash
# Batch upload all episodes
python batch_runner.py --project myproject --upload

# Batch generate without upload
python batch_runner.py --project myproject --no-upload

# Batch clean regeneration
python batch_runner.py --project myproject --clean

# Batch web publishing only
python batch_runner.py --project myproject --publish-only
```

### Selective Batch

**Process specific file**:
```bash
python batch_runner.py --project myproject --file SAGA_01_Episode_05.json
```

**Process specific language only**:
```bash
python batch_runner.py --project myproject --lang en
```

### Monitoring Batch Progress

**Output Example**:
```
▶️ [1/10] Procesando: SAGA_01_Episode_01.json
==================================================
🚀 INICIANDO: Episode 1 (Saga 1 Ep 1)
🖼️ [Fase 1] Generando Miniaturas Pro...
🎬 [Fase 2] Generando Assets...
   🎨 Generando Imagen 0...
   🎤 [Kokoro] Generando (es) con voz 'em_alex'...
...
✅ TERMINADO EN 1234s

▶️ [2/10] Procesando: SAGA_01_Episode_02.json
...
```

### Error Handling in Batch

**If one episode fails**:
```
❌ FALLO CRÍTICO en SAGA_01_Episode_05.json: Out of memory

▶️ [6/10] Procesando: SAGA_01_Episode_06.json
...
```

**Summary at End**:
```
==================================================
⚠️ PROCESO TERMINADO CON 1 ERRORES:
 - SAGA_01_Episode_05.json: CUDA out of memory
```

**What to Do**:
- Fix the error (free GPU memory)
- Re-run batch (cached episodes will skip)
- Or run failed episode individually

---

## YouTube Upload Setup

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project: "Z-Image-Turbo"
3. Enable YouTube Data API v3:
   - APIs & Services → Enable APIs
   - Search "YouTube Data API v3"
   - Click Enable

### Step 2: Create OAuth Credentials

1. Go to APIs & Services → Credentials
2. Click "Create Credentials" → "OAuth client ID"
3. Application type: "Desktop app"
4. Name: "Z-Image-Turbo CLI"
5. Download JSON (will be `client_secret_XXX.json`)

### Step 3: Configure Project

1. Copy downloaded file to project root
2. Rename to `client_secret.json`
```bash
mv ~/Downloads/client_secret_XXX.json client_secret.json
```

3. Verify `.gitignore` includes this file (should be there already)

### Step 4: First Upload (OAuth Flow)

```bash
python main.py --project myproject --file episode.json --upload
```

**What Happens**:
1. Script opens browser automatically
2. Google login page appears
3. Select your Google account (with YouTube channel)
4. Grant permissions (view and manage YouTube account)
5. Browser shows "Authentication successful"
6. Script continues with upload

**Token Saved**: `token_myproject_es.pickle` (cached for future)

### Step 5: Multi-Channel Setup (Optional)

**If you have separate ES/EN channels**:

1. First run (Spanish):
```bash
python main.py --project myproject --file episode.json --lang es --upload
```
- OAuth flow for Spanish channel
- Token saved: `token_myproject_es.pickle`

2. Second run (English):
```bash
python main.py --project myproject --file episode.json --lang en --upload
```
- OAuth flow for English channel
- Token saved: `token_myproject_en.pickle`

**Result**: Each language uploads to its own channel.

### Troubleshooting OAuth

**Problem**: "Token expired" error

**Solution**:
```bash
# Delete cached token
rm token_myproject_es.pickle

# Re-run (will trigger OAuth again)
python main.py --project myproject --file episode.json --upload
```

**Problem**: "Quota exceeded"

**Solution**:
- Wait 24 hours (quota resets daily)
- Or request quota increase in Google Cloud Console

---

## Web Publishing Setup

### Step 1: Clone Web Platform Repository

```bash
cd C:/Users/YourName/Documents/workspace/proyectos-ai/
git clone <web-platform-repo-url> Z-content-platform
```

### Step 2: Configure Paths

Edit `Z-Image-Turbo/modules/publishing/web_publisher.py`:
```python
# Update these paths to match your setup
TURBO_BASE = Path("C:/Users/YourName/Documents/workspace/proyectos-ai/Z-Image-Turbo")
CONTENT_BASE = Path("C:/Users/YourName/Documents/workspace/proyectos-ai/Z-content-platform")
BASE_INPUT_DIR = TURBO_BASE / "inputs/scripts/beyondCarbon"
TARGET_BASE_DIR = CONTENT_BASE / "data/sites/specbio"
```

### Step 3: Create Markdown Essays (Optional)

**Location**: `inputs/scripts/myproject/Ensayos/{lang}/`

**Structure**:
```
inputs/scripts/myproject/Ensayos/
├── es/
│   ├── SAGA_01_Episode_01.md
│   └── SAGA_01_Episode_02.md
└── en/
    ├── SAGA_01_Episode_01.md
    └── SAGA_01_Episode_02.md
```

**Content** (example):
```markdown
# Episode Title

This is the full transcript or article version of the video.

## Section 1

Content here...

## Section 2

More content...
```

**Note**: Don't include YAML frontmatter - the system generates it automatically.

### Step 4: Create Channel Bible (Optional)

**Location**: `inputs/scripts/myproject/channel_bible.json`

**Purpose**: Define saga metadata

**Structure**:
```json
[
  {
    "id": 1,
    "title": {
      "es": "Biología Especulativa",
      "en": "Speculative Biology"
    },
    "premise": {
      "es": "Explorando formas de vida alternativas.",
      "en": "Exploring alternative life forms."
    }
  },
  {
    "id": 2,
    "title": {
      "es": "Química Imposible",
      "en": "Impossible Chemistry"
    },
    "premise": {
      "es": "Elementos que no deberían existir.",
      "en": "Elements that shouldn't exist."
    }
  }
]
```

### Step 5: Test Publishing

```bash
# Generate and publish
python main.py --project myproject --file episode.json --publish

# Or publish only (fast)
python main.py --project myproject --file episode.json --publish-only
```

**Output Location**: Check `Z-content-platform/data/sites/specbio/series/saga-XX/ep-XX/`

### Step 6: Deploy Web Platform

```bash
cd Z-content-platform
# Follow web platform's deployment instructions
# Usually: npm run build && npm run deploy
```

---

## Common Workflows

### Workflow 1: Complete Production Pipeline

**Goal**: Create, upload, and publish a new episode

```bash
# Step 1: Create JSON script
nano inputs/scripts/myproject/SAGA_01_Episode_10.json

# Step 2: Generate everything
python main.py --project myproject --file SAGA_01_Episode_10.json --upload --publish

# Step 3: Review output
ls outputs/myproject/SAGA_01_Episode_10/

# Step 4: Check YouTube (video will be private)
# Go to YouTube Studio, review, then publish manually

# Step 5: Deploy web platform
cd ../Z-content-platform
npm run deploy
```

**Time**: ~20-25 minutes per language

---

### Workflow 2: Rapid Prototyping

**Goal**: Quickly test script changes without regenerating everything

```bash
# First run (full generation)
python main.py --project myproject --file test.json --no-upload

# Edit JSON (change text or prompts)
nano inputs/scripts/myproject/test.json

# Second run (uses cache, regenerates only changed parts)
python main.py --project myproject --file test.json --no-upload

# If audio sounds wrong, clean start
python main.py --project myproject --file test.json --no-upload --clean
```

**Time**:
- Full run: 15-20 min
- Cached run (text change): 8-10 min
- Cached run (metadata only): 2-3 min

---

### Workflow 3: A/B Testing Thumbnails

**Goal**: Generate multiple thumbnail variants for testing

**Step 1**: Add variants to JSON:
```json
{
  "seo": {
    "es": {
      "variants": [
        {"title": "Título A", "thumb_text": "TEXTO VARIANTE A"},
        {"title": "Título B", "thumb_text": "TEXTO VARIANTE B"},
        {"title": "Título C", "thumb_text": "TEXTO VARIANTE C"},
        {"title": "Título D", "thumb_text": "TEXTO VARIANTE D"},
        {"title": "Título E", "thumb_text": "TEXTO VARIANTE E"}
      ]
    }
  }
}
```

**Step 2**: Generate:
```bash
python main.py --project myproject --file episode.json --no-upload
```

**Step 3**: Review variants:
```bash
ls outputs/myproject/episode/assets/thumbnails/
# thumbnail_es_v1.png (official, auto-uploaded)
# thumbnail_es_v2.png
# thumbnail_es_v3.png
# thumbnail_es_v4.png
# thumbnail_es_v5.png
```

**Step 4**: Upload video with variant #1, then test others:
- Monitor CTR (Click-Through Rate) in YouTube Analytics
- Replace thumbnail with better variant in YouTube Studio

---

### Workflow 4: Batch Season Production

**Goal**: Produce an entire 10-episode saga

**Step 1**: Prepare all scripts
```bash
inputs/scripts/myproject/
├── SAGA_02_Episode_11.json
├── SAGA_02_Episode_12.json
├── SAGA_02_Episode_13.json
├── SAGA_02_Episode_14.json
├── SAGA_02_Episode_15.json
├── SAGA_02_Episode_16.json
├── SAGA_02_Episode_17.json
├── SAGA_02_Episode_18.json
├── SAGA_02_Episode_19.json
└── SAGA_02_Episode_20.json
```

**Step 2**: Run overnight batch:
```bash
# Start batch (no upload for safety)
python batch_runner.py --project myproject --no-upload > batch_log.txt 2>&1 &

# Or with upload (if confident)
python batch_runner.py --project myproject --upload > batch_log.txt 2>&1 &
```

**Step 3**: Monitor (next day):
```bash
# Check log
tail -f batch_log.txt

# Check outputs
ls outputs/myproject/
```

**Step 4**: Handle any failures:
```bash
# Re-run failed episodes only
python main.py --project myproject --file SAGA_02_Episode_15.json --upload
```

**Time**: 3-4 hours for 10 episodes (2 languages)

---

### Workflow 5: Metadata Update (Fast)

**Goal**: Fix YouTube titles/descriptions without regenerating videos

**Step 1**: Edit JSON (change seo.es.variants[0].title or description)
```bash
nano inputs/scripts/myproject/episode.json
```

**Step 2**: Regenerate web content only:
```bash
python main.py --project myproject --file episode.json --publish-only
```

**Step 3**: For YouTube, manually update in YouTube Studio

**Time**: 10-20 seconds

---

## Troubleshooting

### Problem: CUDA Out of Memory

**Symptoms**:
```
RuntimeError: CUDA out of memory. Tried to allocate 2.00 GiB
```

**Solutions**:

1. **Close other GPU applications** (browsers, games, etc.)
```bash
# Check GPU usage
nvidia-smi
```

2. **Reduce image resolution** (temporary fix):
Edit `modules/generators/image_gen.py`:
```python
# Change from 1920x1072 to 1280x720
width = 1280
height = 720
```

3. **Enable aggressive CPU offloading** (slower but uses less VRAM):
Edit `modules/generators/image_gen.py`:
```python
self.pipe.enable_model_cpu_offload()  # Instead of sequential
```

4. **Restart Python** (clears GPU memory):
```bash
# Close current process
# Re-run command
```

---

### Problem: Audio Desync

**Symptoms**: Audio drifts from video, especially in long videos

**Solutions**:

1. **Clean start** (regenerate all audio with frame-perfect padding):
```bash
python main.py --project myproject --file episode.json --clean
```

2. **Verify FPS consistency**:
Check `main.py` line 33: `FPS_VIDEO = 30`
Check `main.py` line 364: `fps=24`

**These should match!** Update to both be 24 or both be 30.

3. **Test sync**:
```bash
# Generate short test video
python main.py --project test --file short_episode.json --no-upload
# Play in VLC and check sync at start, middle, end
```

---

### Problem: TTS Audio Quality Issues

**Symptoms**: Robotic voice, poor pronunciation, unnatural pauses

**Solutions**:

1. **Improve text formatting**:
```json
// Bad
"script_es": "Hola.Como.Estas."

// Good
"script_es": "Hola. ¿Cómo estás?"
```

2. **Add natural punctuation**:
```json
"script_es": "En un planeta lejano, a miles de años luz, la vida evolucionó de forma diferente."
```

3. **Use ellipsis for pauses**:
```json
"script_es": "Imagina... un mundo donde la vida... es de cristal."
```

4. **Try different TTS engine**:
Edit `main.py` line 421:
```python
# Change from Kokoro to Google
self.tts_gen.generar_google(txt, path, "es", first, last)
```

5. **Adjust speed**:
Edit `modules/generators/tts_gen.py`:
```python
# Line 201: Kokoro speed
speed=1.0  # Try 0.9 (slower) or 1.1 (faster)

# Line 147: Google speed
"speakingRate": 0.9  # Default is 0.9, try 0.85 or 1.0
```

---

### Problem: Music Generation Fails

**Symptoms**:
```
❌ Error en MusicGen: ...
```

**Solutions**:

1. **Verify music environment**:
```bash
cd ../music_gen
venv_music\Scripts\activate
python generador.py --prompt "test" --duracion 30 --filename test
```

2. **Check paths in config.py**:
```python
print(config.MUSIC_VENV_PYTHON)  # Should exist
print(config.MUSIC_SCRIPT)        # Should exist
```

3. **Reinstall music dependencies**:
```bash
cd ../music_gen
rm -rf venv_music
python -m venv venv_music
venv_music\Scripts\activate
pip install torch==1.13.1 transformers scipy audiocraft
```

4. **Skip music** (temporary workaround):
Comment out music generation in `main.py`:
```python
# Line 151: Comment out
# ruta_bso = self._gestionar_musica(max_dur - intro_dur)
ruta_bso = None  # Skip music
```

---

### Problem: YouTube Upload Fails

**Symptoms**:
```
❌ Error: Quota exceeded
```
or
```
❌ Authentication failed
```

**Solutions**:

1. **Quota exceeded**:
- Wait 24 hours (quota resets at midnight PT)
- Check quota usage: Google Cloud Console → YouTube Data API → Quotas
- Request increase (takes 1-2 weeks)

2. **Authentication failed**:
```bash
# Delete cached token
rm token_myproject_es.pickle

# Re-run (triggers OAuth)
python main.py --project myproject --file episode.json --upload
```

3. **Video too large**:
```bash
# Check video size
ls -lh outputs/myproject/episode/*.mp4

# If over 10GB, reduce quality in main.py:
# Line 369: Change CRF from 18 to 23
ffmpeg_params=["-crf", "23"]  # Smaller file, slightly lower quality
```

---

### Problem: Slow Generation

**Symptoms**: Taking 30+ minutes per episode

**Optimization Tips**:

1. **Use faster preset**:
Edit `main.py` line 368:
```python
preset="ultrafast",  # Instead of "medium"
```
**Trade-off**: 5x faster, slightly lower quality

2. **Reduce CRF** (smaller file):
```python
ffmpeg_params=["-crf", "23"]  # Instead of 18
```

3. **Skip intro**:
Edit `config.py`:
```python
INTRO_FILE = None  # Skip intro attachment
```

4. **Reduce inference steps** (faster images):
Edit `modules/generators/image_gen.py` line 62:
```python
num_inference_steps=6,  # Instead of 9 (faster, lower quality)
```

5. **Process single language**:
```bash
python main.py --project myproject --file episode.json --lang es
```

---

## Best Practices

### 1. Script Writing

**Do**:
- Write naturally (as you would speak)
- Keep scenes 20-60 seconds
- Use descriptive image prompts (50+ words)
- Include chapter markers every 3-5 scenes
- Proofread for typos (TTS will read them literally)

**Don't**:
- Write robotic, list-style text
- Make scenes too short (<10 seconds) or too long (>90 seconds)
- Use vague image prompts ("a forest")
- Overuse chapter markers (every scene)
- Include URLs or special characters in narration

---

### 2. Project Organization

**Do**:
- Use consistent naming: `SAGA_XX_Episode_YY.json`
- Keep saga numbers sequential (1, 2, 3...)
- Keep episode numbers sequential within saga
- Store related assets in project folder
- Version control your JSON scripts (git)

**Don't**:
- Mix naming conventions (Saga01_Ep01.json, S1E1.json)
- Skip episode numbers (01, 02, 05...)
- Hardcode absolute paths in JSON
- Commit generated videos to git

---

### 3. Performance

**Do**:
- Run batch jobs overnight
- Use cache (don't use `--clean` unnecessarily)
- Close other GPU applications before running
- Use `--no-upload` for testing
- Monitor GPU temperature (keep under 85°C)

**Don't**:
- Run multiple factories simultaneously (GPU contention)
- Use `--clean` for minor text changes
- Upload drafts (use `--no-upload`, review first)
- Let GPU overheat (improve cooling)

---

### 4. Quality Control

**Do**:
- Preview videos before uploading
- Check audio sync at start, middle, end
- Verify subtitles are readable
- Test thumbnails (A/B test variants)
- Review YouTube description formatting

**Don't**:
- Auto-publish to YouTube (use private, review first)
- Skip subtitle review (fix TTS errors)
- Use first thumbnail variant blindly
- Ignore viewer feedback on audio quality

---

### 5. YouTube SEO

**Do**:
- Front-load keywords in title
- Write detailed descriptions (150+ words)
- Include chapter timestamps in description
- Use 10-15 relevant tags
- Add captions in multiple languages
- Upload custom thumbnails
- Set playlist (organize sagas)

**Don't**:
- Keyword stuff titles
- Copy-paste generic descriptions
- Skip chapter markers
- Over-tag (50+ tags)
- Rely on auto-generated captions only
- Use default thumbnail
- Upload videos as standalone (no playlist)

---

## Advanced Usage

### Custom TTS Voices

**Add new Kokoro voice**:

1. Check available voices:
Edit `modules/generators/tts_gen.py`:
```python
# After line 72, add:
print("Available voices:", self.model_kokoro.get_voices())
```

2. Run:
```bash
python main.py --project test --file test.json --no-upload
```

3. Update voice selection:
Edit `modules/generators/tts_gen.py` line 184:
```python
voice_target = "em_emma"  # Instead of em_alex
```

---

### Custom Font for Thumbnails

**Change font**:

1. Copy font file to project:
```bash
cp path/to/MyFont.ttf fonts/MyFont.ttf
```

2. Update config.py:
```python
FONT_PATH = str(BASE_DIR / "fonts/MyFont.ttf")
```

---

### Custom Intro Video

**Per-project intro**:

1. Add intro to project assets:
```bash
cp intro.mp4 inputs/assets/myproject/intro_1920x1080.mp4
```

2. Update config.py:
```python
# Change from:
INTRO_FILE = ASSETS_DIR / "beyondCarbon/intro_1920x1072.mp4"

# To:
import os
project_name = os.environ.get("PROJECT_NAME", "beyondCarbon")
INTRO_FILE = ASSETS_DIR / f"{project_name}/intro_1920x1080.mp4"
```

3. Set environment variable:
```bash
export PROJECT_NAME=myproject
python main.py --project myproject --file episode.json
```

---

### Parallel Batch Processing

**Run multiple batches on different GPUs** (if you have multiple GPUs):

**Terminal 1** (GPU 0):
```bash
CUDA_VISIBLE_DEVICES=0 python batch_runner.py --project projectA
```

**Terminal 2** (GPU 1):
```bash
CUDA_VISIBLE_DEVICES=1 python batch_runner.py --project projectB
```

---

### Integration with CI/CD

**Automated nightly builds** (example with cron):

```bash
# Edit crontab
crontab -e

# Add line (runs at 2 AM daily)
0 2 * * * cd /path/to/Z-Image-Turbo && /path/to/venv/bin/python batch_runner.py --project myproject --no-upload > /path/to/logs/batch_$(date +\%Y\%m\%d).log 2>&1
```

---

## Conclusion

This guide covers 95% of use cases. For advanced customization, refer to:
- [CODE_WIKI.md](CODE_WIKI.md) - Technical implementation details
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design and patterns
- [CAPABILITIES.md](CAPABILITIES.md) - Full feature reference

**Need help?** Check source code comments or open an issue.

---

**Document Version**: 1.0
**Last Updated**: 2025-01-15
**Tested With**: Python 3.10, CUDA 11.8, RTX 3060
