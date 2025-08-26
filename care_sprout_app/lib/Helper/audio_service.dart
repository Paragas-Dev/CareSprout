import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final _bgMusicPlayer = AudioPlayer();

  final ValueNotifier<bool> musicEnabled = ValueNotifier(true);
  final ValueNotifier<bool> soundEnabled = ValueNotifier(true);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    musicEnabled.value = prefs.getBool('musicEnabled') ?? true;
    soundEnabled.value = prefs.getBool('soundEnabled') ?? true;

    await FlameAudio.audioCache.loadAll([
      "bg_music.mp3",
      "btn_Click.mp3",
      "message_sent.mp3",
    ]);

    if (musicEnabled.value) {
      playBgMusic();
    }
  }

  Future<void> playBgMusic() async {
    if (musicEnabled.value) {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play('bg_music.mp3', volume: 0.5);
    }
  }

  Future<void> pauseBgMusic() async {
    await FlameAudio.bgm.pause();
  }

  Future<void> resumeBgMusic() async {
    if (musicEnabled.value) {
      await FlameAudio.bgm.resume();
    }
  }

  Future<void> stopBgMusic() async {
    await FlameAudio.bgm.stop();
  }

  Future<void> playClickSound() async {
    if (soundEnabled.value) {
      FlameAudio.play('btn_Click.mp3', volume: 1.0);
    }
  }

  Future<void> playMessageSent() async {
    if (soundEnabled.value) {
      FlameAudio.play('message_sent.mp3', volume: 1.0);
    }
  }

  Future<void> toggleMusic(bool enable) async {
    musicEnabled.value = enable;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', enable);

    if (enable) {
      await playBgMusic();
    } else {
      await pauseBgMusic();
    }
  }

  Future<void> toggleSound(bool enable) async {
    soundEnabled.value = enable;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enable);
    if (kDebugMode) {
      print('Sound is now: $enable');
    }
  }

  void dispose() {
    FlameAudio.bgm.stop();
  }
}
