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
      title: 'Flutter network image example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter network image example'),
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
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              final int totalSize = loadingProgress.expectedTotalBytes ??
                  loadingProgress.cumulativeBytesLoaded;
              final double progress =
                  loadingProgress.cumulativeBytesLoaded / totalSize;
              return CircularProgressIndicator(
                value: progress,
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.cloud_off,
                color: Colors.grey,
                size: 48,
              );
            },
          ),
        ),
      ),
    );
  }
}
