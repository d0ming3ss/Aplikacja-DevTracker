import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_inz/pages/login_page.dart';
import 'package:flutter_application_inz/pages/register_page.dart';

class welcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cookieJar = PersistCookieJar();
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.6,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 155, 67, 16),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.6,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 243, 104, 40),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(120),
                          bottomRight: Radius.circular(120))),
                  child: Center(
                    child: Image.asset(
                      'images/clipboard.png',
                      scale: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.66,
                padding: EdgeInsets.only(top: 40, bottom: 30),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 155, 67, 16),
                ),
                child: Column(
                  children: [
                    Text(
                      "DevTracker",
                      style: TextStyle(
                        fontSize: 38,
                        fontFamily: 'Inspiration',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        wordSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Nadzoruj i śledź postępty swoich projektów!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Inspiration',
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    SizedBox(height: 21.5),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LoginPage(cookieJar: cookieJar),
                              ));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 80),
                          child: Text(
                            "Zaloguj się",
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
                    ),
                    SizedBox(height: 20),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 67.5),
                          child: Text(
                            "Zarejestruj się",
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
