import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String _apiKey = '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';

  Future<String> getChatResponse(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "Eres un experto en animales peligrosos y naturaleza."},
          {"role": "user", "content": prompt},
        ]
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['choices'][0]['message']['content'];
    } else {
      return "Error al consultar información: ${response.statusCode}";
    }
  }
}