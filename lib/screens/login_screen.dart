import 'package:flutter/material.dart';
import 'package:flutter_go_chat/widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  final Function(int) loginSuccess;

  const LoginScreen({super.key, required this.loginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String startText = "Sign in";
  final _controller = TextEditingController();

  void startLogin() {
    final text = _controller.text.trim();
    // this will be action with database
    if (_controller.text.trim().isNotEmpty && RegExp(r'^\d+$').hasMatch(text)) {
      widget.loginSuccess(int.parse(text));
    } else {
      setState(() => startText = "Enter valid ID");
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Image.asset('assets/images/rabbit.png', width: 100, height: 100),
            const SizedBox(height: 15),
            Text(startText),
            const SizedBox(height: 8),
            SizedBox(
              width: 250,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: "Enter your ID"),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(width: 250, child: PasswordField()),
            const SizedBox(height: 10),
            ElevatedButton(child: Text("БУРМАЛДА"), onPressed: () => startLogin()),
          ],
        ),
      ),
    );
  }
}