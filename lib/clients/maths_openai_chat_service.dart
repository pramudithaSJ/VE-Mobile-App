import 'dart:convert';
import 'package:http/http.dart' as http;

class Maths_OpenAIChatService {
  final String apiKey =
      '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'; //  API key
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  List<String> twoDimensionalShapes = [
    'Rectangle', 
    'Square',
    'Triangle',
    'Circle'
  ];
  List<String> threeDimensionalShapes = [
    'Cone',
    'Cuboid',
    'cylinder',
    'Sphere',
    'Cube',
    'Tetrahedron'
  ];

  Future<String> generateDescription(String prompt) async {
    print(prompt);
    // Check if the prompt corresponds to a 2D or 3D object
    bool is2DObject = twoDimensionalShapes.contains(prompt);
    bool is3DObject = threeDimensionalShapes.contains(prompt);

    if (!is2DObject && !is3DObject) {
      throw Exception('Unknown object type');
    }

    String objectTypeName = is2DObject ? '2D' : '3D';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "user",
            "content":
                "generate random short description about $prompt, a $objectTypeName object. Also, generate short description about how to calculate the ${is2DObject ? 'area and perimeter' : 'area, perimeter, and volume'} of $prompt."
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final messageContent = responseData['choices'][0]['message']['content'];
      return messageContent;
    } else {
      throw Exception('Failed to load description');
    }
  }
}
