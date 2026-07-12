<!-- ===================================================================== -->
<!--                            ⚠️  DISCLAIMER                              -->
<!-- ===================================================================== -->

> # 🔬 THIS IS A SIMULATION
>
> **This app does not connect to any banking network, does not read real NFC
> tags, and does not store real card data. It is strictly for UI/UX
> benchmarking and education.**
>
> - All cards are **procedurally generated fiction** — random numbers, fake
>   names, invented banks. No real PANs, no real CVVs.
> - The "tap to pay" flow is a **scripted animation**. There is no NFC I/O, no
>   HCE service, no authorization, and no money movement of any kind.
> - The completion screen says **"Test Transaction Complete — Demo Mode"** and
>   records only a local timestamp. There is deliberately **no "Approved"
>   language and no authorization code.**
> - A **persistent, non-dismissible watermark** ("🔬 DEMO — FOR TESTING ONLY")
>   is drawn over every screen, including the payment simulation.
> - "Aurora Wallet" is a **fictional brand**. This app does not use, imitate,
>   or reproduce the branding, logos, colour scheme, typeface, or sounds of any
>   real product.

---

# Aurora Wallet (Demo)

A fictional-brand wallet UI built to benchmark digital-wallet UX patterns:
carousel physics, tap-to-reveal shimmer, frosted-glass sheets, and a clearly
labelled simulated payment journey. Built with Flutter + BLoC/Cubit in a Clean
Architecture layout.

## What it demonstrates

| Area | Implementation |
|------|----------------|
| Card carousel | `PageView` with a coverflow transform (neighbours scale down) |
| Tap animation | Bouncy `Curves.elasticOut` pop + tap-to-reveal |
| Shimmer reveal | Full number + CVV shimmer in via the `shimmer` package |
| 500 cards | `CardFactory` (Factory pattern), deterministic when seeded |
| Contrast | Foreground colour picked from gradient luminance (no `palette_generator` image dependency needed) |
| Search | Filter 500 cards by bank or network |
| Transactions | Draggable **frosted-glass** `DraggableScrollableSheet`, fake randomised rows with relative timestamps |
| Payment sim | Full-screen overlay: glowing aurora circle + rotating checkmark, generic feedback, demo-only completion panel |
| State | `flutter_bloc` Cubits (`CardsCubit`, `PaymentCubit`) |
| Performance | `RepaintBoundary` around every card |
| Status bar | Light (white) icons over the dark theme |

## Project structure

```
lib/
├── main.dart
├── core/
│   ├── constants/card_networks.dart
│   ├── services/sound_service.dart
│   ├── theme/{app_colors,app_theme}.dart
│   ├── utils/color_utils.dart
│   └── widgets/demo_watermark.dart
└── features/
    ├── cards/
    │   ├── data/{card_factory,faker_data}.dart
    │   ├── domain/models/card_template.dart
    │   └── presentation/
    │       ├── cubit/{cards_cubit,cards_state}.dart
    │       ├── pages/wallet_home_page.dart
    │       └── widgets/{card_carousel,wallet_card_widget,
    │                    card_search_bar,network_logo,shimmer_reveal}.dart
    ├── payment/
    │   └── presentation/
    │       ├── cubit/{payment_cubit,payment_state}.dart
    │       └── widgets/payment_overlay.dart
    └── transactions/
        ├── transaction_model.dart
        └── transactions_sheet.dart
```

## Prerequisites

- Flutter SDK **3.19+** (Dart 3.3+)
- Android SDK + a device/emulator

## First-time setup

The full Android project (`android/`) is committed, so no `flutter create` step
is needed — just fetch packages:

```bash
flutter pub get
```

Application id: `com.aurora.aurora_wallet`. Verified toolchain:

| Component | Version |
|-----------|---------|
| Flutter   | 3.44.6 (stable) |
| Gradle wrapper | 8.14.3 |
| Android Gradle Plugin | 8.9.1 |
| Kotlin | 2.1.20 |
| compileSdk / targetSdk | 36 |

> Newer Flutter templates default to AGP 9.x / Gradle 9.x. This project is
> pinned to the AGP 8.9.1 / Gradle 8.14.3 combination it was built and verified
> against; bump both together if you want the newer chain.

### Optional: native splash ("Loading Wallet…")

```bash
dart run flutter_native_splash:create
```
Splash config lives at the bottom of `pubspec.yaml` (dark `#0B0B0F`).

## Run (debug)

```bash
flutter run
```

## Build a release APK

### 1. Create a signing key

A debug-style keystore is fine for internal testing:

```bash
keytool -genkey -v -keystore ~/aurora-demo.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias aurora
```

### 2. `android/key.properties`

Create this file (it is git-ignored):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=aurora
storeFile=/absolute/path/to/aurora-demo.jks
```

### 3. Wire signing into Gradle

In **`android/app/build.gradle`** (Groovy) add, *above* the `android { }`
block:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

…and inside `android { }`:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

> Using **`build.gradle.kts`** (newer Flutter templates)? Use the Kotlin DSL
> equivalent:
> ```kotlin
> import java.util.Properties
> import java.io.FileInputStream
>
> val keystoreProperties = Properties()
> val keystorePropertiesFile = rootProject.file("key.properties")
> if (keystorePropertiesFile.exists()) {
>     keystoreProperties.load(FileInputStream(keystorePropertiesFile))
> }
> // android { signingConfigs { create("release") { ... } }
> //          buildTypes { getByName("release") { signingConfig = signingConfigs.getByName("release") } } }
> ```

### 4. Build

```bash
flutter clean
flutter pub get
flutter build apk --release

# Output:
#   build/app/outputs/flutter-apk/app-release.apk
```

Split per-ABI (smaller APKs):

```bash
flutter build apk --release --split-per-abi
```

## Notes on assets & networking

- **No local images.** Network logos are fetched at runtime from the public
  simple-icons CDN and tinted to the card foreground; if a fetch fails, a
  stylised text chip is drawn instead, so cards never render broken.
- **Sound** defaults to the platform click + haptic (offline-safe, brand-neutral).
  To add an audible tone for lab sessions, set a **CC0 / royalty-free** URL in
  `lib/core/services/sound_service.dart` (`genericSuccessSoundUrl`). Do not
  point it at any proprietary/branded sound.

## Licensing of third-party marks

The simple-icons logos are third-party trademarks shown only to differentiate
fictional demo cards. Ensure your usage complies with each mark's guidelines
before any distribution beyond internal testing.
