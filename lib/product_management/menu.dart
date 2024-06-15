// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class MenuPage extends StatefulWidget {
//   final String orderType;
//   const MenuPage({super.key, this.orderType = ''});

//   @override
//   State<MenuPage> createState() => _MenuPageState();
// }

// class _MenuPageState extends State<MenuPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<String> categories = [];
//   int selectedIndex = 0;
//   bool isLoading = true;
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchCategories();
//   }

//   Future<void> fetchCategories() async {
//     try {
//       QuerySnapshot snapshot = await _firestore.collection('Category').get();
//       List<String> fetchedCategories =
//           snapshot.docs.map((doc) => doc['name'] as String).toList();
//       setState(() {
//         categories = fetchedCategories;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching categories: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void filterCategories(String query) {
//     List<String> filteredList = categories.where((category) {
//       return category.toLowerCase().contains(query.toLowerCase());
//     }).toList();
//     setState(() {
//       var filteredCategories = filteredList;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? const Center(child: CircularProgressIndicator())
//         : Column(
//             children: [
//               Container(
//                 height: 50,
//                 margin: const EdgeInsets.only(top: 25),
//                 padding: const EdgeInsets.symmetric(horizontal: 25),
//                 child: TextField(
//                   controller: searchController,
//                   style: const TextStyle(color: Color(0xFFB1A6A6)),
//                   decoration: InputDecoration(
//                     hintText: 'Hunt for your daily delight!',
//                     hintStyle: const TextStyle(color: Color(0xFFB1A6A6)),
//                     prefixIcon: const Icon(Icons.search),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                   ),
//                   onChanged: (value) {
//                     filterCategories(value);
//                   },
//                 ),
//               ),
//               Container(
//                 height: 60,
//                 margin: const EdgeInsets.symmetric(horizontal: 25),
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: categories.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedIndex = index;
//                         });
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         margin: EdgeInsets.only(
//                             right: index == categories.length - 1 ? 0 : 10,
//                             left: index == 0 ? 0 : 10,
//                             top: 15),
//                         decoration: BoxDecoration(
//                           color: selectedIndex == index
//                               ? const Color(0xFFE5CAC3)
//                               : Colors.transparent,
//                           border: Border.all(
//                             color: selectedIndex == index
//                                 ? Colors.transparent
//                                 : Colors.transparent,
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Center(
//                           child: Text(
//                             categories[index],
//                             style: TextStyle(
//                                 color: selectedIndex == index
//                                     ? const Color(0xFF4B371C)
//                                     : Colors.black,
//                                 fontWeight: selectedIndex == index
//                                     ? FontWeight.bold
//                                     : FontWeight.w400,
//                                 fontSize: 15),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.symmetric(
//                     horizontal: 25,
//                     vertical: 5), // Add horizontal and vertical margin here
//                 child: const Divider(),
//               ), // Add the Divider widget here
//               Expanded(
//                 child: Center(
//                   child: Text(
//                     'Selected: ${categories[selectedIndex]}',
//                     style: const TextStyle(fontSize: 24),
//                   ),
//                 ),
//               ),
//             ],
//           );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:onlyu_cafe/model/menu_item.dart';
import 'package:onlyu_cafe/product_management/view_product_details.dart';
import 'package:onlyu_cafe/router/router.dart';
import 'package:onlyu_cafe/service/cart_service.dart';

class MenuPage extends StatefulWidget {
  final String orderType;
  const MenuPage({Key? key, this.orderType = ''}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> categories = [];
  int selectedIndex = 0;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  Future<void> _toggleAvailability(MenuItem menuItem) async {
    try {
      await _firestore.collection('menu_items').doc(menuItem.id).update({
        'isAvailable': !menuItem.isAvailable,
      });
    } catch (e) {
      print('Error updating availability: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Category').get();
      List<String> fetchedCategories =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterCategories(String query) {
    List<String> filteredList = categories.where((category) {
      return category.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      var filteredCategories = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            color: const Color.fromARGB(255, 248, 240, 238),
            child: Column(
              children: [
                // Your search bar and category selector code remains the same
                // ...
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 25),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Color(0xFFB1A6A6)),
                    decoration: InputDecoration(
                      hintText: 'Hunt for your daily delight!',
                      hintStyle: const TextStyle(color: Color(0xFFB1A6A6)),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      filterCategories(value);
                    },
                  ),
                ),
                Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          margin: EdgeInsets.only(
                              right: index == categories.length - 1 ? 0 : 10,
                              left: index == 0 ? 0 : 10,
                              top: 15),
                          decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? const Color(0xFFE5CAC3)
                                : Colors.transparent,
                            border: Border.all(
                              color: selectedIndex == index
                                  ? Colors.transparent
                                  : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                  color: selectedIndex == index
                                      ? const Color(0xFF4B371C)
                                      : Colors.black,
                                  fontWeight: selectedIndex == index
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5), // Add horizontal and vertical margin here
                  child: const Divider(),
                ), // Add the Divider widget here

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('menu_items')
                        .where('category', isEqualTo: categories[selectedIndex])
                        .where('isAvailable', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error fetching menu items'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No menu items found'));
                      }

                      List<MenuItem> menuItems = snapshot.data!.docs
                          .map((doc) => MenuItem.fromDocument(doc))
                          .toList();

                      return ListView.separated(
                        itemCount: menuItems.length,
                        itemBuilder: (context, index) {
                          MenuItem menuItem = menuItems[index];
                          return ListTile(
                            leading: menuItem.imageUrl.isNotEmpty
                                ? Image.network(menuItem.imageUrl,
                                    width: 60, height: 60, fit: BoxFit.cover)
                                : Icon(Icons.image),
                            title: Text(menuItem.name),
                            subtitle: Text(
                                '${menuItem.description}\n${menuItem.price.toStringAsFixed(2)}'),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: Icon(Icons.add_shopping_cart),
                              onPressed: () {
                                if (!isAuthenticated()) {
                                  context.go("/login");
                                } else {
                                  // CartService().addtoCart(menuItem.id);
                                  CartService()
                                      .addtoCart(menuItem.id)
                                      .then((_) {
                                    context.push("/cart",
                                        extra: widget.orderType);
                                  });
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewProductDetails(
                                      item: menuItem,
                                    ),
                                  ));

                              setState(() {
                                selectedIndex = index;
                              });
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}