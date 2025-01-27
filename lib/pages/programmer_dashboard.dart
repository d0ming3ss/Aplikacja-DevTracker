import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_inz/pages/date_pages.dart';
import 'package:flutter_application_inz/pages/jira_boards_page.dart';
import 'package:flutter_application_inz/pages/project_progress_page.dart';
import 'package:flutter_application_inz/pages/task_prog_page.dart';

class ProgHomePage extends StatelessWidget {
  final CookieJar cookieJar;

  const ProgHomePage({Key? key, required this.cookieJar}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 243, 104, 40),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard,
                      size: 60,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Witaj, Programisto",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            wordSpacing: 5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.computer,
                      size: 60,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 50,
                runSpacing: 50,
                children: [
                  _buildCircularButton(context, "Zadania", Icons.task, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TaskProgPage()),
                    );
                  }),
                  _buildCircularButton(context, "Jira", Icons.bug_report, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JiraBoardsPage()),
                    );
                  }),
                  _buildCircularButton(context, "Postępy", Icons.trending_up,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProjectProgressPage()),
                    );
                  }),
                  _buildCircularButton(context, "Harmonogram", Icons.schedule,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DatePages()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 155, 67, 16),
            ),
            child: Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}
