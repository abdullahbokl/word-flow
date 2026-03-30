# WordFlow Version Management

## Overview

WordFlow uses **semantic versioning** (major.minor.patch) with CI/CD automation for build numbers.

## Version Format

```
major.minor.patch+build_number

Example: 1.2.5+42
  ├─ 1        : Major version (breaking changes)
  ├─ 2        : Minor version (new backward-compatible features)
  ├─ 5        : Patch version (bug fixes)
  └─ 42       : Build number (automatically incremented by CI)
```

## Where Version is Defined

- **pubspec.yaml** — SOURCE OF TRUTH for app version
- **android/app/build.gradle.kts** — Auto-derived from pubspec.yaml
- **ios/Runner/Info.plist** — Auto-derived from pubspec.yaml

## Version Numbering Scheme

### MAJOR Version (e.g., 2.x.x → 3.0.0)
When:
- Breaking changes to app architecture or data format
- Major feature rewrites
- Significant UI/UX redesigns
- Database schema migrations (breaking compatibility)

Bump: `major.minor.patch` → `(major+1).0.0`

```bash
# Example: 1.5.3+42 → 2.0.0+1
version: 2.0.0+1  # in pubspec.yaml
```

### MINOR Version (e.g., 1.2.x → 1.3.0)
When:
- New backward-compatible feature
- New observability instrumentation
- New BLoC state or usecase
- New model or entity

Bump: `major.minor.patch` → `major.(minor+1).0`

```bash
# Example: 1.2.3+42 → 1.3.0+1
version: 1.3.0+1  # in pubspec.yaml
```

### PATCH Version (e.g., 1.2.3 → 1.2.4)
When:
- Bug fix (no new features)
- Performance improvement
- Dependency security update
- Test improvement

Bump: `major.minor.patch` → `major.minor.(patch+1)`

```bash
# Example: 1.2.3+42 → 1.2.4+1
version: 1.2.4+1  # in pubspec.yaml
```

## Build Number Management

**Build number:** Incremented automatically for each release build by CI/CD.

- **Local development:** Use any build number (e.g., +1)
- **CI/CD pipeline:** GitHub Actions auto-increments build number on each release
- **Reset on version bump:** Always reset to +1 when changing major.minor.patch

### Build Number Increment Flow

```
1. Developer bumps version: 1.2.3 → 1.3.0
   └─ Update pubspec.yaml to: version: 1.3.0+1

2. Developer creates PR and merges to main

3. CI/CD pipeline runs release job:
   └─ flutter build appbundle --build-name 1.3.0 --build-number 42
   └─ Creates build: 1.3.0+42

4. Next CI/CD build auto-increments:
   └─ flutter build appbundle --build-name 1.3.0 --build-number 43
   └─ Creates build: 1.3.0+43

5. New version release (1.4.0):
   └─ Reset to: version: 1.4.0+1 in pubspec.yaml
   └─ CI/CD continues incrementing from +2
```

## How to Bump Version

### 1. Update pubspec.yaml

```yaml
# Before:
version: 1.2.3+42

# After (patch bump):
version: 1.2.4+1

# After (minor bump):
version: 1.3.0+1

# After (major bump):
version: 2.0.0+1
```

### 2. Create Commit

```bash
git checkout -b chore/bump-version-1.2.4
git add pubspec.yaml
git commit -m "chore: bump version to 1.2.4

BREAKING CHANGES: None
NEW FEATURES: None
BUG FIXES:
- Fix sync deadlock on rapid reconnect
- Fix memory leak in BLoC disposal
"
git push origin chore/bump-version-1.2.4
```

### 3. Create PR and Get Approval

- Title: "chore: bump version to X.Y.Z"
- Include changelog in description
- Link any associated issues

### 4. Merge to main

CI/CD automatically builds with next build number

## Verifying Version

### Local Build

```bash
# Extract version from pubspec.yaml
grep "^version:" pubspec.yaml

# Output: version: 1.2.4+1
```

### Android APK

```bash
# Extract version info
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep versionName

# Output: package: name='com.example.wordflow' versionCode='42' versionName='1.2.4'
```

### iOS IPA

```bash
# Extract version from Info.plist inside IPA
unzip -p app-release.ipa "Runner.app/Info.plist" | grep -A1 CFBundleShortVersionString

# Output: CFBundleShortVersionString: 1.2.4
```

## Release Checklist

- [ ] Update pubspec.yaml version (reset build number to +1)
- [ ] Update CHANGELOG.md with new features and fixes
- [ ] Create version bump commit: `chore: bump version to X.Y.Z`
- [ ] Create PR with changelog
- [ ] Get code review approval
- [ ] Merge to main branch
- [ ] CI/CD builds release artifacts automatically
- [ ] Verify builds in GitHub Actions
- [ ] Tag release: `git tag v1.2.4 && git push origin v1.2.4`
- [ ] Create GitHub Release with APK/IPA downloads

## CI/CD Integration

### Automatic Build Number Increment

GitHub Actions CI/CD automatically sets build numbers for release builds:

```yaml
# In .github/workflows/ci.yml (build-android job)
flutter build apk \
  --release \
  --build-name 1.2.4 \           # From pubspec.yaml
  --build-number ${{ github.run_number }}  # Auto-increment from CI
```

### Example CI Run

```
GitHub Actions Run #42:
  Input: pubspec.yaml version: 1.2.4+1
  Output: APK built with versionCode=42, versionName=1.2.4

GitHub Actions Run #43:
  Input: pubspec.yaml version: 1.2.4+1
  Output: APK built with versionCode=43, versionName=1.2.4

Developer bumps version to 1.3.0:
GitHub Actions Run #44:
  Input: pubspec.yaml version: 1.3.0+1
  Output: APK built with versionCode=44, versionName=1.3.0
```

## Git Tags for Releases

```bash
# Tag a release
git tag v1.2.4 -m "Release 1.2.4: Bug fixes and performance improvements"
git push origin v1.2.4

# List all tags
git tag -l

# View tag details
git show v1.2.4
```

## Platform-Specific Version Mappings

### Android (android/app/build.gradle.kts)

```kotlin
// Auto-derived from pubspec.yaml version
versionCode = flutterVersionCode.toInteger()  // = github.run_number
versionName = flutterVersionName              // = major.minor.patch
```

### iOS (ios/Runner/Info.plist)

```xml
<key>CFBundleShortVersionString</key>
<string>1.2.4</string>  <!-- = major.minor.patch -->
<key>CFBundleVersion</key>
<string>42</string>     <!-- = build number -->
```

## Troubleshooting

### Build number mismatch

**Problem:** Local build has version 1.2.4+999 but CI shows 1.2.4+42

**Solution:** This is expected. CI/CD uses its own build numbers. Always use CI-built APKs for release.

### Version not updating on device

**Problem:** App shows old version after update

**Solution:** 
```bash
# Force rebuild
flutter clean
dart run build_runner build --delete-conflicting-outputs
flutter pub get
flutter build apk --release
```

### CI keeps rebuilding same version

**Problem:** Version stays 1.2.4+1 across multiple CI runs

**Solution:** This is correct behavior. Build number is set by `github.run_number` at CI runtime. Each pushed commit increments the build number automatically.

## Related Documentation

- **pubspec.yaml** — Version declaration and metadata
- **.github/workflows/ci.yml** — CI/CD versioning automation
- **CHANGELOG.md** — Release notes and version history
- **README.md** — Getting started and development setup
