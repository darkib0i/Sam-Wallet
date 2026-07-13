<!--
=====================================================================
  THIS IS A SIMULATION.
  This app does not connect to any banking network, does not read real
  NFC tags, and does not store real card data. It is strictly for
  UI/UX benchmarking and education.
=====================================================================
-->

# Wallet Clone (Demo)

> **THIS IS A SIMULATION.** This app does not connect to any banking network,
> does not read real NFC tags, and does not store real card data. It is strictly
> for UI/UX benchmarking and education.

A Samsung-Wallet-style UI built with Flutter for animation and layout
benchmarking. Every card, number, name, transaction, and "payment" is fake and
generated locally.

## Deliberate safety choices

The payment flow is intentionally **not** a convincing replica of a real
completed transaction:

- A permanent **"DEMO · NOT A REAL PAYMENT"** watermark is painted across the
  payment overlay.
- The result reads **"Demo approved — Testing mode, no funds moved"** with a
  clearly-labelled *mock reference* (never a bank authorization code).
- There is **no success chime / no cloned Samsung sound** — only a light haptic.
- The header carries a persistent **DEMO** badge and the app label is
  "Wallet Clone (Demo)".

This keeps it useful for evaluating animation timing and layout while making it
impossible to mistake for a genuine payment.

## Features

- **500 generated card designs** via a seeded `CardFactory` (factory pattern):
  distinct gradients, networks (Visa, Mastercard, Amex, Diners, JCB, UnionPay,
  RuPay, Maestro, Crypto…), faker card-holder names, and format-only PANs.
- **Contrast-aware text** — light/dark foreground chosen from each card's
  gradient luminance (a lightweight stand-in for `palette_generator`).
- **Coverflow carousel** — `PageView` that scales/fades adjacent cards.
- **Bouncy spring tap** and **tap-to-reveal shimmer** on the full number & CVV.
- **Search** filtering all cards by bank or network.
- **Draggable "Recent activity" sheet** with randomized, time-stamped fake
  transactions ("2 mins ago", "Yesterday", …).
- **Simulated tap-to-pay** triggered by the on-screen "NFC field (test)" button.
- `RepaintBoundary` around every card face for smooth scrolling.

## Architecture

Feature-first / clean-ish layering with **Cubit (flutter_bloc)** state:

```
lib/
  core/theme, core/utils
  features/
    cards/    domain · data (CardFactory) · presentation (cubit, pages, widgets)
    payment/  domain · data (TransactionFactory) · presentation (cubit, widgets)
    animations/  spring_tap, shimmer
```

## Build

Requires the Flutter SDK and the Android SDK.

```bash
flutter pub get

# Debug run on a connected device / emulator
flutter run

# Release APKs (debug-signed by default — fine for sideload testing)
flutter build apk --release                 # universal (~47 MB)
flutter build apk --release --split-per-abi # per-ABI (arm64 ~17 MB)
```

Output: `build/app/outputs/flutter-apk/`.

### Optional: sign with your own keystore

```bash
keytool -genkey -v -keystore ~/wallet-demo.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias demo
```

Create `android/key.properties`:

```
storePassword=<password>
keyPassword=<password>
keyAlias=demo
storeFile=/absolute/path/to/wallet-demo.jks
```

…then reference it from `android/app/build.gradle`'s `signingConfigs` and build
`flutter build apk --release`. A debug keystore is acceptable for testing.

## Toolchain used to build this

Flutter 3.44.6 · Dart 3.12 · AGP 8.7.3 · Gradle 8.9 · Kotlin 2.1.0 ·
compileSdk 36.
