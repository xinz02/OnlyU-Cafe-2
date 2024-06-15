// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'rating.dart'; // Import for RatingWidget

class OrderDetailsPage extends StatefulWidget {
  final DocumentSnapshot order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    dateTime = dateTime.add(const Duration(hours: 8)); // Adjust to Malaysia time (UTC+8)
    DateFormat dateFormat = DateFormat('d/M/yyyy h:mm:ss a');
    return dateFormat.format(dateTime);
  }

  double foodRating = 0;
  double serviceRating = 0;

  void _submitRating(double foodRating, double serviceRating) {
    // Assuming you have an 'orders' collection where the ratings are stored
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');

    orders.doc(widget.order.id).update({
      'foodRating': foodRating,
      'serviceRating': serviceRating,
    }).then((value) {
      // Handle successful submission (e.g., show success message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ratings updated successfully!'),
        ),
      );
      setState(() {
        this.foodRating = foodRating;
        this.serviceRating = serviceRating;
      });
    }).catchError((error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update ratings: $error'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(widget.order['items']);
    double totalOrderPrice = 0.0;

    // Calculate total order price
    items.forEach((item) {
      double price = item['price'] as double;
      int quantity = item['quantity'] as int;
      totalOrderPrice += (price * quantity);
    });

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
          "Order Details",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // First Container Box for Order Details
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderDetail('Order ID:', widget.order.id),
                        _buildOrderDetail('Order Status:', widget.order['status']),
                        _buildOrderDetail('Order Time:', formatTimestamp(widget.order['timestamp'])),
                        _buildOrderDetail('Option:', widget.order['option']),
                        if (widget.order['option'] == 'Pickup')
                          _buildOrderDetail('Pickup Time:', widget.order['pickupTime']),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Order Summary Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Order Summary',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Ordered Items Container Box
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final double totalPrice = (item['price'] as double) * (item['quantity'] as int);
                        final isLastItem = index == items.length - 1;
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              leading: Image.network(
                                item['imageUrl'] as String,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                item['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                'Price: RM${(item['price'] as double).toStringAsFixed(2)}',
                              ),
                              trailing: Text('x ${item['quantity']}'),
                            ),
                            if (!isLastItem)
                              const Divider(indent: 16, endIndent: 16, height: 0),
                          ],
                        );
                      })..add(
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'RM ${totalOrderPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Rate this Order Button
          if (widget.order['status'] == 'Picked Up')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RatingWidget(
                      order: widget.order,
                      onRatingSubmitted: _submitRating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40), 
                  backgroundColor: const Color.fromARGB(255, 195, 133, 134),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Rate this Order',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
