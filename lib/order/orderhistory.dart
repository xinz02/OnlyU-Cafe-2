// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/widgets.dart';
// import 'package:intl/intl.dart';
// import 'package:onlyu_cafe/order/orderdetails.dart';
// import 'package:onlyu_cafe/model/cart_item.dart';

// class OrderHistoryPage extends StatefulWidget {
//   const OrderHistoryPage({super.key});

//   @override
//   State<OrderHistoryPage> createState() => _OrderHistoryPageState();
// }

// class _OrderHistoryPageState extends State<OrderHistoryPage> {
//   // List<DocumentSnapshot> _orders = [];
//   List<DocumentSnapshot> _ongoingOrders = [];
//   List<DocumentSnapshot> _pastOrders = [];

//   @override
//   void initState() {
//     super.initState();
//     _getUserOrders();
//   }

//   String formatTimestamp(Timestamp timestamp) {
//     DateTime dateTime = timestamp.toDate();
//     dateTime = dateTime
//         .add(const Duration(hours: 8)); // Adjust to Malaysia time (UTC+8)
//     DateFormat dateFormat = DateFormat('d/M/yyyy h:mm:ss a');
//     return dateFormat.format(dateTime);
//   }

//   Future<void> _getUserOrders() async {
//     final User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       try {
//         final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
//             .collection('orders')
//             .where('userId', isEqualTo: user.uid)
//             .orderBy('timestamp', descending: true)
//             .get();

//         if (mounted) {
//           setState(() {
//             // _orders = ordersSnapshot.docs;
//             _ongoingOrders = ordersSnapshot.docs
//                 .where((order) => order['status'] == 'Paid')
//                 .toList();
//             _pastOrders = ordersSnapshot.docs
//                 .where((order) => order['status'] == 'Picked Up')
//                 .toList();
//           });
//         }
//       } catch (error) {
//         print('Failed to get orders: $error');
//       }
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
//           "Order History",
//           style: TextStyle(
//               fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Ongoing Orders",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.left,
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               _ongoingOrders.isEmpty
//                   ? const Center(child: Text("No orders found"))
//                   : ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: _ongoingOrders.length,
//                       itemBuilder: (context, index) {
//                         final order = _ongoingOrders[index];
//                         List<dynamic> items =
//                             order['items']; // Extracting items from the order

//                         return Column(
//                           children: [
//                             Container(
//                               decoration: const BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(15)),
//                               ),
//                               child: ListTile(
//                                 title: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Order: ${order.id}',
//                                       style: const TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600),
//                                     ),
//                                     Text(
//                                       'RM ${order['totalAmount'].toStringAsFixed(2)}',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 13,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 subtitle: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const SizedBox(height: 5),
//                                     const Text(
//                                       'Items:',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 2,
//                                     ),
//                                     ...List.generate(items.length, (i) {
//                                       final item = items[i];
//                                       return Text(
//                                         '${i + 1}. ${item['name']} x${item['quantity']}',
//                                         style: const TextStyle(fontSize: 13),
//                                       );
//                                     }),
//                                     const SizedBox(
//                                       height: 5,
//                                     ),
//                                     Text(
//                                         'Order at:  ${formatTimestamp(order['timestamp'])}'),
//                                   ],
//                                 ),
//                                 // trailing: Column(
//                                 //   crossAxisAlignment: CrossAxisAlignment.start,
//                                 //   children: [
//                                 //     Text(
//                                 //       'RM ${order['totalAmount'].toStringAsFixed(2)}',
//                                 //       style: const TextStyle(
//                                 //         fontWeight: FontWeight.w600,
//                                 //         fontSize: 13,
//                                 //       ),
//                                 //     ),
//                                 //   ],
//                                 // ),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           OrderDetailsPage(order: order),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//               const Text(
//                 "Past Orders",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.left,
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               _pastOrders.isEmpty
//                   ? const Center(child: Text("No orders found"))
//                   : ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: _pastOrders.length,
//                       itemBuilder: (context, index) {
//                         final order = _pastOrders[index];
//                         List<dynamic> items =
//                             order['items']; // Extracting items from the order

