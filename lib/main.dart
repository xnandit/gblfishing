import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/members_screen.dart';
import 'screens/documentation_screen.dart';
import 'screens/update_score.dart';
import 'screens/login_screen.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const FishingApp(),
    ),
  );
}

class FishingApp extends StatelessWidget {
  const FishingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GBLFishingMania',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
      },
      builder: (context, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) async {
            if (didPop) return;
            
            final currentRoute = ModalRoute.of(context);
            if (currentRoute != null && currentRoute.settings.name == '/login') {
              return;
            }
            
            // If we're not on login screen, logout
            await context.read<UserProvider>().logout();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (Route<dynamic> route) => false,
              );
            }
          },
          child: child!,
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Widget> _getPages(BuildContext context) {
    final bool isAdmin = context.watch<UserProvider>().isAdmin;
    return <Widget>[
      const DashboardScreenContent(),
      const LeaderboardScreen(),
      if (isAdmin) const UpdateScoreScreen(),
      const MembersScreen(),
      const DocumentationScreen(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = context.watch<UserProvider>().isAdmin;
    final pages = _getPages(context);
    
    // Adjust selected index if needed when admin status changes
    if (!isAdmin && _selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('GBLFishingMania'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
              
              try {
                await context.read<UserProvider>().logout();
                
                if (context.mounted) {
                  // Close loading indicator
                  Navigator.of(context).pop();
                  
                  // Navigate to login
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  // Close loading indicator
                  Navigator.of(context).pop();
                  
                  // Show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error during logout. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/icon/background4.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          FadeTransition(
            opacity: _animation,
            child: pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard, size: 30),
              label: 'Leaderboard',
            ),
            if (isAdmin)
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_circle, size: 40),
                label: 'Update',
              ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people, size: 30),
              label: 'Members',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.photo_library, size: 30),
              label: 'Documentation',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

class DashboardScreenContent extends StatelessWidget {
  final List<Map<String, String>> _appointments = const [
    {
      'date': 'Sabtu, 23 November 2024',
      'agenda': 'Mancing di laut',
      'location': 'PIK Ancol',
      'for': 'Semua Anggota'
    },
  ];

  const DashboardScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jadwal Kegiatan Memancing Berikutnya',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.calendar_today, color: Colors.white),
                    ),
                    title: Text(
                      'Next Event: ${appointment['date']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Agenda: ${appointment['agenda']}'),
                        Text('Location: ${appointment['location']}'),
                        Text('For: ${appointment['for']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
