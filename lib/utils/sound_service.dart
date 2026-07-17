import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // Set audio context for short sounds
    await _player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notification,
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );

    _initialized = true;
  }

  static Future<void> playClick() async {
    if (!_initialized) await init();

    try {
      await _player.play(AssetSource('assets/sound/click.mp3'));
    } catch (e) {
      //debugPrint('Sound error: $e');
    }
  }

  static void dispose() {
    _player.dispose();
  }
}
