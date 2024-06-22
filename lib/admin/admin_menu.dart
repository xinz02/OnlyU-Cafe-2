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
  List<String> filteredCategories = [];
  int selectedIndex = 0;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  List<MenuItem> menuItems = []; // Store all menu items
  List<MenuItem> filteredMenuItems = []; // Store filtered menu items

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
      fetchMenuItems(); // Fetch menu items after fetching categories
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMenuItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('menu_items').get();
      List<MenuItem> fetchedMenuItems =
          snapshot.docs.map((doc) => MenuItem.fromDocument(doc)).toList();
      setState(() {
        menuItems = fetchedMenuItems;
        // Initialize filteredMenuItems with items of the selected category initially
        filteredMenuItems = fetchedMenuItems
            .where((menuItem) => menuItem.category == categories[selectedIndex])
            .toList();
      });
    } catch (e) {
      print('Error fetching menu items: $e');
    }
  }

  void filterMenuItemsByName(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      // Update filtered menu items based on the search query
      if (isSearching) {
        filteredMenuItems = menuItems.where((menuItem) =>
            menuItem.name.toLowerCase().contains(query.toLowerCase())).toList();
      } else {
        // Filter by selected category
        String selectedCategory = filteredCategories[selectedIndex];
        filteredMenuItems = menuItems.where((menuItem) =>
            menuItem.category == selectedCategory).toList();
      }
    });
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
                        filterMenuItemsByName(value.toLowerCase()); // Convert to lowercase for case-insensitive search
                      },
                    ),
                  ),
                  if (!isSearching) // Show category selector only if not searching
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
                                // Update filtered menu items when a category is selected
                                filteredMenuItems = menuItems.where((menuItem) =>
                                    menuItem.category == categories[selectedIndex]).toList();
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
                  if (!isSearching) // Only show this divider if not searching
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                      child: Divider(),
                    ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredMenuItems.length,
                      itemBuilder: (context, index) {
                        MenuItem menuItem = filteredMenuItems[index];
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
                                builder: (context) =>
                                    EditMenuItemForm(
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
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
