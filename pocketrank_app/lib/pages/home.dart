import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'login.dart';
import 'match.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.pb});

  final String title;
  final PocketBase pb;

  @override
  State<MyHomePage> createState() => _MyHomePageState(pb: pb);
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final PocketBase pb;
  var _userName = "Not logged in";
  var _rankings = <Ranking>[];
  final logger = Logger();
  late final AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    pb.authStore.onChange.listen((e) async {
      setState(() {
        _userName = (pb.authStore.model as RecordModel).data["name"];
      });
      _fetchRankings();
    });
  }

  _MyHomePageState({required this.pb});

  void _fetchRankings() async {
    if (_userName == "Not logged in") {
      return;
    }
    try {
      final url =
          Uri.https(dotenv.env["SERVER_URL"]!, 'api/pocketrank/ratings');
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

  void _onMatchAdded() {
    _fetchRankings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2.0 * 3.141592653589793,
                    child: child,
                  );
                },
                child: SvgPicture.asset(
                  'web/images/pocketrank.svg',
                  height: 80,
                ),
              ),
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
                    MaterialPageRoute(
                        builder: (context) =>
                            AddMatchPage(pb: pb, onMatchAdded: _onMatchAdded)),
                  );
                },
                style: _userName != "Not logged in"
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white)
                    : ElevatedButton.styleFrom(),
                child: const Text('Add Match'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage(pb: pb)),
                  );
                },
                style: _userName == "Not logged in"
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white)
                    : ElevatedButton.styleFrom(),
                child: const Text('Go to Login Page'),
              ),
              const SizedBox(height: 20),
              /*if (_userName == "Not logged in")
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResetPasswordPage(),
                      ),
                    );
                  },
                  child: const Text('Reset Password'),
                ),
              const SizedBox(height: 20),*/
              if (_userName == "Not logged in")
                ElevatedButton(
                  onPressed: () {
                    _redirectToDiscord();
                  },
                  child: const Text('Login with Discord'),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _redirectToDiscord() async {
    final discordAuthUrl = Uri.https(
        dotenv.env["DISCORD_OAUTH2_HOST"]!, dotenv.env["DISCORD_OAUTH2_PATH"]!);
    await launchUrl(discordAuthUrl);
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
