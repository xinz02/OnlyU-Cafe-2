import 'package:flutter/material.dart';
import 'package:onlyu_cafe/admin/admin_menu.dart'; // Import the AdminMenuPage
import 'package:onlyu_cafe/product_management/add_menu_item.dart';
import 'package:onlyu_cafe/admin/admin_userList.dart'; // Import AdminUsersPage

class AdminSettingPage extends StatelessWidget {
  const AdminSettingPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            ListTile(
              title: Text('All Users'),
              leading: Icon(Icons.person),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminUsersPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}