import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyu_cafe/model/cart_item.dart';

class Order {
  final String userId;
  final String userName;
  final String option;
  final String? pickupTime;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final Timestamp timestamp;

  Order({
    required this.userId,
    required this.userName,
    required this.option,
    this.pickupTime,
    required this.items,
    required this.totalAmount,
    this.status = 'Paid',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'option': option,
      'pickupTime': pickupTime,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
