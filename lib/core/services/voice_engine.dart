import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceEngine {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  VoiceEngine() {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      debugPrint('🎨 VoiceEngine: Initializing sensory-friendly voice...');

      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0); // Reset to gTTS default
      await _tts.setSpeechRate(0.4); // Lowered to match gTTS 'slow=True' pace

      if (Platform.isAndroid || Platform.isIOS) {
        // Check if British English is available
        final languages = await _tts.getLanguages;
        if (languages.contains("en-GB")) {
          await _tts.setLanguage("en-GB");

          // Try to find a female voice specifically in the British locale
          final voices = await _tts.getVoices;
          try {
            final femaleVoice = voices.cast<Map>().firstWhere(
              (v) =>
                  v["locale"].toString().contains("en-GB") &&
                  (v["name"].toString().toLowerCase().contains("female") ||
                      v["name"].toString().toLowerCase().contains("fis")),
              orElse:
                  () => voices.cast<Map>().firstWhere(
                    (v) => v["locale"].toString().contains("en-GB"),
                  ),
            );
            await _tts.setVoice({
              "name": femaleVoice["name"],
              "locale": femaleVoice["locale"],
            });
            debugPrint(
              '🎨 VoiceEngine: Using Female UK Voice (${femaleVoice["name"]})',
            );
          } catch (e) {
            debugPrint(
              '🎨 VoiceEngine: Could not filter gender, using default British voice',
            );
          }
        } else {
          await _tts.setLanguage("en-US");
          debugPrint('🎨 VoiceEngine: en-GB not found, falling back to en-US');
        }
      } else {
        await _tts.setLanguage("en-GB");
      }

      // iOS specific: enable audio session
      if (Platform.isIOS) {
        await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ]);
      }

      await _tts.awaitSpeakCompletion(true);

      _tts.setErrorHandler((msg) {
        debugPrint('❌ VoiceEngine Error: $msg');
      });

      _isInitialized = true;
      debugPrint('✅ VoiceEngine: Ready.');
    } catch (e) {
      debugPrint('❌ VoiceEngine Init Error: $e');
    }
  }

  Future<void> speakMastery(String itemName, {String? childName}) async {
    if (!_isInitialized) await _init();

    debugPrint('🎤 VoiceEngine: Speaking mastery for $itemName');
    await _tts.stop();
    
    // Generic message (Name removed as per request)
    final message = "Congratulations! You have learned $itemName!";
    final result = await _tts.speak(message);
    if (result == 0) {
      debugPrint('⚠️ VoiceEngine: Speak returned 0 (failed or interrupted)');
    }
  }

  Future<void> speak(String text, {double? pitch, double? rate}) async {
    if (!_isInitialized) await _init();
    await _tts.stop();

    if (pitch != null) await _tts.setPitch(pitch);
    if (rate != null) await _tts.setSpeechRate(rate);

    await _tts.speak(text);

    if (pitch != null) await _tts.setPitch(1.0);
    if (rate != null) await _tts.setSpeechRate(0.25);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
