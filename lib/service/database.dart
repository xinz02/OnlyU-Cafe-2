import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:onlyu_cafe/model/menu_item';
import 'dart:io';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) {
    return _firestore.collection("User").doc(userId).set(userInfoMap);
  }

  Future<void> addMenuItem(MenuItem menuItem) async {
    try {
      await _firestore.collection("menu_items").add(menuItem.toMap());
      print("Menu item added successfully.");
    } catch (e) {
      print("Error adding menu item: $e");
    }
  }

  Future<List<MenuItem>> getMenuItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('menu_items').get();
      return snapshot.docs.map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Error getting menu items: $e");
      return [];
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = _storage.ref().child('menu_images/$fileName');
      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }
}
