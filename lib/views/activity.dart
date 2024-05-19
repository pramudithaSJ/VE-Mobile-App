import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:visualear/clients/tts_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String color = "";
  int answer = 0;
  String question = "";
  bool start=false;
  String localIp = "http://172.20.10.3:5555/";
  int money=0;
  TextToSpeechConverter TextSpeech = TextToSpeechConverter();
  late stt.SpeechToText _speech;
  bool _isSound = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
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
            if (text.contains("start question")||text=="start question"||text=="start") {
              app_start();
            } else if (text.contains("repeat question")||text=="repeat question"||text=="repeat") {
              app_repeat();
            } else if (text.contains("start answering")||text=="start answering"||text=="next amount"||text=="amount") {
              start_money();
            } else if (text.contains("answer is done")||text=="answer is done"||text=="done") {
              answerIsDone();
            } else if (text.contains("repeat answer")||text=="repeat answer") {
              repeatAnswer();
            } else if (text.contains("cancel question")||text=="cancel question"||text=="cancel") {
              cancelQuestion();
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
    await TextSpeech.speak("This is your question");
    var url = localIp + 'question';

    var response = await http.get(Uri.parse(url));
    var decoded = json.decode(response.body) as Map<String, dynamic>;
    print(decoded['question']);
    print(decoded['answer']);
    question = decoded['question'].toString();
    answer = double.parse(decoded['answer'].toString()).toInt();
    await Future.delayed(Duration(seconds: 3));
    await TextSpeech.speak(decoded['question'].toString());
    start = true;
  } else {
    await TextSpeech.speak("Cancel The Question");
  }
}


  void app_repeat() async {
    if(start){
      await TextSpeech.speak(question);
    }else{
      await TextSpeech.speak("First Off All You Start The Question");
    }
  }

  void start_money() async {
    if(start){
      if(money==0){
        await TextSpeech.speak("Please starting show your money");
      }else{
        await TextSpeech.speak("Show you next money");
      }
      var url = localIp + 'one';

      var response = await http
          .get(Uri.parse(url));
      ;
      var decoded =
      json.decode(response.body) as Map<String, dynamic>;
      print(decoded['results']);
      money=money+int.parse(decoded['results']);
      await TextSpeech.speak("Detected Money Amount : "+decoded['results'].toString());
    }else{
      await TextSpeech.speak("First Off All You Start The Question");
    }
  }

  void answerIsDone() async {
    print(answer);
    print(money);
    // if(start==false) {
      if(answer==money){
        await TextSpeech.speak("Congratulations your answer is correct");
      }else if(answer>money){
        await TextSpeech.speak("Your answer is incorrect. The correct answer is Rs."+answer.toString()+". The value of the answer you have shown is "+money.toString()+" rupees. "+(answer-money).toString()+" rupees less to correct the answer.");
      }else{
        await TextSpeech.speak("Your answer is incorrect. The correct answer is Rs."+answer.toString()+". The value of the answer you have shown is "+money.toString()+" rupees. "+(money-answer).toString()+" rupees more to correct the answer.");
      }
    // }else{
    //   await TextSpeech.speak("First Off All You Start The Question");
    // }
  }

  void repeatAnswer() async {
    if(start==false) {
      money=0;
    }else{
      await TextSpeech.speak("First Off All You Start The Question");
    }
  }

  void cancelQuestion() async {
    if(start==false) {
      answer = 0;
      question = "";
      start=false;
      money=0;
    }else{
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
                                          color: Color.fromARGB(
                                              255, 248, 129, 169)),
                                      Text("Start Question",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 248, 129, 169),
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
                                        color:
                                            Color.fromARGB(255, 248, 129, 169)),
                                    Text("Repeat Question",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 248, 129, 169),
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
                              onTap: () async{
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
                                      color: Color.fromARGB(255, 248, 129, 169),
                                    ),
                                    Text("Start Answering or Next Amount",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 248, 129, 169),
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
                                  color: Color.fromARGB(255, 248, 129, 169),
                                ),
                                Text("Answer Is Done",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 248, 129, 169),
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
                                      color: Color.fromARGB(255, 248, 129, 169),
                                    ),
                                    Text("Repeat Answer",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 248, 129, 169),
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
                                  color: Color.fromARGB(255, 248, 129, 169),
                                ),
                                Text("Cancel Question",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 248, 129, 169),
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
                                      color: Color.fromARGB(255, 248, 129, 169),
                                    ),
                                    Text("Voice Command",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 248, 129, 169),
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
