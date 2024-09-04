import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

import 'login.dart';
import 'match.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.pb});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final PocketBase pb;

  @override
  State<MyHomePage> createState() => _MyHomePageState(pb: pb);
}

class _MyHomePageState extends State<MyHomePage> {
  final PocketBase pb;
  var _userName = "Not logged in";
  var _rankings = <Ranking>[];
  final logger = Logger();

  _MyHomePageState({required this.pb});

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
      for (var ranking in rankingsList) {
        ranking.setLeadingEmoji(rankingsList.indexOf(ranking));
      }
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
                  return ListTile(
                    leading: Text(_rankings[index].leadingEmoji,
                        style: const TextStyle(fontSize: 20)),
                    title: Text(_rankings[index].name),
                    subtitle: Text('Rank: ${_rankings[index].rank}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMatchPage(pb: pb)),
                );
              },
              child: const Text('Add Match'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(pb: pb)),
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

class Ranking {
  Ranking({required this.name, required this.rank});

  final String name;
  final int rank;
  String leadingEmoji = '\u{1F3C5}';

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      name: json['name'] as String,
      rank: json['rank'] as int,
    );
  }

  void setLeadingEmoji(int leaderboardPosition) {
    switch (leaderboardPosition) {
      case 0:
        leadingEmoji = '\u{1F947}';
        break;
      case 1:
        leadingEmoji = '\u{1F948}';
        break;
      case 2:
        leadingEmoji = '\u{1F949}';
        break;
      default:
        leadingEmoji = '\u{1F3C5}';
        break;
    }
  }
}
