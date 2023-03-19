import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://zalatimoprod.rhinosoft.io/api/products';

  Future<List<dynamic>> fetchProducts({int page = 1}) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl?maxPrice=1000&minPrice=0&modes=ALL&page=$page&pageSize=10'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch products');
    }
  }
}
