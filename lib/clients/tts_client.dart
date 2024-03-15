import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechConverter {
  FlutterTts flutterTts = FlutterTts();

  TextToSpeechConverter() {
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0); // Adjust the pitch of the speech
    flutterTts.setSpeechRate(0.5); // Adjust the speed of the speech
    flutterTts.awaitSpeakCompletion(true);
  }

  Future<bool> speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
    return true;
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }
}
