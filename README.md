# Coffee Taper

[![iOS build and tests](https://github.com/gnutgnut/coffee-taper/actions/workflows/ios.yml/badge.svg)](https://github.com/gnutgnut/coffee-taper/actions/workflows/ios.yml)

A tiny native iPhone app. One big cup-shaped slider, from a full cup to zero in eighths. Drag the coffee level down when you are ready: **1 → ⅞ → ¾ → ⅝ → ½ → ⅜ → ¼ → ⅛ → 0**.

Your choice is saved on the phone and stays there between launches and between days. You can move it back up too. The cup means a fraction of your usual serving, not a caffeine measurement. Nothing changes automatically.

- SwiftUI, iOS 16 or later; no third-party dependencies.
- Gentle haptic feedback at each step.
- VoiceOver adjustable control, reduced-motion support and scrollable layout for large text.
- Local storage only. No account, analytics, network requests or subscriptions.
- Deleting the app deletes its saved setting. No cross-device sync.

## Run on your iPhone

1. On your Mac, unzip this project and open **CoffeeTaper.xcodeproj** in an Xcode version that supports your iPhone's iOS version.
2. Select the **CoffeeTaper** app target → **Signing & Capabilities**. Enable automatic signing and choose your Apple development team. Change the bundle identifier if Xcode says it is unavailable.
3. Connect your iPhone, trust the Mac, and enable Developer Mode on the phone if prompted.
4. Choose your iPhone as the run destination and press **⌘R**.

For Apple's device setup instructions, see [Running your app on simulated or physical devices](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices).

An Apple Account with a Personal Team can be used for personal device testing, subject to Apple's provisioning limits. This source ZIP is not an installable IPA. TestFlight/App Store distribution requires the appropriate Apple Developer Program setup and signing.

## GitHub CI

`.github/workflows/ios.yml` runs on pushes to `main`, pull requests, and manual dispatch. It uses a macOS runner with Xcode to:

1. Choose an available iPhone simulator.
2. Build the app and run XCTest checks for first launch, saved-level reload (including zero), drag mapping and range limits.
3. Upload **CoffeeTaper-Simulator** and the test result bundle under the workflow run's **Artifacts**.

The simulator artifact runs on a Mac in an iOS Simulator. It **cannot be installed on a physical iPhone**. For example, after extracting the artifact ZIP and the inner `CoffeeTaper-Simulator.zip`:

```sh
xcrun simctl install booted CoffeeTaper.app
xcrun simctl launch booted com.gnutgnut.CoffeeTaper
```

CI does not need Apple signing credentials. Signed iPhone builds and automatic TestFlight delivery are not configured; those need your Apple developer team and securely stored signing/upload credentials. Never commit certificates or private keys.

## Verification status

The [first GitHub Actions run](https://github.com/gnutgnut/coffee-taper/actions/runs/35426838980) successfully compiled the app, passed all five XCTest tests, and uploaded the simulator app and test results on 19 September 2026. Physical iPhone interaction and VoiceOver testing remain to be done.

Before relying on the app, check on an iPhone: drag through all eighths, close and reopen at ⅞ and zero, leave it overnight, and try VoiceOver adjustment. The saved level should never reset or taper automatically.
