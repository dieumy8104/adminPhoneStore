import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  static String routeName = '/';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSee = true;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  Future signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email and password.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
      if(mounted){
        Navigator.pushReplacementNamed(context, '/home_page');
      } else {
        _showErrorDialog('Failed to navigate to home page.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
      }

      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

   
  @override
  Widget build(BuildContext context) { 
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoginForm(
                inputController: _emailController,
                hintText: 'Email',
                message: "Enter your email",
                prefix: const Icon(Icons.account_circle_sharp),
              ),
              const SizedBox(
                height: 15,
              ),
              LoginForm(
                inputController: _passController,
                hintText: 'Password',
                message: 'Enter your password',
                suffix: IconButton(
                  icon: isSee
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.remove_red_eye),
                  onPressed: () {
                    setState(
                      () {
                        isSee = !isSee;
                      },
                    );
                  },
                ),
                prefix: const Icon(Icons.lock),
                obscureText: isSee,
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity, 
                child: ElevatedButton(
                  onPressed: () {
                    signIn(); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 211, 88, 123),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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

// ignore: must_be_immutable
class LoginForm extends StatelessWidget {
  TextEditingController inputController;

  String hintText;
  String message;
  IconButton? suffix;
  Icon? prefix;
  bool? readOnly;
  bool? obscureText;
  LoginForm({
    super.key,
    required this.inputController,
    required this.hintText,
    required this.message,
    this.readOnly,
    this.suffix,
    this.prefix,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          obscureText: obscureText ?? false,
          obscuringCharacter: '*',
          readOnly: readOnly ?? false,
          controller: inputController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return message;
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: prefix,
            suffixIcon: suffix,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                  color: Color.fromARGB(255, 135, 135, 135), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                  color: Color.fromARGB(255, 109, 109, 109), width: 2),
            ),
            hintText: hintText,
            hintStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
