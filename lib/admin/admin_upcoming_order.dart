import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyu_cafe/admin/admin_order_details.dart';

class AdminUpcomingOrderPage extends StatefulWidget {
  const AdminUpcomingOrderPage({Key? key}) : super(key: key);

  @override
  _AdminUpcomingOrderPageState createState() => _AdminUpcomingOrderPageState();
}

class _AdminUpcomingOrderPageState extends State<AdminUpcomingOrderPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 240, 238),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 229, 202, 195),
          // appBar: AppBar(
          title: const Text('Upcoming Order Page'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pick Up Order'),
              Tab(text: 'Dine In Order'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrderListView(orderType: 'Pickup'),
            OrderListView(orderType: 'Dine In'),
          ],
        ),
      ),
    );
  }
}

class OrderListView extends StatelessWidget {
  final String orderType;

  const OrderListView({Key? key, required this.orderType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'Paid': Colors.green.shade200,
      'Preparing': Colors.yellow.shade200,
      'Ready': Colors.blue.shade200,
      'Picked Up': Colors.orange.shade200,
    };
    // return StreamBuilder<QuerySnapshot>(
    //   stream: FirebaseFirestore.instance
    //       .collection('orders')
    //       .where('option', isEqualTo: orderType)
    //       .where()
    //       .orderBy('timestamp', descending: true)
    //       .snapshots(),
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('option', isEqualTo: orderType)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return const Center(child: Text("No orders found"));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final orderDateTime =
                order['timestamp'].toDate().add(const Duration(hours: 8));
            final orderTime =
                '${orderDateTime.year}-${orderDateTime.month}-${orderDateTime.day} ${TimeOfDay.fromDateTime(orderDateTime).format(context)}';
            final amount = double.parse(order['totalAmount'].toString())
                .toStringAsFixed(2);
            final status = order['status'];
            final statusColor = statusColors[status] ?? Colors.grey.shade200;
            return Card(
              child: ListTile(
                title: Text(
                  'Order ID: ${order.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 2,
                    ),
                    Text('Order Time: $orderTime',
                        style: const TextStyle(
                          fontSize: 13,
                        )),
                    Container(
                      color: statusColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        " $status",
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
                trailing: Text(
                  'RM $amount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminOrderDetailsPage(order: order),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
