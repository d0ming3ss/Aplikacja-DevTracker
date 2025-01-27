import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  final CookieJar cookieJar = CookieJar();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/users'));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        setState(() {
          users = jsonData;
          isLoading = false;
        });
      } else {
        print(
            'Błąd: Otrzymano status ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Błąd podczas pobierania danych użytkowników: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> changeUserRole(String email, String currentRole) async {
    if (currentRole != 'Programista') {
      print('Rola może być zmieniona tylko dla Programisty');
      return;
    }

    try {
      var cookies = await cookieJar
          .loadForRequest(Uri.parse('http://localhost:8080/users'));

      final response = await http.post(
        Uri.parse('http://localhost:8080/users/change-role'),
        headers: {
          'Cookie': cookies
              .map((cookie) => '${cookie.name}=${cookie.value}')
              .join('; '),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'newRole': 'Menadżer',
        }),
      );

      if (response.statusCode == 200) {
        print("Zmieniono rolę użytkownika");
        fetchUsers();
      } else {
        print(
            "Błąd podczas zmiany roli: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Błąd podczas zmiany roli: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/users/$userId'),
      );

      if (response.statusCode == 204) {
        print("Użytkownik został usunięty");
        fetchUsers();
      } else {
        print("Błąd podczas usuwania użytkownika: ${response.statusCode}");
      }
    } catch (e) {
      print("Błąd podczas usuwania użytkownika: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista użytkowników"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final fullName = "${user['firstName']} ${user['lastName']}";
                final email = user['email'];
                final role = "${user['roles']}";
                final userId = user['id'];

                return ListTile(
                  title: Text(
                    fullName,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Rola: $role',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color.fromARGB(255, 155, 67, 16)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (role == 'Programista')
                        ElevatedButton(
                          onPressed: () {
                            changeUserRole(email, role);
                          },
                          child: Text("Zmień na Menadżera"),
                        ),
                      SizedBox(width: 10),
                      if (role != 'Administrator')
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteUser(userId);
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
