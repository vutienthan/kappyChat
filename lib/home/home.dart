import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  String currentMenu = "Home"; // Mục menu hiện tại

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // Lấy thông tin người dùng
  }

  // Danh sách các nội dung ứng với các mục menu
  Widget _buildContent() {
    switch (currentMenu) {
      case "Home":
        return _homeContent();
      case "Friends":
        return _friendsContent();
      case "Community":
        return _communityContent();
      default:
        return const Center(child: Text("Ошибка: Неизвестное меню!"));
    }
  }

  Widget _homeContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Добро пожаловать в приложение!", // Chào mừng người dùng
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            "Здравствуйте, ${user?.displayName ?? 'Пользователь CapyBara'}!",
            style: const TextStyle(fontSize: 18, color: Color(0xFF555555)),
          ),
          Text(
            "Email: ${user?.email ?? 'Не указано'}",
            style: const TextStyle(fontSize: 16, color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }

  Widget _friendsContent() {
    return const Center(
      child: Text(
        "Ваши друзья появятся здесь.", // "Bạn bè của bạn sẽ xuất hiện ở đây."
        style: TextStyle(fontSize: 18, color: Color(0xFF333333)),
      ),
    );
  }

  Widget _communityContent() {
    return const Center(
      child: Text(
        "Сообщество: Добро пожаловать в открытую сеть!", // "Cộng đồng: Chào mừng đến với mạng xã hội mở!"
        style: TextStyle(fontSize: 18, color: Color(0xFF333333)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const LoginPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentMenu), // Tiêu đề thay đổi theo menu
        backgroundColor: const Color(0xFFA67C52),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFF8F4E3), // Màu nền Drawer giống Discord
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFFA67C52), // Header màu capybara
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Color(0xFFA67C52)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.displayName ?? "Пользователь CapyBara", // Tên người dùng
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? "Email: Не указано", // Email người dùng
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Color(0xFFA67C52)),
                title: const Text("Главная", style: TextStyle(color: Colors.black)),
                onTap: () {
                  setState(() {
                    currentMenu = "Home";
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Color(0xFFA67C52)),
                title: const Text("Друзья", style: TextStyle(color: Colors.black)),
                onTap: () {
                  setState(() {
                    currentMenu = "Friends";
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.public, color: Color(0xFFA67C52)),
                title: const Text("Сообщество", style: TextStyle(color: Colors.black)),
                onTap: () {
                  setState(() {
                    currentMenu = "Community";
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Color(0xFFA67C52)),
                title: const Text("Выйти", style: TextStyle(color: Colors.black)),
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
      body: _buildContent(),
    );
  }
}