//                         return Column(
//                           children: [
//                             Container(
//                               decoration: const BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(15)),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 10, horizontal: 5),
//                                 child: ListTile(
//                                   title: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Order: ${order.id}',
//                                         style: const TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                       Text(
//                                         'RM ${order['totalAmount'].toStringAsFixed(2)}',
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   subtitle: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       const SizedBox(height: 5),
//                                       const Text(
//                                         'Items:',
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         height: 2,
//                                       ),
//                                       ...List.generate(items.length, (i) {
//                                         final item = items[i];
//                                         return Text(
//                                           '${i + 1}. ${item['name']} x${item['quantity']}',
//                                           style: const TextStyle(fontSize: 13),
//                                         );
//                                       }),
//                                       const SizedBox(
//                                         height: 5,
//                                       ),
//                                       Text(
//                                           'Order at:  ${formatTimestamp(order['timestamp'])}'),
//                                       const SizedBox(
//                                         height: 5,
//                                       ),
//                                       TextButton(
//                                           onPressed: () {},
//                                           style: TextButton.styleFrom(
//                                               alignment: Alignment.center,
//                                               backgroundColor:
//                                                   const Color.fromARGB(
//                                                       255, 195, 133, 134),
//                                               // maximumSize: Size(150, 75),
//                                               shape:
//                                                   const RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.all(
//                                                     Radius.circular(8)),
//                                               ),
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 10,
//                                                       horizontal: 108)),
//                                           child: const Text(
//                                             "Reorder Now!",
//                                             style:
//                                                 TextStyle(color: Colors.white),
//                                           )),
//                                     ],
//                                   ),
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             OrderDetailsPage(order: order),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 15,
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:onlyu_cafe/order/orderdetails.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  // List<DocumentSnapshot> _orders = [];
  List<DocumentSnapshot> _ongoingOrders = [];
  List<DocumentSnapshot> _pastOrders = [];

  @override
  void initState() {
    super.initState();
    _getUserOrders();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    dateTime = dateTime
        .add(const Duration(hours: 8)); // Adjust to Malaysia time (UTC+8)
    DateFormat dateFormat = DateFormat('d/M/yyyy h:mm:ss a');
    return dateFormat.format(dateTime);
  }

  Future<void> _getUserOrders() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .get();

        if (mounted) {
          setState(() {
            // _orders = ordersSnapshot.docs;
            _ongoingOrders = ordersSnapshot.docs
                .where((order) => order['status'] != 'Picked Up')
                .toList();
            _pastOrders = ordersSnapshot.docs
                .where((order) => order['status'] == 'Picked Up')
                .toList();
          });
        }
      } catch (error) {
        print('Failed to get orders: $error');
      }
    }
  }

  Future<void> _reorder(DocumentSnapshot pastOrder) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final newOrderData = {
          'userId': user.uid,
          'items': pastOrder['items'],
          'totalAmount': pastOrder['totalAmount'],
          'status':
              'Paid', // Set initial status as 'Paid' or other appropriate status
          'timestamp': Timestamp.now(),
        };

        await FirebaseFirestore.instance.collection('orders').add(newOrderData);

        // Show a success message or navigate to another screen if necessary
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reorder successful!')),
        );
      } catch (error) {
        print('Failed to reorder: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reorder')),
        );
      }
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
          "Order History",
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ongoing Orders",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              const SizedBox(
                height: 15,
              ),
              _ongoingOrders.isEmpty
                  ? const Center(child: Text("No orders found"))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ongoingOrders.length,
                      itemBuilder: (context, index) {
                        final order = _ongoingOrders[index];
                        List<dynamic> items =
                            order['items']; // Extracting items from the order

                        return Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Text(
                                    //   'Order: ${order.id}',
                                    //   style: const TextStyle(
                                    //       fontSize: 14,
                                    //       fontWeight: FontWeight.w600),
                                    // ),
                                    Flexible(
                                      child: Text(
                                        'Order: ${order.id}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      'RM ${order['totalAmount'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Items:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    ...List.generate(items.length, (i) {
                                      final item = items[i];
                                      return Text(
                                        '${i + 1}. ${item['name']} x${item['quantity']}',
                                        style: const TextStyle(fontSize: 13),
                                      );
                                    }),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                        'Order at:  ${formatTimestamp(order['timestamp'])}'),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrderDetailsPage(order: order),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        );
                      },
                    ),
              const Text(
                "Past Orders",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              const SizedBox(
                height: 15,
              ),
              _pastOrders.isEmpty
                  ? const Center(child: Text("No orders found"))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pastOrders.length,
                      itemBuilder: (context, index) {
                        final order = _pastOrders[index];
                        List<dynamic> items =
                            order['items']; // Extracting items from the order

                        return Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 5),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Order: ${order.id}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        'RM ${order['totalAmount'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Items:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      ...List.generate(items.length, (i) {
                                        final item = items[i];
                                        return Text(
                                          '${i + 1}. ${item['name']} x${item['quantity']}',
                                          style: const TextStyle(fontSize: 13),
                                        );
                                      }),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          'Order at:  ${formatTimestamp(order['timestamp'])}'),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      // TextButton(
                                      //     onPressed:
                                      //         () {}, // Call the reorder function
                                      //     style: TextButton.styleFrom(
                                      //         alignment: Alignment.center,
                                      //         backgroundColor:
                                      //             const Color.fromARGB(
                                      //                 255, 195, 133, 134),
                                      //         shape:
                                      //             const RoundedRectangleBorder(
                                      //           borderRadius: BorderRadius.all(
                                      //               Radius.circular(8)),
                                      //         ),
                                      //         padding:
                                      //             const EdgeInsets.symmetric(
                                      //                 vertical: 10,
                                      //                 horizontal: 108)),
                                      //     child: const Text(
                                      //       "Reorder Now!",
                                      //       style:
                                      //           TextStyle(color: Colors.white),
                                      //     )),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderDetailsPage(order: order),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
