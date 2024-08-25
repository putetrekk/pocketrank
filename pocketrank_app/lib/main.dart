import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

void main() {
  runApp(const MyApp());
}

final pb = PocketBase('http://127.0.0.1:8090');

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var _data = ResultList<RecordModel>();
  var _rankings = [];
  

  void _incrementCounter() {
    setState(() {
      _counter += 3;
    });
  }

  void _fetchData() async {
    try {
      final data = await pb.collection('results').getList(
        page: 1,
        perPage: 20,
      );
      setState(() {
        _data = data;
      });
    } catch (e) {
      print('Failed to fetch data: $e');
    }
  }

  void _fetchRankings() async {
    try {
      final url = Uri.http('127.0.0.1:8090', 'api/pocketrank/get_rank/john');
      final response = await http.get(
        url,
        headers: {'Authorization': pb.authStore.token},
      );
      final List<dynamic> rankingsList = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      setState(() {
        _rankings = rankingsList;
      });
    } catch (e) {
      print('Failed to fetch rankings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchRankings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _data.totalItems,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_data.items[index].toString()),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _rankings.length,
                itemBuilder: (context, index) {
                  final ranking = _rankings[index] as Map<String, dynamic>;
                  final key = ranking.keys.first;
                  return ListTile(
                    title: Text('$key: ${ranking[key]}'),
                    subtitle: Text('Rank: ${ranking['rank']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}