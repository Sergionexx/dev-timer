import 'dart:convert';
import 'package:http/http.dart' as http;

class BackgroundService {
  static const String _apiUrl =
      'https://yapysoft.online/api-remove-bg/generate-background-base64';

  static Future<String?> generateBackground(
      String prompt, int width, int height,
      {String style = 'realistic'}) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'width': width,
          'height': height,
          'style': style,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['imageBase64'];
        } else {
          throw Exception(data['message'] ?? 'Error desconocido');
        }
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al generar el fondo: $e');
      return null;
    }
  }
}
