import 'dart:convert';
import 'package:http/http.dart' as http;

class CarService {
  final String baseUrl = 'http://localhost:8080';

  // Функция для автоматической отправки данных на сервер
  Future<void> addCar(Map<String, dynamic> carData) async {
    final url = Uri.parse('$baseUrl/cars');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(carData),
    );

    if (response.statusCode == 200) {
      print('Car added successfully: ${response.body}');
    } else {
      print('Failed to add car: ${response.statusCode}');
    }
  }
}
