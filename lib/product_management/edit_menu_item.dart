import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:onlyu_cafe/model/menu_item.dart';

class EditMenuItemForm extends StatefulWidget {
  final MenuItem menuItem;
  final Function(MenuItem) onUpdate;

  const EditMenuItemForm(
      {Key? key, required this.menuItem, required this.onUpdate})
      : super(key: key);

  @override
  _EditMenuItemFormState createState() => _EditMenuItemFormState();
}

class _EditMenuItemFormState extends State<EditMenuItemForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price;
  late String _category;
  File? _imageFile;
  bool _isLoading = false;
  List<String> _categories = ['Please select category'];
  bool _isFetchingCategories = false;

  @override
  void initState() {
    super.initState();
    _name = widget.menuItem.name;
    _description = widget.menuItem.description;
    _price = widget.menuItem.price;
    _category = widget.menuItem.category;
    _fetchImage();
    _fetchCategories();
  }

  Future<void> _fetchImage() async {
    try {
      final String imageUrl = widget.menuItem.imageUrl;
      final HttpClientRequest request = await HttpClient()
          .getUrl(Uri.parse(imageUrl.replaceFirst('http://', 'https://')));
      final HttpClientResponse response = await request.close();
      final Uint8List bytes =
          await consolidateHttpClientResponseBytes(response);
      final String tempPath = (await getTemporaryDirectory()).path;
      final File imageFile =
          File('$tempPath/${DateTime.now().millisecondsSinceEpoch}.png');
      await imageFile.writeAsBytes(bytes);
      setState(() {
        _imageFile = imageFile;
      });
    } catch (e) {
      print('Error fetching image: $e');
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isFetchingCategories = true;
    });

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Category').get();
      List<String> fetchedCategories =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        _categories.addAll(fetchedCategories);
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }

    setState(() {
      _isFetchingCategories = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<String> _uploadImageToStorage() async {
    try {
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('menu_images')
          .child(
              '${DateTime.now().millisecondsSinceEpoch}-${_imageFile!.path.split('/').last}');

      await storageRef.putFile(_imageFile!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image to storage: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<void> _updateMenuItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        String imageUrl = widget.menuItem.imageUrl;
        if (_imageFile != null &&
            _imageFile!.path != widget.menuItem.imageUrl) {
          imageUrl = await _uploadImageToStorage();
        }

        MenuItem updatedMenuItem = MenuItem(
          id: widget.menuItem.id,
          name: _name,
          description: _description,
          price: _price,
          imageUrl: imageUrl,
          isAvailable: widget.menuItem.isAvailable,
          category: _category,
        );

        await FirebaseFirestore.instance
            .collection('menu_items')
            .doc(widget.menuItem.id)
            .update({
          'name': _name,
          'description': _description,
          'price': _price,
          'category': _category,
          'imageUrl': imageUrl,
        });

        widget.onUpdate(updatedMenuItem);
        Navigator.pop(context);
      } catch (e) {
        print('Error updating menu item: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMenuItem() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('menu_items')
                    .doc(widget.menuItem.id)
                    .delete();

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu Item'),
        backgroundColor: const Color.fromARGB(255, 229, 202, 195),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox.expand(
              child: Container(
                color: const Color.fromARGB(255, 248, 240, 238),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextFormField(
                          initialValue: _name,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _name = value!;
                          },
                        ),
                        const SizedBox(height: 10),
                        _isFetchingCategories
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                    labelText: 'Category'),
                                value: _category,
                                items: _categories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _category = newValue!;
                                  });
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value == 'Please select category') {
                                    return 'Please select a valid category';
                                  }
                                  return null;
                                },
                              ),
                        TextFormField(
                          initialValue: _description,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _description = value!;
                          },
                        ),
                        TextFormField(
                          initialValue: _price.toStringAsFixed(2),
                          decoration: const InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a price';
                            }
                            try {
                              double.parse(value);
                            } catch (e) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _price = double.parse(value!);
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text("Edit product image: "),
                            const SizedBox(
                              width: 15,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: _pickImage,
                              child: const Text('Pick Image'),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        if (_imageFile != null)
                          Image.file(
                            _imageFile!,
                            height: 500,
                            width: 500,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _updateMenuItem,
                              child: const Text('Save Changes'),
                            ),
                            ElevatedButton(
                              onPressed: _deleteMenuItem,
                              child: const Text(
                                'Delete Item',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}