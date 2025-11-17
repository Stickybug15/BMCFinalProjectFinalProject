import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/widgets/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  // 1. This is the "chat room ID". It's just the user's ID.
  final String chatRoomId; 
  // 2. This is for the AppBar title (e.g., "Chat with user@example.com")
  final String? userName; 

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // 3. Get Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 4. Controllers
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 1. This function runs ONCE when the screen is loaded
  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    
    // 2. We need to know which counter to reset
    // 3. If I am the USER opening this chat:
    if (currentUser.uid == widget.chatRoomId) {
      await _firestore.collection('chats').doc(widget.chatRoomId).set({
        'unreadByUserCount': 0, // Reset the user's count
      }, SetOptions(merge: true)); // 'merge: true' creates the doc if it doesn't exist
    } 
    // 4. If I am the ADMIN opening this chat:
    else { 
      await _firestore.collection('chats').doc(widget.chatRoomId).set({
        'unreadByAdminCount': 0, // Reset the admin's count
      }, SetOptions(merge: true));
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final String messageText = _messageController.text.trim();
    _messageController.clear();
    
    final timestamp = FieldValue.serverTimestamp();
    try {
      // --- TASK 1: Save the message ---
      // (This is standard: save to the 'messages' subcollection)
      await _firestore
          .collection('chats')
          .doc(widget.chatRoomId)   // This is the USER's ID
          .collection('messages') // The subcollection
          .add({                    // Add a new message document
        'text': messageText,
        'createdAt': timestamp,
        'senderId': currentUser.uid,
        'senderEmail': currentUser.email,
      });

      // --- TASK 2: Update the Parent Doc & Unread Counts ---
      Map<String, dynamic> parentDocData = {
        'lastMessage': messageText,
        'lastMessageAt': timestamp,
      };
      
      // 1. If I am the USER sending:
      if (currentUser.uid == widget.chatRoomId) {
        parentDocData['userEmail'] = currentUser.email;
        // Increment the ADMIN's unread count
        parentDocData['unreadByAdminCount'] = FieldValue.increment(1);
      } 
      // 2. If I am the ADMIN sending:
      else { 
        // Increment the USER's unread count
        parentDocData['unreadByUserCount'] = FieldValue.increment(1);
      }

      // 3. Use .set(merge: true) to create/update the parent doc
      await _firestore
          .collection('chats')
          .doc(widget.chatRoomId)
          .set(parentDocData, SetOptions(merge: true));

      // --- TASK 3: Scroll to bottom ---
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

    } catch (e) {
      developer.log("Error sending message: $e");
    }
  }

 @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        // Show "Chat with [User Email]" for admin, or "Contact Admin" for user
        title: Text(widget.userName ?? 'Contact Admin'),
      ),
      body: Column(
        children: [
          // --- The Message List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Query the 'messages' subcollection
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('createdAt', descending: false) // Oldest first
                  .snapshots(),
              
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}\n\n(Have you created the Firestore Index?)'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Say hello!'));
                }
                
                final messages = snapshot.data!.docs;
                
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    return ChatBubble(
                      message: messageData['text'] ?? '',
                      // Check if sender is the current user
                      isCurrentUser: messageData['senderId'] == currentUser!.uid,
                    );
                  },
                );
              },
            ),
          ),
          // --- The Text Input Field ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
