import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;
  bool isPasswordVisible = false; // Biến để quản lý trạng thái hiện/ẩn mật khẩu

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Войти"), // "Đăng nhập" => "Войти"
        backgroundColor: const Color(0xFFFF2442), // Màu đỏ
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white, // Nền trắng
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Center(
                child: Text(
                  "Добро пожаловать!", // "Chào mừng bạn!" => "Добро пожаловать!"
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF2442), // Màu đỏ
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Color(0xFFFF2442)),
                  border: OutlineInputBorder(),
                  labelText: "Электронная почта", // "Email" => "Электронная почта"
                  hintText: "Введите ваш email", // "Nhập email của bạn" => "Введите ваш email"
                ),
                validator: ValidationBuilder()
                    .email("Неверный формат электронной почты") // Thông báo lỗi email không hợp lệ
                    .maxLength(50, "Максимум 50 символов") // Email tối đa 50 ký tự
                    .build(),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                obscureText: !isPasswordVisible, // Hiển thị hoặc ẩn mật khẩu
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFFF2442)),
                  border: const OutlineInputBorder(),
                  labelText: "Пароль", // "Mật khẩu" => "Пароль"
                  hintText: "Введите ваш пароль", // "Nhập mật khẩu của bạn" => "Введите ваш пароль"
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFFFF2442),
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible; // Đổi trạng thái
                      });
                    },
                  ),
                ),
                validator: ValidationBuilder()
                    .minLength(8, "Минимум 8 символов") // Mật khẩu tối thiểu 8 ký tự
                    .maxLength(30, "Максимум 30 символов") // Mật khẩu tối đa 30 ký tự
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
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email!,
                        password: password!,
                      );

                      // Hiển thị thông báo thành công
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Вы успешно вошли!")), // "Bạn đã đăng nhập thành công!" => "Вы успешно вошли!"
                      );

                      // Chuyển đến màn hình chính (home)
                      Navigator.pushReplacementNamed(context, '/home');
                    } on FirebaseAuthException catch (e) {
                      String errorMessage;
                      if (e.code == 'wrong-password') {
                        errorMessage = "Неверный пароль!"; // "Sai mật khẩu!" => "Неверный пароль!"
                      } else if (e.code == 'user-not-found') {
                        errorMessage = "Пользователь не найден!"; // "Không tìm thấy người dùng!" => "Пользователь не найден!"
                      } else {
                        errorMessage = "Ошибка: ${e.message}"; // "Lỗi: " => "Ошибка: "
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
                  backgroundColor: const Color(0xFFFF2442), // Màu đỏ
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Войти", // "Đăng nhập" => "Войти"
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup'); // Điều hướng sang trang đăng ký
                },
                child: const Text(
                  "У вас нет аккаунта? Зарегистрироваться", // "Bạn chưa có tài khoản? Đăng ký ngay" => "У вас нет аккаунта? Зарегистрироваться"
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Color(0xFFFF2442),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
