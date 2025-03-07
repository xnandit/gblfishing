// Full code for LeaderboardScreen to display ranking of fishing club members with data fetched from an API, with added animations.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    try {
      print('Fetching data from API...');
      final response = await http.get(
        Uri.parse('http://api3.cleanverseid.com/api/api/scores'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Decoded response: $data');
        
        // Group scores by user and calculate total score
        final Map<String, Map<String, dynamic>> userScores = {};
        
        for (var item in data) {
          final userId = item['user_id'].toString();
          if (!userScores.containsKey(userId)) {
            userScores[userId] = {
              'name': item['user_name'],
              'position': item['user_position'],
              'photoUrl': item['user_photo'],
              'totalScore': 0,
              'activitiesCount': 0,
            };
          }
          userScores[userId]!['totalScore'] = (userScores[userId]!['totalScore'] as int) + (item['score'] ?? 0);
          userScores[userId]!['activitiesCount'] = (userScores[userId]!['activitiesCount'] as int) + 1;
        }
        
        // Convert to list and sort by total score
        final List<Map<String, dynamic>> sortedLeaderboard = userScores.entries
            .map((entry) => {
                  'name': entry.value['name'],
                  'score': entry.value['totalScore'],
                  'position': entry.value['position'],
                  'photoUrl': entry.value['photoUrl'],
                  'activitiesCount': entry.value['activitiesCount'],
                })
            .toList();
        
        // Sort by score in descending order
        sortedLeaderboard.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
        
        // Add ranks
        for (var i = 0; i < sortedLeaderboard.length; i++) {
          sortedLeaderboard[i]['rank'] = i + 1;
        }
        
        setState(() {
          _leaderboard = sortedLeaderboard;
          _isLoading = false;
          _error = '';
        });
      } else {
        print('API returned error ${response.statusCode}: ${response.body}');
        setState(() {
          _leaderboard = [];
          _error = 'Server error: ${response.statusCode}. Please try again later.';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching leaderboard data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = 'Unable to load leaderboard. Please check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/icon/background3.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                  ? Center(
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchLeaderboardData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _leaderboard.length,
                        itemBuilder: (context, index) {
                          final user = _leaderboard[index];
                          return AnimatedLeaderboardItem(
                            rank: user['rank'],
                            name: user['name'],
                            score: user['score'],
                            position: user['position'],
                            photoUrl: user['photoUrl'],
                            activitiesCount: user['activitiesCount'],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedLeaderboardItem extends StatefulWidget {
  final int rank;
  final String name;
  final int score;
  final String position;
  final String? photoUrl;
  final int activitiesCount;

  const AnimatedLeaderboardItem({
    Key? key,
    required this.rank,
    required this.name,
    required this.score,
    required this.position,
    this.photoUrl,
    required this.activitiesCount,
  }) : super(key: key);

  @override
  _AnimatedLeaderboardItemState createState() => _AnimatedLeaderboardItemState();
}

class _AnimatedLeaderboardItemState extends State<AnimatedLeaderboardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: widget.rank <= 3 ? Colors.amber : Colors.blue[100],
            child: Text(
              '${widget.rank}',
              style: TextStyle(
                color: widget.rank <= 3 ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            widget.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            widget.position,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.score} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              Text(
                '${widget.activitiesCount} activities',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
