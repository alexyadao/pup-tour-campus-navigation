import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // 🔑 PASTE YOUR "AIza..." KEY HERE
  static const String _apiKey = 'AIzaSyDS_eRswnbACIt74aF-IZbUH22AI00pwLY';

  Future<String?> sendMessage(String userMessage) async {
    try {
      // ✅ UPDATED: We are now using 'gemini-2.5-flash' (The 2026 Standard)
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey'
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": 
                    "You are 'PUP Guide', a helpful virtual tour guide for the Polytechnic University of the Philippines. "
                    "Answer this question from a student: $userMessage"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print("❌ Server Error: ${response.statusCode} - ${response.body}");
        return "I am having trouble connecting. (Error ${response.statusCode})";
      }
    } catch (e) {
      print("❌ Connection Error: $e");
      return "Sorry, I can't connect to the internet right now.";
    }
  }
}












