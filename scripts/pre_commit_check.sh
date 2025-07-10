#!/bin/bash

# InfraKit Pre-Commit Production Readiness Check
# Comprehensive validation before committing changes

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
WARNINGS=0

print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                     🚀 InfraKit Pre-Commit Check                            ║${NC}"
    echo -e "${CYAN}║                   Production Readiness Validation                           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_command() {
    local cmd="$1"
    local description="$2"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $description - $cmd not found"
        ((FAILED++))
    fi
}

check_file() {
    local file="$1"
    local description="$2"
    local required="$3"
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASSED++))
    else
        if [[ "$required" == "required" ]]; then
            echo -e "${RED}✗${NC} $description - File not found: $file"
            ((FAILED++))
        else
            echo -e "${YELLOW}⚠${NC} $description - Optional file not found: $file"
            ((WARNINGS++))
        fi
    fi
}

check_directory() {
    local dir="$1"
    local description="$2"
    
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $description - Directory not found: $dir"
        ((FAILED++))
    fi
}

check_git_status() {
    echo -e "${BLUE}📋 Checking Git Status...${NC}"
    
    # Check if we're in a git repository
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Git repository detected"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Not in a git repository"
        ((FAILED++))
        return
    fi
    
    # Check for uncommitted changes
    if git diff-index --quiet HEAD --; then
        echo -e "${GREEN}✓${NC} No uncommitted changes in tracked files"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} Uncommitted changes detected in tracked files"
        ((WARNINGS++))
    fi
    
    # Check for untracked important files
    local untracked_important=$(git ls-files --others --exclude-standard | grep -E "\.(md|yml|yaml|sh|env\.example)$" | head -5)
    if [[ -n "$untracked_important" ]]; then
        echo -e "${YELLOW}⚠${NC} Important untracked files detected:"
        echo "$untracked_important" | sed 's/^/   - /'
        ((WARNINGS++))
    else
        echo -e "${GREEN}✓${NC} No critical untracked files"
        ((PASSED++))
    fi
}

check_docker_environment() {
    echo -e "${BLUE}🐳 Checking Docker Environment...${NC}"
    
    check_command "docker" "Docker installed"
    check_command "docker-compose" "Docker Compose installed"
    
    # Check if Docker daemon is running
    if docker info >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker daemon is running"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Docker daemon is not running"
        ((FAILED++))
    fi
    
    # Check Docker Compose file syntax
    if docker-compose config >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker Compose syntax is valid"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Docker Compose syntax errors detected"
        ((FAILED++))
    fi
}

check_environment_files() {
    echo -e "${BLUE}📄 Checking Environment Files...${NC}"
    
    check_file "$PROJECT_ROOT/.env.example" "Environment template exists" "required"
    check_file "$PROJECT_ROOT/.env" "Environment file exists" "optional"
    check_file "$PROJECT_ROOT/.env.production" "Production environment template" "optional"
    check_file "$PROJECT_ROOT/.env.edge" "Edge environment template" "optional"
    
    # Check for sensitive data in .env files
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        if grep -q "password\|secret\|key" "$PROJECT_ROOT/.env" >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠${NC} Potential sensitive data in .env file"
            ((WARNINGS++))
        else
            echo -e "${GREEN}✓${NC} No obvious sensitive data in .env file"
            ((PASSED++))
        fi
    fi
}

check_secrets_directory() {
    echo -e "${BLUE}🔐 Checking Secrets Configuration...${NC}"
    
    check_directory "$PROJECT_ROOT/secrets" "Secrets directory exists"
    
    if [[ -d "$PROJECT_ROOT/secrets" ]]; then
        local secret_count=$(find "$PROJECT_ROOT/secrets" -type f | wc -l)
        if [[ $secret_count -gt 0 ]]; then
            echo -e "${GREEN}✓${NC} Secrets directory contains $secret_count files"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠${NC} Secrets directory is empty"
            ((WARNINGS++))
        fi
    fi
    
    check_file "$PROJECT_ROOT/SECRETS_SETUP.md" "Secrets setup documentation" "required"
}

check_documentation() {
    echo -e "${BLUE}📚 Checking Documentation...${NC}"
    
    check_file "$PROJECT_ROOT/README.md" "Main README exists" "required"
    check_file "$PROJECT_ROOT/CHANGELOG.md" "Changelog exists" "required"
    check_file "$PROJECT_ROOT/CONTRIBUTING.md" "Contributing guide exists" "optional"
    check_file "$PROJECT_ROOT/DEPLOYMENT_GUIDE.md" "Deployment guide exists" "required"
    check_file "$PROJECT_ROOT/BRANDING_GUIDE.md" "Branding guide exists" "optional"
    
    # Check if README has basic sections
    if [[ -f "$PROJECT_ROOT/README.md" ]]; then
        local required_sections=("Installation" "Usage" "Services" "Configuration")
        for section in "${required_sections[@]}"; do
            if grep -q "# $section\|## $section" "$PROJECT_ROOT/README.md"; then
                echo -e "${GREEN}✓${NC} README contains $section section"
                ((PASSED++))
            else
                echo -e "${YELLOW}⚠${NC} README missing $section section"
                ((WARNINGS++))
            fi
        done
    fi
}

