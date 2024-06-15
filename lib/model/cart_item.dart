// import 'package:cloud_firestore/cloud_firestore.dart';

// class CartItem {
//   final String id;
//   final String name;
//   final double price;
//   final int quantity;
//   String imageUrl;

//   CartItem({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.quantity,
//     required this.imageUrl,
//   });

//   // // Factory constructor to create a CartItem from Firestore document snapshot
//   // factory CartItem.fromFirestore(DocumentSnapshot doc) {
//   //   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//   //   return CartItem(
//   //     id: doc.id,
//   //     name: data['name'],
//   //     price: data['price'].toDouble(),
//   //     quantity: data['quantity'],
//   //   );
//   // }

//   // // Method to convert a CartItem to a Map for Firestore
//   // Map<String, dynamic> toMap() {
//   //   return {
//   //     'name': name,
//   //     'price': price,
//   //     'quantity': quantity,
//   //   };
//   // }

//   // Convert a MenuItem object into a map
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'price': price,
//       'imageUrl': imageUrl,
//       'quantity': quantity,
//     };
//   }

//   // Create a MenuItem object from a map
//   factory CartItem.fromMap(Map<String, dynamic> map, String itemId) {
//     return CartItem(
//       id: itemId,
//       name: map['name'],
//       price: map['price'],
//       quantity: map['quantity'],
//       imageUrl: map['imageUrl'],
//     );
//   }

//   factory CartItem.fromDocument(DocumentSnapshot doc) {
//     return CartItem(
//       id: doc.id,
//       name: doc['name'],
//       price: doc['price'],
//       quantity: doc['quantity'],
//       imageUrl: doc['imageUrl'],
//     );
//   }
// }
import 'package:onlyu_cafe/model/menu_item.dart' as menu_model;

class CartItem {
  menu_model.MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, required this.quantity});

  // Convert CartItem to a map
  Map<String, dynamic> toMap() {
    return {
      'ItemID': menuItem.id,
      'name': menuItem.name,
      'description': menuItem.description,
      'price': menuItem.price,
      'imageUrl': menuItem.imageUrl,
      'isAvailable': menuItem.isAvailable,
      'category': menuItem.category,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      menuItem: menu_model.MenuItem(
        id: map['ItemID'],
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        price: map['price'] ?? 0.0,
        imageUrl: map['imageUrl'] ?? '',
        isAvailable: map['isAvailable'] ?? true,
        category: map['category'] ?? '',
      ),
      quantity: map['quantity'] ?? 0,
    );
  }
}



  // factory CartItem.fromDocument(DocumentSnapshot doc) {
  //   return CartItem(
  //     id: doc.id,
  //     name: doc['name'],
  //     description: doc['description'],
  //     price: doc['price'],
  //     imageUrl: doc['imageUrl'],
  //     isAvailable: doc['isAvailable'],
  //     category: doc['category'],
  //   );
  // }
