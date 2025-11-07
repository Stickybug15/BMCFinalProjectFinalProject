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

  // 1. This function will mark all unread notifications as "read"
  void _markNotificationsAsRead(List<QueryDocumentSnapshot> docs) {
    // 2. Use a "WriteBatch" to update multiple documents at once
    final batch = _firestore.batch();

    for (var doc in docs) {
      if (doc['isRead'] == false) {
        // 3. If it's unread, add an "update" operation to the batch
        batch.update(doc.reference, {'isRead': true});
      }
    }

    // 4. "Commit" the batch, sending all updates to Firestore
    batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _user == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<QuerySnapshot>(
              // 5. Get ALL notifications for this user, newest first
              stream: _firestore
                  .collection('notifications')
                  .where('userId', isEqualTo: _user!.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('You have no notifications.'),
                  );
                }

                final docs = snapshot.data!.docs;

                // 6. --- IMPORTANT ---
                //    As soon as we have the notifications,
                //    we call our function to mark them as read.
                _markNotificationsAsRead(docs);

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final timestamp = (data['createdAt'] as Timestamp?);
                    final formattedDate = timestamp != null
                        ? DateFormat(
                            'MM/dd/yy hh:mm a',
                          ).format(timestamp.toDate())
                        : '';

                    // 7. Check if this notification was *just* read
                    final bool wasUnread = data['isRead'] == false;

                    return ListTile(
                      // 8. Show a "new" icon if it was unread
                      leading: wasUnread
                          ? const Icon(
                              Icons.circle,
                              color: Colors.deepPurple,
                              size: 12,
                            )
                          : const Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
                              size: 12,
                            ),
                      title: Text(
                        data['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: wasUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text('${data['body'] ?? ''}\n$formattedDate'),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
    );
  }
}
