
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // 1. If no user, show an empty box
    if (user == null) {
      return const SizedBox();
    }

    // 2. This StreamBuilder's only job is to check for unread notifications
    return StreamBuilder<QuerySnapshot>(
      // 3. The Query:
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false) // 4. Only get UNREAD
          .snapshots(),
      
      builder: (context, snapshot) {
        // 5. We don't care about loading/error, just the data
        bool hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        // 6. The Badge widget
        return Badge(
          // 7. Show a small red dot if 'hasUnread' is true
          isLabelVisible: hasUnread,
          // 8. The icon button itself
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              // 9. Navigate to the new NotificationsScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

