#!/bin/bash

# InfraKit Branding Validation Script
# Checks that all branding assets are properly integrated

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS_DIR="$PROJECT_ROOT/assets"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                     🎨 InfraKit Branding Validation                         ║${NC}"
echo -e "${CYAN}║                  Checking asset integration and usage                       ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Track validation results
PASSED=0
FAILED=0
WARNINGS=0

# Function to check if file exists
check_file() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $description: ${BLUE}$(basename "$file")${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $description: ${RED}$(basename "$file") NOT FOUND${NC}"
        ((FAILED++))
    fi
}

# Function to check if file contains reference
check_reference() {
    local file="$1"
    local pattern="$2"
    local description="$3"
    
    if [[ -f "$file" ]] && grep -q "$pattern" "$file"; then
        echo -e "${GREEN}✓${NC} $description: ${BLUE}$(basename "$file")${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} $description: ${YELLOW}$(basename "$file") - Pattern not found${NC}"
        ((WARNINGS++))
    fi
}

echo -e "${BLUE}🔍 Checking Asset Files...${NC}"

# Check all required asset files
check_file "$ASSETS_DIR/logo/infrakit-logo-full-optimized.png" "Full logo with wordmark (PNG)"
check_file "$ASSETS_DIR/logo/infrakit-logo-icon-optimized.png" "Clean icon only (PNG)"
check_file "$ASSETS_DIR/logo/infrakit-logo-full.svg" "Full logo with wordmark (SVG)"
check_file "$ASSETS_DIR/logo/infrakit-logo-icon.svg" "Clean icon only (SVG)"
check_file "$ASSETS_DIR/logo/infrakit-wordmark.svg" "Wordmark only (SVG)"
check_file "$ASSETS_DIR/favicon/favicon.ico" "Multi-size ICO favicon"
check_file "$ASSETS_DIR/README.md" "Assets documentation"

# Optional files (won't fail validation if missing)
echo -e "${BLUE}📋 Checking Optional Assets...${NC}"

# Check for vector logo assets
if [[ -f "$ASSETS_DIR/logo/infrakit-logo-full.svg" ]]; then
    echo -e "${GREEN}✓${NC} Vector full logo: infrakit-logo-full.svg"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Vector full logo: infrakit-logo-full.svg (required)"
    ((FAILED++))
fi

if [[ -f "$ASSETS_DIR/logo/infrakit-logo-icon.svg" ]]; then
    echo -e "${GREEN}✓${NC} Vector icon logo: infrakit-logo-icon.svg"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Vector icon logo: infrakit-logo-icon.svg (required)"
    ((FAILED++))
fi

if [[ -f "$ASSETS_DIR/logo/infrakit-wordmark.svg" ]]; then
    echo -e "${GREEN}✓${NC} Vector wordmark: infrakit-wordmark.svg"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Vector wordmark: infrakit-wordmark.svg (required)"
    ((FAILED++))
fi

# Legacy optional assets check
if [[ -f "$ASSETS_DIR/infrakit-logo.svg" ]]; then
    echo -e "${GREEN}✓${NC} Legacy vector logo: infrakit-logo.svg"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} Legacy vector logo: infrakit-logo.svg (optional - not found)"
    ((WARNINGS++))
fi

if [[ -f "$ASSETS_DIR/infrakit-social.svg" ]]; then
    echo -e "${GREEN}✓${NC} Social media preview: infrakit-social.svg"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} Social media preview: infrakit-social.svg (optional - not found)"
    ((WARNINGS++))
fi

if [[ -f "$ASSETS_DIR/favicon/favicon.svg" ]]; then
    echo -e "${GREEN}✓${NC} Browser favicon: favicon.svg"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} Browser favicon: favicon.svg (optional - not found)"
    ((WARNINGS++))
fi

echo ""
echo -e "${BLUE}📚 Checking Documentation Integration...${NC}"

# Check documentation files for branding references
check_reference "$PROJECT_ROOT/README.md" "infrakit-logo-full.svg" "README logo integration"
check_reference "$PROJECT_ROOT/README.md" "Branding Assets" "README branding section"
check_reference "$PROJECT_ROOT/DEPLOYMENT_GUIDE.md" "infrakit-logo-icon.svg" "Deployment guide branding"
check_reference "$PROJECT_ROOT/docker-compose.yml" "InfraKit" "Docker Compose branding"
check_reference "$PROJECT_ROOT/Makefile" "InfraKit" "Makefile branding"

echo ""
echo -e "${BLUE}📋 Checking Templates and Config Files...${NC}"

# Check GitHub templates
check_reference "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/bug_report.md" "infrakit-logo-icon.svg" "Bug report template"
check_reference "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/feature_request.md" "infrakit-logo-icon.svg" "Feature request template"
check_reference "$PROJECT_ROOT/CHANGELOG.md" "branding integration" "Changelog branding entry"

echo ""
echo -e "${BLUE}🎯 Checking Asset Sizes and Formats...${NC}"

# Check PNG files exist and are reasonably sized
for asset_path in "$ASSETS_DIR/logo/infrakit-logo-full-optimized.png" "$ASSETS_DIR/logo/infrakit-logo-icon-optimized.png"; do
    if [[ -f "$asset_path" ]]; then
        asset=$(basename "$asset_path")
        size=$(stat -c%s "$asset_path" 2>/dev/null || stat -f%z "$asset_path" 2>/dev/null || echo "0")
        if [[ $size -gt 1000 ]]; then
            echo -e "${GREEN}✓${NC} $asset: ${BLUE}$(( size / 1024 ))KB${NC}"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠${NC} $asset: ${YELLOW}File too small ($(( size / 1024 ))KB)${NC}"
            ((WARNINGS++))
        fi
    else
        asset=$(basename "$asset_path")
        echo -e "${RED}✗${NC} $asset: ${RED}File not found${NC}"
        ((FAILED++))
    fi
done

echo ""
echo -e "${BLUE}🔗 Checking Links and References...${NC}"

# Check for common branding patterns
if grep -r "infrakit-logo-full.svg\|infrakit-logo-icon.svg\|infrakit-wordmark.svg" "$PROJECT_ROOT"/*.md > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Asset references found in documentation"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} No asset references found in main documentation"
    ((WARNINGS++))
fi

# Check for InfraKit branding consistency
if grep -r "InfraKit" "$PROJECT_ROOT"/*.md > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} InfraKit branding found in documentation"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} InfraKit branding not found in documentation"
    ((FAILED++))
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                           📊 Validation Summary                              ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}✓ Passed: $PASSED${NC}"
if [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}⚠ Warnings: $WARNINGS${NC}"
fi
if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}✗ Failed: $FAILED${NC}"
fi

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}🎉 All critical branding validations passed!${NC}"
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}💡 Consider addressing the warnings above for optimal branding.${NC}"
    fi
    exit 0
else
    echo -e "${RED}❌ Some branding validations failed. Please review the errors above.${NC}"
    exit 1
fi
