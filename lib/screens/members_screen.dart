// Full code for MembersScreen to display list of club members with added animations and background image.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchMembersData();
  }

  Future<void> _fetchMembersData() async {
    try {
      print('Fetching members data from API...');
      final response = await http.get(
        Uri.parse('http://api3.cleanverseid.com/api/api/users'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('Decoded response: $responseData');
        
        List<dynamic> data;
        if (responseData is Map) {
          data = List<dynamic>.from(responseData['data'] ?? []);
        } else if (responseData is List) {
          data = responseData;
        } else {
          throw Exception('Unexpected response format');
        }
        
        setState(() {
          _members = data.map((item) {
            try {
              return {
                'name': item['name']?.toString() ?? 'Unknown',
                'role': item['position']?.toString() ?? 'Member',
                'photoUrl': item['url_photo']?.toString(),
              };
            } catch (e) {
              print('Error mapping item: $e');
              return {
                'name': 'Unknown',
                'role': 'Member',
                'photoUrl': null,
              };
            }
          }).toList();
          _isLoading = false;
          _error = '';
        });
      } else if (response.statusCode == 404) {
        print('API returned 404 - endpoint not found');
        setState(() {
          _members = [];
          _error = 'No members data available. Please check the API endpoint.';
          _isLoading = false;
        });
      } else {
        print('API returned error ${response.statusCode}: ${response.body}');
        setState(() {
          _members = [];
          _error = 'Server error: ${response.statusCode}. Please try again later.';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching members data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = 'Unable to load members. Please check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota Klub'),
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
                    Icons.people,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Members',
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
                          'Kepengurusan & Anggota',
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
                      onRefresh: _fetchMembersData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          return AnimatedMemberItem(
                            name: member['name']!,
                            role: member['role']!,
                            photoUrl: member['photoUrl'],
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

class AnimatedMemberItem extends StatefulWidget {
  final String name;
  final String role;
  final String? photoUrl;

  const AnimatedMemberItem({
    super.key, 
    required this.name, 
    required this.role, 
    this.photoUrl,
  });

  @override
  _AnimatedMemberItemState createState() => _AnimatedMemberItemState();
}

class _AnimatedMemberItemState extends State<AnimatedMemberItem>
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
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            backgroundImage: widget.photoUrl != null ? NetworkImage(widget.photoUrl!) : null,
            child: widget.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
          ),
          title: Text(
            widget.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            widget.role,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
