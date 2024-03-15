import 'package:flutter/material.dart';
import 'package:visualear/clients/tts_client.dart';
import 'package:visualear/clients/ws_client.dart';
import 'package:visualear/models/detection.dart';
import 'package:visualear/widgets/appbar_widget.dart';
import '../clients/maths_openai_chat_service.dart';

class Maths extends StatefulWidget {
  const Maths({super.key});

  @override
  State<Maths> createState() => _MathsState();
}

class _MathsState extends State<Maths> {
  String color = "";
  List<DetectedObject> detectionsList = List.empty();
  ObjectDetectionClient? detectionClient;
  bool isStart = false;

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

  void startDetection() async {
    if (detectionClient != null) return; 
    if (mounted) {
      isStart = true;
    }

    String server = 'ws://192.168.1.8:9001';
    await tts.speak("Please wait for result");
    print(server);
    detectionClient =
        ObjectDetectionClient(server); // Listen to the detections stream
    detectionClient?.startDetection();

     // Listen to the detections stream
    detectionClient?.detectionsStream.listen((_detections) async {
      // Process the detections here
      // For example, you can update the UI based on the received detections
      print('New detections: $_detections');
      setState(() {
        detectionsList = [];
        generating : true;
      });
      if (_detections.isNotEmpty) {
        stopDetection();
        detectionsList = _detections;
        for (DetectedObject object in _detections) {
          String des =
              await Maths_OpenAIChatService().generateDescription(object.label);
          setState(() {
            object.setDescription(des);
          });
          print("${object.label}\n$des");    
        }
        stopDetection();

        String result = detectionsList
            .map((e) =>
                "${e.label}. confidence is ${e.confidence}.${e.description ?? ''}")
            .join("\r\n");
        await tts.speak("Here is detection result.$result");

        if (mounted) {
          setState(() {
            
            isStart = false;
          });
        }
      }else {
        stopDetection();
        await tts.speak("Nothing detected. try again.");
      }
    }, onError: (error) async {
      // Handle any errors that occur in the stream
      print('Error in detection stream: $error');
      if (mounted) {
        setState(() {
          isStart = false;
        });
      }
    }, onDone: () {
      // Handle the stream being closed, if necessary
      print('Detection stream closed');  
    });
  }

  void onStartTap() {
    if (mounted) {
      setState(() {
        color = detectionClient != null ? "" : "C";
      });
    }
    if (detectionClient == null) {
      detectionsList = [];
      startDetection();
    } else {
      stopDetection();
    }
  }

  @override
  void dispose() {
    super.dispose();
    stopDetection();
  }

  String speakresult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Learning Maths',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                
                Center(
                  child: GestureDetector(
                    onTap: isStart? null : () {
                      onStartTap();
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
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                 Text(
                  speakresult,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 10, 61, 103),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                //if (detectionsList.isNotEmpty)
                
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
                                  Text("${e.count} ${e.label} ${e.confidence}%",
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                                  ),explainButton(e)
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

  // Split description into paragraphs
  List<String> paragraphs = e.description?.split('\n') ?? [];

  for (String paragraph in paragraphs) {
    // Speak each paragraph
    await tts.speak(paragraph);

    // Delay for 5 seconds after reading each paragraph
    await Future.delayed(Duration(seconds: 50));
  }

  setState(() {
    e.isSpeak = false;
  });
}


}
