// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:onlyu_cafe/admin/admin_menu.dart'; // Import the AdminMenuPage
import 'package:onlyu_cafe/product_management/add_menu_item.dart';
import 'package:onlyu_cafe/admin/admin_category.dart';

class AdminSettingPage extends StatelessWidget {
  const AdminSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            ListTile(
              title: Text('All Categories'),
              leading: Icon(Icons.category),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminCategoryPage(),
                ),
              ),
            ),
            ListTile(
              title: Text('Add New Item'),
              leading: Icon(Icons.add),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddMenuItemPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
