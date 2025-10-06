import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = "AIzaSyBOKUZmqLP_l1q28cvc7pvWdFWausgpVcU";
  final String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  Future<String> getDrugsFeedback(List<String> drugs) async {
    final prompt =
        """
You are a professional pharmacist AI.
The following drugs were selected: ${drugs.join(", ")}.

Please explain the possible risks and give safe usage advice in clear simple language.
""";

    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "x-goog-api-key": apiKey},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      throw Exception("Gemini API failed: ${response.body}");
    }
  }
}
