import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movieapp/home_page.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movies App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProviderScope(child: MainPage()),
    );
  }
}
