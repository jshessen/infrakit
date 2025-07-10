#!/bin/bash

# InfraKit Asset Migration Script
# Migrates to the new improved naming convention

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
echo -e "${CYAN}║                      🔄 Asset Migration to New Naming                       ║${NC}"
echo -e "${CYAN}║                    Implementing improved naming convention                   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create the new directory structure if it doesn't exist
mkdir -p "$ASSETS_DIR/logo"

echo -e "${BLUE}🔄 Migrating to improved naming convention...${NC}"

# Move and rename files to new convention
if [[ -f "$ASSETS_DIR/infrakit_logo.png" ]]; then
    cp "$ASSETS_DIR/infrakit_logo.png" "$ASSETS_DIR/logo/infrakit-logo-full.png"
    echo -e "${GREEN}✓${NC} Migrated: infrakit_logo.png → logo/infrakit-logo-full.png"
fi

if [[ -f "$ASSETS_DIR/icon.png" ]]; then
    cp "$ASSETS_DIR/icon.png" "$ASSETS_DIR/logo/infrakit-logo-icon.png"
    echo -e "${GREEN}✓${NC} Migrated: icon.png → logo/infrakit-logo-icon.png"
fi

if [[ -f "$ASSETS_DIR/icon_ik.png" ]]; then
    cp "$ASSETS_DIR/icon_ik.png" "$ASSETS_DIR/logo/infrakit-logo-icon-letters.png"
    echo -e "${GREEN}✓${NC} Migrated: icon_ik.png → logo/infrakit-logo-icon-letters.png"
fi

echo ""
echo -e "${BLUE}📊 File Size Comparison:${NC}"

# Compare file sizes
compare_sizes() {
    local old_file="$1"
    local new_file="$2"
    local description="$3"
    
    if [[ -f "$old_file" && -f "$new_file" ]]; then
        old_size=$(stat -c%s "$old_file" 2>/dev/null || stat -f%z "$old_file" 2>/dev/null)
        new_size=$(stat -c%s "$new_file" 2>/dev/null || stat -f%z "$new_file" 2>/dev/null)
        
        old_mb=$(( old_size / 1048576 ))
        new_mb=$(( new_size / 1048576 ))
        
        if [[ $old_mb -eq 0 ]]; then
            old_kb=$(( old_size / 1024 ))
            echo -e "${description}: ${old_kb}KB → ${new_mb}MB"
        else
            echo -e "${description}: ${old_mb}MB → ${new_mb}MB"
        fi
    fi
}

compare_sizes "$ASSETS_DIR/infrakit_logo.png" "$ASSETS_DIR/logo/infrakit-logo-full.png" "Full Logo"
compare_sizes "$ASSETS_DIR/icon.png" "$ASSETS_DIR/logo/infrakit-logo-icon.png" "Icon"
compare_sizes "$ASSETS_DIR/icon_ik.png" "$ASSETS_DIR/logo/infrakit-logo-icon-letters.png" "Icon with Letters"

echo ""
echo -e "${BLUE}🔗 Updating documentation references...${NC}"

# Create a backup of README.md
cp "$PROJECT_ROOT/README.md" "$PROJECT_ROOT/README.md.backup"

# Update README.md with new asset paths
sed -i 's|assets/infrakit_logo.png|assets/logo/infrakit-logo-full.png|g' "$PROJECT_ROOT/README.md"
sed -i 's|assets/icon.png|assets/logo/infrakit-logo-icon.png|g' "$PROJECT_ROOT/README.md"
sed -i 's|assets/icon_ik.png|assets/logo/infrakit-logo-icon-letters.png|g' "$PROJECT_ROOT/README.md"

echo -e "${GREEN}✓${NC} Updated README.md with new asset paths"

# Update DEPLOYMENT_GUIDE.md
if [[ -f "$PROJECT_ROOT/DEPLOYMENT_GUIDE.md" ]]; then
    cp "$PROJECT_ROOT/DEPLOYMENT_GUIDE.md" "$PROJECT_ROOT/DEPLOYMENT_GUIDE.md.backup"
    sed -i 's|assets/icon_ik.png|assets/logo/infrakit-logo-icon-letters.png|g' "$PROJECT_ROOT/DEPLOYMENT_GUIDE.md"
    echo -e "${GREEN}✓${NC} Updated DEPLOYMENT_GUIDE.md with new asset paths"
