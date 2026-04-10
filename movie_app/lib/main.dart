import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/login_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo sqflite_ffi cho Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Tạo admin mặc định nếu chưa tồn tại
  final dbHelper = DatabaseHelper.instance;
  final adminExists = await dbHelper.adminExists();
  if (!adminExists) {
    await dbHelper.createAdmin(
      email: 'admin@flixfilm.com',
      password: 'admin123',
    );
    debugPrint('✓ Admin account created: admin@flixfilm.com / admin123');
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
    );
  }
}
