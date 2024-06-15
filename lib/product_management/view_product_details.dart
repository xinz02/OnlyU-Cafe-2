import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyu_cafe/model/menu_item.dart';
import 'package:onlyu_cafe/service/cart_service.dart';

class ViewProductDetails extends StatefulWidget {
  final MenuItem item;

  const ViewProductDetails({super.key, required this.item});

  @override
  State<ViewProductDetails> createState() => _ViewProductDetailsState();
}

class _ViewProductDetailsState extends State<ViewProductDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Item'),
        backgroundColor: const Color.fromARGB(255, 229, 202, 195),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15,
            ),
            Center(
              child: CircleAvatar(
                radius: 85, // Adjust the radius as needed
                backgroundImage: widget.item.imageUrl.isNotEmpty
                    ? NetworkImage(widget.item.imageUrl)
                    : null,
                child: widget.item.imageUrl.isEmpty
                    ? const Icon(
                        Icons.image,
                        size: 85,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Price: \RM${widget.item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                CartService().addtoCart(widget.item.id);
                 Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 246, 231, 232),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 52),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Add Item to Cart"),
            ),
          ],
        ),
      ),
    );
  }
}
