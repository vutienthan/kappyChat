import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String? username;
  String? email;
  String? password;

  bool _isPasswordVisible = false; // Biến để quản lý trạng thái hiển thị mật khẩu
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Регистрация"), // "Đăng ký" => "Регистрация"
        backgroundColor: const Color(0xFFBAA378), // Màu nâu nhạt
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF5EFE6), // Nền màu be nhạt
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Center(
                child: Text(
                  "Создать учетную запись", // "Đăng ký tài khoản" => "Создать учетную запись"
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBAA378), // Màu nâu nhạt
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Color(0xFFBAA378)),
                  border: OutlineInputBorder(),
                  labelText: "Имя пользователя", // "Tên người dùng" => "Имя пользователя"
                  hintText: "Введите имя пользователя", // "Nhập tên người dùng" => "Введите имя пользователя"
                ),
                validator: ValidationBuilder()
                    .minLength(6, "Минимум 6 символов")
                    .maxLength(20, "Максимум 20 символов")
                    .build(),
                onChanged: (value) {
                  username = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Color(0xFFBAA378)),
                  border: OutlineInputBorder(),
                  labelText: "Электронная почта", // "Email" => "Электронная почта"
                  hintText: "Введите электронную почту", // "Nhập email" => "Введите электронную почту"
                ),
                validator: ValidationBuilder()
                    .email("Неверный формат электронной почты")
                    .maxLength(50, "Максимум 50 символов")
                    .build(),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                obscureText: !_isPasswordVisible, // Điều chỉnh hiển thị mật khẩu
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFBAA378)),
                  border: const OutlineInputBorder(),
                  labelText: "Пароль", // "Mật khẩu" => "Пароль"
                  hintText: "Введите пароль", // "Nhập mật khẩu" => "Введите пароль"
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFFBAA378),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible; // Thay đổi trạng thái hiển thị mật khẩu
                      });
                    },
                  ),
                ),
                validator: ValidationBuilder()
                    .minLength(8, "Минимум 8 символов")
                    .maxLength(30, "Максимум 30 символов")
                    .build(),
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email!,
                        password: password!,
                      );

                      // Hiển thị thông báo thành công
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Регистрация успешна!")), // "Đăng ký thành công!" => "Регистрация успешна!"
                      );

                      // Điều hướng về trang đăng nhập sau khi đăng ký thành công
                      Navigator.pushReplacementNamed(context, '/login');
                    } on FirebaseAuthException catch (e) {
                      String errorMessage;
                      if (e.code == 'weak-password') {
                        errorMessage = "Пароль слишком слабый!"; // "Mật khẩu quá yếu!" => "Пароль слишком слабый!"
                      } else if (e.code == 'email-already-in-use') {
                        errorMessage = "Эта электронная почта уже используется!"; // "Email đã được sử dụng!" => "Эта электронная почта уже используется!"
                      } else {
                        errorMessage = "Неизвестная ошибка: ${e.message}"; // "Lỗi không xác định" => "Неизвестная ошибка"
                      }

                      // Hiển thị lỗi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    } catch (e) {
                      // Xử lý các lỗi không mong muốn
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Произошла ошибка!")), // "Đã xảy ra lỗi!" => "Произошла ошибка!"
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBAA378), // Màu nâu nhạt
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Зарегистрироваться", // "Đăng ký" => "Зарегистрироваться"
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
