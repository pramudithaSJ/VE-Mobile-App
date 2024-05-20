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
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
    welcomeMessage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensures the welcome message is played every time the HomePage is re-visited.
    welcomeMessage();
  }

  void welcomeMessage() async {
    await flutterTts.speak(
        "Welcome to Visual Ear. Tap on the screen to give voice command. You can say  'maths' to learn maths, 'science' to learn science, 'activity' to start an activity ,and 'walk' to start walking.");
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
      ).then((_) => welcomeMessage()); // Call welcomeMessage after returning
    } else if (command.contains("maths")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Maths()),
      ).then((_) => welcomeMessage()); // Call welcomeMessage after returning
    } else if (command.contains("science")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SciencePage()),
      ).then((_) => welcomeMessage()); // Call welcomeMessage after returning
    } else if (command.contains("activity")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ActivityPage()),
      ).then((_) => welcomeMessage()); // Call welcomeMessage after returning
    } else if (command.contains("home")) {
      welcomeMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _listen();
          },
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
                  ),
                ],
              ),
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
                                color: Colors.white,
                                size: 50,
                              ),
                              Text(
                                learningMaths,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          color: primaryColor,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.circle_grid_hex_fill,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text(
                                learningScience,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                                CupertinoIcons.money_dollar_circle_fill,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text(
                                mathsActivity,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          color: primaryColor,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.location_circle_fill,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text(
                                walking,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
