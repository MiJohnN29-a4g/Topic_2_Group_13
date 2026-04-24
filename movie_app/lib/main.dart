import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'repositories/user_repository.dart';
import 'screens/login_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/search_screen.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✓ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠ Firebase initialization failed: $e');
    debugPrint('Running in offline mode with hardcoded data');
  }

  // Tạo admin mặc định nếu chưa tồn tại (chỉ khi Firebase hoạt động)
  try {
    final userRepository = UserRepository();
    final adminExists = await userRepository.adminExists();
    if (!adminExists) {
      await userRepository.createAdmin(
        email: 'admin@flixfilm.com',
        password: 'admin123',
      );
      debugPrint('✓ Admin account created: admin@flixfilm.com / admin123');
    }
  } catch (e) {
    debugPrint('⚠ Admin creation skipped: $e');
    debugPrint('You can still use the app with hardcoded movie data');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlixFilm",
      theme: ThemeData.dark(),
      home: LoginScreen(),
      routes: {
        '/landing': (_) => const LandingScreen(),
        '/search': (_) => const SearchScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/landing' && settings.arguments is User) {
          return MaterialPageRoute(
            builder: (_) => LandingScreen(user: settings.arguments as User),
          );
        }
        if (settings.name == '/search' && settings.arguments is User) {
          return MaterialPageRoute(
            builder: (_) => SearchScreen(user: settings.arguments as User),
          );
        }
        return null;
      },
    );
  }
}