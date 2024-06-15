import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyu_cafe/home.dart';
import 'package:onlyu_cafe/product_management/menu.dart';
import 'package:onlyu_cafe/service/cart_service.dart';
import 'package:onlyu_cafe/service/notification.dart';
import 'package:onlyu_cafe/user_management/firebase_options.dart';
import 'package:onlyu_cafe/user_management/login.dart';
import 'package:onlyu_cafe/user_management/profile.dart';
import 'package:onlyu_cafe/router/router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;

// import 'package:onlyu_cafe/service/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = goRouter();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // routerConfig: goRouter,
      title: 'Only U Cafe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 248, 240, 238),
        ),
        useMaterial3: true,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  // String _orderType = '';
  int _itemQuantity = 0;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _cartStream;

  @override
  void initState() {
    super.initState();
    _fetchCartQuantity();
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2 && !isAuthenticated()) {
        context.go("/login");
      }
      _selectedIndex = index;
    });
  }

  void _navigateToMenu(String orderType) {
    setState(() {
      _selectedIndex = 1; // Switch to the Menu tab
      // _orderType = orderType; // Set the order type
    });
  }

  Future<void> _fetchCartQuantity() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CartService cartService = CartService();
      _cartStream = cartService.getCartStream();
      _cartStream.listen((docSnapshot) {
        if (docSnapshot.exists && docSnapshot.data() != null) {
          Map<String, dynamic> data = docSnapshot.data()!;
          List<dynamic> cartList = data['cartList'];

          int totalQuantity = 0;

          for (var item in cartList) {
            totalQuantity += (item['quantity'] as num).toInt();
          }

          setState(() {
            _itemQuantity = totalQuantity;
          });
        } else {
          setState(() {
            _itemQuantity = 0;
          });
        }
      });
    }
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
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              if (!isAuthenticated()) {
                context.go("/login");
              } else {
                context.push("/cart");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 229, 202, 195),
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0)),
            ),
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(top: -10, end: -10),
              badgeContent: Text(
                '$_itemQuantity',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(onButtonPressed: _navigateToMenu),
          MenuPage(), //orderType: _orderType),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.menu_book), label: "Menu"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
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
