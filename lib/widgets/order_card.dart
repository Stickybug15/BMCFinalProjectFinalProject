import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 1. Import the intl package

class OrderCard extends StatelessWidget {
  // 2. We'll pass in the entire order data map
  final Map<String, dynamic> orderData;

  const OrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    // 3. Safely get the timestamp
    final Timestamp? timestamp = orderData['createdAt'];
    final String formattedDate;

    if (timestamp != null) {
      // 4. Use DateFormat to make it readable
      //    (e.g., "11/06/2025 - 10:51 AM")
      formattedDate = DateFormat(
        'MM/dd/yyyy - hh:mm a',
      ).format(timestamp.toDate());
    } else {
      formattedDate = 'Date not available';
    }

    // 5. Use a Card for a nice UI
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        // 6. Use a ListTile for clean, structured content
        child: ListTile(
          // 7. Title: Total Price
          title: Text(
            'Total: ₱${(orderData['totalPrice'] as double).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          // 8. Subtitle: Item count and Status
          subtitle: Text(
            'Items: ${orderData['itemCount']}\n'
            'Status: ${orderData['status']}',
          ),

          // 9. Trailing: The formatted date
          trailing: Text(
            formattedDate,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          // 10. Allows the subtitle to have 2 lines
          isThreeLine: true,
        ),
      ),
    );
  }
}
