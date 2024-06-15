import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyu_cafe/main.dart';
import 'package:onlyu_cafe/order/orderdetails.dart';
import 'package:onlyu_cafe/router/router.dart';
import 'package:onlyu_cafe/service/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyu_cafe/service/notification.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _username = '';
  String _email = '';
  String _phoneNum = '';
  List<DocumentSnapshot> _orders = [];

  @override
  void initState() {
    super.initState();
    if (isAuthenticated()) {
      _getUserData();
      // _getUserOrders();
    }
  }

  Future<void> _getUserData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final DocumentSnapshot userData =
          await _firestore.collection('User').doc(user.uid).get();

      if (userData.exists) {
        final String name = userData.get('name');
        final String email = userData.get('email');
        final String phoneNum = userData.get('phoneNumber') ?? '';
        if (mounted) {
          setState(() {
            _username = name;
            _email = email;
            _phoneNum = phoneNum;
          });
        }
      } else {
        print('User data not found');
      }
    } else {
      if (mounted) {
        setState(() {
          _username = 'guest';
          _email = 'guest@gmail.com';
          _phoneNum = '0123456789';
        });
      }
      print('User not logged in');
    }
  }

  // Future<void> _getUserOrders() async {
  //   final User? user = _auth.currentUser;

  //   if (user != null) {
  //     try {
  //       final QuerySnapshot ordersSnapshot = await _firestore
  //           .collection('orders')
  //           .where('userId', isEqualTo: user.uid)
  //           .orderBy('timestamp', descending: true)
  //           .get();

  //       if (mounted) {
  //         setState(() {
  //           _orders = ordersSnapshot.docs;
  //         });
  //       }
  //     } catch (error) {
  //       print('Failed to get orders: $error');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          if (currentUser!.photoURL != null)
            Image.network(
              currentUser!.photoURL!,
              width: 72,
              height: 72,
            )
          else
            const Icon(
              Icons.person,
              size: 72,
            ),

          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Text(
                  'Personal Details',
                  style: TextStyle(
                      color: Color(0xFF4B371C), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          MyTextBox(
            text: _username,
            sectionName: 'Name',
            editable: false,
          ),

          const SizedBox(height: 10),
          MyTextBox(
            text: _email,
            sectionName: 'Email',
            editable: false,
          ),

          const SizedBox(height: 10),
          MyTextBox(
            text: _phoneNum,
            sectionName: 'Phone',
            editable: true,
            onPressed: () => _editPhone(context),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: TextButton(
                onPressed: () {
                  context.push("/orderhistory");
                },
                style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    // maximumSize: Size(150, 75),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20)),
                child: const Text("View Order History")),
          ),
          const SizedBox(
            height: 15,
          ),
          _auth.currentUser != null
              ? Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        //!
                        final user = _auth.currentUser;
                        if (user != null) {
                          await NotificationService()
                              .setDeviceTokenToNull(user.uid);
                          await AuthMethods().signOut();
                        }
                        runApp(const MyApp());
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                )
              : Container(),

          //     const SizedBox(height: 20),
          //     const Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 20),
          //       child: Text(
          //         'My Orders',
          //         style: TextStyle(
          //           color: Color(0xFF4B371C),
          //           fontWeight: FontWeight.bold,
          //           fontSize: 20,
          //         ),
          //       ),
          //     ),
          //     const SizedBox(height: 10),

          //     // Display orders
          //     _orders.isEmpty
          //         ? const Center(child: Text("No orders found"))
          //         : ListView.builder(
          //             shrinkWrap: true,
          //             physics: const NeverScrollableScrollPhysics(),
          //             itemCount: _orders.length,
          //             itemBuilder: (context, index) {
          //               final order = _orders[index];
          //               return ListTile(
          //                 title: Text('Order ID: ${order.id}'),
          //                 subtitle: Text(
          //                     'Date Placed: ${order['timestamp'].toDate().toString()}'),
          //                 trailing: Text(
          //                     'Amount Paid: \$${order['totalAmount'].toStringAsFixed(2)}'),
          //                 onTap: () {
          //                   Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                       builder: (context) =>
          //                           OrderDetailsPage(order: order),
          //                     ),
          //                   );
          //                 },
          //               );
          //             },
          //           ),
        ],
      ),
    );
  }

  void _editPhone(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    String newPhone = _phoneNum;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Phone Number'),
        content: TextField(
          onChanged: (value) => newPhone = value,
          decoration: const InputDecoration(
            hintText: 'Enter new phone number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newPhone.isNotEmpty && newPhone != _phoneNum) {
                try {
                  await FirebaseFirestore.instance
                      .collection('User')
                      .doc(user.uid)
                      .update({'phoneNumber': newPhone});

                  if (mounted) {
                    setState(() {
                      _phoneNum = newPhone;
                    });
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Phone number updated successfully')),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to update phone number: $error')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final VoidCallback? onPressed;
  final bool editable;

  const MyTextBox({
    Key? key,
    required this.text,
    required this.sectionName,
    this.onPressed,
    this.editable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionName,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: TextStyle(
                  color: editable ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
          if (onPressed != null && editable)
            IconButton(
              onPressed: onPressed,
              icon: const Icon(
                Icons.edit,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
