# Release Instructions

This document outlines the process for creating new releases of qubase_mcp.

## Release Process

1. **Prepare for Release**
   - Ensure all desired changes are merged into the main branch
   - Update version numbers in relevant files
   - Update changelog if applicable

2. **Create and Push a Release Tag**
   ```bash
   # Ensure you're on the main branch
   git checkout main
   git pull origin main

   # Create a new tag
   git tag v1.0.0  # Replace with your version number

   # Push the tag
   git push origin v1.0.0
   ```

3. **GitHub Actions Automation**
   The tag push will automatically trigger the release workflow which:
   - Builds the application for all platforms (Linux, macOS, and Windows)
   - Creates platform-specific packages:
     - Linux: `qubase_mcp-linux-x64.tar.gz`
     - macOS: `qubase_mcp-macos-x64.dmg`
     - Windows: `qubase_mcp-windows-x64.zip`
   - Creates a GitHub release with these packages

4. **Monitor the Build**
   - Go to the GitHub Actions tab in the repository
   - Monitor the "Build and Release" workflow
   - Ensure all platforms build successfully

5. **Verify the Release**
   After the workflow completes:
   - Go to the Releases page on GitHub
   - Verify that all artifacts are present
   - Check that the packages can be downloaded
   - Test the packages on respective platforms if possible

## Manual Release (if needed)

If you need to trigger a build manually:
1. Go to the GitHub Actions tab
2. Select the "Build and Release" workflow
3. Click "Run workflow"
4. Select the branch to build from
5. Click "Run workflow"

## Troubleshooting

If the release build fails:
1. Check the GitHub Actions logs for error messages
2. Common issues:
   - Insufficient permissions (needs `GITHUB_TOKEN`)
   - Network connectivity issues
   - Platform-specific build dependencies missing

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality additions
- PATCH version for backwards-compatible bug fixes

Example: v1.0.0, v1.1.0, v1.1.1 
