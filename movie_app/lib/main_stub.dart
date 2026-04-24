// Phiên bản không dùng Firebase - Dùng để test UI trên Windows/Chrome
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/search_screen.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
