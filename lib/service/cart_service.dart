import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyu_cafe/model/cart_item.dart';
import 'package:onlyu_cafe/model/menu_item.dart' as menu_model;

class CartService {
  List<CartItem> cartItems = [];
  String userId = FirebaseAuth.instance.currentUser!.uid;

  CartService();

  Future<void> addtoCart(String itemID) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance.collection('cart').doc(userId).get();

    if (docSnapshot.exists) {
      Map<String, dynamic> cartData = docSnapshot.data()!;
      var cartList = cartData['cartList'] as List<dynamic>;

      bool itemExists = false;
      for (var item in cartList) {
        if (item['ItemID'] == itemID) {
          item['quantity'] += 1;
          itemExists = true;
          break;
        }
      }

      if (!itemExists) {
        cartList.add({
          'ItemID': itemID,
          'quantity': 1,
        });
      }

      await FirebaseFirestore.instance.collection('cart').doc(userId).update({
        'cartList': cartList,
      });
    } else {
      await FirebaseFirestore.instance.collection('cart').doc(userId).set({
        'cartList': [
          {
            'ItemID': itemID,
            'quantity': 1,
          },
        ]
      });
    }
  }

  Future<List<CartItem>> getCartList() async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance.collection('cart').doc(userId).get();
    List<CartItem> newCartList = [];

    if (docSnapshot.exists) {
      Map<String, dynamic> cartData = docSnapshot.data()!;
      var cartList = cartData['cartList'] as List<dynamic>;

      for (var item in cartList) {
        DocumentSnapshot<Map<String, dynamic>> items = await FirebaseFirestore
            .instance
            .collection('menu_items')
            .doc(item['ItemID'])
            .get();

        if (items.exists) {
          Map<String, dynamic> itemData = items.data()!;
          menu_model.MenuItem menuItem = menu_model.MenuItem(
              id: items.id,
              name: items['name'] ?? '',
              description: items['description'] ?? '',
              price: items['price'] ?? 0.00,
              imageUrl: items['imageUrl'] ?? '',
              isAvailable: items['isAvailable'] ?? true,
              category: items['category'] ?? '');

          CartItem cartItems =
              CartItem(menuItem: menuItem, quantity: item['quantity']);

          newCartList.add(cartItems);
        }
      }
    }

    return newCartList;
  }

  Future<void> updateItemQuantity(String itemID, int newQuantity) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapShot =
        await FirebaseFirestore.instance.collection('cart').doc(userId).get();

    if (docSnapShot.exists) {
      List<dynamic> cartList = docSnapShot.get('cartList');

      int index = cartList.indexWhere((item) => item['ItemID'] == itemID);

      if (index != -1) {
        if (newQuantity >= 1) {
          cartList[index]['quantity'] = newQuantity;
          print(newQuantity);
        } else {
          cartList.removeWhere((item) => item['ItemID'] == itemID);
        }
      }

      await FirebaseFirestore.instance.collection('cart').doc(userId).update({
        'cartList': cartList,
      });
    }
  }

  Future<int> getItemQuantity() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapShot =
          await FirebaseFirestore.instance.collection('cart').doc(userId).get();

      if (docSnapShot.exists && docSnapShot.data() != null) {
        Map<String, dynamic> data = docSnapShot.data()!;
        List<dynamic> cartList = data['cartList'];

        int totalQuantity = 0;

        for (var item in cartList) {
          totalQuantity += (item['quantity'] as num).toInt();
        }

        return totalQuantity;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      return 0;
    }
  }

  Future<void> clearCart() async {
    try {
      await FirebaseFirestore.instance.collection('cart').doc(userId).delete();
      cartItems.clear();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCartStream() {
    return FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .snapshots();
  }
}
