import 'package:flutter/material.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Chats'),
      ),
      body: const Center(
        child: Text('List of user chats will be displayed here.'),
      ),
    );
  }
}