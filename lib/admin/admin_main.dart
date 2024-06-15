import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onlyu_cafe/admin/admin_home.dart';
import 'package:onlyu_cafe/admin/admin_menu.dart';
import 'package:onlyu_cafe/admin/admin_setting.dart';
import 'package:onlyu_cafe/main.dart';
import 'package:onlyu_cafe/service/auth.dart';
import 'package:onlyu_cafe/service/notification.dart';

// class AdminMainPage extends StatefulWidget {
//   const AdminMainPage({super.key});

//   @override
//   State<AdminMainPage> createState() => AdminMainPageState();
// }

// class AdminMainPageState extends State<AdminMainPage> {
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Only U Cafe',
//           style: GoogleFonts.kaushanScript(),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color.fromARGB(255, 229, 202, 195),
//         actions: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               elevation: 0,
//               backgroundColor: const Color.fromARGB(255, 229, 202, 195),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () async {
//               //!
//               final User user = _auth.currentUser!;
//               NotificationService().setDeviceTokenToNull(user.uid);
//               await AuthMethods().signOut();
//               runApp(const MyApp());
//             },
//             child: Icon(Icons.logout),
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: const [
//           AdminHomePage(),
//           AdminMenuPage(),
//           AdminSettingPage(),
//         ],
//       ),
//       bottomNavigationBar: NavigationBar(
//         destinations: const [
//           NavigationDestination(icon: Icon(Icons.home), label: "Home"),
//           NavigationDestination(icon: Icon(Icons.menu_book), label: "Menu"),
//           NavigationDestination(icon: Icon(Icons.settings), label: "More"),
//         ],
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: _onItemTapped,
//         indicatorColor: const Color.fromARGB(255, 229, 202, 195),
//         animationDuration: const Duration(milliseconds: 1000),
//         backgroundColor: Colors.white10,
//         shadowColor: Colors.white30,
//       ),
//     );
//   }

//   void navigateToMenuPage() {
//     _onItemTapped(1);
//   }

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => AdminMainPageState();
}

class AdminMainPageState extends State<AdminMainPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToMenuPage() {
    _onItemTapped(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Only U Cafe',
          style: GoogleFonts.kaushanScript(),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 202, 195),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color.fromARGB(255, 229, 202, 195),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              //!
              final User user = _auth.currentUser!;
              NotificationService().setDeviceTokenToNull(user.uid);
              await AuthMethods().signOut();
              runApp(const MyApp());
            },
            child: Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AdminHomePage(navigateToMenuPage: navigateToMenuPage),
          const AdminMenuPage(),
          const AdminSettingPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.menu_book), label: "Menu"),
          NavigationDestination(icon: Icon(Icons.settings), label: "More"),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: const Color.fromARGB(255, 229, 202, 195),
        animationDuration: const Duration(milliseconds: 1000),
        backgroundColor: Colors.white10,
        shadowColor: Colors.white30,
      ),
    );
  }
}
