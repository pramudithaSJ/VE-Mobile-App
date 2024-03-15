import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:visualear/home.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
void main() async{
  // await getResponse();
  runApp(const MyApp());
}
 Future<void> getResponse() async {

    try {
    final wsUrl = Uri.parse('ws://10.0.2.2:8001');
  
    // final channel = IOWebSocketChannel.connect('ws://localhost:8001');
  final channel = WebSocketChannel.connect(wsUrl);
  await channel.ready;
channel.stream.listen((message) {
    print(message);
    // channel.sink.add('received!');
    // channel.sink.close(status.goingAway);
  });

    } catch (e) {
      debugPrint(e.toString());
    }
  }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
