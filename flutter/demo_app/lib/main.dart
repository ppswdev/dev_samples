import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());

   for (var i = 0; i <= 360; i++) {
      var index = (i / 36.0).ceil();
      print('angle : $i index : $index');
    }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
