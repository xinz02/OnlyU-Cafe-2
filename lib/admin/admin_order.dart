import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyu_cafe/admin/admin_order_details.dart';

class AdminOrderPage extends StatefulWidget {
  const AdminOrderPage({Key? key}) : super(key: key);

  @override
  _AdminOrderPageState createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage> {
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
          title: const Text('Admin Order Page'),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('option', isEqualTo: orderType)
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
            final orderDateTime = order['timestamp'].toDate();
            final orderTime =
                '${orderDateTime.year}-${orderDateTime.month}-${orderDateTime.day} ${TimeOfDay.fromDateTime(orderDateTime).format(context)}';
            final amount = double.parse(order['totalAmount'].toString())
                .toStringAsFixed(2);
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
                subtitle: Text('Order Time: $orderTime',
                    style: const TextStyle(
                      fontSize: 12,
                    )),
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
