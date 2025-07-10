# InfraKit Releases

This directory contains release documentation for InfraKit versions.

## Release Documentation Structure

Each release includes:
- **Release Notes** (`RELEASE_NOTES_vX.X.X.md`) - Detailed release information for GitHub
- **Release Checklist** (`RELEASE_CHECKLIST_vX.X.X.md`) - Internal validation checklist
- **Release Summary** (`RELEASE_SUMMARY_vX.X.X.md`) - Executive summary and status

## Available Releases

### [v1.1.0](./RELEASE_NOTES_v1.1.0.md) - July 10, 2025
**Production-Ready Infrastructure Toolkit**

Major release featuring:
- Complete branding integration with optimized assets
- Production deployment system with multi-environment support
- Enhanced automation with safe update mechanisms
- Comprehensive security enhancements
- Extensive documentation and validation scripts

**Status**: ✅ Released  
**Files**: [Release Notes](./RELEASE_NOTES_v1.1.0.md) | [Checklist](./RELEASE_CHECKLIST_v1.1.0.md) | [Summary](./RELEASE_SUMMARY_v1.1.0.md)

---

## Release Process

For maintainers, the standard release process:

1. **Prepare**: Update CHANGELOG.md and create release documentation
2. **Validate**: Run comprehensive checks (`./scripts/pre_commit_check.sh`)
3. **Document**: Create release notes, checklist, and summary
4. **Commit**: Commit release files to main branch
5. **Tag**: Create annotated git tag
6. **Publish**: Push to GitHub and create release
7. **Archive**: Move release files to `docs/releases/`

## Template Files

For future releases, use these templates:
- [Release Notes Template](../templates/RELEASE_NOTES_TEMPLATE.md)
- [Release Checklist Template](../templates/RELEASE_CHECKLIST_TEMPLATE.md)
- [Release Summary Template](../templates/RELEASE_SUMMARY_TEMPLATE.md)

---

**Latest Release**: [v1.1.0](./RELEASE_NOTES_v1.1.0.md)  
**Next Release**: v1.2.0 (planned)
