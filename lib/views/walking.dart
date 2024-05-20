import 'dart:async';
import 'dart:collection'; // Import for Queue
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class WalkingPage extends StatefulWidget {
  const WalkingPage({super.key});

  @override
  State<WalkingPage> createState() => _WalkingPageState();
}


class Data {
  String? message;
  String? type;
  Data({this.message, this.type});
  Data fromJson(Map<String, dynamic> json) {
    return Data(message: json['message'], type: json['type']);
  }
}
//

class _WalkingPageState extends State<WalkingPage> {
  late FlutterTts flutterTts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isStarted = false;
  late WebSocketChannel _channel; // WebSocket channel reference
  Timer? _responseThrottle; // Timer to throttle WebSocket responses
  bool _ttsSpeaking = false; // Track TTS speaking state
  Queue<String> _notificationQueue = Queue<String>(); // Queue for notifications
  bool _processingQueue = false; // Track if the queue is being processed
  String color = "";

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setCompletionHandler(() {
      setState(() {
        _ttsSpeaking = false;
      });
      _processQueue(); // Process the next item in the queue
    });
    _speech = stt.SpeechToText();
    getResponse();
    _notifyUser();
  }

  void _notifyUser() async {
    await flutterTts
        .setSpeechRate(0.5); // Set speech rate to a slower value (0.0 to 1.0)
    setState(() {
      _ttsSpeaking = true;
    });
    await flutterTts.speak("hi");
  }

  void _listen() async {
    if (_ttsSpeaking) {
      return; // Prevent listening if TTS is speaking
    }

    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => {
          _handleCommand(val.recognizedWords),
          print(val.recognizedWords),
        },
      );
    }
  }

  void _handleCommand(String command) {
    // Implement navigation logic based on the command
    if (command.contains("back")) {
      Navigator.pop(context);
    } else if (command.contains("go to page two")) {
      Navigator.pushNamed(context, '/page2');
    } else if (command.contains("start")) {
      print('start walking');
      _sendMessageToServer({
        'mode': 'walking',
        'command': 'start',
      });
      setState(() {
        _isStarted = true;
      });

      flutterTts.speak("Walking mode started");
    }
  }

  void _notifyStop() async {
    _enqueueNotification("You have stopped the walking mode.");
  }

  Future<void> getResponse() async {
    try {
      final wsUrl = Uri.parse('ws://172.20.10.4:9002');
      _channel = WebSocketChannel.connect(wsUrl);
      await _channel.ready;
      _channel.stream.listen((message) async {
        if (_responseThrottle?.isActive ?? false)
          return; // Ignore messages during throttling
        _responseThrottle =
            Timer(Duration(seconds: 3), () {}); // Throttle responses
        Map data = jsonDecode(message);

        print(data['distance']);
        if (data['type'] == 'safe') {
          flutterTts.speak("You are safe");
        } else {
          final distance = (data['distance'] / 100).toStringAsFixed(0);
          flutterTts.speak("door at $distance meters");
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _sendMessageToServer(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel.sink.add(jsonEncode(message));
    }
  }

  void _enqueueNotification(String message) {
    _notificationQueue.add(message);
    _processQueue();
  }

  void _processQueue() {
    if (_processingQueue || _notificationQueue.isEmpty) {
      return;
    }

    _processingQueue = true;
    final message = _notificationQueue.removeFirst();

    flutterTts.speak(message).then((_) {
      setState(() {
        _processingQueue = false;
      });
    });
  }

  @override
  void dispose() {
    _channel.sink
        .close(); // Close the WebSocket connection when the widget is disposed
    _responseThrottle?.cancel(); // Cancel the throttle timer if active
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              if (_isStarted) {
                _sendMessageToServer({
                  'mode': 'walking',
                  'command': 'stop',
                });
                _notifyStop();
                setState(() {
                  _isStarted = false;
                });
              } else {
                _listen();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Visual",
                        style: TextStyle(
                            color: Color.fromARGB(255, 10, 61, 103),
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Ear",
                        style: TextStyle(
                            color: Color.fromARGB(255, 248, 129, 169),
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 10, 61, 103),
                        borderRadius: BorderRadius.circular(7)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 35,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Walking Mode",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        color = "C";
                      });
                      _sendMessageToServer({
                        'mode': 'walking',
                        'command': 'start',
                      });
                      setState(() {
                        _isStarted = true;
                      });
                      flutterTts.speak("Walking mode started");
                    },
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(125),
                        color: color == "C"
                            ? const Color.fromARGB(255, 248, 126, 167)
                            : const Color.fromARGB(255, 255, 170, 199),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Start",
                            style: TextStyle(
                                color: Color.fromARGB(255, 10, 61, 103),
                                fontSize: 50,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 140,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_ttsSpeaking) {
                        FlutterBeep.beep();
                        _sendMessageToServer({
                          'mode': 'walking',
                          'command': 'stop',
                        });
                        _notifyStop();
                      }
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 10, 61, 103),
                          borderRadius: BorderRadius.circular(7)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Stop",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
