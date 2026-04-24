import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.push('/profile/mybooks'),
            child: Text("My books"),
          ),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            child: Text("login"),
          ),
        ],
      ),
    );
  }
}
