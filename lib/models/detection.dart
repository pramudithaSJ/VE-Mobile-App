class DetectedObject {
  String label;
  double confidence;
  int count;
  List<BoundingBox> boundingBoxes;
  String? description;

  bool isSpeak=false;

  DetectedObject(
      {required this.label,
      required this.confidence,
      required this.boundingBoxes,
      required this.count});


  void setDescription(String des) {
    description = des;
  }

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    var boundingBoxesJson = json['bounding_boxes'] as List<dynamic>;
    List<BoundingBox> boundingBoxes = boundingBoxesJson
        .map((boundingBoxJson) => BoundingBox.fromJson(boundingBoxJson))
        .toList();

    return DetectedObject(
      label: json['label'] as String,
      confidence: (json['confidence'] as List).isEmpty
          ? 0
          : (json['confidence'] as List).first.toDouble(),
      boundingBoxes: boundingBoxes,
      count: json['count'],
    );
  }
}

class BoundingBox {
  int x1;
  int y1;
  int x2;
  int y2;

  BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: json['x1'] as int,
      y1: json['y1'] as int,
      x2: json['x2'] as int,
      y2: json['y2'] as int,
    );
  }
}
