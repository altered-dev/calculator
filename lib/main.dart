import 'package:flutter/material.dart';
import 'history_entry.dart';
import 'numpad.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _history = <HistoryEntry>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        reverse: true,
        children: [
          Numpad(
            onEntryAdded: (entry) => setState(() => _history.add(entry)),
          ),
          Column(
            children: _history.map((entry) => ListTile(
              title: Text(
                entry.value,
                textAlign: TextAlign.right,
              ),
              subtitle: Text(
                entry.result,
                textAlign: TextAlign.right,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
