import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'settings_service.dart';
import 'voice_engine.dart';

/// Which screen's BGM should be playing
enum BgmTrack { home, boardBook, soundMatch, bubblePop, none }

class AudioService {
  final SettingsService _settings;
  final VoiceEngine? _voiceEngine;

  // Single BGM player — we stop/start between screens instead of cross-fading
  final AudioPlayer _bgmPlayer = AudioPlayer();

  // SFX players
  final AudioPlayer _voicePlayer = AudioPlayer();
  final AudioPlayer _soundPlayer = AudioPlayer();

  BgmTrack _currentTrack = BgmTrack.none;
  bool _isCardSequencePlaying = false;
  bool _initialized = false;

  // Fade parameters
  double get _maxBgmVolume => _settings.musicVolume;
  static const Duration _fadeDuration = Duration(milliseconds: 800);
  static const int _fadeSteps = 20;

  static const Map<BgmTrack, String> _trackAssets = {
    BgmTrack.home: 'assets/audio/home_bgm.mp3',
    BgmTrack.boardBook: 'assets/audio/boardbook_bgm.mp3',
    BgmTrack.soundMatch: 'assets/audio/sound_match_bgm.mp3',
    BgmTrack.bubblePop: 'assets/audio/home_bgm.mp3', // Reusing home bgm if no specific bubble pop bgm is provided
  };

  AudioService(this._settings, [this._voiceEngine]) {
    _init();
  }

  Future<void> _init() async {
    // Defer so platform channels are ready
    await Future.delayed(const Duration(milliseconds: 400));
    await _bgmPlayer.setLoopMode(LoopMode.all);
    await _bgmPlayer.setVolume(0);
    _initialized = true;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Switch to the BGM track for the given screen.
  /// Stops any current track immediately, then fades the new one in.
  Future<void> switchTrack(BgmTrack track) async {
    if (!_initialized) await Future.delayed(const Duration(milliseconds: 600));
    if (!_settings.isMusicEnabled && track != BgmTrack.none) return;
    if (track == _currentTrack) return;

    _currentTrack = track;

    // Fade out whatever is currently playing, then stop
    await _fadeOut();

    if (track == BgmTrack.none) return;

    final asset = _trackAssets[track]!;
    try {
      await _bgmPlayer.setAsset(asset);
      await _bgmPlayer.seek(Duration.zero);
      _bgmPlayer.play(); // fire-and-forget loop
      await _fadeIn();
    } catch (_) {
      // Asset missing — ignore silently
    }
  }

  /// Called when parent toggles BGM on/off from settings.
  void updateBgmState(bool enabled) {
    if (enabled) {
      final track = _currentTrack;
      _currentTrack = BgmTrack.none; // force re-arm
      switchTrack(track == BgmTrack.none ? BgmTrack.home : track);
    } else {
      _fadeOut(); // graceful fade out
    }
  }

  /// Called when parent changes BGM volume slider.
  void updateBgmVolume(double volume) {
    if (_bgmPlayer.playing) {
      _bgmPlayer.setVolume(volume);
    }
  }

  bool get isInteractionLocked => _isCardSequencePlaying;

  /// Cancels any in-progress card audio sequence immediately.
  void cancelSequence() {
    _voicePlayer.stop();
    _soundPlayer.stop();
    _isCardSequencePlaying = false;
  }

  // ── Card Sequence ─────────────────────────────────────────────────────────

  Future<void> playTtsCardSequence({
    required String itemName,
    required String? soundPath,
  }) async {
    if (!_settings.isSoundEnabled || _isCardSequencePlaying) return;
    _isCardSequencePlaying = true;

    try {
      // 1. Speak Item Name once via VoiceEngine
      if (_voiceEngine != null) {
        await _voiceEngine!.speak(itemName);
      }

      // 2. Play Action Sound via Just Audio
      if (soundPath != null && soundPath.isNotEmpty) {
        final vol = _settings.voiceVolume;
        await _soundPlayer.setVolume(vol);
        await _soundPlayer.setAsset(soundPath);
        await _soundPlayer.seek(Duration.zero);
        await _soundPlayer.play();
        try {
          await _awaitPlayback(_soundPlayer);
        } catch (_) {}
      }
    } catch (_) {
      // Swallow
    } finally {
      _isCardSequencePlaying = false;
    }
  }

  /// Plays a one-off sound effect (e.g. trophy, button click).
  Future<void> playSound(String assetPath) async {
    if (!_settings.isSoundEnabled) return;
    try {
      final vol = _settings.voiceVolume;
      // Use sound player for one-offs
      await _soundPlayer.setVolume(vol);
      await _soundPlayer.setAsset(assetPath);
      await _soundPlayer.seek(Duration.zero);
      await _soundPlayer.play();
    } catch (_) {
      // Ignore errors
    }
  }

  /// Plays a random balloon pop sound.
  Future<void> playRandomPopSound() async {
    if (!_settings.isSoundEnabled) return;
    try {
      final int randIndex = DateTime.now().millisecondsSinceEpoch % 4 + 1; // 1 to 4
      final String assetPath = 'assets/audio/balloon_pop/pop$randIndex.mp3';
      
      final vol = _settings.voiceVolume;
      await _soundPlayer.setVolume(vol);
      await _soundPlayer.setAsset(assetPath);
      await _soundPlayer.seek(Duration.zero);
      await _soundPlayer.play();
      try {
        await _awaitPlayback(_soundPlayer);
      } catch (_) {}
    } catch (_) {
      // Ignore errors
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    _voicePlayer.dispose();
    _soundPlayer.dispose();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _fadeOut() async {
    final startVol = _bgmPlayer.volume;
    if (startVol <= 0) {
      await _bgmPlayer.stop();
      return;
    }
    final stepMs = _fadeDuration.inMilliseconds ~/ _fadeSteps;
    for (int i = _fadeSteps - 1; i >= 0; i--) {
      await Future.delayed(Duration(milliseconds: stepMs));
      await _bgmPlayer.setVolume((startVol * i / _fadeSteps).clamp(0, 1.0));
    }
    await _bgmPlayer.stop();
  }

  Future<void> _fadeIn() async {
    final targetVol = _maxBgmVolume;
    final stepMs = _fadeDuration.inMilliseconds ~/ _fadeSteps;
    for (int i = 1; i <= _fadeSteps; i++) {
      await Future.delayed(Duration(milliseconds: stepMs));
      await _bgmPlayer.setVolume((targetVol * i / _fadeSteps).clamp(0, 1.0));
    }
  }

  Future<void> _awaitPlayback(AudioPlayer player) async {
    await player.playerStateStream
        .firstWhere((s) => s.processingState == ProcessingState.completed)
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw TimeoutException('Audio timeout'),
        );
  }
}
