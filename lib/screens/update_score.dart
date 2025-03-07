import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// Updates the user's score using the CleanVerID API
/// Returns a Future that resolves to true if successful, false otherwise
Future<bool> updateScore({
  required String userId,
  required int score,
  required BuildContext context,
}) async {
  // Check if user is admin
  if (!context.read<UserProvider>().isAdmin) {
    print('Unauthorized: Admin access required');
    return false;
  }

  // API endpoint
  const String baseUrl = 'http://api3.cleanverseid.com';
  const String path = '/api/api/scores/update';
  
  try {
    // First verify the user exists
    final userResponse = await http.get(
      Uri.parse('$baseUrl/api/api/users'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (userResponse.statusCode != 200) {
      print('Error fetching users: ${userResponse.statusCode}');
      return false;
    }

    final List<dynamic> users = jsonDecode(userResponse.body);
    bool userExists = users.any((user) => user['id'].toString() == userId);

    if (!userExists) {
      print('User with ID $userId not found');
      return false;
    }

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'userId': userId,
      'score': score,
    };

    print('Sending score update request: $requestBody');

    // Send POST request to update score
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    // Log the response for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Check if request was successful
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['message'] == 'Score updated successfully') {
        print('Score ${data['operation'] == 'update' ? 'updated' : 'inserted'} successfully');
        return true;
      }
      return false;
    } else if (response.statusCode == 404) {
      print('User not found');
      return false;
    } else {
      print('Error updating score: ${response.statusCode}');
      print('Error response: ${response.body}');
      return false;
    }
  } catch (e, stackTrace) {
    print('Exception while updating score: $e');
    print('Stack trace: $stackTrace');
    return false;
  }
}

class UpdateScoreScreen extends StatefulWidget {
  const UpdateScoreScreen({super.key});

  @override
  _UpdateScoreScreenState createState() => _UpdateScoreScreenState();
}

class _UpdateScoreScreenState extends State<UpdateScoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _scoreController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _submitScore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await updateScore(
        userId: _userIdController.text,
        score: int.parse(_scoreController.text),
        context: context,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _userIdController.clear();
        _scoreController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update score'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating score'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check admin status
    if (!context.watch<UserProvider>().isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Unauthorized Access',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/icon/background4.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a user ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _scoreController,
                          decoration: const InputDecoration(
                            labelText: 'Score',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a score';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitScore,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Update Score'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