check_scripts() {
    echo -e "${BLUE}🛠️  Checking Scripts...${NC}"
    
    check_directory "$PROJECT_ROOT/scripts" "Scripts directory exists"
    
    local important_scripts=("setup_env.sh" "security_check.sh" "validate_branding.sh" "update.sh")
    for script in "${important_scripts[@]}"; do
        local script_path="$PROJECT_ROOT/scripts/$script"
        check_file "$script_path" "Script: $script" "required"
        
        if [[ -f "$script_path" && -x "$script_path" ]]; then
            echo -e "${GREEN}✓${NC} Script $script is executable"
            ((PASSED++))
        elif [[ -f "$script_path" ]]; then
            echo -e "${YELLOW}⚠${NC} Script $script is not executable"
            ((WARNINGS++))
        fi
    done
}

check_assets() {
    echo -e "${BLUE}🎨 Checking Assets...${NC}"
    
    check_directory "$PROJECT_ROOT/assets" "Assets directory exists"
    check_directory "$PROJECT_ROOT/assets/logo" "Logo assets directory"
    check_directory "$PROJECT_ROOT/assets/favicon" "Favicon assets directory"
    
    # Check for main logo files
    local logo_files=("infrakit-logo-full.svg" "infrakit-logo-icon.svg" "infrakit-wordmark.svg")
    for logo in "${logo_files[@]}"; do
        check_file "$PROJECT_ROOT/assets/logo/$logo" "Logo: $logo" "required"
    done
    
    # Check favicon
    check_file "$PROJECT_ROOT/assets/favicon/favicon.ico" "Favicon ICO file" "required"
    
    # Run branding validation if available
    if [[ -x "$PROJECT_ROOT/scripts/validate_branding.sh" ]]; then
        echo -e "${BLUE}🎨 Running branding validation...${NC}"
        if "$PROJECT_ROOT/scripts/validate_branding.sh" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Branding validation passed"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠${NC} Branding validation had warnings"
            ((WARNINGS++))
        fi
    fi
}

check_security() {
    echo -e "${BLUE}🔒 Checking Security...${NC}"
    
    # Check .gitignore
    check_file "$PROJECT_ROOT/.gitignore" "Gitignore file exists" "required"
    
    if [[ -f "$PROJECT_ROOT/.gitignore" ]]; then
        local important_ignores=(".env" "secrets/" "*.key" "*.pem")
        for ignore_pattern in "${important_ignores[@]}"; do
            if grep -q "$ignore_pattern" "$PROJECT_ROOT/.gitignore"; then
                echo -e "${GREEN}✓${NC} Gitignore includes $ignore_pattern"
                ((PASSED++))
            else
                echo -e "${YELLOW}⚠${NC} Gitignore missing $ignore_pattern"
                ((WARNINGS++))
            fi
        done
    fi
    
    # Run security check if available
    if [[ -x "$PROJECT_ROOT/scripts/security_check.sh" ]]; then
        echo -e "${BLUE}🔒 Running security check...${NC}"
        if "$PROJECT_ROOT/scripts/security_check.sh" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Security check passed"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠${NC} Security check had warnings"
            ((WARNINGS++))
        fi
    fi
}

check_makefile() {
    echo -e "${BLUE}🏗️  Checking Makefile...${NC}"
    
    check_file "$PROJECT_ROOT/Makefile" "Makefile exists" "required"
    
    if [[ -f "$PROJECT_ROOT/Makefile" ]]; then
        local important_targets=("help" "up" "down" "install" "update" "check")
        for target in "${important_targets[@]}"; do
            if grep -q "^$target:" "$PROJECT_ROOT/Makefile"; then
                echo -e "${GREEN}✓${NC} Makefile has $target target"
                ((PASSED++))
            else
                echo -e "${YELLOW}⚠${NC} Makefile missing $target target"
                ((WARNINGS++))
            fi
        done
        
        # Check if Makefile syntax is valid
        if make -n help >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Makefile syntax is valid"
            ((PASSED++))
        else
            echo -e "${RED}✗${NC} Makefile syntax errors detected"
            ((FAILED++))
        fi
    fi
}

print_summary() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                           📊 Pre-Commit Summary                              ║${NC}"
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
        echo -e "${GREEN}🎉 Production readiness check passed!${NC}"
        if [[ $WARNINGS -gt 0 ]]; then
            echo -e "${YELLOW}💡 Consider addressing the warnings above for optimal production deployment.${NC}"
        else
            echo -e "${GREEN}✨ Perfect! Ready for production deployment.${NC}"
        fi
        echo -e "${GREEN}🚀 Safe to commit and deploy!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Production readiness check failed.${NC}"
        echo -e "${RED}🛠️  Please fix the critical issues above before committing.${NC}"
        exit 1
    fi
}

# Main execution
cd "$PROJECT_ROOT"
print_header

check_git_status
check_docker_environment
check_environment_files
check_secrets_directory
check_documentation
check_scripts
check_assets
check_security
check_makefile

print_summary
