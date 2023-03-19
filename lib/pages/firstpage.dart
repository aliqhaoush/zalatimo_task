import 'package:flutter/material.dart';
import 'package:zalatimo/infinitescroll/infinite_scroll.dart';
import 'package:zalatimo/variabels/colors.dart';

import 'HomePage.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.black],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/zalatimo.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: backgroundColor,
                  backgroundColor: Colors.black.withOpacity(.5),
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  textStyle: const TextStyle(
                    fontFamily: "Myriad",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('PageSize'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InfintyScrollRiverPod()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(.5),
                  foregroundColor: backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  textStyle: const TextStyle(
                    fontFamily: "Myriad",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Infinity Scroll'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
