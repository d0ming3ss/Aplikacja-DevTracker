import 'package:flutter/material.dart';
import 'package:flutter_application_inz/pages/welcome_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _userlastnameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      const String apiUrl = 'http://localhost:8080/auth/register';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'firstName': _usernameController.text.trim(),
            'lastName': _userlastnameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  'Rejestracja zakończona sukcesem!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(Duration(milliseconds: 1800));

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => welcomeScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  'Błędne dane: ${response.statusCode} ${response.body}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Wystąpił błąd: $e',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                SizedBox(
                  height: 150.0,
                  child: Center(
                    child: Image.asset('images/register.png'),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Imię',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Imię nie może być puste';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _userlastnameController,
                  decoration: const InputDecoration(
                    labelText: 'Nazwisko',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nazwisko nie może być puste';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email nie może być pusty';
                    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Wprowadź poprawny adres email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Hasło',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hasło nie może być puste';
                    } else if (value.length < 6) {
                      return 'Hasło musi mieć co najmniej 6 znaków';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text(
                    'Zarejestruj',
                    style: TextStyle(
                      fontFamily: 'Inspiration',
                      color: Color.fromARGB(255, 243, 104, 40),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 135),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => welcomeScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Masz już konto?  Zaloguj się!',
                      style: TextStyle(
                        fontFamily: 'Inspiration',
                        color: Color.fromARGB(255, 243, 104, 40),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
