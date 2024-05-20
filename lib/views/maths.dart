import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visualear/clients/tts_client.dart';
import 'package:visualear/clients/ws_client.dart';
import 'package:visualear/models/detection.dart';
import 'package:visualear/widgets/appbar_widget.dart';
import '../clients/maths_openai_chat_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Maths extends StatefulWidget {
  const Maths({super.key});

  @override
  State<Maths> createState() => _MathsState();
}

class Data {
  String? message;
  String? type;
  Data({this.message, this.type});
  Data fromJson(Map<String, dynamic> json) {
    return Data(message: json['message'], type: json['type']);
  }
}

class _MathsState extends State<Maths> {
  late FlutterTts flutterTts;
  String color = "";
  List<DetectedObject> detectionsList = [];
  ObjectDetectionClient? detectionClient;
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
      final wsUrl = Uri.parse('ws://172.20.10.4:9002');
      _channel = WebSocketChannel.connect(wsUrl);
      await _channel.ready;
      _channel.stream.listen((message) async {
        Map data = jsonDecode(message);
        List<dynamic> detections = data['detections'];
        String detectionWord = "";
        if (detections.isNotEmpty) {
          detectionWord = detections[0]['detections'];
        }
        flutterTts.speak("One Item Detected");
        print(data['detections']);
        String description =
            await Maths_OpenAIChatService().generateDescription(detectionWord);
        await flutterTts.speak("this is a ${data['detections']}");
        await flutterTts.speak(description);
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
    if (command.contains("back")) {
      Navigator.pop(context);
    } else if (command.contains("go to page two")) {
      Navigator.pushNamed(context, '/page2');
    } else if (command.contains("start")) {
      print('start maths');
      _sendMessageToServer({
        'mode': 'math',
        'command': 'start',
      });
      flutterTts.speak("Maths mode started");
    }
  }

  void _notifyUser() async {
    await flutterTts.setSpeechRate(0.5);
    setState(() {});
    await flutterTts.speak("You are in learning math mode now");
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
    if (detectionClient != null) {
      detectionClient?.stopDetection();
      detectionClient?.dispose();
      detectionClient = null;

      if (mounted) {
        setState(() {
          isStart = false;
        });
      }
    }
  }

  bool generating = false;

  @override
  void dispose() {
    super.dispose();
    stopDetection();
  }

  String speakResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (_isStarted) {
              _sendMessageToServer({
                'mode': 'walking',
                'command': 'stop',
              });
              setState(() {
                _isStarted = false;
              });
            } else {
              _listen();
            }
          },
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
                  const SizedBox(height: 20),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 10, 61, 103),
                        borderRadius: BorderRadius.circular(7)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.book_fill,
                          size: 35,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Maths Mode",
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
                      if (_isStarted) {
                        _sendMessageToServer({
                          'mode': 'walking',
                          'command': 'stop',
                        });
                        setState(() {
                          _isStarted = false;
                        });
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isStart ? "Detecting" : "Start",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 10, 61, 103),
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(
                    speakResult,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 10, 61, 103),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (detectionsList.isNotEmpty)
                    const Text(
                      'Detections',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: detectionsList
                        .map(
                          (e) => Card(
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${e.count} ${e.label} ${e.confidence}%",
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      explainButton(e),
                                    ],
                                  ),
                                  Text(
                                    e.description ?? "loading description...",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
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
            const SizedBox(width: 10),
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

    List<String> paragraphs = e.description?.split('\n') ?? [];

    for (String paragraph in paragraphs) {
      await tts.speak(paragraph);
      await Future.delayed(Duration(seconds: 5));
    }

    setState(() {
      e.isSpeak = false;
    });
  }
}
