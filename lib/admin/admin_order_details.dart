import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for DateFormat
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyu_cafe/service/notification.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final DocumentSnapshot order;

  const AdminOrderDetailsPage({Key? key, required this.order})
      : super(key: key);

  @override
  _AdminOrderDetailsPageState createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  late String _selectedStatus;
  late NotificationService _notificationService; // Declare NotificationService

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order['status'];
    _notificationService =
        NotificationService(); // Initialize NotificationService
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(widget.order['items']);
    final orderTime = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(widget.order['timestamp'].toDate());
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 229, 202, 195),
        title: const Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${widget.order.id}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: ['Paid', 'Preparing', 'Ready', 'Picked Up'].map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 195, 133, 134),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _updateOrderStatus(_selectedStatus);
                },
                child: const Text(
                  'Update Order Status',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Time: $orderTime',
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text('Status: $_selectedStatus',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Text('Option: ${widget.order['option']}'),
            if (widget.order['option'] == 'Pickup')
              Text('Pickup Time: ${widget.order['pickupTime']}'),
            const SizedBox(height: 20),
            const Text(
              "Ordered Items: ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 6,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(item['imageUrl']),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(
                            width: 2,
                          ),
                          Text('x ${item['quantity']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: RM ${item['price'].toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({'status': newStatus});

      if (newStatus == 'Ready') {
        // Fetch user ID from the order document
        String userId = widget.order['userId'];

        // Get user's device token
        String? deviceToken =
            await _notificationService.getUserDeviceToken(userId);

        if (deviceToken != null) {
          // Send notification when status is updated to 'Ready'
          await _notificationService.sendMessage(
              Future.value(deviceToken),
              'Order Ready', // Title of the message
              'Your order ${widget.order.id} is ready for pickup!' // Body of the message
              );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status: $error')),
      );
    }
  }
}
