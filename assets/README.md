# InfraKit Assets

This directory contains all branding and visual assets for InfraKit, organized by purpose and optimized for different use cases.

## 📁 Directory Structure

```
assets/
├── logo/                    # Main logo assets
│   ├── infrakit-logo-full-optimized.png          # Optimized full logo (144KB)
│   ├── infrakit-logo-full.svg          # Vector full logo (web-optimized)
│   ├── infrakit-logo-icon-optimized.png          # Optimized icon (195KB)
│   ├── infrakit-logo-icon.svg          # Vector icon (web-optimized)
│   └── infrakit-wordmark.svg           # Wordmark only (web-optimized)
├── favicon/                 # Browser favicon assets
│   ├── favicon.ico          # Multi-size ICO (15KB)
│   ├── favicon.svg          # Modern browser favicon (SVG)
│   ├── favicon-16x16.png    # 16px favicon (1KB)
│   ├── favicon-32x32.png    # 32px favicon (2KB)
│   └── favicon-48x48.png    # 48px favicon (4KB)
├── optimized/               # Size-optimized variants
│   ├── icon-64x64.png       # 64px icon (7KB)
│   ├── icon-128x128.png     # 128px icon (20KB)
│   └── icon-256x256.png     # 256px icon (61KB)
├── social/                  # Social media optimized
│   ├── og-image.png         # Open Graph (285KB)
│   └── twitter-card.png     # Twitter Card (284KB)
├── infrakit-logo.svg        # Legacy compatibility SVG
├── infrakit-social.svg      # Social media optimized SVG
└── README.md               # This file
```

## 🎨 Logo Assets

### Primary Logos (`logo/`)
- **`infrakit-logo-full.svg`** - Full logo with wordmark (web-optimized)
  - Primary logo for headers and main documentation
  - Use for: README headers, presentations, official documents
  - Optimal size: 300-600px width
  - Format: SVG (recommended for modern web)

- **`infrakit-logo-full-optimized.png`** - Optimized full logo (144KB)
  - PNG version of full logo, web-optimized
  - Use for: Legacy browser support, specific size requirements
  - Optimal size: 300-600px width

- **`infrakit-logo-icon.svg`** - Clean icon only (web-optimized)
  - Simplified logo without text
  - Use for: Social media avatars, compact spaces, profile pictures
  - Optimal size: 64-256px
  - Format: SVG (recommended for modern web)

- **`infrakit-logo-icon-optimized.png`** - Optimized icon (195KB)
  - PNG version of icon, web-optimized
  - Use for: Legacy browser support, specific size requirements
  - Optimal size: 64-256px

- **`infrakit-wordmark.svg`** - Wordmark only (web-optimized)
  - Text-based branding without icon
  - Use for: Footers, secondary branding locations
  - Optimal size: 200-400px width
  - Format: SVG only

## 🖼️ Favicon Assets (`favicon/`)

- **`favicon.ico`** - Multi-size ICO (15KB)
  - Browser tab icon with embedded sizes
  - Use for: Cross-browser favicon support
  - Sizes: 16x16, 32x32, 48x48px

- **`favicon-16x16.png`** - 16px favicon (1KB)
- **`favicon-32x32.png`** - 32px favicon (2KB)
- **`favicon-48x48.png`** - 48px favicon (4KB)
- **`favicon.svg`** - Modern browser favicon (267KB)
- **`favicon-vector.png`** - Vector reference (195KB)

## 🎯 Optimized Assets (`optimized/`)

- **`icon-64x64.png`** - 64px icon (7KB)
- **`icon-128x128.png`** - 128px icon (20KB)
- **`icon-256x256.png`** - 256px icon (61KB)

## 📱 Social Media Assets (`social/`)

- **`og-image.png`** - Open Graph image (285KB)
- **`twitter-card.png`** - Twitter Card image (284KB)

## 📊 Usage Recommendations

### **Web-Optimized (Recommended)**
- `infrakit-logo-full.svg` - Scalable, web-optimized
- `infrakit-logo-icon.svg` - Scalable, web-optimized
- `infrakit-wordmark.svg` - Scalable, web-optimized

### **Legacy Support (Fallback)**
- `infrakit-logo-full-optimized.png` (144KB) - Fast loading, web-optimized
- `infrakit-logo-icon-optimized.png` (195KB) - Smaller file size, good quality

### **Optional SVG Assets**
- `infrakit-logo.svg` - Legacy compatibility SVG
- `infrakit-social.svg` - Social media optimized SVG
- `favicon/favicon.svg` - Modern browser favicon support

## 🎨 Usage Examples

### In Markdown
```markdown
<!-- Full logo -->
![InfraKit Logo](assets/infrakit_logo.png)

<!-- Icon only -->
![InfraKit Icon](assets/icon.png)

<!-- Icon with letters -->
![InfraKit IK](assets/icon_ik.png)
```

### In HTML
```html
<!-- Full logo -->
<img src="assets/infrakit_logo.png" alt="InfraKit" width="300">

<!-- Icon -->
<img src="assets/icon.png" alt="InfraKit Icon" width="64">

<!-- Favicon -->
<link rel="icon" href="assets/favicon.svg" type="image/svg+xml">
```

## 📐 Dimensions

| Asset | Width | Height | Format | Use Case |
|-------|-------|--------|---------|----------|
| `infrakit_logo.png` | 400px | 120px | PNG | Headers, docs |
| `icon.png` | 200px | 200px | PNG | Avatars, compact |
| `icon_ik.png` | 200px | 200px | PNG | Favicons, apps |
| `infrakit-logo.svg` | Scalable | Scalable | SVG | Web, scalable |
| `infrakit-social.svg` | 1200px | 630px | SVG | Social previews |
| `favicon.svg` | 16px+ | 16px+ | SVG | Browser tabs |

## 🔄 Updates

When updating assets:
1. Maintain aspect ratios
2. Ensure transparency where needed
3. Optimize file sizes
4. Test on both light and dark backgrounds
5. Update this documentation

## 📖 Guidelines

For complete branding guidelines, see:
- **[BRANDING_GUIDE.md](../BRANDING_GUIDE.md)** - Complete brand guide
- **[README.md](../README.md)** - Main documentation with examples

## 🎯 Quick Reference

### Common Sizes Needed
- **16px**: Favicon, small icons
- **32px**: Toolbar icons, small buttons
- **64px**: Medium icons, list items
- **128px**: Large icons, cards
- **200px**: Profile pictures, avatars
- **400px**: Headers, banners

### File Format Guidelines
- **PNG**: Best for documentation, headers, static use
- **SVG**: Best for web, scalable applications
- **ICO**: For Windows favicon compatibility (not included)

---

*All assets are designed to work on both light and dark backgrounds and maintain clarity at various sizes.*
