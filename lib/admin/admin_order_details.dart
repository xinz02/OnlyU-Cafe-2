import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:onlyu_cafe/service/notification.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final DocumentSnapshot order;

  const AdminOrderDetailsPage({Key? key, required this.order})
      : super(key: key);

  @override
  _AdminOrderDetailsPageState createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  String? _selectedStatus;
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order['status'];
    _notificationService = NotificationService();
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(widget.order['items']);
    final orderTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        widget.order['timestamp'].toDate().add(const Duration(hours: 8)));

    // Calculate total amount including tax
    double totalAmount = calculateTotalAmount(items);

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
            Text(
              'Order ID: ${widget.order.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
                  _selectedStatus = value;
                });
              },
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
                Text(
                  'Status: ${_selectedStatus ?? 'Unknown'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text('Option: ${widget.order['option'] ?? 'Unknown'}'),
            if (_selectedStatus == 'Picked Up')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.order['option'] == 'Pickup')
                    Text(
                        'Pickup Time: ${widget.order['pickupTime'] ?? 'Unknown'}'),
                  const SizedBox(height: 10),
                  if (widget.order['foodRating'] != null &&
                      widget.order['serviceRating'] != null)
                    if (widget.order['foodRating'] == 0 ||
                        widget.order['serviceRating'] == 0)
                      const Text('The user did not rate this order')
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRatingRow(
                            icon: Icons.fastfood,
                            label: 'Food',
                            rating: widget.order['foodRating'].toDouble(),
                          ),
                          const SizedBox(height: 10),
                          _buildRatingRow(
                            icon: Icons.room_service,
                            label: 'Service',
                            rating: widget.order['serviceRating'].toDouble(),
                          ),
                        ],
                      )
                  else
                    const Text('The user did not rate this order'),
                ],
              ),
            const SizedBox(height: 20),
            const Text(
              "Ordered Items: ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: items.length + 2, // +2 for subtotal and total
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          item['imageUrl'] ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'x ${item['quantity'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Price: RM ${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  } else if (index == items.length) {
                    // Display Subtotal below the last item
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Subtotal:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'RM ${calculateSubtotal(items).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Display Total (include tax) below the subtotal
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Total (include tax):',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'RM ${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            if (_selectedStatus != 'Picked Up')
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
                    if (_selectedStatus != null) {
                      _updateOrderStatus(_selectedStatus!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a status')),
                      );
                    }
                  },
                  child: const Text(
                    'Update Order Status',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(
      {required IconData icon, required String label, required double rating}) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 18, 18, 17), size: 25),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const Spacer(),
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 25.0,
        ),
      ],
    );
  }

  double calculateSubtotal(List<Map<String, dynamic>> items) {
    double subtotal = 0.0;
    for (var item in items) {
      double price = item['price'] ?? 0.0;
      int quantity = item['quantity'] ?? 0;
      subtotal += price * quantity;
    }
    return subtotal;
  }

  double calculateTotalAmount(List<Map<String, dynamic>> items) {
    // Calculate subtotal
    double subtotal = calculateSubtotal(items);

    // Calculate taxes
    double taxRate1 = 0.05; // 5% tax rate
    double taxRate2 = 0.08; // 8% tax rate
    double taxAmount1 = subtotal * taxRate1;
    double taxAmount2 = subtotal * taxRate2;

    // Calculate total amount including tax
    double totalAmount = subtotal + taxAmount1 + taxAmount2;

    return totalAmount;
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

  Future<void> _updateRatingInFirestore(
      double newRating, String ratingField) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({
        ratingField: newRating,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating updated successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update rating: $error')),
      );
    }
  }
}
