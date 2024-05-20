import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visualear/constant/colors.dart';
import 'package:visualear/views/activity.dart';
import 'package:visualear/views/maths.dart';
import 'package:visualear/views/science.dart';
import 'package:visualear/views/walking.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'constant/string.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_tts/flutter_tts.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late WebSocketChannel _channel;
  late FlutterTts flutterTts;


  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _connectToWebSocket();
    flutterTts = FlutterTts();
    
  }

  void _connectToWebSocket() {
    try {
      final wsUrl = Uri.parse('ws://192.168.1.35:9002');
      _channel = WebSocketChannel.connect(wsUrl);
      _channel.stream.listen((message) {
        // Log the messages received from the server
        print('Received message: $message');
      });

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _sendMessageToServer(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel.sink.add(jsonEncode(message));
      print('Sent message: ${jsonEncode(message)}');
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => _handleCommand(val.recognizedWords),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleCommand(String command) {
    print(command);
    if (command.contains("walk")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WalkingPage()),
      );
    } else if (command.contains("maths")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Maths()),
      );
    } else if (command.contains("science")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SciencePage()),
      );
    } else if (command.contains("activity")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ActivityPage()),
      );
      // _sendMessageToServer({'mode': 'money'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: GestureDetector(
        onTap: () {
          _listen();
        },
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        color: primaryColor,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.book_fill,
                              size: 25,
                            ),
                            Text(learningMaths)
                          ],
                        ),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Container(
                        color: primaryColor,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.book_fill,
                              size: 25,
                            ),
                            Text(learningScience)
                          ],
                        ),
                      ))
                    ],
                  ),
                )),
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        color: primaryColor,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.book_fill,
                              size: 25,
                            ),
                            Text(mathsActivity)
                          ],
                        ),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          color: primaryColor,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.book_fill,
                                size: 25,
                              ),
                              Text(walking)
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      )),
    );
  }
}
