// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';

// class MenuItem {
//   String id;
//   String name;
//   String description;
//   double price;
//   File? imageFile;
//   bool isAvailable;
//   String category;

//   MenuItem({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.imageFile,
//     required this.isAvailable,
//     required this.category,
//   });

//   // Convert a MenuItem object into a map
//   Map<String, dynamic> toMap() {
//     // Convert File to String (file path) before storing in the database
//     String imagePath = imageFile != null ? imageFile!.path : '';

//     return {
//       'name': name,
//       'description': description,
//       'price': price,
//       'imagePath': imagePath,
//       'isAvailable': isAvailable,
//       'category': category,
//     };
//   }

//   // Create a MenuItem object from a map
//   factory MenuItem.fromMap(Map<String, dynamic> map, String itemId) {
//     // Convert String (file path) back to File when retrieving from the database
//     File? imageFile = map['imagePath'] != '' ? File(map['imagePath']) : null;

//     return MenuItem(
//         id: itemId,
//         name: map['name'],
//         description: map['description'],
//         price: map['price'],
//         imageFile: imageFile,
//         isAvailable: map['isAvailable'],
//         category: map['category']);
//   }

//   factory MenuItem.fromDocument(DocumentSnapshot doc) {
//     return MenuItem(
//       id: doc.id,
//       name: doc['name'],
//       description: doc['description'],
//       price: doc['price'],
//       imageFile: doc['imageUrl'],
//       isAvailable: doc['isAvailable'],
//       category: doc['category'],
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';


class MenuItem {
  String id;
  String name;
  String description;
  double price;
  String imageUrl;
  bool isAvailable;
  String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.category,
  });

  // Convert a MenuItem object into a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'category': category,
    };
  }

  // Create a MenuItem object from a map
  factory MenuItem.fromMap(Map<String, dynamic> map, String itemId) {
    return MenuItem(
      id: itemId,
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      isAvailable: map['isAvailable'],
      category: map['category'],
    );
  }

  factory MenuItem.fromDocument(DocumentSnapshot doc) {
    return MenuItem(
      id: doc.id,
      name: doc['name'],
      description: doc['description'],
      price: doc['price'],
      imageUrl: doc['imageUrl'],
      isAvailable: doc['isAvailable'],
      category: doc['category'],
    );
  }

  
}
