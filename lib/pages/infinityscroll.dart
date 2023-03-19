import 'dart:convert';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../variabels/colors.dart';

class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imageUrl: json['mediaUrl'],
      price: json['price'].toDouble(),
    );
  }
}

final apiResponseProvider = FutureProvider.autoDispose((ref) async {
  final pageNumber = ref.watch(pageNumberProvider);
  final url =
      'https://zalatimoprod.rhinosoft.io/api/products?maxPrice=1000&minPrice=0&modes=ALL&page=$pageNumber&pageSize=$pageSize';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final body = response.body;
    final data = json.decode(body)['data'];
    final products = data.map((json) => Product.fromJson(json)).toList();
    return products;
  } else {
    throw Exception('Failed to load data');
  }
});

final pageNumberProvider =
    StateNotifierProvider<PageNumberNotifier, int>((ref) {
  return PageNumberNotifier();
});

final isLoadingMoreProvider = StateProvider((ref) => false);
final isLastPageProvider = StateProvider((ref) => false);

const pageSize = 10;

class PageNumberNotifier extends StateNotifier<int> {
  PageNumberNotifier() : super(1);

  void increment() {
    state++;
  }
}

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(apiResponseProvider);
    final isLoadingMore = ref.watch(isLoadingMoreProvider);
    final isLastPage = ref.watch(isLastPageProvider);

    final scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (!isLastPage && !isLoadingMore) {
          // ignore: invalid_use_of_protected_member
          ref.read(pageNumberProvider.notifier).state + 1;
          ref.read(isLoadingMoreProvider.notifier).state = true;
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: data.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => const Center(
          child: Text('Failed to load data'),
        ),
        data: (products) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 13),
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 31),
                    itemCount: products.length + (isLastPage ? 0 : 1),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == products.length && !isLastPage) {
                        return isLoadingMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      } else {
                        final product = products[index];
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
                                        product.imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 2.5),
                                    Text(
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
                                    const SizedBox(height: 2),
                                    Text(
                                      "${product.price}",
                                      style: const TextStyle(
                                        color: textColors,
                                        fontFamily: "Myriad",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
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
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
