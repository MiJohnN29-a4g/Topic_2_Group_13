import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔥 BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1a0000),
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Column(
            children: [
              // 🔴 HEADER
              Padding(
                padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "FLIXFILM",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 BODY CENTER
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 400, // 👈 FIX QUAN TRỌNG
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20),
                      child: Column(
                        children: [
                          const Text(
                            "Nhập thông tin của bạn để đăng nhập",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Hoặc bắt đầu với một tài khoản mới.",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // 🔹 EMAIL
                          TextField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText:
                              "Email hoặc số điện thoại",
hintStyle: const TextStyle(
                                  color: Colors.white54),
                              filled: true,
                              fillColor: Colors.black54,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(5),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // 🔹 PASSWORD
                          TextField(
                            controller: passController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Mật khẩu",
                              hintStyle: const TextStyle(
                                  color: Colors.white54),
                              filled: true,
                              fillColor: Colors.black54,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(5),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🔴 BUTTON
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(
                                  double.infinity, 50),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const HomeScreen(),
                                ),
                              );
                            },
                            child: const Text("Tiếp tục"),
                          ),

                          const SizedBox(height: 20),

                          // 🔹 SUPPORT TEXT
                          const Text(
                            "Nhận trợ giúp",
                            style: TextStyle(
                                color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
