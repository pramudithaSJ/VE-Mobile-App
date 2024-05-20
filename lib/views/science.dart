import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:visualear/clients/tts_client.dart';
import 'package:visualear/clients/ws_client.dart';
import 'package:visualear/models/detection.dart';
import 'package:visualear/widgets/appbar_widget.dart';
import '../clients/maths_openai_chat_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../clients/openai_chat_service.dart';
import '../clients/speech_recognizer.dart';

class SciencePage extends StatefulWidget {
  const SciencePage({super.key});

  @override
  State<SciencePage> createState() => _SciencePageState();
}

class _SciencePageState extends State<SciencePage> {
  late FlutterTts flutterTts;
  String detectedWord = "";
  List<DetectedObject?> detectionsList = [];
  bool isStart = false;
  late WebSocketChannel _channel;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    getResponse();
    _notifyUser();
  }

  Future<void> getResponse() async {
    try {
      final wsUrl = Uri.parse('ws://192.168.1.38:9002');
      _channel = WebSocketChannel.connect(wsUrl);

      _channel.stream.listen((message) async {
        // Correctly parse the incoming JSON string
        Map data = jsonDecode(message);
        print(data);
        List<dynamic> detections = data['detections'];
        detectedWord = detections[0];

        // setState(() {
        //   detectionsList = detections
        //       .map((e) => DetectedObject.fromJson(e))
        //       .toList();
        // });

        await flutterTts
            .speak("One item detected. Can you identify the detected object?");
        await flutterTts.awaitSpeakCompletion(true);

        // Start listening for the user's response
        _listen();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _listen() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );

    final options = SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: false,
        autoPunctuation: true,
        enableHapticFeedback: true);

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        listenFor: Duration(seconds: 30), // Maximum listening duration
        listenOptions: options,
        onResult: (val) {
          if (val.finalResult) {
            _handleCommand(val.recognizedWords);
          }
        },
      );
    }
  }

  void _handleCommand(String command) async {
    // Implement navigation logic based on the command
    if (command.contains("back")) {
      Navigator.pop(context);
    } else if (command.contains("go to page two")) {
      Navigator.pushNamed(context, '/page2');
    } else if (command.contains("start")) {
      print('start science');
      _sendMessageToServer({
        'mode': 'science',
        'command': 'start',
      });
      await flutterTts.speak("Science mode started");
    } else if (detectedWord.isNotEmpty) {
      if (command.toLowerCase().trim() == detectedWord.toLowerCase().trim()) {
        await flutterTts.speak("Correct, you identified $detectedWord.");
        detectedWord = "";
      } else {
        await flutterTts.speak("Your answer is wrong.");
        String description =
            await OpenAIChatService().generateDescription(detectedWord);
        await flutterTts.speak("This is a $detectedWord.");
        await flutterTts.speak(description);
        detectedWord = "";
      }
    }
  }

  void _notifyUser() async {
    await flutterTts
        .setSpeechRate(0.5); // Set speech rate to a slower value (0.0 to 1.0)
    setState(() {});
    await flutterTts.speak("You are in learning science mode now");
  }

  void _sendMessageToServer(Map<String, dynamic> message) {
    print(message);
    try {
      _channel.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void stopDetection() async {
    if (isStart) {
      _sendMessageToServer({'mode': 'science', 'command': 'stop'});
      setState(() {
        isStart = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    stopDetection();
    _channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Visual",
                      style: TextStyle(
                        color: Color.fromARGB(255, 10, 61, 103),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Ear",
                      style: TextStyle(
                        color: Color.fromARGB(255, 248, 129, 169),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
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
                        CupertinoIcons.circle_grid_hex_fill,
                        size: 35,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Science Mode",
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
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_isStarted) {
                        stopDetection();
                      } else {
                        _listen();
                      }
                    },
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(125),
                        color: isStart
                            ? const Color.fromARGB(255, 248, 126, 167)
                            : const Color.fromARGB(255, 255, 170, 199),
                      ),
                      child: Center(
                        child: Text(
                          isStart
                              ? "Detecting"
                              : (_isListening ? "Listening.." : "Start"),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 10, 61, 103),
                              fontSize: 50,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  detectedWord,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 10, 61, 103),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (detectionsList.isNotEmpty)
                  const Text('Detections',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: detectionsList
                      .map((e) => Card(
                          child: SizedBox(
                              width: double.maxFinite,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${e!.count} ${e.label} ${e.confidence}%",
                                        style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      explainButton(e)
                                    ],
                                  ),
                                  Text(
                                    e.description ?? "loading description...",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ))))
                      .toList(),
                ),
                const SizedBox(
                  height: 70,
                ),
                GestureDetector(
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
    );
  }

  TextToSpeechConverter tts = TextToSpeechConverter();

  Widget explainButton(DetectedObject e) {
    return InkWell(
      onTap: e.isSpeak ? () => tts.stop() : () => speak(e),
      child: Container(
        height: 60,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
            ),
            Icon(
              e.isSpeak ? Icons.stop : Icons.play_arrow,
              size: 35,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> speak(DetectedObject e) async {
    setState(() {
      e.isSpeak = true;
    });
    tts.stop();
    bool s1 = await tts.speak(
        "Detected ${e.count} ${e.label}. Confidence is ${e.confidence}%. ${e.description}");
    setState(() {
      e.isSpeak = false;
    });
  }
}
