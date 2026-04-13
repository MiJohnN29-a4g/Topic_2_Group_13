import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flixfilm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';

    // Bảng users
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType,
        password $textType,
        createdAt $textType,
        membershipType $textTypeNullable,
        membershipExpiry $textTypeNullable,
        isActive $intType DEFAULT 0,
        role $textType DEFAULT 'user'
      )
    ''');

    // Bảng purchase history
    await db.execute('''
      CREATE TABLE purchases (
        id $idType,
        userId $intType,
        packageType $textType,
        purchaseDate $textType,
        expiryDate $textType,
        amount $textType,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // --- User Operations ---

  Future<User?> createUser(User user) async {
    final db = await database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  /// Tạo admin account mặc định
  Future<User?> createAdmin({
    required String email,
    required String password,
  }) async {
    final existingAdmin = await getUserByEmail(email);
    if (existingAdmin != null) {
      return null; // Admin đã tồn tại
    }

    final admin = User(
      email: email,
      password: password,
      createdAt: DateTime.now().toString(),
      role: 'admin',
      isActive: true,
    );

    final db = await database;
    final id = await db.insert('users', admin.toMap());
    return admin.copyWith(id: id);
  }

  /// Kiểm tra admin có tồn tại chưa
  Future<bool> adminExists() async {
    final db = await database;
    final result = await db.query(
      'users',
      where: "role = 'admin'",
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Lấy tất cả admin
  Future<List<User>> getAllAdmins() async {
    final db = await database;
    final result = await db.query(
      'users',
      where: "role = 'admin'",
    );
    return result.map((json) => User.fromMap(json)).toList();
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> activateMembership({
    required int userId,
    required String packageType,
    required DateTime expiryDate,
  }) async {
    final db = await database;

    // Update user
    await db.update(
      'users',
      {
        'membershipType': packageType,
        'membershipExpiry': expiryDate.toIso8601String(),
        'isActive': 1,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    // Insert purchase record
    return db.insert('purchases', {
      'userId': userId,
      'packageType': packageType,
      'purchaseDate': DateTime.now().toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'amount': packageType == 'monthly' ? '74000' : '740000',
    });
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'createdAt DESC');
    return result.map((json) => User.fromMap(json)).toList();
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Purchase Operations ---

  Future<List<Map<String, dynamic>>> getUserPurchases(int userId) async {
    final db = await database;
    return await db.query(
      'purchases',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'purchaseDate DESC',
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
