// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyu_cafe/cart/cart.dart';
import 'package:onlyu_cafe/home.dart';
import 'package:onlyu_cafe/main.dart';
import 'package:onlyu_cafe/order/checkout.dart';
import 'package:onlyu_cafe/order/orderhistory.dart';
import 'package:onlyu_cafe/product_management/menu.dart';
import 'package:onlyu_cafe/user_management/login.dart';
import 'package:onlyu_cafe/user_management/profile.dart';
import 'package:onlyu_cafe/user_management/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyu_cafe/admin/admin_main.dart';

bool isAuthenticated() {
  // Check if there's a user logged in
  return FirebaseAuth.instance.currentUser != null;
}

// GoRouter goRouter() {
//   return GoRouter(initialLocation: '/main', routes: [
//     GoRoute(
//         path: '/main',
//         builder: ((context, state) => const NavigationBarExample())),
//     GoRoute(path: '/menu', builder: ((context, state) => const MenuPage())),
//     GoRoute(path: '/profile', builder: ((context, state) => ProfilePage())),
//     GoRoute(path: '/cart', builder: ((context, state) => const CartPage())),
//     GoRoute(path: '/signup', builder: ((context, state) => const SignUp())),
//     GoRoute(path: '/home', builder: ((context, state) => const HomePage())),
//   ]);
// }

// final goRouter = GoRouter(
//   initialLocation: '/home',
//   routes: [
//     GoRoute(
//       path: '/signup',
//       builder: (context, state) => const SignUp(),
//     ),
//     GoRoute(
//       path: '/login',
//       builder: (context, state) => const Login(),
//     ),
//     ShellRoute(
//       navigatorKey: GlobalKey<
//           NavigatorState>(), // Optional, for handling nested navigation
//       builder: (context, state, child) {
//         return MyShell(child: child); // Use the shell layout
//       },
//       routes: [
//         GoRoute(
//           path: '/home',
//           builder: (context, state) =>
//               const HomePage(), // Define the Home screen
//         ),
//         GoRoute(
//           path: '/menu',
//           builder: (context, state) =>
//               const MenuPage(), // Define the Search screen
//         ),
//         GoRoute(
//           path: '/profile',
//           builder: (context, state) =>
//               isAuthenticated() ? const ProfilePage() : const Login(),
//           redirect: (context, state) {
//             // Check if user is authenticated
//             if (!isAuthenticated()) {
//               return '/login';
//             }
//             return null;
//           },
//         ),
//       ],
//     ),
//   ],
// );

Future<String> _getUserRole() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = _auth.currentUser;

  String role = 'user'; // Default role

  if (user != null) {
    final DocumentSnapshot userData =
        await _firestore.collection('User').doc(user.uid).get();
    if (userData.exists) {
      role = userData.get('role');
    }
  }

  return role;
}

GoRouter goRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        // builder: (context, state) //=> MainPage(),
        //     {
        //   String role = _getUserRole() as String;
        //   print("user role " + role);
        //   if (_getUserRole() == 'admin') {
        //     print("Redirecting to admin pg");
        //     return AdminMainPage();
        //   } else if (_getUserRole() == 'user') {
        //     print("Redirecting to user pg");
        //     return MainPage();
        //   } else {
        //     return MainPage();
        //   }
        // }),
        builder: (context, state) => FutureBuilder<String>(
          future: _getUserRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for the role, show a loading spinner or similar
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Handle error, maybe return an error page
              return const Center(child: Text('Error fetching role'));
            } else if (snapshot.hasData) {
              String role = snapshot.data!;
              print("User role: $role");

              if (role == 'admin') {
                print("Redirecting to admin page");
                return AdminMainPage();
              } else if (role == 'user') {
                print("Redirecting to user page");
                return MainPage();
              } else {
                return MainPage(); // Default to MainPage if role is not recognized
              }
            } else {
              // Default case if no data or any other issues
              return MainPage();
            }
          },
        ),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => MainPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminMainPage(),
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const MenuPage(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => CartPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUp(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => CheckOutPage(),
      ),
      GoRoute(
        path: '/orderhistory',
        builder: (context, state) => OrderHistoryPage(),
      ),
      //   GoRoute(
      //   path: '/order_details',
      //   builder: (context, state) => OrderDetailsPage(order: state.extra['order']),
      // ),
      // GoRoute(
      //   path: '/home/:tab',
      //   builder: (context, state) {
      //     String tabStr = state.pathParameters['tab'] ?? '0';
      //     int tabIndex = int.parse(tabStr);
      //     return MainPage(
      //       tab: tabIndex,
      //     );
      //   },
      // ),
    ],
  );
}
