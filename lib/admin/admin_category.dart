import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoryPage extends StatefulWidget {
  const AdminCategoryPage({super.key});

  @override
  _AdminCategoryPageState createState() => _AdminCategoryPageState();
}

class _AdminCategoryPageState extends State<AdminCategoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('Category').orderBy('id').get();
      List<String> fetchedCategories =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatCategoryName(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  Future<void> addCategory(String name) async {
    name = formatCategoryName(name);
    bool exists = categories.contains(name);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Category already exists')));
      return;
    }

    try {
      QuerySnapshot snapshot = await _firestore.collection('Category').get();
      int newId = snapshot.size + 1;
      DocumentReference docRef = _firestore.collection('Category').doc();
      await docRef.set({'id': newId, 'name': name});
      fetchCategories(); // Refresh the categories list
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  Future<void> deleteCategory(String name) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .where('category', isEqualTo: name)
          .get();
      if (snapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('This category has associated items.')));
        return;
      }

      QuerySnapshot categorySnapshot = await _firestore
          .collection('Category')
          .where('name', isEqualTo: name)
          .get();
      for (var doc in categorySnapshot.docs) {
        await doc.reference.delete();
      }

      fetchCategories(); // Refresh the categories list
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  Future<void> editCategory(String oldName, String newName) async {
    newName = formatCategoryName(newName);
    if (categories.contains(newName)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Category already exists')));
      return;
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .where('category', isEqualTo: oldName)
          .get();
      WriteBatch batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'category': newName});
      }

      QuerySnapshot categorySnapshot = await _firestore
          .collection('Category')
          .where('name', isEqualTo: oldName)
          .get();
      for (var doc in categorySnapshot.docs) {
        batch.update(doc.reference, {'name': newName});
      }

      await batch.commit();
      fetchCategories(); // Refresh the categories list
    } catch (e) {
      print('Error editing category: $e');
    }
  }

  void _showAddCategoryDialog() {
    TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(hintText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String name = categoryController.text.trim();
                if (name.isNotEmpty) {
                  addCategory(name);
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(String oldName) {
    TextEditingController categoryController =
        TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(hintText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newName = categoryController.text.trim();
                if (newName.isNotEmpty && newName != oldName) {
                  editCategory(oldName, newName);
                }
                Navigator.of(context).pop();
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String categoryName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteCategory(categoryName);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      appBar: AppBar(
        title: Text('All Categories'),
        backgroundColor: const Color.fromARGB(255, 229, 202, 195),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String categoryName = categories[index];
                return ListTile(
                  title: Text(categoryName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditCategoryDialog(categoryName),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            _showDeleteConfirmationDialog(categoryName),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
