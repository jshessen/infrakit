#!/bin/bash

# InfraKit Asset Optimization and Reorganization Script
# Converts PNG to SVG where beneficial and creates optimized versions

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS_DIR="$PROJECT_ROOT/assets"

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    🎨 InfraKit Asset Optimization                           ║${NC}"
echo -e "${CYAN}║                   Converting and reorganizing assets                        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if ImageMagick is available
if ! command -v convert >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ ImageMagick not found. Install it for PNG optimization:${NC}"
    echo -e "${YELLOW}  Ubuntu/Debian: apt install imagemagick${NC}"
    echo -e "${YELLOW}  macOS: brew install imagemagick${NC}"
    echo -e "${YELLOW}  Manual conversion will be needed${NC}"
    echo ""
fi

# Check if inkscape is available for SVG conversion
if ! command -v inkscape >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Inkscape not found. Install it for SVG conversion:${NC}"
    echo -e "${YELLOW}  Ubuntu/Debian: apt install inkscape${NC}"
    echo -e "${YELLOW}  macOS: brew install inkscape${NC}"
    echo ""
fi

# Function to check file size
get_file_size() {
    local file="$1"
    if [[ -f "$file" ]]; then
        stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Function to format file size
format_size() {
    local size="$1"
    if [[ $size -ge 1048576 ]]; then
        echo "$(( size / 1048576 ))MB"
    elif [[ $size -ge 1024 ]]; then
        echo "$(( size / 1024 ))KB"
    else
        echo "${size}B"
    fi
}

echo -e "${BLUE}📊 Current Asset Analysis:${NC}"

# Analyze current assets
for asset in "$ASSETS_DIR"/*.png; do
    if [[ -f "$asset" ]]; then
        name=$(basename "$asset")
        size=$(get_file_size "$asset")
        formatted_size=$(format_size "$size")
        
        echo -e "${GREEN}📄${NC} $name: ${BLUE}$formatted_size${NC}"
        
        # Recommend conversion based on size
        if [[ $size -gt 1000000 ]]; then
            echo -e "   ${YELLOW}→ Recommend: Convert to SVG or optimize${NC}"
        elif [[ $size -gt 500000 ]]; then
            echo -e "   ${YELLOW}→ Recommend: Optimize PNG${NC}"
        else
            echo -e "   ${GREEN}→ Size OK${NC}"
        fi
    fi
done

echo ""
echo -e "${BLUE}🔄 Recommended Asset Structure:${NC}"

# Create new directory structure
mkdir -p "$ASSETS_DIR/logo"
mkdir -p "$ASSETS_DIR/favicon"
mkdir -p "$ASSETS_DIR/social"
mkdir -p "$ASSETS_DIR/optimized"

echo -e "${GREEN}✓${NC} Created organized directory structure"

# Function to create optimized versions
create_optimized_png() {
    local input="$1"
    local output="$2"
    local size="$3"
    
    if command -v convert >/dev/null 2>&1; then
        convert "$input" -resize "${size}x${size}" -quality 85 "$output"
        echo -e "${GREEN}✓${NC} Created optimized ${size}x${size}: $(basename "$output")"
    else
        echo -e "${YELLOW}⚠${NC} Skipping ${size}x${size} optimization (ImageMagick not available)"
    fi
}

# Create favicon sizes
if [[ -f "$ASSETS_DIR/icon_ik.png" ]]; then
    echo -e "${BLUE}🎯 Creating favicon variants...${NC}"
    
    # Create different sizes for favicon
    create_optimized_png "$ASSETS_DIR/icon_ik.png" "$ASSETS_DIR/favicon/favicon-16x16.png" 16
    create_optimized_png "$ASSETS_DIR/icon_ik.png" "$ASSETS_DIR/favicon/favicon-32x32.png" 32
    create_optimized_png "$ASSETS_DIR/icon_ik.png" "$ASSETS_DIR/favicon/favicon-48x48.png" 48
    
    # Create ICO file if ImageMagick is available
    if command -v convert >/dev/null 2>&1; then
        convert "$ASSETS_DIR/icon_ik.png" -resize 16x16 \
                "$ASSETS_DIR/icon_ik.png" -resize 32x32 \
                "$ASSETS_DIR/icon_ik.png" -resize 48x48 \
                "$ASSETS_DIR/favicon/favicon.ico"
        echo -e "${GREEN}✓${NC} Created multi-size favicon.ico"
    fi
fi

# Create optimized icon sizes
if [[ -f "$ASSETS_DIR/icon.png" ]]; then
    echo -e "${BLUE}📐 Creating optimized icon sizes...${NC}"
    
    create_optimized_png "$ASSETS_DIR/icon.png" "$ASSETS_DIR/optimized/icon-64x64.png" 64
    create_optimized_png "$ASSETS_DIR/icon.png" "$ASSETS_DIR/optimized/icon-128x128.png" 128
    create_optimized_png "$ASSETS_DIR/icon.png" "$ASSETS_DIR/optimized/icon-256x256.png" 256
fi

# Create social media optimized versions
if [[ -f "$ASSETS_DIR/infrakit_logo.png" ]]; then
    echo -e "${BLUE}📱 Creating social media optimized versions...${NC}"
    
    if command -v convert >/dev/null 2>&1; then
        # Open Graph format (1200x630)
        convert "$ASSETS_DIR/infrakit_logo.png" -resize 1200x630 -gravity center -extent 1200x630 -quality 85 "$ASSETS_DIR/social/og-image.png"
        echo -e "${GREEN}✓${NC} Created Open Graph image (1200x630)"
        
        # Twitter Card format (1200x600)
        convert "$ASSETS_DIR/infrakit_logo.png" -resize 1200x600 -gravity center -extent 1200x600 -quality 85 "$ASSETS_DIR/social/twitter-card.png"
        echo -e "${GREEN}✓${NC} Created Twitter Card image (1200x600)"
    fi
fi

echo ""
echo -e "${BLUE}📝 Asset Renaming Recommendations:${NC}"

# Propose better naming
cat << EOF
Current → Recommended:
${YELLOW}infrakit_logo.png${NC} → ${GREEN}logo/infrakit-logo-full.png${NC}
${YELLOW}icon.png${NC} → ${GREEN}logo/infrakit-logo-icon.png${NC}
${YELLOW}icon_ik.png${NC} → ${GREEN}logo/infrakit-logo-icon-letters.png${NC}

${BLUE}New structure benefits:${NC}
• Consistent naming convention (kebab-case)
• Organized by purpose (logo/, favicon/, social/)
• Clear size variants
• Optimized file sizes
• Multiple format support
EOF

echo ""
echo -e "${BLUE}🔧 Next Steps:${NC}"
echo "1. Review the optimized assets in the new directories"
echo "2. Test the smaller file sizes in documentation"
echo "3. Update references to use the new naming convention"
echo "4. Consider SVG conversion for logos (vector graphics)"
echo "5. Use the ICO favicon for better browser compatibility"

echo ""
echo -e "${GREEN}🎉 Asset optimization complete!${NC}"
echo -e "${CYAN}Check the new directories: logo/, favicon/, social/, optimized/${NC}"
