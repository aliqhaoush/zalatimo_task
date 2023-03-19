import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../variabels/colors.dart';
import 'product_provider.dart';

class InfintyScrollRiverPod extends StatelessWidget {
  const InfintyScrollRiverPod({super.key});

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
      body: Consumer(
        builder: (context, ref, _) {
          final productProvider = ref.watch(productsProvider);
          return Center(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 13),
                    child: Stack(children: [
                      GridView.builder(
                        itemCount: productProvider.products.length + 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          if (index == productProvider.products.length &&
                              !productProvider.isLoading) {
                            productProvider.fetchProducts();
                          }
                          if (productProvider.isLoading) {
                            const Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final product = productProvider.products[index];
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
                                          product['mediaUrl'],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(height: 2.5),
                                      Text(
                                        "${product['name']}",
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
                                      Text(
                                        "${product['price']} JOD",
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
                        },
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
