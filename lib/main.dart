import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Arts and Crafts Color Palette ---
const Color craftOrange = Color(0xFFE57A44);
const Color craftBrown = Color(0xFF8C5E58);
const Color craftCream = Color(0xFFFDF4E3);
const Color craftCharcoal = Color(0xFF36454F);
const Color craftRed = Color(0xFFC15454);
// --- END OF COLOR PALETTE ---

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final cartProvider = CartProvider();
  runApp(
    ChangeNotifierProvider.value(
      value: cartProvider,
      child: const MyApp(),
    ),
  );
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eCommerce App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: craftOrange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: craftOrange,
          brightness: Brightness.light,
          primary: craftOrange,
          secondary: craftBrown,
          surface: craftCream,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: craftCharcoal,
          error: craftRed,
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: craftCream,
        textTheme: GoogleFonts.latoTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ).apply(
          bodyColor: craftCharcoal,
          displayColor: craftCharcoal,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) return Colors.green;
                return craftOrange; // Defer to the default
              },
            ),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            shape: WidgetStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: craftCharcoal.withAlpha(128)),
          ),
          labelStyle: TextStyle(color: craftCharcoal.withAlpha(204)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: craftOrange, width: 2.0),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: craftCharcoal,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
