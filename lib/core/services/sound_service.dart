import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Generic, brand-neutral feedback for the demo payment simulation.
///
/// By design this does NOT play any real product's payment chime. The default
/// feedback is the platform click sound plus a light haptic, which is reliable
/// and works offline.
///
/// If you want an audible tone for lab sessions, drop a CC0 / royalty-free
/// success sound URL into [genericSuccessSoundUrl] — it will be streamed via
/// `audioplayers`. Leave it empty to use system feedback only. Do NOT point
/// this at any proprietary/branded sound.
class SoundService {
  static const String genericSuccessSoundUrl = '';

  final AudioPlayer _player = AudioPlayer();

  Future<void> playGenericSuccess() async {
    // Always give tactile + system feedback (guaranteed, offline-safe).
    unawaitedHaptic();
    await SystemSound.play(SystemSoundType.click);

    if (genericSuccessSoundUrl.isEmpty) return;
    try {
      await _player.play(UrlSource(genericSuccessSoundUrl));
    } catch (_) {
      // Network / codec issues are non-fatal for a demo; system feedback
      // already fired above.
    }
  }

  void unawaitedHaptic() {
    // Fire-and-forget; ignore platforms without a vibrator.
    HapticFeedback.mediumImpact();
  }

  void dispose() => _player.dispose();
}
