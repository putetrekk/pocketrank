import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

final pb = PocketBase('http://127.0.0.1:8090');
final logger = Logger();

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    await pb.collection('users').authWithPassword(
          _usernameController.text,
          _passwordController.text,
        );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                _login();
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
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

class Ranking {
  Ranking({required this.name, required this.rank});

  final String name;
  final int rank;

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      name: json['name'] as String,
      rank: json['rank'] as int,
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var _userName = "Not logged in";
  var _rankings = <Ranking>[];

  void _fetchRankings() async {
    try {
      final url = Uri.http('127.0.0.1:8090', 'api/pocketrank/ratings');
      final response = await http.get(
        url,
        headers: {'Authorization': pb.authStore.token},
      );
      final rankingsList = (jsonDecode(utf8.decode(response.bodyBytes)) as List)
          .map((e) => Ranking.fromJson(e))
          .toList();
      setState(() {
        _rankings = rankingsList;
      });
    } catch (e) {
      logger.e('Failed to fetch rankings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    pb.authStore.onChange.listen((e) async {
      setState(() {
        _userName = (pb.authStore.model as RecordModel).data["name"];
      });
      _fetchRankings();
    });
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
              "You're logged in as:",
            ),
            Text(
              _userName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _rankings.length,
                itemBuilder: (context, index) {
                  final ranking = _rankings[index];
                  return ListTile(
                    title: Text('Player: ${ranking.name}'),
                    subtitle: Text('Rating: ${ranking.rank}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Go to Login Page'),
            ),
          ],
        ),
      ),
    );
  }
}
