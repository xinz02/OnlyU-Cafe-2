import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyu_cafe/model/menu_item.dart';
import 'package:onlyu_cafe/product_management/edit_menu_item.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({Key? key}) : super(key: key);

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> categories = [];
  int selectedIndex = 0;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

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

  Stream<QuerySnapshot> filterMenuItems() {
    if (selectedIndex >= 0 &&
        selectedIndex < categories.length &&
        !isSearching) {
      return _firestore
          .collection('menu_items')
          .where('category', isEqualTo: categories[selectedIndex])
          .snapshots();
    } else {
      return _firestore.collection('menu_items').snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 240, 238),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Color.fromARGB(255, 248, 240, 238),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(top: 25),
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: Color(0xFFB1A6A6)),
                      decoration: InputDecoration(
                        hintText: 'Search for menu items...',
                        hintStyle: TextStyle(color: Color(0xFFB1A6A6)),
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          isSearching = value.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  if (!isSearching)
                    Container(
                      height: 60,
                      margin: EdgeInsets.symmetric(horizontal: 25),
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
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              margin: EdgeInsets.only(
                                  right: index == categories.length - 1 ? 0 : 10,
                                  left: index == 0 ? 0 : 10,
                                  top: 15),
                              decoration: BoxDecoration(
                                color: selectedIndex == index
                                    ? Color(0xFFE5CAC3)
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
                                        ? Color(0xFF4B371C)
                                        : Colors.black,
                                    fontWeight: selectedIndex == index
                                        ? FontWeight.bold
                                        : FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    child: Divider(),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: isSearching
                          ? _firestore
                              .collection('menu_items')
                              .where('name', isGreaterThanOrEqualTo: searchController.text.trim())
                              .where('name', isLessThanOrEqualTo: searchController.text.trim() + '\uf8ff')
                              .snapshots()
                          : filterMenuItems(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error fetching menu items'));
                        }

                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(
                              child: Text('No menu items found'));
                        }

                        List<MenuItem> menuItems = snapshot.data!.docs
                            .map((doc) => MenuItem.fromDocument(doc))
                            .toList();

                        if (isSearching) {
                          // Perform substring search case insensitive
                          String query = searchController.text.toLowerCase();
                          menuItems.retainWhere((menuItem) =>
                              menuItem.name.toLowerCase().contains(query));
                        }

                        return ListView.separated(
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            MenuItem menuItem = menuItems[index];
                            return ListTile(
                              leading: menuItem.imageUrl.isNotEmpty
                                  ? Image.network(
                                      menuItem.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image),
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
                            return Divider();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
