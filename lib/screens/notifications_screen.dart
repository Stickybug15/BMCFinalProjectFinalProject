import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showUnread = true;

  Future<void> _markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          FilterChip(
            label: Text(_showUnread ? 'Unread' : 'All'),
            selected: _showUnread,
            onSelected: (bool selected) {
              setState(() {
                _showUnread = selected;
              });
            },
          )
        ],
      ),
      body: _user == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('notifications')
                  .where('userId', isEqualTo: _user.uid)
                  .where('isRead', isEqualTo: _showUnread ? false : null)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(_showUnread
                        ? 'You have no unread notifications.'
                        : 'You have no notifications.'),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final timestamp = (data['createdAt'] as Timestamp?);
                    final formattedDate = timestamp != null
                        ? DateFormat(
                            'MM/dd/yy hh:mm a',
                          ).format(timestamp.toDate())
                        : '';

                    return Dismissible(
                      key: Key(doc.id),
                      onDismissed: (direction) {
                        _markNotificationAsRead(doc.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Notification marked as read'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                _firestore
                                    .collection('notifications')
                                    .doc(doc.id)
                                    .update({'isRead': false});
                              },
                            ),
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.circle,
                          color: Colors.deepPurple,
                          size: 12,
                        ),
                        title: Text(
                          data['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('${data['body'] ?? ''}\n$formattedDate'),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