fi

# Update GitHub issue templates
if [[ -f "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/bug_report.md" ]]; then
    cp "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/bug_report.md" "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/bug_report.md.backup"
    sed -i 's|../../assets/icon_ik.png|../../assets/logo/infrakit-logo-icon-letters.png|g' "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/bug_report.md"
    echo -e "${GREEN}✓${NC} Updated bug report template"
fi

if [[ -f "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/feature_request.md" ]]; then
    cp "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/feature_request.md" "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/feature_request.md.backup"
    sed -i 's|../../assets/icon_ik.png|../../assets/logo/infrakit-logo-icon-letters.png|g' "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/feature_request.md"
    echo -e "${GREEN}✓${NC} Updated feature request template"
fi

echo ""
echo -e "${BLUE}🎯 Recommended favicon implementation:${NC}"

# Create an HTML snippet for favicon implementation
cat > "$ASSETS_DIR/favicon/favicon-implementation.html" << 'EOF'
<!-- InfraKit Favicon Implementation -->
<!-- Add these tags to your HTML <head> section -->

<!-- Standard favicon -->
<link rel="icon" href="/assets/favicon/favicon.ico" type="image/x-icon">

<!-- PNG favicons for different sizes -->
<link rel="icon" type="image/png" sizes="16x16" href="/assets/favicon/favicon-16x16.png">
<link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="48x48" href="/assets/favicon/favicon-48x48.png">

<!-- SVG favicon for modern browsers -->
<link rel="icon" href="/assets/favicon.svg" type="image/svg+xml">

<!-- Apple Touch Icon -->
<link rel="apple-touch-icon" href="/assets/optimized/icon-256x256.png">

<!-- Open Graph / Social Media -->
<meta property="og:image" content="/assets/social/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:image" content="/assets/social/twitter-card.png">
EOF

echo -e "${GREEN}✓${NC} Created favicon implementation guide: favicon/favicon-implementation.html"

echo ""
echo -e "${BLUE}📁 New Asset Structure:${NC}"

# Show the new structure
echo "assets/"
echo "├── logo/"
echo "│   ├── infrakit-logo-full.png          # Full logo (230KB)"
echo "│   ├── infrakit-logo-icon.png          # Icon only (2MB)"
echo "│   └── infrakit-logo-icon-letters.png  # Icon with I/K letters (1.9MB)"
echo "├── favicon/"
echo "│   ├── favicon.ico                     # Multi-size ICO (27KB)"
echo "│   ├── favicon-16x16.png              # 16px favicon (1KB)"
echo "│   ├── favicon-32x32.png              # 32px favicon (2KB)"
echo "│   └── favicon-48x48.png              # 48px favicon (4KB)"
echo "├── optimized/"
echo "│   ├── icon-64x64.png                 # 64px icon (7KB)"
echo "│   ├── icon-128x128.png               # 128px icon (20KB)"
echo "│   └── icon-256x256.png               # 256px icon (61KB)"
echo "└── social/"
echo "    ├── og-image.png                   # Open Graph (44KB)"
echo "    └── twitter-card.png              # Twitter Card (42KB)"

echo ""
echo -e "${GREEN}🎉 Asset migration complete!${NC}"
echo ""
echo -e "${BLUE}💡 Benefits of the new structure:${NC}"
echo "• Consistent kebab-case naming"
echo "• Organized by purpose (logo/, favicon/, social/)"
echo "• Multiple size variants for optimal loading"
echo "• Proper favicon formats (.ico for compatibility)"
echo "• Optimized social media images"
echo "• Dramatically reduced file sizes for small icons"

echo ""
echo -e "${YELLOW}🔧 Next steps:${NC}"
echo "1. Test the new asset paths in your browser"
echo "2. Implement the favicon HTML (see favicon/favicon-implementation.html)"
echo "3. Consider removing the old assets once verified"
echo "4. Update any custom documentation or configs"

echo ""
echo -e "${CYAN}✨ Your assets are now optimized and properly organized!${NC}"
