import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserRepository {
  FirebaseFirestore? _firestore;
  firebase_auth.FirebaseAuth? _auth;
  bool _isAvailable = false;

  final String _usersCollection = 'users';
  final String _purchasesCollection = 'purchases';

  UserRepository() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _auth = firebase_auth.FirebaseAuth.instance;
        _isAvailable = true;
      }
    } catch (e) {
      _firestore = null;
      _auth = null;
      _isAvailable = false;
    }
  }

  /// Collection reference
  CollectionReference? get _usersRef => _firestore?.collection(_usersCollection);
  CollectionReference? get _purchasesRef => _firestore?.collection(_purchasesCollection);

  /// User ID hiện tại
  String? get currentUserId => _auth?.currentUser?.uid;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isLoggedIn => _auth?.currentUser != null;

  // ==================== AUTH OPERATIONS ====================

  /// Kiểm tra Firebase có sẵn không
  bool get isAvailable => _isAvailable && _firestore != null && _auth != null;

  /// Đăng ký với email/password
  Future<User?> register({
    required String email,
    required String password,
    String? name,
  }) async {
    if (!isAvailable) {
      throw Exception('Firebase không khả dụng. Vui lòng kiểm tra kết nối.');
    }
    try {
      // Tạo tài khoản Firebase Auth
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo document trong Firestore
      final user = User(
        id: credential.user!.uid,
        email: email,
        name: name,
        password: password,
        createdAt: DateTime.now().toIso8601String(),
        role: 'user',
        isActive: true,
      );

      await _usersRef!.doc(credential.user!.uid).set(user.toMap());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  /// Đăng nhập với email/password
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) {
      throw Exception('Firebase không khả dụng. Vui lòng kiểm tra kết nối.');
    }
    try {
      // Đăng nhập Firebase Auth
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin user từ Firestore
      final doc = await _usersRef!.doc(credential.user!.uid).get();

      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }

      // Nếu không có trong Firestore, tạo mới
      final user = User(
        id: credential.user!.uid,
        email: email,
        password: password,
        createdAt: DateTime.now().toIso8601String(),
        role: 'user',
        isActive: true,
      );

      await _usersRef!.doc(credential.user!.uid).set(user.toMap());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    if (isAvailable) {
      await _auth!.signOut();
    }
  }

  /// Xử lý lỗi Firebase Auth
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu (ít nhất 6 ký tự)';
      case 'email-already-in-use':
        return 'Email đã được đăng ký';
      case 'user-not-found':
        return 'Email không tồn tại';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản đã bị khóa';
      case 'too-many-requests':
        return 'Quá nhiều lần thử, vui lòng đợi';
      default:
        return 'Lỗi: ${e.message}';
    }
  }

  // ==================== ADMIN OPERATIONS ====================

  /// Tạo admin account
  Future<User?> createAdmin({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) {
      debugPrint('Firebase không khả dụng, bỏ qua tạo admin');
      return null;
    }
    // Kiểm tra admin đã tồn tại
    final existingAdmin = await _getAdminByEmail(email);
    if (existingAdmin != null) {
      return null;
    }

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final admin = User(
        id: credential.user!.uid,
        email: email,
        password: password,
        createdAt: DateTime.now().toIso8601String(),
        role: 'admin',
        isActive: true,
      );

      await _usersRef!.doc(credential.user!.uid).set(admin.toMap());

      return admin;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  /// Kiểm tra admin có tồn tại
  Future<bool> adminExists() async {
    if (!isAvailable) return false;
    try {
      final snapshot = await _usersRef!
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Lấy admin theo email
  Future<User?> _getAdminByEmail(String email) async {
    if (!isAvailable) return null;
    try {
      final snapshot = await _usersRef!
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return User.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Lấy tất cả admin
  Future<List<User>> getAllAdmins() async {
    if (!isAvailable) return [];
    final snapshot = await _usersRef!
        .where('role', isEqualTo: 'admin')
        .get();

    return snapshot.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ==================== USER OPERATIONS ====================

  /// Lấy user theo ID
  Future<User?> getUserById(String id) async {
    if (!isAvailable) return null;
    final doc = await _usersRef!.doc(id).get();

    if (doc.exists) {
      return User.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  /// Lấy user theo email
  Future<User?> getUserByEmail(String email) async {
    if (!isAvailable) return null;
    final snapshot = await _usersRef!
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return User.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  /// Cập nhật user
  Future<void> updateUser(User user) async {
    if (!isAvailable) return;
    await _usersRef!.doc(user.id).update(user.toMap());
  }

  /// Xóa user
  Future<void> deleteUser(String id) async {
    if (!isAvailable) return;
    await _usersRef!.doc(id).delete();
  }

  /// Lấy tất cả user
  Stream<List<User>> getAllUsersStream() {
    if (!isAvailable) return Stream.value([]);
    return _usersRef!
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<User>> getAllUsers() async {
    if (!isAvailable) return [];
    final snapshot = await _usersRef!
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ==================== MEMBERSHIP OPERATIONS ====================

  /// Kích hoạt membership
  Future<void> activateMembership({
    required String userId,
    required String packageType,
    required DateTime expiryDate,
    required double amount,
  }) async {
    if (!isAvailable) return;
    final batch = _firestore!.batch();

    // Update user
    final userRef = _usersRef!.doc(userId);
    batch.update(userRef, {
      'membershipType': packageType,
      'membershipExpiry': expiryDate.toIso8601String(),
      'isActive': true,
    });

    // Insert purchase record
    final purchaseRef = _purchasesRef!.doc();
    batch.set(purchaseRef, {
      'userId': userId,
      'packageType': packageType,
      'purchaseDate': DateTime.now().toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'amount': amount,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Lấy lịch sử purchase của user
  Future<List<Map<String, dynamic>>> getUserPurchases(String userId) async {
    if (!isAvailable) return [];
    final snapshot = await _purchasesRef!
        .where('userId', isEqualTo: userId)
        .orderBy('purchaseDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  /// Stream lịch sử purchase
  Stream<List<Map<String, dynamic>>> getUserPurchasesStream(String userId) {
    if (!isAvailable) return Stream.value([]);
    return _purchasesRef!
        .where('userId', isEqualTo: userId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  // ==================== STREAM OPERATIONS ====================

  /// Stream user hiện tại
  Stream<User?> get currentUserStream {
    if (!isAvailable) return Stream.value(null);
    return _auth!.authStateChanges().asyncMap((authUser) async {
      if (authUser == null) return null;

      final doc = await _usersRef!.doc(authUser.uid).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}
