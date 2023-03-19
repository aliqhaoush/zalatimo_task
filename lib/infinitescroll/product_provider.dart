import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

final productsProvider = ChangeNotifierProvider((ref) => ProductProvider());

class ProductProvider extends ChangeNotifier {
  final apiService = ApiService();
  final List<dynamic> getproducts = [];
  int currentPage = 1;
  bool loading = false;

  List<dynamic> get products => getproducts;
  bool get isLoading => loading;

  Future<void> fetchProducts() async {
    try {
      loading = true;
      final products = await apiService.fetchProducts(page: currentPage);
      getproducts.addAll(products);
      currentPage++;
      loading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
