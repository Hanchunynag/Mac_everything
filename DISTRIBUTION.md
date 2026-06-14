# Distribution

MacEverything currently supports a local demo distribution path and has the
project structure needed to move toward TestFlight, Mac App Store, or Developer
ID distribution.

## Local Demo

```bash
make run-app
```

This builds and opens:

```text
.build/MacEverything.app
```

To create a zip for GitHub Releases or direct sharing:

```bash
make release-zip
```

The zip is written to:

```text
.build/dist/MacEverything-0.3.3-macOS.zip
```

## Local Run Caveats

Local development builds are useful for fast demos, but they are not the same
as a public macOS release:

- The app is signed with a local Apple Development identity when available.
  That signature is meant for this development Mac and may not satisfy
  Gatekeeper on another Mac.
- A widely shared app should be signed with a Developer ID Application
  certificate, notarized by Apple, and then packaged as a `.dmg` or `.zip`.
- `make run-app` writes generated output under `.build`. Cleaning the package
  or switching build tools can remove that app bundle; rerun `make run-app` or
  `make package` to recreate it.
- Search results depend on Spotlight indexing and macOS privacy permissions.
  Missing files usually mean Spotlight cannot see that location, or the app
  has not been granted enough access.
- Full Disk Access may be needed for broad local testing. A Mac App Store
  version should avoid unrestricted full-disk assumptions and use explicit
  folder selection flows.
- Xcode may print destination or build-number warnings during local packaging.
  They are noisy but usually nonfatal if the script still prints the app path
  and signing identity.

## TestFlight Demo Path

1. Join the Apple Developer Program.
2. Create an explicit App ID for `com.hanchunyang.MacEverything`.
3. Create the app record in App Store Connect.
4. Open `MacEverything.xcodeproj` in Xcode.
5. Select the `MacEverything` scheme and a macOS destination.
6. Archive from Xcode.
7. Upload the archive to App Store Connect.
8. Add internal or external testers in TestFlight.

## Mac App Store Path

Mac App Store review is stricter for file search tools. A store-ready version
should avoid unrestricted full-disk behavior and instead let users choose
folders to index through standard macOS permission flows.

Before submission, prepare:

- App icon.
- Screenshots.
- Privacy policy.
- App sandbox and file access behavior.
- App category and description.
- Version and build number.
- Review notes explaining how search works and what folders are accessed.

## Developer ID Path

For an Everything-like utility with broader file access, Developer ID
distribution is likely a better fit than the Mac App Store.

Expected release flow:

1. Sign the app with a Developer ID Application certificate.
2. Notarize the app with Apple.
3. Staple the notarization ticket.
4. Package as `.dmg` or `.zip`.
5. Publish through GitHub Releases or a website.

The current `make release-zip` output is suitable for local demo sharing, but
not yet notarized for wide public distribution.
