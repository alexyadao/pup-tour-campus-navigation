import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for locking orientation
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_routes.dart';

// Global shortcut to access the Supabase client easily across the app
final supabase = Supabase.instance.client;

Future<void> main() async {
  // Required by Flutter when using 'await' in main
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load the .env file from the root directory
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase with your keys from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 3. LOCK ORIENTATION TO PORTRAIT 
  // This prevents the app from rotating to landscape and breaking the UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 4. Run the App
  runApp(const PUPTourApp());
}

class PUPTourApp extends StatelessWidget {
  const PUPTourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PUP Tour',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
        // Ensuring buttons across the app follow your theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF850909),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}

// HELPFUL EXTENSION
// allows you call context.showSnackBar("message") from any screen
extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}