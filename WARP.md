# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Primary Development Workflow
```bash
# Install dependencies (workspace-wide)
nvm use # Use Node.js v22.x
npm install

# Set up Git LFS for 3D assets
git lfs install
git lfs pull

# Start development servers (recommended)
npm run iterate
# This builds the library in watch mode and starts preview app on http://localhost:3000

# Alternative: run packages individually
cd packages/avatar-creator && npm run iterate  # Build library + serve assets
cd examples/avatar-preview-app && npm run iterate  # Start preview app
```

### Build and Release
```bash
# Production build
npm run build

# Preview production build
cd examples/avatar-preview-app && npm run start

# Validate code quality
npm run validate  # Runs type-check, lint, and dependency checks

# Individual validation commands
npm run type-check-all
npm run lint-all
npm run lint-fix-all
npm run depcheck-all
```

## Architecture Overview

### Monorepo Structure
- **`packages/avatar-creator`**: Core React component library using PlayCanvas 3D engine
- **`examples/avatar-preview-app`**: Next.js demo application showcasing the library
- **Turbo.build**: Manages build orchestration and caching across packages

### Core Components

#### Avatar System
- **AvatarLoader**: Central class managing 3D model loading, animation, and rendering
- **Configurator**: UI component for customizing avatar appearance
- **Renderer**: PlayCanvas integration component handling 3D rendering

#### Data Model
Avatar data follows a slot-based system with support for:
- **Body Types**: `bodyA` and `bodyB` with different proportions/skeletons  
- **Slots**: `head`, `hair`, `top`, `bottom`, `shoes`, `outfit` (complete look)
- **Skin Dependency**: Some slots require 7 variants (`_01` to `_07`) for different skin tones
- **Secondary Assets**: `top` and `bottom` can have secondary models (e.g., layered clothing)

#### 3D Asset Pipeline
- **GLB Models**: 3D assets using PlayCanvas-compatible GLB format with UE5 Manny skeleton
- **Thumbnails**: Paired `.webp` files for UI previews
- **Textures**: PBR materials with 1024x1024 textures (albedo, normals, roughness+metalness, AO)

### Build System
- **ESBuild**: Used for TypeScript compilation and bundling
- **Custom Plugins**: CSS chunks fix plugin and TypeScript declaration generation
- **Asset Handling**: Base64 embedding for WASM modules (Draco compression)

### Animation System
- **PlayCanvas AnimGraph**: State machine for animation control
- **Animation Types**: `idle`, `appear` (on load), `emote` (user-triggered)
- **MML Format**: Custom format for avatar configuration serialization

## Key Development Patterns

### Asset Loading
- Assets cached with 1-second expiration to manage memory
- Asynchronous loading with loading state management
- Support for skin-dependent assets with automatic suffix handling

### Component Architecture
- React components with CSS Modules for styling
- Event-driven communication between 3D engine and UI
- Separation of 3D logic (scripts/) from UI components

### Testing 3D Assets
- Validate GLB files: https://github.khronos.org/glTF-Validator/
- Preview models: https://playcanvas.com/model-viewer
- Test with various part combinations to prevent clipping

### Release Process
- Automated releases on version changes in `packages/avatar-creator/package.json`
- CI publishes to npm as `@msquared/avatar-creator`
- Manual releases via `./scripts/release-new-version.sh`

## Code Quality Standards

### License Headers
All source files require MIT license headers (enforced by ESLint):
```typescript
/**
 * @license
 * Copyright Improbable MV Limited.
 *
 * Use of this source code is governed by an MIT-style license that can be
 * found in the LICENSE file at https://github.com/msquared-io/avatar-creator/blob/main/LICENSE
 */
```

### TypeScript Configuration
- Strict mode enabled with `noEmit` for type checking
- Import sorting enforced via ESLint
- No non-null assertions allowed (use proper type guards)

### Asset Organization
- All 3D models must follow naming conventions (e.g., `Body_A_TorsoHeadless_01.glb`)
- Thumbnails must match model filenames with `.webp` extension
- URLs in data.json exclude file extensions (added by application)

## Environment Configuration
- Node.js v22.x required (see `.nvmrc`)
- Git LFS required for handling large 3D assets and images
- Development server runs on port 3000 by default
- Asset URLs configured via data.json or environment variables

## Common Issues

### Git LFS Setup
If 3D models or images appear corrupted:
```bash
git lfs install
git lfs pull
```

### Build Failures
Most build issues relate to TypeScript or missing dependencies:
```bash
npm run type-check-all  # Check TypeScript errors
npm run lint-fix-all    # Fix auto-fixable linting issues
```

### Asset Loading Issues
- Verify GLB file validity using official validator
- Check console for PlayCanvas loading errors
- Ensure thumbnail files exist with matching names