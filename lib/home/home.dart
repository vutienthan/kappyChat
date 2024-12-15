import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user; // Lưu trữ thông tin người dùng

  @override
  void initState() {
    super.initState();
    // Lấy thông tin người dùng hiện tại
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    // Nếu người dùng chưa đăng nhập, điều hướng đến trang đăng nhập
    if (user == null) {
      return const LoginPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Главная страница"), // Tiêu đề "Trang chính"
        backgroundColor: const Color(0xFFA67C52), // Màu capybara (nâu sáng)
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white, // Nền trắng
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFA67C52), // Màu capybara (nâu sáng)
                ),
                child: Text(
                  "Ваш аккаунт", // "Tài khoản của bạn"
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Color(0xFFA67C52)),
                title: const Text("Выйти"), // "Đăng xuất" bằng tiếng Nga
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Добро пожаловать в приложение!", // "Chào mừng bạn đến với ứng dụng!"
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Hiển thị tên và email người dùng
            Text(
              "Добро пожаловать, ${user?.displayName ?? 'Пользователь CapyBara'}!", // "Chào mừng bạn, tên người dùng!"
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              "Email: ${user?.email ?? 'Не указано'}", // "Email: email của người dùng"
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA67C52), // Màu capybara (nâu sáng)
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                "Выйти", // "Đăng xuất" bằng tiếng Nga
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
