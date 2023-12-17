import 'package:flutter/material.dart';
import 'package:flutter_network_image/flutter_network_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter network provider demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter network provider demo'),
        ),
        body: Center(
          child: Image(
            width: 300,
            height: 300,
            fit: BoxFit.cover,
            image: NetworkImageProvider(
              'https://example.com/image.png',
              retryWhen: (Attempt attempt) => attempt.counter < 10,
            ),
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame != null) {
                return child;
              }

              return const CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) {
              return const Text('Loading image failed!');
            },
          ),
        ),
      ),
    );
  }
}
