import 'dart:convert';
import 'dart:math';
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
  var _ratings = <PlayerRating>[];
  var _latestRatings = <PlayerRating>[];
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
    final url = dotenv.env["TLS_ENABLED"] == 'true'
        ? Uri.https(dotenv.env["SERVER_URL"]!, 'api/pocketrank/ratings')
        : Uri.http(dotenv.env["SERVER_URL"]!, 'api/pocketrank/ratings');
    final response = await http.get(
      url,
      headers: {'Authorization': pb.authStore.token},
    );
    final ratings = (jsonDecode(utf8.decode(response.bodyBytes)) as List)
        .map((e) => PlayerRating.fromJson(e))
        .toList();

    final latestRatings = ratings
        .where((element) =>
            element.date.millisecondsSinceEpoch ==
            ratings
                .where((e) => e.name == element.name)
                .map((e) => e.date.millisecondsSinceEpoch)
                .reduce(max))
        .toList()
      ..sort((a, b) => b.rank.compareTo(a.rank));

    for (var ranking in latestRatings) {
      ranking.setLeadingEmoji(latestRatings.indexOf(ranking));
    }
    setState(() {
      _ratings = ratings;
      _latestRatings = latestRatings;
    });
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
                  itemCount: _latestRatings.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text(_latestRatings[index].leadingEmoji,
                          style: const TextStyle(fontSize: 20)),
                      title: Text(_latestRatings[index].name),
                      subtitle: Text('Rank: ${_latestRatings[index].rank}'),
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

class PlayerRating {
  PlayerRating({required this.name, required this.date, required this.rank});

  final String name;
  final DateTime date;
  final int rank;
  String leadingEmoji = '\u{1F3C5}';

  factory PlayerRating.fromJson(Map<String, dynamic> json) {
    return PlayerRating(
      name: json['name'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json['rated_at'] as int),
      rank: json['rating'] as int,
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
