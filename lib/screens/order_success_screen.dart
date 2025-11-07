import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed!'),
        // 1. This removes the "back" button from the AppBar
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2. A nice success icon
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),

              // 3. Confirmation text
              const Text(
                'Thank You!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your order has been placed successfully.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // 4. A button to go back to the home screen
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  // 5. Navigate and clear all other screens
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    // 6. This (route) => false removes all screens behind it
                        (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
