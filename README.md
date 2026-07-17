# Wallet UI Clone (Flutter / Android)

A pixel-faithful reproduction of a wallet home screen, rebuilt in Flutter as a
**UI mockup only**. It is not a real payment app: it performs no NFC, no
network calls, and stores no card data. The card number, brand marks and text
are static mock artwork drawn on-device with `CustomPainter`.

## What it renders

- Replica status bar (time + system icons)
- "Samsung Wallet" header with add / announcement / overflow actions
- "Add your membership cards…" banner
- Vouchers | Memberships tab row
- A navy debit card with the wavy pattern, contactless mark, card-network
  mark and masked number `•••• 3363`, with peeking cards on either side
- The "PIN" pill and the "Quick access / All" bottom navigation

Everything is positioned in reference pixels and scaled to the device width, so
the layout matches the reference on any Pixel-class phone.

## Run

```bash
flutter pub get
flutter run            # debug
flutter build apk      # release APK
```

Requires Flutter 3.27+ / Dart 3.6+ (uses the `Color.withValues` API).

> All brand names and marks belong to their respective owners and are
> reproduced here only as static mock artwork for a UI layout study.
