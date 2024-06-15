import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final DocumentSnapshot order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    dateTime = dateTime
        .add(const Duration(hours: 8)); // Adjust to Malaysia time (UTC+8)
    DateFormat dateFormat = DateFormat('d/M/yyyy h:mm:ss a');
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(widget.order['items']);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary: ",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              'Order ID: ${widget.order.id}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Order Status: ${widget.order['status']}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Order Time: ${formatTimestamp(widget.order['timestamp'])}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Option: ${widget.order['option']}',
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.order['option'] == 'Pickup')
              Text(
                'Pickup Time: ${widget.order['pickupTime']}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: items.length,
            //     itemBuilder: (context, index) {
            //       final item = items[index];
            //       final price =
            //           double.parse(item['price'].toString()).toStringAsFixed(2);
            //       return
            //           // Container(
            //           // decoration: BoxDecoration(
            //           //   borderRadius: BorderRadius.circular(15),
            //           // color: Colors.white,
            //           // ),
            //           // child:
            //           Column(
            //         children: [
            //           ListTile(
            //             leading: Image.network(item['imageUrl'] as String),
            //             title: Text(item['name'] as String),
            //             subtitle: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text('Category: ${item['category']}'),
            //                 Text('Description: ${item['description']}'),
            //                 Text('Quantity: ${item['quantity']}'),
            //                 Text('Price: \$$price'),
            //               ],
            //             ),
            //           ),
            //           if (index < items.length - 1) const Divider(),
            //         ],
            //         // ),
            //       );
            //     },
            //   ),
            // ),
            // Container(
            //   child:  for (int i = 0; i < items.length; i++) Container(child: Text('Hi')),
            // ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: items
                        .map((item) => Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 12, 15),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.network(
                                    item['imageUrl'] as String,
                                    width: 120,
                                    height: 120,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] as String,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'RM ${double.parse((item['price'] * item['quantity']).toString()).toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'x ${item['quantity']}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            )))
                        .toList(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'RM ${double.parse(widget.order['totalAmount'].toString()).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // if (widget.order['status'] == 'Ready')
            //   ElevatedButton(
            //     onPressed: () {
            //       // Handle rating functionality
            //     },
            //     child: const Text('Rate'),
            //   ),
          ],
        ),
      ),
    );
  }
}
