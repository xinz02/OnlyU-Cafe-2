import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyu_cafe/model/menu_item.dart';
import 'package:onlyu_cafe/product_management/view_product_details.dart';
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
  List<String> filteredCategories = [];
  int selectedIndex = 0;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  List<MenuItem> menuItems = []; // Store all menu items
  List<MenuItem> filteredMenuItems = []; // Store filtered menu items

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
            .where((menuItem) =>
                menuItem.category == categories[selectedIndex] &&
                menuItem.isAvailable)
            .toList();
      });
    } catch (e) {
      print('Error fetching menu items: $e');
    }
  }

  void filterMenuItemsByName(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (isSearching) {
        filteredMenuItems = menuItems
            .where((menuItem) =>
                menuItem.name.toLowerCase().contains(query.toLowerCase()) &&
                menuItem.isAvailable)
            .toList();
      } else {
        filteredMenuItems = menuItems
            .where((menuItem) =>
                menuItem.category == filteredCategories[selectedIndex] &&
                menuItem.isAvailable)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
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
                        hintText: 'Search for menu items...',
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
                        filterMenuItemsByName(value.toLowerCase());
                      },
                    ),
                  ),
                  if (!isSearching)
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
                                selectedIndex = index;
                                filterMenuItemsByName(searchController.text.toLowerCase());
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              margin: EdgeInsets.only(
                                  right: index == filteredCategories.length - 1 ? 0 : 10,
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
                                  filteredCategories[index],
                                  style: TextStyle(
                                    color: selectedIndex == index
                                        ? const Color(0xFF4B371C)
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
                  if (!isSearching)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                      child: const Divider(),
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
                              : const Icon(Icons.image),
                          title: Text(menuItem.name),
                          subtitle: Text(
                              '${menuItem.description}\n${menuItem.price.toStringAsFixed(2)}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () {
                              CartService().addtoCart(menuItem.id).then((_) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewProductDetails(item: menuItem),
                                  ),
                                );
                              });
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewProductDetails(item: menuItem),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
