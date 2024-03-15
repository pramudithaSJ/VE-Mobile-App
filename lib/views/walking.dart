import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WalkingPage extends StatefulWidget {
  const WalkingPage({super.key});

  @override
  State<WalkingPage> createState() => _WalkingPageState();
}

Future<void> _getBeep({required Map<String, dynamic> message}) async {
  Data data = Data().fromJson(message);
  if (data.type == 'message') {
    print('--------->inside if');
    Future.delayed(const Duration(seconds: 5), () => FlutterBeep.beep());
  }
}

class Data {
  String? message;
  String? type;
  Data({this.message, this.type});

  Data fromJson(Map<String, dynamic> json) {
    return Data(message: json['message'], type: json['type']);
  }
}

class _WalkingPageState extends State<WalkingPage> {
  late FlutterTts flutterTts;

  String color = "";
  @override
  void initState() {
    flutterTts = FlutterTts();
    getResponse();
    super.initState();
  }

  Future<void> getResponse() async {
    try {
      final wsUrl = Uri.parse('ws://192.168.1.3:9001');

      final channel = WebSocketChannel.connect(wsUrl);
      await channel.ready;
      channel.stream.listen((message) async {
        Map data = jsonDecode(message);
        print(message);
        if (data['type'] == 'message') {
          await Future.delayed(Duration(seconds: 5));
          FlutterBeep.beep();
        } else {
          await Future.delayed(Duration(seconds: 5));
          flutterTts.speak("Hello World");
          FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_SOFT_ERROR_LITE);
          
        }
        // channel.sink.add('received!');
        // channel.sink.close(status.goingAway);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
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
                  onTap: () => FlutterBeep.beep(),
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
                          "Get beep",
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
}
