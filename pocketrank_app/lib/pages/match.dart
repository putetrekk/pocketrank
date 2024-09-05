import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class AddMatchPage extends StatefulWidget {
  final PocketBase pb;

  const AddMatchPage({super.key, required this.pb});

  @override
  _AddMatchPageState createState() => _AddMatchPageState(pb: pb);
}

class Result {
  final String player;
  final String match;
  final int place;

  Result({required this.player, required this.match, required this.place});
}

class _AddMatchPageState extends State<AddMatchPage> {
  final PocketBase pb;
  final _results = [
    Result(
      player: 'someplayerid',
      match: 'somematchid',
      place: 1,
    ),
  ];
  var _availablePlayers = ResultList<RecordModel>();
  final _selectedPlayer = TextEditingController();

  _AddMatchPageState({required this.pb});

  void _loadAvailablePlayers() async {
    try {
      final availablePlayers =
          await pb.collection('available_players').getList();
      setState(() {
        _availablePlayers = availablePlayers;
      });
    } catch (e) {
      print('Failed to load available players: $e');
    }
  }

  void _addMatch() async {
    try {
      final match = await pb.collection('matches').create();
      for (var result in _results) {
        await pb.collection('results').create(body: {
          'match': match.id,
          'player': result.player,
          'place': result.place,
        });
      }
    } catch (e) {
      print('Failed to add match: $e');
    }
  }

  void addPlayer() {
    final player = _availablePlayers.items
        .firstWhere((element) => element.id == _selectedPlayer.text);
    final result = Result(
      player: player.id,
      match: 'somematchid',
      place: 1,
    );
    setState(() {
      _results.add(result);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAvailablePlayers();
  }

  @override
  void dispose() {
    _selectedPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: _results
                  .map((e) => Row(
                        children: [
                          Text(e.player),
                          DropdownButton<int>(
                            items: List.generate(_results.length, (index) {
                              return DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text((index + 1).toString()),
                              );
                            }),
                            value: e.place,
                            onChanged: (value) {
                              setState(() {
                                _results.remove(e);
                                _results.add(Result(
                                  player: e.player,
                                  match: e.match,
                                  place: value!,
                                ));
                              });
                            },
                            hint: const Text('Select a score'),
                          ),
                        ],
                      ))
                  .toList(),
            ),
            DropdownButton<String>(
              items: _availablePlayers.items.map(
                (e) {
                  return DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(e.data['name']),
                  );
                },
              ).toList(),
              value: _selectedPlayer.text.isEmpty ? null : _selectedPlayer.text,
              onChanged: (value) {
                setState(() {
                  _selectedPlayer.text = value!;
                });
              },
              hint: const Text('Select a player'),
            ),
            ElevatedButton(
              onPressed: addPlayer,
              child: const Text('Add Player'),
            ),
            ElevatedButton(
              onPressed: _addMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Set the primary color of the button
              ),
              child: const Text('Save Match'),
            ),
          ],
        ),
      ),
    );
  }
}
