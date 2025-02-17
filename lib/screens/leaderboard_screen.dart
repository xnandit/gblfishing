// Full code for LeaderboardScreen to display ranking of fishing club members with data fetched from an API, with added animations.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final List<Map<String, dynamic>> _leaderboard = [
    {'name': 'John Doe', 'score': 150, 'rank': 1},
    {'name': 'Jane Smith', 'score': 145, 'rank': 2},
    {'name': 'Bob Johnson', 'score': 140, 'rank': 3},
    {'name': 'Alice Brown', 'score': 135, 'rank': 4},
    {'name': 'Charlie Wilson', 'score': 130, 'rank': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/icon/background3.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.cyan.withOpacity(0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GBLFishingMania',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2.0,
                                color: Colors.black45,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Lihat ranking anggota berdasarkan aktivitas memancing.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Konten leaderboard di bawah header
            Expanded(
              child: ListView.builder(
                itemCount: _leaderboard.length,
                itemBuilder: (context, index) {
                  final player = _leaderboard[index];
                  return AnimatedLeaderboardItem(
                    rank: player['rank'],
                    member: player['name'],
                    totalCatch: 'Total Tangkap: ${player['score']} ikan',
                  );
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class AnimatedLeaderboardItem extends StatefulWidget {
  final String member;
  final String totalCatch;
  final int rank;

  const AnimatedLeaderboardItem(
      {super.key,
      required this.rank,
      required this.member,
      required this.totalCatch});

  @override
  _AnimatedLeaderboardItemState createState() =>
      _AnimatedLeaderboardItemState();
}

class _AnimatedLeaderboardItemState extends State<AnimatedLeaderboardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Timer(const Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text('#${widget.rank}'),
          ),
          title: Text(widget.member),
          subtitle: Text(widget.totalCatch),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
