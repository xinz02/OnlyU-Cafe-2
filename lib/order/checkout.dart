// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:onlyu_cafe/model/cart_item.dart';
// // import 'package:onlyu_cafe/service/cart_service.dart';
// // import 'package:intl/intl.dart';

// // class CheckOutPage extends StatefulWidget {
// //   const CheckOutPage({Key? key}) : super(key: key);

// //   @override
// //   _CheckOutPageState createState() => _CheckOutPageState();
// // }

// // class _CheckOutPageState extends State<CheckOutPage> {
// //   final CartService _cartService = CartService();
// //   List<CartItem> _cartItems = [];
// //   bool _isLoading = true;
// //   String? _errorMessage;
// //   String _selectedOption = 'Dine In';
// //   String? _selectedTime;
// //   List<String> _timeOptions = [];
// //   String _userName = 'guest';
// //   double _totalPrice = 0.0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchCartItems();
// //     _fetchUserName();
// //     _generateTimeOptions();
// //   }

// //   Future<void> _fetchCartItems() async {
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = null;
// //     });

// //     try {
// //       List<CartItem> items = await _cartService.getCartList();
// //       double total = items.fold(0.0, (sum, item) => sum + item.menuItem.price * item.quantity);
// //       setState(() {
// //         _cartItems = items;
// //         _isLoading = false;
// //         _totalPrice = total;
// //       });
// //     } catch (error) {
// //       setState(() {
// //         _errorMessage = error.toString();
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<void> _fetchUserName() async {
// //     final FirebaseAuth _auth = FirebaseAuth.instance;
// //     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //     final User? user = _auth.currentUser;

// //     if (user != null) {
// //       final DocumentSnapshot userData =
// //           await _firestore.collection('User').doc(user.uid).get();

// //       if (userData.exists) {
// //         final String name = userData.get('name');
// //         setState(() {
// //           _userName = name;
// //         });
// //       } else {
// //         print('User data not found');
// //       }
// //     } else {
// //       setState(() {
// //         _userName = 'guest';
// //       });
// //       print('User not logged in');
// //     }
// //   }

// //   void _generateTimeOptions() {
// //     final now = DateTime.now();
// //     final int currentHour = now.hour;
// //     final int currentMinute = now.minute;

// //     DateTime startTime;
// //     if (currentHour < 10 || (currentHour == 10 && currentMinute < 30)) {
// //       startTime = DateTime(now.year, now.month, now.day, 10, 30);
// //     } else {
// //       int startHour = currentMinute > 30 ? currentHour + 1 : currentHour;
// //       int startMinute = currentMinute > 30 ? 0 : 30;
// //       startTime = DateTime(now.year, now.month, now.day, startHour, startMinute);

// //       if (startTime.isBefore(now.add(Duration(hours: 1)))) {
// //         startTime = startTime.add(Duration(minutes: 60));
// //       }
// //     }

// //     DateTime endTime = DateTime(now.year, now.month, now.day, 21, 0);
// //     while (startTime.isBefore(endTime)) {
// //       _timeOptions.add(DateFormat('HH:mm').format(startTime));
// //       startTime = startTime.add(Duration(minutes: 30));
// //     }

// //     setState(() {
// //       _timeOptions.insert(0, 'ASAP');
// //     });
// //   }

// //   void _placeOrder() {
// //     // Implement your place order logic here
// //     print('Order placed');
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Checkout'),
// //       ),
// //       body: _isLoading
// //           ? const Center(
// //               child: CircularProgressIndicator(),
// //             )
// //           : _errorMessage != null
// //               ? Center(
// //                   child: Text('Error: $_errorMessage'),
// //                 )
// //               : Column(
// //                   children: [
// //                     Padding(
// //                       padding: const EdgeInsets.all(16.0),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Name: $_userName',
// //                             style: const TextStyle(fontSize: 18),
// //                           ),
// //                           const SizedBox(height: 16),
// //                           Row(
// //                             children: [
// //                               const Text('Choose Option:'),
// //                               const SizedBox(width: 16),
// //                               DropdownButton<String>(
// //                                 value: _selectedOption,
// //                                 onChanged: (String? newValue) {
// //                                   setState(() {
// //                                     _selectedOption = newValue!;
// //                                     if (_selectedOption == 'Dine In') {
// //                                       _selectedTime = null;
// //                                     }
// //                                   });
// //                                 },
// //                                 items: <String>['Dine In', 'Pickup']
// //                                     .map<DropdownMenuItem<String>>((String value) {
// //                                   return DropdownMenuItem<String>(
// //                                     value: value,
// //                                     child: Text(value),
// //                                   );
// //                                 }).toList(),
// //                               ),
// //                             ],
// //                           ),
// //                           if (_selectedOption == 'Pickup') ...[
// //                             const SizedBox(height: 16),
// //                             const Text('Choose Pickup Time:'),
// //                             const SizedBox(height: 8),
// //                             DropdownButton<String>(
// //                               value: _selectedTime,
// //                               onChanged: (String? newValue) {
// //                                 setState(() {
// //                                   _selectedTime = newValue!;
// //                                 });
// //                               },
// //                               items: _timeOptions
// //                                   .map<DropdownMenuItem<String>>((String value) {
// //                                 return DropdownMenuItem<String>(
// //                                   value: value,
// //                                   child: Text(value),
// //                                 );
// //                               }).toList(),
// //                             ),
// //                           ],
// //                         ],
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: ListView.builder(
// //                         itemCount: _cartItems.length,
// //                         itemBuilder: (context, index) {
// //                           final cartItem = _cartItems[index];
// //                           return ListTile(
// //                             leading: Image.network(
// //                               cartItem.menuItem.imageUrl,
// //                               width: 50,
// //                               height: 50,
// //                               fit: BoxFit.cover,
// //                             ),
// //                             title: Text(cartItem.menuItem.name),
// //                             subtitle: Text(
// //                               'Price: RM${cartItem.menuItem.price.toStringAsFixed(2)}',
// //                             ),
// //                             trailing: Text('x ${cartItem.quantity}'),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                     Padding(
// //                       padding: const EdgeInsets.all(16.0),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'Total Price:',
// //                             style: TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           Text(
// //                             'RM${_totalPrice.toStringAsFixed(2)}',
// //                             style: const TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                       child: ElevatedButton(
// //                         onPressed: _placeOrder,
// //                         child: const Text('Place Order'),
// //                         style: ElevatedButton.styleFrom(
// //                           minimumSize: Size(double.infinity, 50),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 16),
// //                   ],
// //                 ),
// //     );
// //   }
// // }

// // ignore_for_file: sort_child_properties_last, prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:go_router/go_router.dart';
// import 'package:onlyu_cafe/model/cart_item.dart';
// import 'package:onlyu_cafe/order/orderdetails.dart';
// import 'package:onlyu_cafe/service/cart_service.dart';
// import 'package:intl/intl.dart';
// import 'package:onlyu_cafe/model/order.dart' as cafe;
// import 'package:onlyu_cafe/service/notification.dart';

// class CheckOutPage extends StatefulWidget {
//   const CheckOutPage({Key? key}) : super(key: key);

//   @override
//   _CheckOutPageState createState() => _CheckOutPageState();
// }

// class _CheckOutPageState extends State<CheckOutPage> {
//   final CartService _cartService = CartService();
//   List<CartItem> _cartItems = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   String _selectedOption = 'Dine In';
//   String? _selectedTime;
//   List<String> _timeOptions = [];
//   String _userName = 'guest';
//   double _totalPrice = 0.0;
//   double gst = 0.0;
//   double serviceTax = 0.0;
//   double finalAmount = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCartItems();
//     _fetchUserName();
//     _generateTimeOptions();
//   }

//   Future<void> _fetchCartItems() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       List<CartItem> items = await _cartService.getCartList();
//       double total = items.fold(
//           0.0, (sum, item) => sum + item.menuItem.price * item.quantity);
//       setState(() {
//         _cartItems = items;
//         _isLoading = false;
//         _totalPrice = total;
//         _calculateGST();
//         _calculateServiceTax();
//         _calculateFinalTotalPrice();
//       });
//     } catch (error) {
//       setState(() {
//         _errorMessage = error.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchUserName() async {
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     final User? user = _auth.currentUser;

//     if (user != null) {
//       final DocumentSnapshot userData =
//           await _firestore.collection('User').doc(user.uid).get();

//       if (userData.exists) {
//         final String name = userData.get('name');
//         setState(() {
//           _userName = name;
//         });
//       } else {
//         print('User data not found');
//       }
//     } else {
//       setState(() {
//         _userName = 'guest';
//       });
//       print('User not logged in');
//     }
//   }

//   void _generateTimeOptions() {
//     final now = DateTime.now();
//     final int currentHour = now.hour;
//     final int currentMinute = now.minute;

//     DateTime startTime;
//     if (currentHour < 10 || (currentHour == 10 && currentMinute < 30)) {
//       startTime = DateTime(now.year, now.month, now.day, 10, 30);
//     } else {
//       int startHour = currentMinute > 30 ? currentHour + 1 : currentHour;
//       int startMinute = currentMinute > 30 ? 0 : 30;
//       startTime =
//           DateTime(now.year, now.month, now.day, startHour, startMinute);

//       if (startTime.isBefore(now.add(Duration(hours: 1)))) {
//         startTime = startTime.add(Duration(minutes: 60));
//       }
//     }

//     DateTime endTime = DateTime(now.year, now.month, now.day, 21, 0);
//     while (startTime.isBefore(endTime)) {
//       _timeOptions.add(DateFormat('HH:mm').format(startTime));
//       startTime = startTime.add(Duration(minutes: 30));
//     }

//     setState(() {
//       _timeOptions.insert(0, 'ASAP');
//     });
//   }

//   void _calculateGST() {
//     setState(() {
//       gst = _totalPrice * 0.08;
//     });
//   }

//   void _calculateServiceTax() {
//     setState(() {
//       serviceTax = _totalPrice * 0.05;
//     });
//   }

//   void _calculateFinalTotalPrice() {
//     setState(() {
//       finalAmount = _totalPrice + gst + serviceTax;
//     });
//   }

//   void _placeOrder(BuildContext context) {
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     final User? user = _auth.currentUser;
//     NotificationService notificationService = NotificationService();

//     if (user != null) {
//       // Get a reference to the 'orders' collection
//       CollectionReference orders =
//           FirebaseFirestore.instance.collection('orders');

//       cafe.Order order = cafe.Order(
//         userId: user.uid,
//         userName: _userName,
//         option: _selectedOption,
//         pickupTime: _selectedTime,
//         items: _cartItems,
//         totalAmount: finalAmount,
//         timestamp: Timestamp.now(),
//         foodRating: 0.0,
//         serviceRating: 0.0,
//       );

//       // Add the order to Firestore with auto-generated ID
//       orders.add(order.toMap()).then((DocumentReference document) {
//         // Access the auto-generated ID assigned to the document
//         String orderId = document.id;

//         // Perform any additional actions with the orderId if needed

//         // Clear the cart after order is placed
//         _cartService.clearCart();

//         // Navigate to the order details page
//         context.go("/user");

//         notificationService.sendMessage(
//             notificationService.getUserDeviceToken(user.uid),
//             'Order Placed',
//             'Your order has been placed.');

//         // Show a confirmation message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Order placed successfully! We will inform you when the order is ready.'),
//             duration: Duration(seconds: 3), // Adjust duration as needed
//           ),
//         );
//       }).catchError((error) {
//         print("Failed to add order: $error");
//         // Handle errors here if needed
//       });
//     } else {
//       print('User not logged in');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 248, 240, 238),
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 229, 202, 195),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         title: const Text(
//           "Check Out",
//           style: TextStyle(
//             fontSize: 20.0,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : _errorMessage != null
//               ? Center(
//                   child: Text('Error: $_errorMessage'),
//                 )
//               : Stack(
//                   children: [
//                     SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         const Text(
//                                           'Name:',
//                                           style: TextStyle(fontSize: 16),
//                                         ),
//                                         Text(
//                                           _userName,
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         const Text(
//                                           'Order Type:',
//                                           style: TextStyle(fontSize: 16),
//                                         ),
//                                         DropdownButton<String>(
//                                           value: _selectedOption,
//                                           onChanged: (String? newValue) {
//                                             setState(() {
//                                               _selectedOption = newValue!;
//                                               if (_selectedOption ==
//                                                   'Dine In') {
//                                                 _selectedTime = null;
//                                               } else if (_selectedOption ==
//                                                   'Pickup') {
//                                                 _selectedTime =
//                                                     'ASAP'; // Set _selectedTime to 'ASAP' if Pickup is selected
//                                               }
//                                             });
//                                           },
//                                           items: <String>['Dine In', 'Pickup']
//                                               .map<DropdownMenuItem<String>>(
//                                                   (String value) {
//                                             return DropdownMenuItem<String>(
//                                               value: value,
//                                               child: Text(
//                                                 value,
//                                                 style: const TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                             );
//                                           }).toList(),
//                                         ),
//                                       ],
//                                     ),
//                                     if (_selectedOption == 'Pickup') ...[
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           const Text(
//                                             'Pickup Time:',
//                                             style: TextStyle(fontSize: 16),
//                                           ),
//                                           Expanded(
//                                             child: Align(
//                                               alignment: Alignment.centerRight,
//                                               child: DropdownButton<String>(
//                                                 value: _selectedTime,
//                                                 onChanged: (String? newValue) {
//                                                   setState(() {
//                                                     _selectedTime = newValue!;
//                                                   });
//                                                 },
//                                                 items: _timeOptions.map<
//                                                         DropdownMenuItem<
//                                                             String>>(
//                                                     (String value) {
//                                                   return DropdownMenuItem<
//                                                       String>(
//                                                     value: value,
//                                                     child: Text(
//                                                       value,
//                                                       style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: value == 'ASAP'
//                                                             ? Colors.black
//                                                             : null,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 16.0, vertical: 8.0),
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                 'Order Summary',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           ListView(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             children: [
//                               Container(
//                                 margin:
//                                     const EdgeInsets.symmetric(horizontal: 18),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Column(
//                                   children:
//                                       List.generate(_cartItems.length, (index) {
//                                     final cartItem = _cartItems[index];
//                                     final isLastItem =
//                                         index == _cartItems.length - 1;
//                                     return Column(
//                                       children: [
//                                         ListTile(
//                                           contentPadding:
//                                               const EdgeInsets.symmetric(
//                                                   vertical: 10, horizontal: 12),
//                                           leading: Image.network(
//                                             cartItem.menuItem.imageUrl,
//                                             width: 50,
//                                             height: 50,
//                                             fit: BoxFit.cover,
//                                           ),
//                                           title: Text(
//                                             cartItem.menuItem.name,
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 16),
//                                           ),
//                                           subtitle: Text(
//                                             'Price: RM${cartItem.menuItem.price.toStringAsFixed(2)}',
//                                           ),
//                                           trailing:
//                                               Text('x ${cartItem.quantity}'),
//                                         ),
//                                         if (!isLastItem)
//                                           const Divider(
//                                             indent: 16,
//                                             endIndent: 16,
//                                             height: 0,
//                                           ),
//                                       ],
//                                     );
//                                   }),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 100),
//                         ],
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.zero, // No border radius
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset:
//                                   const Offset(0, -3), // Adjust shadow offset
//                             ),
//                           ],
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'Subtotal:',
//                                     style: TextStyle(fontSize: 18),
//                                   ),
//                                   Text(
//                                     'RM${_totalPrice.toStringAsFixed(2)}',
//                                     style: const TextStyle(fontSize: 18),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'SST (8%):',
//                                     style: TextStyle(fontSize: 18),
//                                   ),
//                                   Text(
//                                     'RM${gst.toStringAsFixed(2)}',
//                                     style: const TextStyle(fontSize: 18),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'Service Tax (5%):',
//                                     style: TextStyle(fontSize: 18),
//                                   ),
//                                   Text(
//                                     'RM${serviceTax.toStringAsFixed(2)}',
//                                     style: const TextStyle(fontSize: 18),
//                                   ),
//                                 ],
//                               ),
//                               const Divider(),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'Total Price:',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'RM${finalAmount.toStringAsFixed(2)}',
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               Center(
//                                 // Center widget added here
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     _placeOrder(context);
//                                   },
//                                   child: const Text(
//                                     'Place Order',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   style: ElevatedButton.styleFrom(
//                                     minimumSize:
//                                         const Size(double.infinity, 50),
//                                     backgroundColor: const Color.fromARGB(
//                                         255, 195, 133, 134),
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 15, horizontal: 110),
//                                     elevation: 2,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyu_cafe/model/cart_item.dart';
import 'package:onlyu_cafe/order/orderdetails.dart';
import 'package:onlyu_cafe/service/cart_service.dart';
import 'package:intl/intl.dart';
import 'package:onlyu_cafe/model/order.dart' as cafe;
import 'package:onlyu_cafe/service/notification.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({Key? key}) : super(key: key);

  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final CartService _cartService = CartService();
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedOption = 'Dine In';
  String? _selectedTime;
  List<String> _timeOptions = [];
  String _userName = 'guest';
  double _totalPrice = 0.0;
  double gst = 0.0;
  double serviceTax = 0.0;
  double finalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
    _fetchUserName();
    _generateTimeOptions();
  }

  Future<void> _fetchCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<CartItem> items = await _cartService.getCartList();
      double total = items.fold(
          0.0, (sum, item) => sum + item.menuItem.price * item.quantity);
      setState(() {
        _cartItems = items;
        _isLoading = false;
        _totalPrice = total;
        _calculateGST();
        _calculateServiceTax();
        _calculateFinalTotalPrice();
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserName() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final User? user = _auth.currentUser;

    if (user != null) {
      final DocumentSnapshot userData =
          await _firestore.collection('User').doc(user.uid).get();

      if (userData.exists) {
        final String name = userData.get('name');
        setState(() {
          _userName = name;
        });
      } else {
        print('User data not found');
      }
    } else {
      setState(() {
        _userName = 'guest';
      });
      print('User not logged in');
    }
  }

  void _generateTimeOptions() {
    final now = DateTime.now();
    final int currentHour = now.hour;
    final int currentMinute = now.minute;

    DateTime startTime;
    if (currentHour < 10 || (currentHour == 10 && currentMinute < 30)) {
      startTime = DateTime(now.year, now.month, now.day, 10, 30);
    } else {
      int startHour = currentMinute > 30 ? currentHour + 1 : currentHour;
      int startMinute = currentMinute > 30 ? 0 : 30;
      startTime =
          DateTime(now.year, now.month, now.day, startHour, startMinute);

      if (startTime.isBefore(now.add(Duration(hours: 1)))) {
        startTime = startTime.add(Duration(minutes: 60));
      }
    }

    DateTime endTime = DateTime(now.year, now.month, now.day, 21, 0);
    while (startTime.isBefore(endTime)) {
      _timeOptions.add(DateFormat('HH:mm').format(startTime));
      startTime = startTime.add(Duration(minutes: 30));
    }

    setState(() {
      _timeOptions.insert(0, 'ASAP');
    });
  }

  void _calculateGST() {
    setState(() {
      gst = _totalPrice * 0.08;
    });
  }

  void _calculateServiceTax() {
    setState(() {
      serviceTax = _totalPrice * 0.05;
    });
  }

  void _calculateFinalTotalPrice() {
    setState(() {
      finalAmount = _totalPrice + gst + serviceTax;
    });
  }

  void _placeOrder(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    NotificationService notificationService = NotificationService();

    if (user != null) {
      // Get a reference to the 'orders' collection
      CollectionReference orders =
          FirebaseFirestore.instance.collection('orders');

      cafe.Order order = cafe.Order(
        userId: user.uid,
        userName: _userName,
        option: _selectedOption,
        pickupTime: _selectedTime,
        items: _cartItems,
        totalAmount: finalAmount,
        timestamp: Timestamp.now(),
        foodRating: 0.0,
        serviceRating: 0.0,
      );

      // Add the order to Firestore with auto-generated ID
      orders.add(order.toMap()).then((DocumentReference document) {
        // Access the auto-generated ID assigned to the document
        String orderId = document.id;

        // Perform any additional actions with the orderId if needed

        // Clear the cart after order is placed
        _cartService.clearCart();

        // Navigate to the order details page
        context.go("/user");

        notificationService.sendMessage(
            notificationService.getUserDeviceToken(user.uid),
            'Order Placed',
            'Your order has been placed.');

        // Show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order placed successfully! We will inform you when the order is ready.'),
            duration: Duration(seconds: 3), // Adjust duration as needed
          ),
        );
      }).catchError((error) {
        print("Failed to add order: $error");
        // Handle errors here if needed
      });
    } else {
      print('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 229, 202, 195),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Check Out",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Text('Error: $_errorMessage'),
                )
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 150.0), // Add padding at the bottom
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Name:',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            _userName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Order Type:',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          DropdownButton<String>(
                                            value: _selectedOption,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _selectedOption = newValue!;
                                                if (_selectedOption ==
                                                    'Dine In') {
                                                  _selectedTime = null;
                                                } else if (_selectedOption ==
                                                    'Pickup') {
                                                  _selectedTime =
                                                      'ASAP'; // Set _selectedTime to 'ASAP' if Pickup is selected
                                                }
                                              });
                                            },
                                            items: <String>['Dine In', 'Pickup']
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      if (_selectedOption == 'Pickup') ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Pickup Time:',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: DropdownButton<String>(
                                                  value: _selectedTime,
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _selectedTime = newValue!;
                                                    });
                                                  },
                                                  items: _timeOptions.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: value == 'ASAP'
                                                              ? Colors.black
                                                              : null,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Order Summary',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: List.generate(_cartItems.length,
                                        (index) {
                                      final cartItem = _cartItems[index];
                                      final isLastItem =
                                          index == _cartItems.length - 1;
                                      return Column(
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 12),
                                            leading: Image.network(
                                              cartItem.menuItem.imageUrl,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                            title: Text(
                                              cartItem.menuItem.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            subtitle: Text(
                                              'Price: RM${cartItem.menuItem.price.toStringAsFixed(2)}',
                                            ),
                                            trailing:
                                                Text('x ${cartItem.quantity}'),
                                          ),
                                          if (!isLastItem)
                                            const Divider(
                                              indent: 16,
                                              endIndent: 16,
                                              height: 0,
                                            ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.zero, // No border radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                                  const Offset(0, -3), // Adjust shadow offset
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Subtotal:',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    'RM${_totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'SST (8%):',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    'RM${gst.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Service Tax (5%):',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    'RM${serviceTax.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Price:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'RM${finalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                // Center widget added here
                                child: ElevatedButton(
                                  onPressed: () {
                                    _placeOrder(context);
                                  },
                                  child: const Text(
                                    'Place Order',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    backgroundColor: const Color.fromARGB(
                                        255, 195, 133, 134),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 110),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
