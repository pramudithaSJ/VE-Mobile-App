import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognizer {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // Callback for when text is recognized
  Function(String text)? onResult;
  Function(String error)? onError;
  Function(String status)? onStatus;

  SpeechRecognizer({this.onResult, this.onError, this.onStatus}) {
    _speech = stt.SpeechToText();
  }

  // Initialize speech recognizer
  Future<bool> initialize() async {
    bool available = await _speech.initialize(
      onError: (val) => onError?.call(val.errorMsg),
      onStatus: (val) => onStatus?.call(val),
    );
    return available;
  }

  // Start listening
  Future<void> startListening() async {
    print('startListening : _isListening:' + _isListening.toString());
    if (!_isListening) {
      _isListening = true;
      _speech.listen(
        onResult: (val) {
          onResult?.call(val.recognizedWords);
        },
      );
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    print('stopListening');
    if (_isListening) {
      _isListening = false;
      await _speech.stop();
    }
  }

  // Check if the recognizer is currently listening
  bool get isListening => _isListening;

  // Dispose of the speech recognizer
  void dispose() {
    print('disposed');
    _speech.stop();
    _speech.cancel();
    _speech = null!;
  }
}
