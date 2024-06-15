import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyu_cafe/model/cart_item.dart';
import 'package:onlyu_cafe/service/cart_service.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService cartService = CartService();
  List<CartItem> cartItems = [];
  bool isLoading = true;
  String? errorMessage;
  double totalPrice = 0;
  double gst = 0;
  double serviceTax = 0;
  double finalAmount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  void _fetchCartItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<CartItem> items = await cartService.getCartList();
      setState(() {
        cartItems = items;
        isLoading = false;
        _calculateTotalPrice();
        _calculateGST();
        _calculateServiceTax();
        _calculateFinalTotalPrice();
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  void _updateQuantity(String itemId, int newQuantity) async {
    try {
      await cartService.updateItemQuantity(itemId, newQuantity);
      _fetchCartItems();
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    }
  }

  double _calculateSubtotal(double price, int quantity) {
    return price * quantity;
  }

  void _calculateTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += _calculateSubtotal(item.menuItem.price, item.quantity);
    }
    setState(() {
      totalPrice = total;
    });
  }

  void _calculateGST() {
    double total = 0;
    for (var item in cartItems) {
      total += _calculateSubtotal(item.menuItem.price, item.quantity);
    }
    setState(() {
      gst = 0;
    });
    // return price * 0.05;
  }

  void _calculateServiceTax() {
    double total = 0;
    for (var item in cartItems) {
      total += _calculateSubtotal(item.menuItem.price, item.quantity);
    }
    setState(() {
      serviceTax = 0;
    });
    // return price * 0.05;
  }

  void _calculateFinalTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += _calculateSubtotal(item.menuItem.price, item.quantity);
    }

    total = gst + serviceTax + total;
    setState(() {
      finalAmount = total;
    });
  }

  void _showRemoveItemDialog(String itemId, int newQuantity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Cart Item"),
          content: const Text('Do you want to remove this cart item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _updateQuantity(itemId, newQuantity);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    'RM${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Service Tax (5%):',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    'RM${serviceTax.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GST (5%):',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    'RM${gst.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'RM${finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  context.push("/checkout");
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 195, 133, 134),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 130),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text(
                  "Checkout",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
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
          "Your Cart",
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Text('Error: $errorMessage'),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          double subtotal = _calculateSubtotal(
                            cartItems[index].menuItem.price,
                            cartItems[index].quantity,
                          );
                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              leading:
                                  cartItems[index].menuItem.imageUrl.isNotEmpty
                                      ? Image.network(
                                          cartItems[index].menuItem.imageUrl,
                                          width: 75,
                                          height: 85,
                                          fit: BoxFit.cover)
                                      : const Icon(Icons.image),
                              title: Text(
                                cartItems[index].menuItem.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Row(
                                children: [
                                  IconButton(
                                    color: const Color.fromARGB(
                                        255, 195, 133, 134),
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      int newQuantity =
                                          cartItems[index].quantity - 1;
                                      if (newQuantity < 1) {
                                        _showRemoveItemDialog(
                                            cartItems[index].menuItem.id,
                                            newQuantity);
                                      } else {
                                        _updateQuantity(
                                            cartItems[index].menuItem.id,
                                            newQuantity);
                                      }
                                    },
                                  ),
                                  Text(
                                    '${cartItems[index].quantity}',
                                  ),
                                  IconButton(
                                    color: const Color.fromARGB(
                                        255, 195, 133, 134),
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      int newQuantity =
                                          cartItems[index].quantity + 1;
                                      _updateQuantity(
                                          cartItems[index].menuItem.id,
                                          newQuantity);
                                    },
                                  ),
                                ],
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'RM ${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: _showBottomSheet,
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'RM${finalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.push("/checkout");
                                },
                                child: const Text(
                                  "Checkout",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 195, 133, 134),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 130),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}