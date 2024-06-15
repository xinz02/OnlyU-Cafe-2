// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:onlyu_cafe/admin/admin_order.dart';
// import 'package:onlyu_cafe/product_management/add_menu_item.dart';
// import 'package:onlyu_cafe/model/menu_item.dart';

// class AdminMenuPage extends StatefulWidget {
//   const AdminMenuPage({super.key});

//   @override
//   State<AdminMenuPage> createState() => _AdminMenuPageState();
// }

// class _AdminMenuPageState extends State<AdminMenuPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<MenuItem> _menuItems = [];
//   bool _isFetchingMenuItems = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchMenuItems();
//   }

//   Future<void> _fetchMenuItems() async {
//     setState(() {
//       _isFetchingMenuItems = true;
//     });

//     try {
//       QuerySnapshot snapshot = await _firestore.collection('menu_items').get();
//       List<MenuItem> fetchedMenuItems =
//           snapshot.docs.map((doc) => MenuItem.fromDocument(doc)).toList();
//       setState(() {
//         _menuItems = fetchedMenuItems;
//       });
//     } catch (e) {
//       print('Error fetching menu items: $e');
//     }

//     setState(() {
//       _isFetchingMenuItems = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Menu Items')),
//       body: _isFetchingMenuItems
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _menuItems.length,
//               itemBuilder: (context, index) {
//                 MenuItem menuItem = _menuItems[index];
//                 return ListTile(
//                   leading: menuItem.imageUrl.isNotEmpty
//                       ? Image.network(menuItem.imageUrl,
//                           width: 50, height: 50, fit: BoxFit.cover)
//                       : Icon(Icons.image),
//                   title: Text(menuItem.name),
//                   subtitle: Text(
//                       '${menuItem.description}\n${menuItem.price.toStringAsFixed(2)}'),
//                   isThreeLine: true,
//                   trailing: menuItem.isAvailable
//                       ? Icon(Icons.check_circle, color: Colors.green)
//                       : Icon(Icons.cancel, color: Colors.red),
//                 );
//               },
//             ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:onlyu_cafe/model/menu_item.dart';
// import 'package:onlyu_cafe/product_management/edit_menu_item.dart';

// class AdminMenuPage extends StatefulWidget {
//   const AdminMenuPage({super.key});

//   @override
//   State<AdminMenuPage> createState() => _AdminMenuPageState();
// }

// class _AdminMenuPageState extends State<AdminMenuPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   List<String> categories = [];
//   List<String> filteredCategories = [];
//   int selectedIndex = 0;
//   bool isLoading = true;
//   TextEditingController searchController = TextEditingController();

