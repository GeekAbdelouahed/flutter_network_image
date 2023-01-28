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
  int _counter = 0;

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
              'http://localhost/img/gus.png',
              retryWhen: () {
                _counter++;
                return _counter < 10;
              },
            ),
            height: 150,
            width: 150,
          ),
        ),
      ),
    );
  }
}
