import 'dart:async';
import 'dart:convert';

import 'package:visualear/models/detection.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ObjectDetectionClient {
  final String url;
  late WebSocketChannel _channel;
  StreamController<List<DetectedObject>> _detectionsController =
      StreamController.broadcast();

  ObjectDetectionClient(this.url) {
    _connect();
  }

  bool _isClosed = false;

  void sendCommand(Map<String, dynamic> command) {
    if (!_isClosed) {
      _channel.sink.add(jsonEncode(command));
    }
  }

// To change the model
  void changeModel(String modelPath) {
    sendCommand({
      'command': 'change_model',
      'model_path': modelPath,
    });
  }

// To start detection
  void startDetection() {
    sendCommand({
      'command': 'start_detection',
    });
  }

// To stop detection
  void stopDetection() {
    sendCommand({
      'command': 'stop_detection',
    });
  }

  void _connect() {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel.stream.listen(
      (data) {  
        if (!_isClosed) {
          var decodedData = jsonDecode(data);
          if (decodedData is List) {
            List<DetectedObject> detections = decodedData
                .map<DetectedObject>((json) => DetectedObject.fromJson(json))
                .toList();

            _detectionsController.add(detections);
          } else {
            print('Data received is not a List');
          }
        }
      },
      onError: (error) {
        print(error);
      },
      //onDone: _reconnect,
    );
  }

  Stream<List<DetectedObject>> get detectionsStream =>
      _detectionsController.stream;

  void _reconnect() {
    Future.delayed(Duration(seconds: 2), () {
      print("Reconnecting to WebSocket...");
      _connect();
    });
  }

  void dispose() {
    _detectionsController.close();
    _channel.sink.close();
    _isClosed = true;
  }
}
