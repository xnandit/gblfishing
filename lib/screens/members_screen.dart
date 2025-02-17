// Full code for MembersScreen to display list of club members with added animations and background image.

import 'package:flutter/material.dart';
import 'dart:async';

class MembersScreen extends StatelessWidget {
  // Static members list data for now, while backend is being developed
  final List<Map<String, String>> _members = [
    {'name': 'Ken Pandjaitan', 'role': 'Ketua', 'alias': 'EL`DERTITAN'},
    {'name': 'Joel Pasaribu', 'role': 'Wakil Ketua', 'alias': 'EL`BREGI'},
    {
      'name': 'Hendrik Marbun',
      'role': 'Kadiv Divisi Penerangan / Humas',
      'alias': 'EL`KLEMER'
    },
    {
      'name': 'Frans Marbun',
      'role': 'Kadiv Divisi Pemberdayaan Janda',
      'alias': 'EL`BRONS'
    },
    {'name': 'Dina Lorenza', 'role': 'Anggota', 'alias': ''},
    {'name': 'Yosafat Sihotang', 'role': 'Tamu', 'alias': ''},
  ];

  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota Klub'),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/icon/background3.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 8.0),
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
                  child: ListView.builder(
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      return AnimatedMemberItem(
                        name: member['name']!,
                        role: member['role']!,
                        alias: member['alias']!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedMemberItem extends StatefulWidget {
  final String name;
  final String role;
  final String alias;

  const AnimatedMemberItem(
      {super.key, required this.name, required this.role, required this.alias});

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
          leading: const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (widget.alias.isNotEmpty)
                Text(
                  'A.K.A ${widget.alias}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
            ],
          ),
          subtitle: Text(
            'Peran: ${widget.role}',
            style: const TextStyle(color: Colors.black54),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Viewed details for ${widget.name}')),
            );
          },
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
