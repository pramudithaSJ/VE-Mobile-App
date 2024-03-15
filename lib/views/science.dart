import 'package:flutter/material.dart';
import 'package:visualear/clients/tts_client.dart';
import 'package:visualear/clients/ws_client.dart';
import 'package:visualear/models/detection.dart';
import 'package:visualear/widgets/appbar_widget.dart';

import '../clients/openai_chat_service.dart';
import '../clients/speech_recognizer.dart';

class SciencePage extends StatefulWidget {
  const SciencePage({super.key});

  @override
  State<SciencePage> createState() => _SciencePageState();
}

class _SciencePageState extends State<SciencePage> {
  String color = "";
  List<DetectedObject?> detectionsList = List.empty();
  ObjectDetectionClient? detectionClient;
  bool isStart = false;

  void stopDetection() async {
    if (detectionClient != null) {
      // Send the command to stop detection first

      // Wait for a few seconds before disposing of the client
      speechRecognizer?.stopListening();
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

  SpeechRecognizer? speechRecognizer;

  void startDetection() async {
    if (detectionClient != null) return;
    if (mounted) {
      isStart = true;
    }
    String server = 'ws://192.168.1.8:9002';
    await tts.speak("Starting object detection. please wait for result");
    print(server);
    detectionClient =
        ObjectDetectionClient(server); // Listen to the detections stream
    detectionClient?.startDetection();

    detectionClient?.detectionsStream.listen((_detections) async {
      // Process the detections here
      // For example, you can update the UI based on the received detections
      print('New detections: $_detections');
      setState(() {
        detectionsList = [];
        generating = true;
        speakresult = '';
      });
      if (_detections.isNotEmpty) {
        stopDetection();
        detectionsList = _detections;
        for (DetectedObject object in _detections) {
          String des =
              await OpenAIChatService().generateDescription(object.label);
          setState(() {
            object.setDescription(des);
          });
          print("${object.label}\n$des");
        }
        await tts.speak(
            "Detected ${_detections.length} types of Objects. Can you identify these objects?");
        bool isavailible = await speechRecognizer!.initialize();
        print(isavailible);
        setState(() {
          islistening = true;
        });
        if (isavailible) await speechRecognizer?.startListening();

        setState(() {
          generating = false;
        });
      } else {
        stopDetection();
        await tts.speak("Nothing detected. try again.");
      }
    }, onError: (error) async {
      // Handle any errors that occur in the stream
      await tts.speak("Error in detection stream.");

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

  bool islistening = false;
  String speakresult = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    speechRecognizer = SpeechRecognizer(onError: (error) {
      print("error : $error");
    }, onResult: (text) {
      if (text.isEmpty) return;
      print("text : $text");
      //speechRecognizer?.stopListening();
      setState(() {
        speakresult = text;
      });
    }, onStatus: (status) async {
      if (status == 'done') {
        print("status : $status");
        print("speakresult : " + speakresult);
        if (mounted)
          setState(() {
            islistening = false;
          });
        if (speakresult == '') {
          await tts.speak('Sorry, I can\'t hear you!');
        } else {
          // Normalize the speech result for comparison
          String normalizedSpeakResult = speakresult.toLowerCase().trim();
          print("detectionsList:" + detectionsList.length.toString());
          // Assuming detectionsList is a list of objects with a 'label' property
          DetectedObject? match;

          try {
            match = detectionsList.firstWhere((DetectedObject? detection) {
              try {
                if (detection == null) return false;
                // Normalize label for case-insensitive comparison
                String normalizedLabel = detection.label.toLowerCase().trim();
                // Check if the speech result is contained within the label or closely matches it
                return normalizedLabel.contains(normalizedSpeakResult) ||
                    normalizedSpeakResult.contains(normalizedLabel);
              } catch (e) {
                return false;
              }
            }); // Use null if no match found
          } catch (e) {}

          print(match.toString());
          if (match != null) {
            // A match is found
            await tts.speak('Correct, you identified "${match.label}".');
          } else {
            // No match found
            await tts.speak('Your answer is wrong.');
            String result = detectionsList
                .map((e) =>
                    "${e!.label}. confidence is ${e.confidence}.${e.description ?? ''}")
                .join("\r\n");
            await tts.speak("Here is detection result.$result");
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    stopDetection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Learning Science',
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
                    onTap: isStart
                        ? null
                        : () {
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
                            isStart
                                ? "Detecting"
                                : (islistening ? "Listening.." : "Start"),
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
        "detected ${e.count} ${e.label}. confidence is ${e.confidence}%.\n${e.description}");
    setState(() {
      e.isSpeak = false;
    });
  }
}
