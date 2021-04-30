import 'package:flutter/material.dart';
import './ui/tasklist.dart';


void main() {
  runApp(TaskExpiryApp());
}


class TaskExpiryApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocExpire',
      theme: new ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: TaskList(),
    );
  }

}
