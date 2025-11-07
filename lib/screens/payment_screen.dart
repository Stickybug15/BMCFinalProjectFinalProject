import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. An enum to represent our different payment methods
//    This is cleaner than using strings like "gcash"
enum PaymentMethod { card, gcash, bank }

class PaymentScreen extends StatefulWidget {
  // 2. We need to know the total amount to be paid
  final double totalAmount;

  // 3. The constructor will require this amount
  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // 4. State variables to track selection and loading
  PaymentMethod _selectedMethod = PaymentMethod.card; // Default to card
  bool _isLoading = false;

  Future<void> _processPayment() async {
    // 1. Start loading spinner on the button
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. --- THIS IS OUR MOCK API CALL ---
      //    We just wait for 3 seconds to simulate a network request
      //    to GCash, a bank, or a credit card processor.
      await Future.delayed(const Duration(seconds: 3));

      // 3. If the "payment" is "successful" (i.e., the 3 seconds are up),
      //    we get the CartProvider.
      //    (listen: false is critical for calls inside functions)
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // 4. Call the functions we built in Module 10
      //    This is the logic we are *moving* from the CartScreen
      await cartProvider.placeOrder();
      await cartProvider.clearCart();

      // 5. If successful, navigate to success screen
      //    We use pushAndRemoveUntil to clear the cart/payment screens
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // 6. Handle any errors from placing the order
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      // 7. ALWAYS stop loading, even if an error occurred
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Use the Philippine Peso sign (₱)
    //    We get the totalAmount from 'widget.totalAmount'
    final String formattedTotal = '₱${widget.totalAmount.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 2. Show the total amount
            Text(
              'Total Amount:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              formattedTotal,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 24),
            const Divider(),

            // 3. Payment method selection
            Text(
              'Select Payment Method:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // 4. RadioListTile for Card
            RadioListTile<PaymentMethod>(
              title: const Text('Credit/Debit Card'),
              secondary: const Icon(Icons.credit_card),
              value: PaymentMethod.card,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),

            // 5. RadioListTile for GCash
            RadioListTile<PaymentMethod>(
              title: const Text('GCash'),
              // We use a generic icon, but you could add a real logo here
              secondary: const Icon(Icons.phone_android),
              value: PaymentMethod.gcash,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),

            // 6. RadioListTile for Bank Transfer
            RadioListTile<PaymentMethod>(
              title: const Text('Bank Transfer'),
              secondary: const Icon(Icons.account_balance),
              value: PaymentMethod.bank,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),

            const SizedBox(height: 32),

            // 7. The "Pay Now" button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              // 8. Disable button when loading
              onPressed: _isLoading ? null : _processPayment,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Pay Now ($formattedTotal)'),
            ),
          ],
        ),
      ),
    );
  }
}
