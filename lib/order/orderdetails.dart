import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'rating.dart' as orderRating; // Import for RatingWidget

class OrderDetailsPage extends StatefulWidget {
  final DocumentSnapshot order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    dateTime = dateTime
        .add(const Duration(hours: 8)); // Adjust to Malaysia time (UTC+8)
    DateFormat dateFormat = DateFormat('d/M/yyyy h:mm:ss a');
    return dateFormat.format(dateTime);
  }

  double foodRating = 0;
  double serviceRating = 0;
  bool ratingsSubmitted = false; // Flag to track if ratings have been submitted

  @override
  void initState() {
    super.initState();
    // Check if ratings exist for this order
    foodRating = (widget.order['foodRating'] ?? 0).toDouble();
    serviceRating = (widget.order['serviceRating'] ?? 0).toDouble();
    // Check if ratings have been submitted
    ratingsSubmitted = foodRating != 0 && serviceRating != 0;
  }

  void _submitRating(double foodRating, double serviceRating) {
    // Assuming you have an 'orders' collection where the ratings are stored
    CollectionReference orders =
        FirebaseFirestore.instance.collection('orders');

    orders.doc(widget.order.id).update({
      'foodRating': foodRating.toInt(),
      'serviceRating': serviceRating.toInt(),
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
        ratingsSubmitted = true; // Update flag to true after submitting ratings
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

  double calculateSubtotal(List<Map<String, dynamic>> items) {
    double subtotal = 0.0;
    for (var item in items) {
      double price = item['price'] as double;
      int quantity = item['quantity'] as int;
      subtotal += (price * quantity);
    }
    return subtotal;
  }

  double calculateTotalAmount(List<Map<String, dynamic>> items) {
    // Assuming tax rates are 5% and 8%
    double subtotal = calculateSubtotal(items);
    double taxRate1 = 0.05; // 5% tax
    double taxRate2 = 0.08; // 8% tax
    double taxAmount1 = subtotal * taxRate1;
    double taxAmount2 = subtotal * taxRate2;
    double totalAmount = subtotal + taxAmount1 + taxAmount2;
    return totalAmount;
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

    // Calculate total amount including tax
    double totalAmount = calculateTotalAmount(items);

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
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  _buildOrderDetail('Order Time:',
                      formatTimestamp(widget.order['timestamp'])),
                  _buildOrderDetail('Option:', widget.order['option']),
                  if (widget.order['option'] == 'Pickup')
                    _buildOrderDetail(
                        'Pickup Time:', widget.order['pickupTime']),
                ],
              ),
            ),

            // const SizedBox(height: 20),

            // Show ratings if available or ratings have been submitted
            if (ratingsSubmitted)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Food Icon and Rating
                        Row(
                          children: [
                            Icon(Icons.fastfood,
                                color: const Color.fromARGB(255, 18, 18, 17),
                                size: 25),
                            const SizedBox(width: 10),
                            Text(
                              'Food',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Food Rating Stars
                        RatingBar.builder(
                          initialRating: foodRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 25.0,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          ignoreGestures: true,
                          onRatingUpdate: (double
                              value) {}, // Disable gesture for rated orders
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Service Icon and Rating
                        Row(
                          children: [
                            Icon(Icons.room_service,
                                color: const Color.fromARGB(255, 18, 18, 17),
                                size: 25),
                            const SizedBox(width: 10),
                            Text(
                              'Service',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Service Rating Stars
                        RatingBar.builder(
                          initialRating: serviceRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 25.0,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          ignoreGestures: true,
                          onRatingUpdate: (double
                              value) {}, // Disable gesture for rated orders
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // const SizedBox(height: 5),

            // Order Summary Text
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
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
                  final double totalPrice =
                      (item['price'] as double) * (item['quantity'] as int);
                  final isLastItem = index == items.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        leading: Image.network(
                          item['imageUrl'] as String,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          item['name'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          'Price: RM${(item['price'] as double).toStringAsFixed(2)}',
                        ),
                        trailing: Text('x ${item['quantity']}'),
                      ),
                      // SizedBox(height: ,)
                      if (!isLastItem)
                        const Divider(indent: 10, endIndent: 10, height: 0),
                    ],
                  );
                })
                  ..add(
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'RM ${totalOrderPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tax (5%):',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'RM ${(totalOrderPrice * 0.05).toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tax (8%):',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'RM ${(totalOrderPrice * 0.08).toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total (include tax):',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'RM ${calculateTotalAmount(items).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
            ),
            SizedBox(
              height: 25,
            )
          ],
        ),
      ),

      // Rate button at the bottom of the page
      bottomNavigationBar: !ratingsSubmitted &&
              widget.order['status'] == 'Picked Up'
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => orderRating.RatingWidget(
                      order: widget.order,
                      onRatingSubmitted: _submitRating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
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
            )
          : null,
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
