import 'package:flutter/material.dart';
import '../data/movie_data.dart';
import 'landing_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _showLoginForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Poster grid background ──────────────────────────────
          _PosterGrid(width: size.width, height: size.height),

          // ── 2. Dark overlay ────────────────────────────────────────
          Container(color: Colors.black.withOpacity(0.60)),

          // ── 3. Top bar ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              onLogin: () => setState(() => _showLoginForm = true),
            ),
          ),

          // ── 4. Center content ──────────────────────────────────────
          Center(
            child: _showLoginForm
                ? _LoginForm(
              emailCtrl: _emailController,
              passCtrl: _passController,
              onSubmit: _goHome,
              onRegister: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen()),
              ),
              onBack: () => setState(() => _showLoginForm = false),
            )
                : _HeroContent(
              emailCtrl: _emailController,
              onStart: () {
                if (_emailController.text.trim().isEmpty) {
                  setState(() => _showLoginForm = true);
                } else {
                  _goHome();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Poster grid (lấy poster từ movie_data)
// ─────────────────────────────────────────────────────────────────────────────
class _PosterGrid extends StatelessWidget {
  final double width;
  final double height;

  const _PosterGrid({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    // Lấy tất cả poster, lặp lại nếu cần
    final posters = movies.map((m) => m.poster).toList();
    final cols = 8;
    final rows = 4;
    final total = cols * rows;
    final List<String> grid = List.generate(
      total,
          (i) => posters[i % posters.length],
    );

    final itemW = width / cols;
    final itemH = height / rows;

    return Stack(
      children: List.generate(total, (i) {
        final col = i % cols;
        final row = i ~/ cols;
        return Positioned(
          left: col * itemW,
          top: row * itemH,
          width: itemW,
          height: itemH,
          child: Image.network(
            grid[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF1A1A1A)),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top navigation bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onLogin;
  const _TopBar({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          const Text(
            'FLIXFILM',
            style: TextStyle(
              color: Colors.red,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          // Right side: language + login
          Row(
            children: [
              // Language selector
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white54),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.language, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Tiếng Việt',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Login button
              ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero content (giống trang chủ Netflix trước khi đăng nhập)
// ─────────────────────────────────────────────────────────────────────────────
class _HeroContent extends StatelessWidget {
  final TextEditingController emailCtrl;
  final VoidCallback onStart;

  const _HeroContent({required this.emailCtrl, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Phim, series không giới hạn\nvà nhiều nội dung khác',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Giá từ 74.000 đ. Hủy bất kỳ lúc nào.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Bạn đã sẵn sàng xem chưa? Nhập email để tạo hoặc kích\nhoạt lại tư cách thành viên của bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Email + button row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Địa chỉ email',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.65),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                      const BorderSide(color: Colors.white38, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                      const BorderSide(color: Colors.white38, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                      const BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                child: const Row(
                  children: [
                    Text(
                      'Bắt đầu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.chevron_right, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login form (hiện khi nhấn Đăng nhập hoặc Bắt đầu không có email)
// ─────────────────────────────────────────────────────────────────────────────
class _LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final VoidCallback onSubmit;
  final VoidCallback onRegister;
  final VoidCallback onBack;

  const _LoginForm({
    required this.emailCtrl,
    required this.passCtrl,
    required this.onSubmit,
    required this.onRegister,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.80),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đăng nhập',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),

          // Email
          _FormField(
            controller: emailCtrl,
            hint: 'Email hoặc số điện thoại',
          ),
          const SizedBox(height: 16),

          // Password
          _FormField(
            controller: passCtrl,
            hint: 'Mật khẩu',
            obscure: true,
          ),
          const SizedBox(height: 24),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Remember me + Help
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nhớ tôi',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Nhận trợ giúp',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Register
          Row(
            children: [
              const Text('Bạn chưa có tài khoản FlixFilm? ',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
              GestureDetector(
                onTap: onRegister,
                child: const Text(
                  'Đăng ký ngay.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Back
          GestureDetector(
            onTap: onBack,
            child: const Text(
              '← Quay lại',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const _FormField({
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF333333),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.white38, width: 1),
        ),
      ),
    );
  }
}