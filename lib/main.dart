import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:visualear/home.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:alan_voice/alan_voice.dart';

void main() async {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visual Ear',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class VoiceControlledNavigator extends StatefulWidget {
  @override
  _VoiceControlledNavigatorState createState() => _VoiceControlledNavigatorState();
}

class _VoiceControlledNavigatorState extends State<VoiceControlledNavigator> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  _VoiceControlledNavigatorState() {
    /// Init Alan Button with project key from Alan AI Studio
    AlanVoice.addButton("27e39b23c207ea78b74586e9db24509f2e956eca572e1d8b807a3e2338fdd0dc/stage");

    /// Handle commands from Alan AI Studio
    AlanVoice.onCommand.add((command) {
      debugPrint("got new command ${command.toString()}");
      _handleCommand(command.data['command']);
    });
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }



  void _handleCommand(String command) {
    print(command);
    if (command.contains("go to page one")) {
      Navigator.pushNamed(context, '/page1');
    } else if (command.contains("go to page two")) {
      Navigator.pushNamed(context, '/page2');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Command Navigation'),
        actions: [
        ],
      ),
      body: Center(
        child: Text('Say "go to page one" or "go to page two"'),
      ),
    );
  }
}
