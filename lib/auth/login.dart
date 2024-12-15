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

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Войти"),
        backgroundColor: const Color(0xFFFF2442), // Цвет заголовка
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white, // Белый фон
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Center(
                child: Text(
                  "Добро пожаловать!",
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF2442),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Color(0xFFFF2442)),
                  border: OutlineInputBorder(),
                  labelText: "Электронная почта",
                  hintText: "Введите ваш email",
                ),
                validator: ValidationBuilder().email().maxLength(50).build(),
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
                  labelText: "Пароль",
                  hintText: "Введите ваш пароль",
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
                validator: ValidationBuilder().minLength(8).maxLength(30).build(),
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
                        const SnackBar(content: Text("Вы успешно вошли!")),
                      );

                      // Chuyển đến màn hình chính (home)
                      Navigator.pushReplacementNamed(context, '/home');
                    } on FirebaseAuthException catch (e) {
                      String errorMessage;
                      if (e.code == 'wrong-password') {
                        errorMessage = "Неверный пароль!";
                      } else if (e.code == 'user-not-found') {
                        errorMessage = "Пользователь не найден!";
                      } else {
                        errorMessage = "Ошибка: ${e.message}";
                      }

                      // Hiển thị lỗi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    } catch (e) {
                      // Xử lý các lỗi không mong muốn
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Произошла ошибка!")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2442), // Цвет кнопки
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Войти",
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
