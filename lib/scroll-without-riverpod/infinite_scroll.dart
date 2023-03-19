import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../variabels/colors.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Product> _products = [];
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrency();
    fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://zalatimoprod.rhinosoft.io/api/products?maxPrice=1000&minPrice=0&modes=ALL&page=$_page&pageSize=10'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final products =
          List<Product>.from(data.map((product) => Product.fromJson(product)));

      setState(() {
        _products.addAll(products);
        _page++;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to fetch products');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      fetchProducts();
    }
  }

  String currency = '';
  Future<void> getCurrency() async {
    final response = await http.get(Uri.parse(
        'https://zalatimoprod.rhinosoft.io/api/products?maxPrice=1000&minPrice=0&modes=ALL&page=1&pageSize=21'));
    final Map<String, dynamic> data = await json.decode(response.body);
    setState(() {
      currency = data['currency'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Infinite scroll',
          style: TextStyle(color: textColors),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 13),
                child: GridView.builder(
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 31),
                  itemCount: _products.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < _products.length) {
                      final product = _products[index];
                      return Card(
                        shadowColor: containerColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Expanded(
                                    child: Image.network(
                                      product.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 2.5),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    child: Text(
                                      product.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: itemsColor,
                                        fontFamily: "Myriad",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "${product.price.toString()} $currency",
                                    style: const TextStyle(
                                      color: textColors,
                                      fontFamily: "Myriad",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                            const Positioned(
                              top: 8,
                              right: 7,
                              child: Icon(
                                Icons.favorite_border,
                                color: heartColors,
                                fill: 0,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['mediaUrl'] as String,
    );
  }
}
