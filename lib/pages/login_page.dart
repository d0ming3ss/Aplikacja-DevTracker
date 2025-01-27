import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_inz/pages/admin_dashboard.dart';
import 'package:flutter_application_inz/pages/manager_dashboard.dart';
import 'package:flutter_application_inz/pages/programmer_dashboard.dart';
import 'package:flutter_application_inz/pages/welcome_screen.dart';
import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:http/http.dart';

class LoginPage extends StatefulWidget {
  final CookieJar cookieJar; // Dodaj parametr do konstrukcji

  const LoginPage({Key? key, required this.cookieJar}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      const String apiUrl = 'http://localhost:8080/auth/login';

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        Response response = await post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
          }),
        );

        // Sprawdzenie statusu odpowiedzi i ciasteczek
        if (response.statusCode == 200) {
          var cookies = response.headers['set-cookie'];
          if (cookies != null) {
            widget.cookieJar.saveFromResponse(
                Uri.parse(apiUrl), [Cookie.fromSetCookieValue(cookies)]);
          }

          var responseData = jsonDecode(response.body);
          print('Response data: $responseData'); // Logowanie odpowiedzi

          // Obsługa przypadku, gdy role są listą
          List<dynamic> roles = responseData['roles'] ?? [];
          print('User roles: $roles'); // Logowanie ról użytkownika

          if (roles.isEmpty) {
            _showSnackBar(context, 'Nieznana rola użytkownika.', Colors.red);
            return;
          }

          // Sprawdzanie ról użytkownika i przekierowanie na odpowiedni dashboard
          if (roles.contains('Administrator')) {
            print('Navigating to AdminHomePage');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminHomePage(
                    cookieJar: widget.cookieJar), // Przekaż cookieJar
              ),
            );
          } else if (roles.contains('Manager')) {
            print('Navigating to ManagerHomePage');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ManagerHomePage(
                    cookieJar: widget.cookieJar), // Przekaż cookieJar
              ),
            );
          } else if (roles.contains('Programista')) {
            print('Navigating to ProgHomePage');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProgHomePage(
                    cookieJar: widget.cookieJar), // Przekaż cookieJar
              ),
            );
          } else {
            _showSnackBar(context, 'Nieznana rola użytkownika.', Colors.red);
          }
        } else {
          print('Błąd logowania: ${response.statusCode}');
          _showSnackBar(context, 'Logowanie nie powiodło się. Spróbuj ponownie',
              Colors.red);
        }
      } catch (e) {
        print('Błąd podczas logowania: $e');
        _showSnackBar(context, 'Wystąpił błąd. Spróbuj ponownie.', Colors.red);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                SizedBox(
                  height: 150.0,
                  child: Center(
                    child: Image.asset('images/user.png'),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 300.0,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-mail nie może być pusty';
                      } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Wprowadź poprawny adres e-mail';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 300.0,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Hasło',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hasło nie może być puste';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text(
                    'Zaloguj',
                    style: TextStyle(
                      fontFamily: 'Inspiration',
                      color: Color.fromARGB(255, 243, 104, 40),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => welcomeScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Nie masz konta?\n Zarejestruj się!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inspiration',
                      color: Color.fromARGB(255, 243, 104, 40),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
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
