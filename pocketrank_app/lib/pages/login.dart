import 'package:flutter/material.dart';

import 'package:pocketbase/pocketbase.dart';

class LoginPage extends StatefulWidget {
  final PocketBase pb;

  const LoginPage({super.key, required this.pb});

  @override
  State<LoginPage> createState() => _LoginPageState(pb: pb);
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final PocketBase pb;

  _LoginPageState({required this.pb});

  void _login() async {
    try {
      await pb.collection('users').authWithPassword(
            _usernameController.text,
            _passwordController.text,
          );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _passwordController.clear();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid username or password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                _login();
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}