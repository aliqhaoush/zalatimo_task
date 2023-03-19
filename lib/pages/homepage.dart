// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../variabels/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//========================= Providers ============================//
StateProvider<int> pageSizeProvider = StateProvider<int>((ref) => 21);
StateProvider<int> currentPageProvider = StateProvider<int>((ref) => 1);

//========================== Data Clss ============================//
class Product {
  final String name;
  final String imageUrl;
  final double price;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
  });
}

class ProductsResult {
  final List<Product> products;
  final int count;

  ProductsResult({
    required this.products,
    required this.count,
  });
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getCount();
    getCurrency();
  }

//======================== API'S ========================//
  final productsProvider =
      FutureProvider.autoDispose<ProductsResult>((ref) async {
    Response response = await http.get(Uri.parse(
        'https://zalatimoprod.rhinosoft.io/api/products?maxPrice=1000&minPrice=0&modes=ALL&page=${ref.watch(currentPageProvider)}&pageSize=${ref.watch(pageSizeProvider)}'));

    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      List<Product> products = (jsonResponse['data'] as List)
          .map((item) => Product(
                name: item['name'],
                imageUrl: item['mediaUrl'],
                price: item['price'].toDouble(),
              ))
          .toList();
      int count = jsonResponse['count'] as int;
      return ProductsResult(products: products, count: count);
    } else {
      throw Exception('Failed to load products');
    }
  });

  ////======================== Get The Count ========================////

  int count = 0;
  Future<void> getCount() async {
    final response = await http.get(Uri.parse(
        'https://zalatimoprod.rhinosoft.io/api/products?maxPrice=1000&minPrice=0&modes=ALL&page=1&pageSize=21'));
    final Map<String, dynamic> data = await json.decode(response.body);
    setState(() {
      count = data['count'];
    });
  }

  ////======================== Get The Currency ========================////
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Traditional Products',
            style: TextStyle(
                color: textColors,
                fontFamily: "Myriad",
                fontSize: 24,
                fontWeight: FontWeight.w400),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Consumer(builder: (context, ref, _) {
                //============ provider =============//
                //========To Get Value=======//
                int currentSize = ref.watch(pageSizeProvider.notifier).state;
                //===================================//
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: DropdownButton<int>(
                    style: const TextStyle(
                        fontFamily: "Myriad", color: textColors, fontSize: 18),
                    alignment: AlignmentDirectional.center,
                    borderRadius: BorderRadius.circular(20),
                    value: currentSize,
                    items: [
                      6,
                      16,
                      21,
                      50,
                    ].map((size) {
                      return DropdownMenuItem<int>(
                        alignment: AlignmentDirectional.center,
                        value: size,
                        child: Text(size.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newSize) {
                      if (newSize != null) {
                        setState(() {
                          //==============It will Read The Provider and set new value ================//
                          ref.read(pageSizeProvider.notifier).state = newSize;
                          ref.read(currentPageProvider.notifier).state = 1;
                        });
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        body: Column(
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.search,
                          color: searchBarColor,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: searchBarColor,
                                fontWeight: FontWeight.w300),
                            hintText: 'Search for an item',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Consumer(builder: (context, ref, _) {
              //================== Providers ===================//
              AsyncValue<ProductsResult> productsResult =
                  ref.watch(productsProvider);
              //================================================//
              return productsResult.when(
                data: (ProductsResult productsResult) => Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 13),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 31),
                      itemCount: productsResult.products.length,
                      itemBuilder: (BuildContext context, int index) {
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
                                        productsResult.products[index].imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 2.5),
                                    Text(
                                      productsResult.products[index].name,
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
                                      "${productsResult.products[index].price} $currency",
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
                      },
                    ),
                  ),
                ),
                loading: () => Center(
                    child: Image.asset(
                  "assets/images/Loading.gif",
                  height: 597,
                )),
                error: (error, stackTrace) => const Center(
                  child: Text(""),
                ),
              );
            }),
            Consumer(builder: (context, ref, child) {
              int currentPage = ref.watch(currentPageProvider.notifier).state;

              final productCount = count;
              final pageSize = ref.watch(pageSizeProvider);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentPage > 1)
                      Padding(
                        padding: const EdgeInsets.all(1),
                        child: InkWell(
                          // ============ Back Button ============= //
                          onTap: () {
                            setState(() {
                              ref.read(currentPageProvider.notifier).state =
                                  currentPage - 1;
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: buttonsColor,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: backgroundColor,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    //To Count The Number of items and divied on pageSize to get the buttons number//
                    //================ .ceil is used if the back is not int make it int ===============//
                    for (var i = 1; i <= (productCount / pageSize).ceil(); i++)
                      if (i == 1 ||
                          i == currentPage ||
                          i == (productCount / pageSize).ceil() ||
                          (i > currentPage - 2 && i < currentPage + 2))
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                ref.read(currentPageProvider.notifier).state =
                                    i;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == currentPage
                                    ? buttonsColor
                                    : Colors.grey[200],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '$i',
                                style: TextStyle(
                                  fontWeight: i == currentPage
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: i == currentPage
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(width: 10),
                    if (currentPage < (productCount / pageSize).ceil())
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        //=============== Foraward Button ===============//
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              ref.read(currentPageProvider.notifier).state =
                                  currentPage + 1;
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: buttonsColor,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: backgroundColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            })
          ],
        ));
  }
}
