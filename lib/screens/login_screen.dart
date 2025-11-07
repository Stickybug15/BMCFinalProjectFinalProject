import 'signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Add Firebase Auth import

// 1. Create a StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// 2. This is the State class
class _LoginScreenState extends State<LoginScreen> {
  // 3. Create a GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();

  // 4. Create TextEditingControllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Add a loading state variable
  bool _isLoading = false;

  // 3. Get an instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 5. Clean up controllers when the widget is removed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 1. Check if the form is valid
    if (!_formKey.currentState!.validate()) {
      return; // If not valid, stop here
    }

    // 2. Set loading to true
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. This is the Firebase command to sign in
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 4. If login is successful, the AuthWrapper's stream
      //    will auto-navigate to HomeScreen. We don't need to do it here.
    } on FirebaseAuthException catch (e) {
      // 5. This 'catch' block handles Firebase-specific errors
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }

      // 6. Show the error message in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // 7. Catch any other general errors
      print(e);
    }

    // 8. ALWAYS set loading to false at the end
    if (mounted) {
      // Check if the widget is still on screen
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    // 1. A Scaffold provides the basic screen structure
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      // 2. SingleChildScrollView prevents the keyboard from
      //    causing a "pixel overflow" error
      body: SingleChildScrollView(
        child: Padding(
          // 3. Add padding around the form
          padding: const EdgeInsets.all(16.0),
          // 4. The Form widget acts as a container for our fields
          child: Form(
            key: _formKey, // 5. Assign our key to the Form
            // 6. A Column arranges its children vertically
            child: Column(
              // 7. Center the contents of the column
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. A spacer
                const SizedBox(height: 20),

                // 2. The Email Text Field
                TextFormField(
                  controller: _emailController, // 3. Link the controller
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(), // 4. Nice border
                  ),
                  keyboardType:
                      TextInputType.emailAddress, // 5. Show '@' on keyboard
                  // 6. Validator function
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null; // 'null' means the input is valid
                  },
                ),

                // 7. A spacer
                const SizedBox(height: 16),

                // 8. The Password Text Field
                TextFormField(
                  controller: _passwordController, // 9. Link the controller
                  obscureText: true, // 10. This hides the password
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  // 11. Validator function
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                // 1. A spacer
                const SizedBox(height: 20),

                // 2. The Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50), // 3. Make it wide
                  ),
                  // 4. onPressed is the click handler

                  // 1. Call our new _login function
                  onPressed: _login,

                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : const Text('Login'),
                ),

                // 6. A spacer
                const SizedBox(height: 10),

                // 7. The "Sign Up" toggle button
                TextButton(
                  onPressed: () {
                    // 8. Navigate to the Sign Up screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
