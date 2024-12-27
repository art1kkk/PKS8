import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  final String baseUrl = 'http://192.168.1.68:8080';

  Future<void> addProduct(Map<String, dynamic> product) async {
    final url = Uri.parse('$baseUrl/add-product');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product),
    );

    if (response.statusCode == 200) {
      print('Product added successfully: ${response.body}');
    } else {
      print('Failed to add product: ${response.statusCode}');
      throw Exception('Failed to add product');
    }
  }
}
