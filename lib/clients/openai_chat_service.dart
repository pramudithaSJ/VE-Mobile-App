import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIChatService {
  final String apiKey = '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'; // Replace with your actual API key
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> generateDescription(String prompt) async {
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
            "content": "generate random short description about ${prompt}",
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
