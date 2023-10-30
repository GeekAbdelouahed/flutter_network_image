import 'package:flutter/material.dart';
import 'package:flutter_network_image/flutter_network_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final int _maxCounter = 10;
  int _counter = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo'),
        ),
        body: Center(
          child: Image(
            image: NetworkImageProvider(
              'https://flutter-with-dart.000webhostapp.com/dart.jpeg',
              retryWhen: () {
                _counter++;
                return _counter <= _maxCounter;
              },
            ),
            width: 300,
          ),
        ),
      ),
    );
  }
}
