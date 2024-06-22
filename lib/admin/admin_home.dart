import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyu_cafe/admin/admin_menu.dart';
import 'package:onlyu_cafe/admin/admin_order.dart';
import 'package:onlyu_cafe/admin/admin_report.dart'; // Import the report page
import 'package:onlyu_cafe/main.dart';
import 'package:onlyu_cafe/service/auth.dart';
import 'package:onlyu_cafe/user_management/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// class AdminHomePage extends StatefulWidget {
//   const AdminHomePage({super.key});

//   @override
//   _AdminHomePageState createState() => _AdminHomePageState();
// }

// class _AdminHomePageState extends State<AdminHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 248, 240, 238),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             const SizedBox(height: 40),
//             StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance.collection('orders').snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return ElevatedButton(
//                     onPressed: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => const AdminOrderPage(),
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 195, 133, 134),
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       minimumSize: const Size(325, 55),
//                     ),
//                     child: const SizedBox(
//                       width: 315,
//                       height: 135,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: <Widget>[
//                               Text(
//                                 "Upcoming Orders:",
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 25),
//                               ),
//                               SizedBox(height: 10),
//                               CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             ],
//                           ),
//                           SizedBox(width: 40),
//                           Icon(Icons.arrow_forward_ios_rounded,
//                               color: Colors.white),
//                         ],
//                       ),
//                     ),
//                   );
//                 } else {
//                   int totalOrders = snapshot.data!.size;
//                   return ElevatedButton(
//                     onPressed: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => const AdminOrderPage(),
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 195, 133, 134),
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       minimumSize: const Size(325, 55),
//                     ),
//                     child: SizedBox(
//                       width: 315,
//                       height: 135,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: <Widget>[
//                               const Text(
//                                 "Upcoming Orders:",
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 25),
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 "$totalOrders",
//                                 style: const TextStyle(
//                                     color: Colors.white, fontSize: 25),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(width: 40),
//                           const Icon(Icons.arrow_forward_ios_rounded,
//                               color: Colors.white),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 40),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 SizedBox(
//                   width: 110,
//                   height: 75,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 237, 219, 219),
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () {},
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.menu_book),
//                         SizedBox(height: 4),
//                         Text('Menu'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 110,
//                   height: 75,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 237, 219, 219),
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => const AdminReportPage(),
//                         ),
//                       );
//                     },
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.summarize),
//                         SizedBox(height: 4),
//                         Text('Report'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 110,
//                   height: 75,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 237, 219, 219),
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () {},
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.feedback),
//                         SizedBox(height: 4),
//                         Text('Feedback'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             const Card(
//               child: ListTile(
//                 title: Text('Coco Chocolate Cake'),
//                 subtitle: Text('Qty: 15'),
//                 trailing: Icon(Icons.whatshot, color: Colors.red),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Card(
//               child: ListTile(
//                 title: Text('Coco Chocolate Cake'),
//                 subtitle: Row(
//                   children: [
//                     Icon(Icons.star, color: Colors.amber),
//                     Icon(Icons.star, color: Colors.amber),
//                     Icon(Icons.star, color: Colors.amber),
//                     Icon(Icons.star, color: Colors.amber),
//                     Icon(Icons.star, color: Colors.amber),
//                   ],
//                 ),
//                 trailing: Icon(Icons.emoji_events, color: Colors.amber),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class AdminHomePage extends StatefulWidget {
  final VoidCallback navigateToMenuPage;

  const AdminHomePage({super.key, required this.navigateToMenuPage});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isNotEqualTo: 'Picked Up')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminOrderPage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 195, 133, 134),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(325, 55),
                    ),
                    child: const SizedBox(
                      width: 315,
                      height: 135,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Upcoming Orders:",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                              SizedBox(height: 10),
                              CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ],
                          ),
                          SizedBox(width: 40),
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  );
                } else {
                  final now = DateTime.now();
                  final startOfDay = DateTime(now.year, now.month, now.day);
                  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

                  final orders = snapshot.data!.docs.where((doc) {
                    final timestamp = (doc['timestamp'] as Timestamp).toDate();
                    return timestamp.isAfter(startOfDay) && timestamp.isBefore(endOfDay);
                  }).toList();

                  int totalOrders = orders.length;

                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminOrderPage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 195, 133, 134),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(325, 55),
                    ),
                    child: SizedBox(
                      width: 315,
                      height: 135,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Upcoming Orders:",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "$totalOrders",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            ],
                          ),
                          const SizedBox(width: 40),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 110,
                  height: 75,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 237, 219, 219),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: widget.navigateToMenuPage,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book),
                        SizedBox(height: 4),
                        Text('Menu'),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  height: 75,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 237, 219, 219),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AdminReportPage(),
                        ),
                      );
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.summarize),
                        SizedBox(height: 4),
                        Text('Report'),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  height: 75,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 237, 219, 219),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feedback),
                        SizedBox(height: 4),
                        Text('Feedback'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Card(
              child: ListTile(
                title: Text('Coco Chocolate Cake'),
                subtitle: Text('Qty: 15'),
                trailing: Icon(Icons.whatshot, color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            const Card(
              child: ListTile(
                title: Text('Coco Chocolate Cake'),
                subtitle: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    Icon(Icons.star, color: Colors.amber),
                    Icon(Icons.star, color: Colors.amber),
                    Icon(Icons.star, color: Colors.amber),
                    Icon(Icons.star, color: Colors.amber),
                  ],
                ),
                trailing: Icon(Icons.emoji_events, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
