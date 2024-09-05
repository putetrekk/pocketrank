import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class AddMatchPage extends StatefulWidget {
  final PocketBase pb;

  const AddMatchPage({super.key, required this.pb});

  @override
  _AddMatchPageState createState() => _AddMatchPageState(pb: pb);
}

class Result {
  final String playerId;
  final String playerName;
  final String match;
  final int place;

  Result(
      {required this.playerId,
      required this.playerName,
      required this.match,
      required this.place});
}

class _AddMatchPageState extends State<AddMatchPage> {
  final PocketBase pb;
  final _results = <Result>[];
  var _availablePlayers = ResultList<RecordModel>();
  List<RecordModel> _remainingAvailablePlayers() {
    return _availablePlayers.items
        .where((element) =>
            !_results.any((result) => result.playerId == element.id))
        .toList();
  }

  var _addingPlayer = false;

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
          'player': result.playerId,
          'place': result.place,
        });
      }
    } catch (e) {
      print('Failed to add match: $e');
    }
  }

  void addPlayer(String playerId) {
    final selectedPlayer =
        _availablePlayers.items.firstWhere((element) => element.id == playerId);
    final result = Result(
      playerId: selectedPlayer.id,
      match: 'somematchid',
      place: 1,
      playerName: selectedPlayer.data['name'],
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
                        mainAxisAlignment: MainAxisAlignment
                            .center,
                        children: [
                          Expanded(
                            child: Text(e.playerName),
                          ),
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
                                  playerId: e.playerId,
                                  match: e.match,
                                  place: value!,
                                  playerName: e.playerName,
                                ));
                              });
                            },
                            hint: const Text('Select a score'),
                          ),
                        ],
                      ))
                  .toList(),
            ),
            if (!_addingPlayer)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _addingPlayer = true;
                  });
                },
                child: const Text('Add Player'),
              )
            else
              DropdownButton<String>(
                items: _remainingAvailablePlayers().map(
                  (e) {
                    return DropdownMenuItem<String>(
                      value: e.id,
                      child: Text(e.data['name']),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null && value.isNotEmpty) {
                      addPlayer(value);
                      _addingPlayer = false;
                    }
                  });
                },
                hint: const Text('Select a player'),
              ),
            ElevatedButton(
              onPressed: _addMatch,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Save Match'),
            ),
          ],
        ),
      ),
    );
  }
}
