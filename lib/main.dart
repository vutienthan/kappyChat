import 'package:firebase_auth/firebase_auth.dart';
import 'package:kappy_chat/views/auth/login.dart';
import 'package:kappy_chat/views/auth/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kappy_chat/views/home/home.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KappyAI',
      theme: ThemeData(
        fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFBAA378), // Màu nâu nhạt (Capybara tone)
          secondary: Color(0xFFD3C2A4), // Màu be
          background: Color(0xFFF5EFE6), // Màu nền nhẹ
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5EFE6), // Màu nền ứng dụng
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? const Signup() // Hiển thị trang đăng ký
          : const HomePage(),
    );
  }
}
