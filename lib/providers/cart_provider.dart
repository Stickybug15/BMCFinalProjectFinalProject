import 'dart:async'; 
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class CartItem {
  final String id; 
  final String name;
  final double price;
  int quantity; 

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1, 
  });

 
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'quantity': quantity};
  }

 
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}


class CartProvider with ChangeNotifier {
  
  List<CartItem> _items = [];

  
  List<CartItem> get items => _items;

 
  String? _userId; 
  StreamSubscription? _authSubscription; 

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CartProvider() {
    initializeAuthListener();
    developer.log('CartProvider created and auth listener initialized.');
  }

  double get subtotal {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

 
  double get vat {
    return subtotal * 0.12; 
  }

  
  double get totalPriceWithVat {
    return subtotal + vat;
  }

 
  int get itemCount {
    
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  
  @override
  void dispose() {
    _authSubscription?.cancel(); 
    notifyListeners();
    super.dispose();
  }

 
  void initializeAuthListener() {
    developer.log('CartProvider auth listener initialized');
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        developer.log('User logged out, clearing cart.');
        _userId = null;
        _items = [];
      } else {
        developer.log('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }

  void addItem(String id, String name, double price, int quantity) {
   
    var index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
     
      _items[index].quantity += quantity;
    } else {
      
      _items.add(CartItem(
        id: id,
        name: name,
        price: price,
        quantity: quantity, 
      ));
    }

    _saveCart(); 
    notifyListeners(); 
  }

 
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      final List<Map<String, dynamic>> cartData =
          _items.map((item) => item.toJson()).toList();

      final double sub = subtotal;
      final double v = vat;
      final double total = totalPriceWithVat;
      final int count = itemCount;

      final newOrder = await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData,
        'subtotal': sub, 
        'vat': v, 
        'totalPrice': total, 
        'itemCount': count,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Create a notification for the new order
      await _firestore.collection('notifications').add({
        'orderId': newOrder.id,
        'userId': _userId,
        'title': 'Order Placed!',
        'body': 'Your order #${newOrder.id.substring(0, 6)} has been placed successfully.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

    } catch (e) {
      developer.log('Error placing order: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    
    _items = [];

    
    if (_userId != null) {
      try {
        
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        developer.log('Firestore cart cleared.');
      } catch (e) {
        developer.log('Error clearing Firestore cart: $e');
      }
    }

    
    notifyListeners();
  }

  Future<void> _fetchCart() async {
    if (_userId == null) return; 

    try {
     
      final doc = await _firestore.collection('userCarts').doc(_userId).get();

      if (doc.exists && doc.data()!['cartItems'] != null) {
        
        final List<dynamic> cartData = doc.data()!['cartItems'];

        
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        developer.log('Cart fetched successfully: ${_items.length} items');
      } else {
       
        _items = [];
      }
    } catch (e) {
      developer.log('Error fetching cart: $e');
      _items = []; 
    }
    notifyListeners(); 
  }

  
  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      
      final List<Map<String, dynamic>> cartData = _items
          .map((item) => item.toJson())
          .toList();

     
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
      developer.log('Cart saved to Firestore');
    } catch (e) {
      developer.log('Error saving cart: $e');
    }
  }
}