//   Future<void> _toggleAvailability(MenuItem menuItem) async {
//     try {
//       await _firestore.collection('menu_items').doc(menuItem.id).update({
//         'isAvailable': !menuItem.isAvailable,
//       });
//     } catch (e) {
//       print('Error updating availability: $e');
//     }
//   }

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
//         filteredCategories = fetchedCategories;
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
//       filteredCategories = filteredList;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? const Center(child: CircularProgressIndicator())
//         : Container(
//             color: const Color.fromARGB(255, 248, 240, 238),
//             child: Column(
//               children: [
//                 Container(
//                   height: 50,
//                   margin: const EdgeInsets.only(top: 25),
//                   padding: const EdgeInsets.symmetric(horizontal: 25),
//                   child: TextField(
//                     controller: searchController,
//                     style: const TextStyle(color: Color(0xFFB1A6A6)),
//                     decoration: InputDecoration(
//                       hintText: 'Hunt for your daily delight!',
//                       hintStyle: const TextStyle(color: Color(0xFFB1A6A6)),
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                     ),
//                     onChanged: (value) {
//                       filterCategories(value);
//                     },
//                   ),
//                 ),
//                 Container(
//                   height: 60,
//                   margin: const EdgeInsets.symmetric(horizontal: 25),
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: filteredCategories.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedIndex =
//                                 categories.indexOf(filteredCategories[index]);
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           margin: EdgeInsets.only(
//                               right: index == filteredCategories.length - 1
//                                   ? 0
//                                   : 10,
//                               left: index == 0 ? 0 : 10,
//                               top: 15),
//                           decoration: BoxDecoration(
//                             color: selectedIndex ==
//                                     categories
//                                         .indexOf(filteredCategories[index])
//                                 ? const Color(0xFFE5CAC3)
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: selectedIndex ==
//                                       categories
//                                           .indexOf(filteredCategories[index])
//                                   ? Colors.transparent
//                                   : Colors.transparent,
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Center(
//                             child: Text(
//                               filteredCategories[index],
//                               style: TextStyle(
//                                   color: selectedIndex ==
//                                           categories.indexOf(
//                                               filteredCategories[index])
//                                       ? const Color(0xFF4B371C)
//                                       : Colors.black,
//                                   fontWeight: selectedIndex ==
//                                           categories.indexOf(
//                                               filteredCategories[index])
//                                       ? FontWeight.bold
//                                       : FontWeight.w400,
//                                   fontSize: 15),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Container(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
//                   child: const Divider(),
//                 ),
//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: _firestore
//                         .collection('menu_items')
//                         .where('category', isEqualTo: categories[selectedIndex])
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       if (snapshot.hasError) {
//                         return const Center(
//                             child: Text('Error fetching menu items'));
//                       }

//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(child: Text('No menu items found'));
//                       }

//                       List<MenuItem> menuItems = snapshot.data!.docs
//                           .map((doc) => MenuItem.fromDocument(doc))
//                           .toList();

//                       return ListView.separated(
//                         itemCount: menuItems.length,
//                         itemBuilder: (context, index) {
//                           MenuItem menuItem = menuItems[index];
//                           return ListTile(
//                             leading: menuItem.imageUrl.isNotEmpty
//                                 ? Image.network(menuItem.imageUrl,
//                                     width: 60, height: 60, fit: BoxFit.cover)
//                                 : const Icon(Icons.image),
//                             title: Text(menuItem.name),
//                             subtitle: Text(
//                                 '${menuItem.description}\n${menuItem.price.toStringAsFixed(2)}'),
//                             isThreeLine: true,
//                             trailing: Switch(
//                               activeColor: Colors.green,
//                               value: menuItem.isAvailable,
//                               onChanged: (value) {
//                                 _toggleAvailability(menuItem);
//                               },
//                             ),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => EditMenuItemForm(
//                                     menuItem: menuItem,
//                                     onUpdate: (updatedMenuItem) {
//                                       // Handle the update of the menu item
//                                       // For example, update the state or perform any other action
//                                     },
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                         separatorBuilder: (context, index) {
//                           return const Divider();
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlyu_cafe/product_management/edit_menu_item.dart';
import 'package:onlyu_cafe/model/menu_item.dart';
import 'package:onlyu_cafe/product_management/edit_menu_item.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> categories = [];
  List<String> filteredCategories = [];
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
        filteredCategories = fetchedCategories;
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
      filteredCategories = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 248, 240, 238),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: const Color.fromARGB(255, 248, 240, 238),
                child: Column(
                  children: [
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
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
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = categories
                                    .indexOf(filteredCategories[index]);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              margin: EdgeInsets.only(
                                  right: index == filteredCategories.length - 1
                                      ? 0
                                      : 10,
                                  left: index == 0 ? 0 : 10,
                                  top: 15),
                              decoration: BoxDecoration(
                                color: selectedIndex ==
                                        categories
                                            .indexOf(filteredCategories[index])
                                    ? const Color(0xFFE5CAC3)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selectedIndex ==
                                          categories.indexOf(
                                              filteredCategories[index])
                                      ? Colors.transparent
                                      : Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  filteredCategories[index],
                                  style: TextStyle(
                                      color: selectedIndex ==
                                              categories.indexOf(
                                                  filteredCategories[index])
                                          ? const Color(0xFF4B371C)
                                          : Colors.black,
                                      fontWeight: selectedIndex ==
                                              categories.indexOf(
                                                  filteredCategories[index])
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
                          horizontal: 25, vertical: 5),
                      child: const Divider(),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('menu_items')
                            .where('category',
                                isEqualTo: categories[selectedIndex])
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error fetching menu items'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('No menu items found'));
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
                                : const Icon(Icons.image),
                            title: Text(menuItem.name),
                            subtitle: Text(
                                '${menuItem.description}\n${menuItem.price.toStringAsFixed(2)}'),
                            isThreeLine: true,
                            trailing: Switch(
                              activeColor: Colors.green,
                              value: menuItem.isAvailable,
                              onChanged: (value) {
                                _toggleAvailability(menuItem);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditMenuItemForm(
                                    menuItem: menuItem,
                                    onUpdate: (updatedMenuItem) {
                                      // Handle the update of the menu item
                                      // For example, update the state or perform any other action
                                    },
                                  ),
                                ),
                              );
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
    ));
  }
}
