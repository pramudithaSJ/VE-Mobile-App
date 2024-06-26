import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:visualear/clients/tts_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String color = "";
  int answer = 0;
  String question = "";
  bool start = false;
  String localIp = "http://172.20.10.4:8080/";
  int money = 0;
  bool _ttsSpeaking = false;
  TextToSpeechConverter TextSpeech = TextToSpeechConverter();
  late stt.SpeechToText _speech;
  bool _isSound = false;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setCompletionHandler(() {
      setState(() {
        _ttsSpeaking = false;
      });
      // Process the next item in the queue
    });
    _speech = stt.SpeechToText();
    _notifyUser();
  }

  void _notifyUser() async {
    await flutterTts
        .setSpeechRate(0.5); // Set speech rate to a slower value (0.0 to 1.0)
    setState(() {
      _ttsSpeaking = true;
    });
    await flutterTts.speak("You are in activity mode now");
  }

  void app_listen() async {
    if (!_isSound) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isSound = true);
        _speech.listen(
          onResult: (val) => setState(() async {
            String text = val.recognizedWords;
            print(text);
            if (text.contains("start question") ||
                text == "start question" ||
                text == "start") {
              app_start();
            } else if (text.contains("repeat question") ||
                text == "repeat question" ||
                text == "repeat") {
              app_repeat();
            } else if (text.contains("start answering") ||
                text == "start answering" ||
                text == "next amount" ||
                text == "show money" ||
                text == "amount") {
              start_money();
            } else if (text.contains("answer is done") ||
                text == "answer is done" ||
                text == "done") {
              answerIsDone();
            } else if (text.contains("reset") || text == "reset answer") {
              repeatAnswer();
            } else if (text.contains("cancel question") ||
                text == "cancel question" ||
                text == "cancel" ||
                text == "cancer") {
              cancelQuestion();
            } else if (text.contains("back")) {
              Navigator.pop(context);
            }
          }),
        );
      }
    } else {
      setState(() => _isSound = false);
      _speech.stop();
    }
  }

  void app_start() async {
    if (start == false) {
      money = 0;
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak("This is your question");

      try {
        // Replace 127.0.0.1 with your development machine's IP address
        var url = 'http://172.20.10.4:8080/question'; // Use your actual IP
        var response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          if (response.body.isNotEmpty) {
            var decoded = json.decode(response.body) as Map<String, dynamic>;
            print(decoded['question']);
            print(decoded['answer']);
            question = decoded['question'].toString();
            answer = double.parse(decoded['answer'].toString()).toInt();
            await flutterTts.setSpeechRate(0.3);
            await flutterTts.speak(decoded['question'].toString());
            start = true;
          } else {
            print('Empty response body');
            await flutterTts.speak(
                "The server returned an empty response. Please try again later.");
          }
        } else {
          print(
              'Failed to fetch question. Status code: ${response.statusCode}');
          await flutterTts.speak(
              "Failed to fetch the question. Please check your connection and try again.");
        }
      } catch (e) {
        print('Failed to fetch question: $e');
        await flutterTts.speak(
            "Failed to fetch the question. Please check your connection and try again.");
      }
    } else {
      await flutterTts.speak("Cancel The Question");
    }
  }

  void app_repeat() async {
    if (start) {
      await TextSpeech.speak(question);
    } else {
      await TextSpeech.speak("First Off All You Start The Question");
    }
  }

  Future<void> start_money() async {
    if (start) {
      if (money == 0) {
        await flutterTts.speak("Please starting show your money");
      } else {
        await flutterTts.speak("Show you next money");
      }
      var url = 'http://172.20.10.4:8080/detect';

      try {
        var response = await http.get(Uri.parse(url));
        var decoded = json.decode(response.body) as Map<String, dynamic>;
        print(decoded['data']);

        // Assuming 'data' is a list, get the first element
        if (decoded['data'] is List && decoded['data'].isNotEmpty) {
          var detectedMoney = decoded['data'][0].toString();
          money += int.parse(detectedMoney);
          await flutterTts.speak("Detected Money Amount: " + detectedMoney);
        } else {
          await flutterTts.speak("No money detected. Please try again.");
        }
      } catch (e) {
        print('Failed to detect money: $e');
        await flutterTts.speak(
            "Failed to detect money. Please check your connection and try again.");
      }
    } else {
      await flutterTts.speak("First of all, you need to start the question");
    }
  }

  void answerIsDone() async {
    print(answer);
    print(money);
    if (start == true) {
      if (answer == money) {
        await flutterTts.speak("Congratulations your answer is correct");
      } else if (answer > money) {
        await flutterTts.speak(
            "Your answer is incorrect. The correct answer is Rs." +
                answer.toString() +
                ". The value of the answer you have shown is " +
                money.toString() +
                " rupees. " +
                (answer - money).toString() +
                " rupees less to correct the answer.");
      } else {
        await flutterTts.speak(
            "Your answer is incorrect. The correct answer is Rs." +
                answer.toString() +
                ". The value of the answer you have shown is " +
                money.toString() +
                " rupees. " +
                (money - answer).toString() +
                " rupees more to correct the answer.");
      }
    } else {
      await TextSpeech.speak("First Off All You Start The Question");
    }
  }

  void repeatAnswer() async {
    if (start == true) {
      await TextSpeech.speak("Money Amount reset to zero");
      money = 0;
    } else {
      await TextSpeech.speak("First Off All You Start The Question");
    }
  }

  void cancelQuestion() async {
    if (start == true) {
      await TextSpeech.speak("You cancel the question.");
      answer = 0;
      question = "";
      start = false;
      money = 0;
    } else {
      await TextSpeech.speak("First Off All You Start The Question");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: Column(children: [
              Row(
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
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                                onTap: () async {
                                  app_start();
                                },
                                child: Container(
                                  color: Color.fromARGB(255, 10, 61, 103),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                          CupertinoIcons
                                              .arrow_right_circle_fill,
                                          size: 50,
                                          color: Colors.white),
                                      Text("Start Question",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ))),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                              onTap: () async {
                                app_repeat();
                              },
                              child: Container(
                                color: Color.fromARGB(255, 10, 61, 103),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        CupertinoIcons
                                            .arrow_2_circlepath_circle_fill,
                                        size: 50,
                                        color: Colors.white),
                                    Text("Repeat Question",
                                        style: TextStyle(
                                         color: Colors.white,
                                        ))
                                  ],
                                ),
                              )),
                        )
                      ],
                    )),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                              onTap: () async {
                                start_money();
                              },
                              child: Container(
                                color: Color.fromARGB(255, 10, 61, 103),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.move,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                    Text("Show Money",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ))
                                  ],
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: GestureDetector(
                          onTap: () async {
                            answerIsDone();
                          },
                          child: Container(
                            color: Color.fromARGB(255, 10, 61, 103),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.money_dollar_circle_fill,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                Text("Answer Is Done",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                repeatAnswer();
                              },
                              child: Container(
                                color: Color.fromARGB(255, 10, 61, 103),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.floppy_disk,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                    Text("Reset Answer",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ))
                                  ],
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            cancelQuestion();
                          },
                          child: Container(
                            color: Color.fromARGB(255, 10, 61, 103),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.repeat,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                Text("Cancel Question",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                              onTap: app_listen,
                              child: Container(
                                color: Color.fromARGB(255, 10, 61, 103),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.mic_fill,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                    Text("Voice Command",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ))
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
                  ))
            ])),
      ),
    );
  }
}
