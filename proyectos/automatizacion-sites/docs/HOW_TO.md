# Z-Content Platform - How-To Guide

**Practical Usage & Workflows**
Version: 2.0
Last Updated: 2025-12-22

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [Creating Your First Site](#creating-your-first-site)
4. [Adding Content](#adding-content)
5. [Building & Deploying](#building--deploying)
6. [Common Workflows](#common-workflows)
7. [Configuration Guide](#configuration-guide)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)

---

## Quick Start

Get a site running in 5 minutes:

```bash
# 1. Clone repository
git clone https://github.com/your-org/z-content-platform.git
cd z-content-platform

# 2. Install dependencies
pip install -r requirements.txt
# OR with Poetry
poetry install

# 3. Check example site
python run.py check --site specbio

# 4. Build example site
python run.py build --site specbio

# 5. Start development server
python run.py serve --site specbio
# Open http://localhost:8000
```

---

## Installation

### Prerequisites

- **Python 3.11+** (3.10 minimum, 3.11+ recommended)
- **pip** or **Poetry** for dependency management
- **Git** (optional, for version control)

### Method 1: pip (Simple)

```bash
# Install dependencies
pip install -r requirements.txt

# Verify installation
python run.py check --site specbio
```

### Method 2: Poetry (Recommended)

```bash
# Install Poetry
curl -sSL https://install.python-poetry.org | python3 -

# Install dependencies
poetry install

# Activate virtual environment
poetry shell

# Verify installation
python run.py check --site specbio
```

### Verify Installation

```bash
# Should show site structure
python run.py check --site specbio

# Expected output:
# ✅ Config loaded: Speculative Biology Archive
#    Domain: https://specbio.com
#    Language: es
#
# Sagas in specbio
# ┌───────────┬─────────────────┬──────────┬──────────────┐
# │ Slug      │ Title           │ Episodes │ Visual Mode  │
# ├───────────┼─────────────────┼──────────┼──────────────┤
# │ saga-01   │ Origins of Life │ 2        │ exo-natgeo   │
# │ saga-02   │ Extreme Worlds  │ 1        │ neo-haeckel  │
# └───────────┴─────────────────┴──────────┴──────────────┘
```

---

## Creating Your First Site

### Step 1: Initialize Site Structure

```bash
# Create site directory
mkdir -p data/sites/mysite/{products,series,posts}

# Create basic structure
cd data/sites/mysite
```

### Step 2: Create Site Configuration

**File**: `data/sites/mysite/config.json`

```json
{
  "site_id": "mysite",
  "name": "My Content Platform",
  "description": "An amazing content platform powered by Z-Content",
  "domain": "https://mysite.com",
  "base_path": "/",
  "language": "en",
  "timezone": "UTC",

  "branding": {
    "logo_path": "/static/img/logo.svg",
    "favicon_path": "/static/favicon.ico",
    "primary_color": "#1a1a1a",
    "accent_color": "#d4af37",
    "background_color": "#fafafa",
    "text_color": "#1a1a1a"
  },

  "media": {
    "provider": "bunnycdn",
    "endpoint": "https://your-zone.b-cdn.net",
    "library_id": "your-library-id"
  },

  "features": {
    "dark_mode": true,
    "search": true,
    "comments": false,
    "paywall": false,
    "newsletter_signup": false,
    "persistent_player": true,
    "show_reading_time": true,
    "show_episode_progress": true
  },

  "seo": {
    "default_og_image": "/static/img/og-default.jpg",
    "twitter_handle": "@mysite",
    "keywords": ["topic1", "topic2", "topic3"],
    "organization_name": "My Organization",
    "same_as": [
      "https://twitter.com/mysite",
      "https://github.com/myorg"
    ]
  },

  "analytics_id": "mysite.com"
}
```

### Step 3: Create Your First Saga

**Directory Structure**:
```bash
mkdir -p data/sites/mysite/series/saga-01
```

**File**: `data/sites/mysite/series/saga-01/meta.en.yaml`

```yaml
slug: saga-01
title: "Getting Started Series"
premise: "Learn the fundamentals of our topic through this comprehensive series."
thumbnail: "thumbnail.jpg"
cover_image: "cover.jpg"
visual_mode: exo-natgeo
author: "Your Name"
language: en
is_complete: false
is_published: true
```

### Step 4: Create Your First Episode

**Directory**:
```bash
mkdir -p data/sites/mysite/series/saga-01/ep-01-welcome
```

**File**: `data/sites/mysite/series/saga-01/ep-01-welcome/content.en.md`

```markdown
---
title: "Welcome to the Series"
slug: welcome
episode_number: 1
season: 1
published_at: 2025-01-15T10:00:00Z
description: "An introduction to our content series."
visual_mode: exo-natgeo
tags:
  - introduction
  - welcome
keywords:
  - getting started
  - introduction
  - tutorial

media:
  cover_image: "hero.jpg"
  youtube_id: ""  # Optional: Add your YouTube video ID
  duration_seconds: 300

recommended_products: []  # Add product IDs later

is_published: true
is_premium: false
---

# Welcome to the Series

This is the beginning of an exciting journey into [topic].

## What You'll Learn

In this series, you'll discover:

- **Concept 1**: Explanation of the first key concept
- **Concept 2**: Understanding the second principle
- **Concept 3**: Practical applications

## Getting Started

Let's dive into the fundamentals...

==Key Term== is defined as...

## Next Steps

Continue to the next episode to learn more!
```

### Step 5: Build Your Site

```bash
# Validate structure
python run.py check --site mysite

# Build static site
python run.py build --site mysite

# Start local server
python run.py serve --site mysite
```

### Step 6: View Your Site

Open your browser to: `http://localhost:8000`

---

## Adding Content

### Adding a New Episode

**1. Create Episode Directory**:
```bash
mkdir -p data/sites/mysite/series/saga-01/ep-02-advanced
```

**2. Create Content File**:

**File**: `ep-02-advanced/content.en.md`

```markdown
---
title: "Advanced Concepts"
slug: advanced
episode_number: 2
season: 1
published_at: 2025-01-20T10:00:00Z
description: "Deep dive into advanced topics."

media:
  cover_image: "hero.jpg"
  youtube_id: "VIDEO_ID_HERE"
  bunny_video_id: "BUNNY_ID_HERE"
  duration_seconds: 600

recommended_products:
  - product-id-1
  - product-id-2

tags:
  - advanced
  - deep-dive

is_published: true
---

# Advanced Concepts

Content goes here...
```

**3. Add Episode Assets** (optional):
```bash
mkdir -p ep-02-advanced/assets
# Add images, videos, etc.
cp hero.jpg ep-02-advanced/assets/
cp diagram.svg ep-02-advanced/assets/
```

**4. Rebuild Site**:
```bash
python run.py build --site mysite
```

### Adding a New Saga

**1. Create Saga Directory**:
```bash
mkdir -p data/sites/mysite/series/saga-02
```

**2. Create Saga Metadata**:

**File**: `saga-02/meta.en.yaml`

```yaml
slug: saga-02
title: "Intermediate Series"
premise: "Build upon the fundamentals with intermediate topics."
thumbnail: "thumbnail.jpg"
cover_image: "cover.jpg"
visual_mode: neo-haeckel
author: "Your Name"
language: en
is_complete: false
is_published: true
```

**3. Add Episodes**:
```bash
mkdir -p data/sites/mysite/series/saga-02/ep-01-first
# Create content.en.md as before
```

### Adding Affiliate Products

**1. Create Product File**:

**File**: `data/sites/mysite/products/equipment.yaml`

```yaml
- id: book-introduction
  name: "Introduction to Topic - Textbook"
  description: "The definitive guide to getting started with our subject."
  category: books
  price_range: "$$"
  currency: USD
  image_url: "/static/img/products/book-intro.jpg"
  affiliate_links:
    - platform: amazon_com
      url: https://amzn.to/YOUR_AFFILIATE_LINK
      geo_target: US
    - platform: amazon_uk
      url: https://amzn.to/YOUR_UK_LINK
      geo_target: UK
  is_active: true

- id: tool-starter-kit
  name: "Beginner's Starter Kit"
  description: "Everything you need to get started."
  category: equipment
  price_range: "$$$"
  currency: USD
  image_url: "/static/img/products/starter-kit.jpg"
  affiliate_links:
    - platform: store_direct
      url: https://shop.example.com/starter-kit?ref=mysite
  is_active: true
```

**2. Reference in Episodes**:

In your episode frontmatter:
```yaml
recommended_products:
  - book-introduction
  - tool-starter-kit
```

### Adding Standalone Posts

**File**: `data/sites/mysite/posts/essay-01.md`

```markdown
---
slug: my-first-essay
title: "My First Essay"
episode_number: 1
published_at: 2025-01-15T10:00:00Z
description: "Thoughts on the nature of content."
visual_mode: clean-minimal

media:
  cover_image: "/static/img/essays/cover.jpg"

tags:
  - essay
  - philosophy

is_published: true
---

# My First Essay

This is a standalone piece of content...
```

---

## Building & Deploying

### Development Workflow

**1. Make Content Changes**

Edit Markdown files, YAML metadata, or site config.

**2. Rebuild Site**

```bash
python run.py build --site mysite
```

**3. Preview Locally**

```bash
python run.py serve --site mysite --port 8000
```

**4. Verify Changes**

Open browser to `http://localhost:8000` and check:
- [ ] Content renders correctly
- [ ] Images load
- [ ] Navigation works
- [ ] Search finds new content

### Production Build

```bash
# Build for production
python run.py build --site mysite

# Output is in: output/mysite/
# Ready to deploy to static hosting
```

### Deployment Options

#### Option 1: Cloudflare Pages (Recommended)

**Setup**:
```bash
# Install Wrangler CLI
npm install -g wrangler

# Authenticate
wrangler login

# Deploy
wrangler pages publish output/mysite --project-name=mysite
```

**CI/CD** (GitHub Actions):

**File**: `.github/workflows/deploy.yml`

```yaml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Build site
        run: python run.py build --site mysite

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: mysite
          directory: output/mysite
          gitHubToken: ${{ secrets.GITHUB_TOKEN }}
```

#### Option 2: Netlify

**Setup**:
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy --prod --dir=output/mysite
```

**Configuration** (`netlify.toml`):
```toml
[build]
  command = "python run.py build --site mysite"
  publish = "output/mysite"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

#### Option 3: AWS S3 + CloudFront

```bash
# Build site
python run.py build --site mysite

# Sync to S3
aws s3 sync output/mysite/ s3://your-bucket-name/ \
  --delete \
  --cache-control "public, max-age=3600"

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

#### Option 4: Self-Hosted (Nginx)

**Nginx Configuration**:

**File**: `/etc/nginx/sites-available/mysite`

```nginx
server {
    listen 80;
    server_name mysite.com www.mysite.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name mysite.com www.mysite.com;

    # SSL certificates (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/mysite.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mysite.com/privkey.pem;

    # Root directory
    root /var/www/mysite;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/html text/css application/javascript application/json image/svg+xml;

    # Cache static assets
    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Cache HTML (shorter duration)
    location ~ \.html$ {
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
    }

    # Security headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Try files, fallback to index
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

**Deployment Script**:

**File**: `deploy.sh`

```bash
#!/bin/bash
set -e

# Build site
python run.py build --site mysite

# Sync to server
rsync -avz --delete \
  output/mysite/ \
  user@server:/var/www/mysite/

# Restart Nginx (if needed)
ssh user@server 'sudo systemctl reload nginx'

echo "✅ Deployment complete!"
```

---

## Common Workflows

### Adding Multi-Language Support

**1. Create Spanish Metadata**:

**File**: `series/saga-01/meta.es.yaml`

```yaml
slug: saga-01
title: "Serie de Introducción"
premise: "Aprende los fundamentos de nuestro tema."
thumbnail: "thumbnail.jpg"
cover_image: "cover.jpg"
visual_mode: exo-natgeo
author: "Tu Nombre"
language: es
is_complete: false
is_published: true
```

**2. Create Spanish Content**:

**File**: `series/saga-01/ep-01-welcome/content.es.md`

```markdown
---
title: "Bienvenido a la Serie"
slug: bienvenido
episode_number: 1
season: 1
published_at: 2025-01-15T10:00:00Z
description: "Una introducción a nuestra serie de contenido."
visual_mode: exo-natgeo
---

# Bienvenido a la Serie

Este es el comienzo de un viaje emocionante...
```

**3. Rebuild**:

```bash
python run.py build --site mysite
# Auto-detects both English and Spanish
# Generates /en/ and /es/ directories
```

### Updating Site Configuration

**1. Edit Config**:

Edit `data/sites/mysite/config.json`:

```json
{
  "branding": {
    "accent_color": "#ff6b6b"  // Change accent color
  },
  "features": {
    "newsletter_signup": true   // Enable newsletter
  }
}
```

**2. Rebuild**:

```bash
python run.py build --site mysite
# New colors and features applied
```

### Migrating Content from Another Platform

**From WordPress**:

```bash
# Export WordPress content to XML
# Convert XML to Markdown (use tools like wordpress-to-markdown)

# Create episode directories
for post in posts/*.md; do
  slug=$(basename "$post" .md)
  mkdir -p "data/sites/mysite/posts"
  # Add frontmatter, move file
done

# Rebuild
python run.py build --site mysite
```

**From Medium**:

```bash
# Export Medium stories (Settings > Account > Download your information)
# Unzip and convert HTML to Markdown

# Process each story
for story in medium-export/*.html; do
  # Convert to Markdown with Pandoc
  pandoc "$story" -o "${story%.html}.md"
  # Add frontmatter, organize into episodes
done
```

### Batch Operations

**Update All Episode Dates**:

```bash
# Python script to update frontmatter
import yaml
from pathlib import Path
from datetime import datetime, timedelta

episodes = Path("data/sites/mysite/series/saga-01").glob("ep-*/content.en.md")
base_date = datetime(2025, 1, 1, 10, 0, 0)

for i, ep_file in enumerate(sorted(episodes)):
    # Read, update, write frontmatter
    # publish_at = base_date + timedelta(days=i*7)
    pass
```

**Find Episodes Without Images**:

```bash
find data/sites/mysite/series -name "content.en.md" -exec grep -L "cover_image" {} \;
```

---

## Configuration Guide

### Site Config Reference

**Complete Configuration** (`config.json`):

```json
{
  // REQUIRED: Basic Identity
  "site_id": "string",          // Lowercase kebab-case
  "name": "string",             // Display name
  "description": "string",      // Meta description
  "domain": "https://...",      // Full domain with https://

  // OPTIONAL: Path and Localization
  "base_path": "/",             // Default: "/"
  "language": "en",             // Default language: "en" or "es"
  "timezone": "UTC",            // IANA timezone

  // Branding Configuration
  "branding": {
    "logo_path": "/static/img/logo.svg",
    "favicon_path": "/static/favicon.ico",
    "primary_color": "#1a1a1a",      // Hex color
    "accent_color": "#d4af37",       // Hex color
    "background_color": "#fafafa",   // Hex color
    "text_color": "#1a1a1a"          // Hex color
  },

  // Media CDN Configuration (BunnyCDN)
  "media": {
    "provider": "bunnycdn",
    "endpoint": "https://your-zone.b-cdn.net",
    "library_id": "your-library-id",
    "pull_zone": "your-pull-zone",
    "cache_ttl_seconds": 86400      // 24 hours
  },

  // Feature Flags
  "features": {
    "dark_mode": true,              // Theme toggle
    "search": true,                 // Client-side search
    "comments": false,              // Comment integration
    "paywall": false,               // Premium content
    "newsletter_signup": false,     // Email signup
    "persistent_player": true,      // Continuous playback
    "show_reading_time": true,      // Estimated reading time
    "show_episode_progress": true   // Progress bar
  },

  // SEO Configuration
  "seo": {
    "default_og_image": "/static/img/og-default.jpg",
    "twitter_handle": "@handle",
    "keywords": ["keyword1", "keyword2"],
    "organization_name": "Organization Name",
    "same_as": [
      "https://twitter.com/handle",
      "https://github.com/org",
      "https://www.wikidata.org/wiki/Q123456"
    ]
  },

  // Analytics (Plausible/Fathom)
  "analytics_id": "mysite.com"
}
```

### Episode Frontmatter Reference

**Complete Episode** (`content.{lang}.md`):

```yaml
---
# REQUIRED Fields
title: "Episode Title"
episode_number: 1              # Integer 1-999
published_at: 2025-01-15T10:00:00Z  # ISO 8601 format

# OPTIONAL Fields
slug: "custom-slug"            # Auto-generated if omitted
season: 1                      # Default: 1
description: "Episode description for SEO"  # Max 2000 chars
content_file: null             # Auto-set by reader

# Taxonomy
visual_mode: exo-natgeo        # neo-haeckel | exo-natgeo | analog-horror | clean-minimal
tags:
  - tag1
  - tag2
keywords:
  - keyword1
  - long-tail-keyword

# Media
media:
  cover_image: "hero.jpg"             # Relative or absolute path
  thumbnail: "thumb.jpg"              # Smaller preview image
  youtube_id: "VIDEO_ID"              # YouTube video ID
  bunny_video_id: "BUNNY_ID"          # BunnyCDN video ID
  video_file: "/path/to/video.mp4"    # Self-hosted video
  audio_file: "/path/to/audio.mp3"    # Audio version
  audio_bunny_id: "AUDIO_ID"          # BunnyCDN audio
  duration_seconds: 600               # Integer seconds

# Monetization
recommended_products:
  - product-id-1
  - product-id-2

# Status
is_published: true                    # Show on site
is_premium: false                     # Behind paywall (future)

# SEO (optional overrides)
last_modified: 2025-01-20T15:30:00Z   # Update timestamp
---

# Episode Content

Markdown content goes here...
```

---

## Troubleshooting

### Common Issues

#### Issue: "Site directory not found"

**Error**:
```
❌ Site directory not found: data/sites/mysite
```

**Solution**:
```bash
# Verify directory exists
ls data/sites/mysite

# Create if missing
mkdir -p data/sites/mysite
```

#### Issue: "Config file not found"

**Error**:
```
❌ Config file not found: data/sites/mysite/config.json
```

**Solution**:
```bash
# Create config.json (see Configuration Guide above)
nano data/sites/mysite/config.json
```

#### Issue: "Pydantic validation failed"

**Error**:
```
❌ Saga validation failed for saga-01:
   Field 'slug' must be lowercase kebab-case
   Got: 'Saga_01'
```

**Solution**:
```yaml
# Fix in meta.yaml
slug: saga-01  # NOT Saga_01 or SAGA-01
```

#### Issue: "No sagas found"

**Error**:
```
⚠ No sagas found.
```

**Solution**:
```bash
# Verify series directory structure
ls data/sites/mysite/series/

# Ensure meta.yaml exists
ls data/sites/mysite/series/saga-01/meta.yaml

# Check file permissions
chmod -R 755 data/sites/mysite/
```

#### Issue: Images not loading

**Problem**: Episode images return 404

**Solution**:
```bash
# 1. Check asset path in frontmatter
media:
  cover_image: "hero.jpg"  # Relative path

# 2. Ensure file exists in episode directory
ls data/sites/mysite/series/saga-01/ep-01/assets/hero.jpg

# 3. Verify build copied assets
ls output/mysite/static/assets/mysite/saga-01/ep-01/hero.jpg

# 4. Rebuild site
python run.py build --site mysite
```

#### Issue: Search not working

**Problem**: Search modal opens but no results

**Solution**:
```bash
# 1. Check search index exists
ls output/mysite/en/api/search-index.json

# 2. Verify JSON is valid
cat output/mysite/en/api/search-index.json | python -m json.tool

# 3. Check browser console for errors
# Open DevTools > Console

# 4. Rebuild with search enabled
# In config.json:
"features": {
  "search": true
}
```

### Debug Mode

**Enable Verbose Logging**:

Edit `run.py` or set environment variable:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

**Check Build Output**:

```bash
python run.py build --site mysite 2>&1 | tee build.log
# Review build.log for errors
```

---

## Best Practices

### Content Organization

**✅ DO**:
- Use kebab-case for slugs (`my-episode`, not `My_Episode`)
- Keep episode numbers sequential (1, 2, 3...)
- Use descriptive episode slugs (`silicon-hypothesis`, not `ep1`)
- Store assets in episode subdirectories (`ep-01/assets/`)

**❌ DON'T**:
- Skip episode numbers (1, 2, 4... ❌)
- Use special characters in slugs (`#`, `@`, `%`)
- Store assets outside content directories
- Hardcode absolute URLs in Markdown

### SEO Best Practices

**✅ DO**:
- Write unique meta descriptions (150-160 characters)
- Use descriptive episode titles (< 60 characters)
- Include relevant keywords naturally
- Add alt text to all images
- Update `last_modified` when editing content

**❌ DON'T**:
- Keyword stuff titles or descriptions
- Use identical descriptions across episodes
- Leave images without alt text
- Publish without `published_at` timestamps

### Performance Best Practices

**✅ DO**:
- Compress images before upload (< 200KB for thumbnails)
- Use WebP/AVIF formats when possible
- Lazy-load below-fold images
- Preload critical CSS and fonts

**❌ DON'T**:
- Upload uncompressed RAW images (10MB+ files)
- Inline large JavaScript libraries
- Load videos on page load (use poster images)

### Development Workflow

**✅ DO**:
- Use Git for version control
- Create feature branches for major changes
- Test locally before deploying
- Use CI/CD for automated builds
- Keep dependencies updated

**❌ DON'T**:
- Edit directly in production
- Skip local testing
- Commit `output/` directory to Git
- Ignore dependency updates

---

## Conclusion

You now have everything needed to:
- ✅ Install and configure Z-Content Platform
- ✅ Create new sites and content
- ✅ Build and deploy to production
- ✅ Troubleshoot common issues
- ✅ Follow best practices

**Next Steps**:
- Read [CAPABILITIES.md](CAPABILITIES.md) for feature documentation
- Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Study [CODE_WIKI.md](CODE_WIKI.md) for implementation details

---

**Document Version**: 2.0.0
**Last Updated**: 2025-12-22
**Support**: https://github.com/your-org/z-content-platform/issues
