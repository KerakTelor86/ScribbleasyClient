import 'package:flutter/material.dart';
import 'package:Scribbleasy/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scribbleasy',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Scribbleasy'),
        ),
        body: Center(
          child: Login(),
        ),
      ),
      theme: ThemeData(
        primaryColor: const Color(0xFF7482FF),
      ),
    );
  }
}
