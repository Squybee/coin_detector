import 'package:coin_detector/coin-detector/coin-detector.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coin Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CoinDetector(),
      debugShowCheckedModeBanner: false,
    );
  }
}
