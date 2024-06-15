// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:onlyu_cafe/model/menu_item.dart';
// import 'package:onlyu_cafe/service/menu_database.dart'; // Adjust the import path as necessary
// import 'package:path/path.dart' as path;

// class AddMenuItemPage extends StatefulWidget {
//   @override
//   _AddMenuItemPageState createState() => _AddMenuItemPageState();
// }

// class _AddMenuItemPageState extends State<AddMenuItemPage> {
//   final _formKey = GlobalKey<FormState>();
//   final MenuDatabaseMethods _menudatabaseMethods = MenuDatabaseMethods();
//   String _name = '';
//   String _description = '';
//   double _price = 0.0;
//   File? _imageFile;
//   bool _isAvailable = true;
//   bool _isLoading = false;
//   String _category = '';
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // final ImagePicker _picker = ImagePicker();

//   // Future<void> _pickImage() async {
//   //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//   //   setState(() {
//   //     _imageFile = pickedFile != null ? File(pickedFile.path) : null;
//   //   });
//   // }

//   // Future<void> _submitForm() async {
//   //   if (_formKey.currentState!.validate()) {
//   //     _formKey.currentState!.save();
//   //     setState(() {
//   //       _isLoading = true;
//   //     });

//   //     if (_imageFile != null) {
//   //       String imageUrl = await _databaseMethods.uploadImage(_imageFile!);
//   //       if (imageUrl.isNotEmpty) {
//   //         MenuItem menuItem = MenuItem(
//   //           id: '',
//   //           name: _name,
//   //           description: _description,
//   //           price: _price,
//   //           imageFile: imageUrl.getDownloadURL(),
//   //           isAvailable: _isAvailable,
//   //           category: _category,
//   //         );
//   //         await _databaseMethods.addMenuItem(menuItem);
//   //         Navigator.pop(context);
//   //       } else {
//   //         // Handle upload error
//   //       }
//   //     } else {
//   //       // Handle image not picked error
//   //     }

//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       _imageFile = pickedFile != null ? File(pickedFile.path) : null;
//     });
//   }

//   Future<String> _uploadImage(File imageFile) async {
//     String fileName = path.basename(imageFile.path);
//     Reference storageRef =
//         FirebaseStorage.instance.ref().child('menu_images/$fileName');
//     UploadTask uploadTask = storageRef.putFile(imageFile);
//     TaskSnapshot taskSnapshot = await uploadTask;
//     return await taskSnapshot.ref.getDownloadURL();
//   }

//   Future<List<String>> fetchCategories() async {
//     List<String> fetchedCategories;
//     // try {
//     QuerySnapshot snapshot = await _firestore.collection('Category').get();

//     fetchedCategories =
//         snapshot.docs.map((doc) => doc['name'] as String).toList();
//     //   return fetchedCategories;
//     // } catch (e) {
//     //   print('Error fetching categories: $e');
//     // }
//     return fetchedCategories;
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       setState(() {
//         _isLoading = true;
//       });

//       if (_imageFile != null) {
//         try {
//           String imageUrl = await _uploadImage(_imageFile!);
//           await FirebaseFirestore.instance.collection('menu_items').add({
//             'name': _name,
//             'description': _description,
//             'price': _price,
//             'imageUrl': imageUrl,
//             'isAvailable': _isAvailable,
//             'category': _category,
//           });
//           Navigator.pop(context);
//         } catch (e) {
//           // Handle upload error
//           print('Error uploading image: $e');
//         }
//       } else {
//         // Handle image not picked error
//         print('Image not selected.');
//       }

//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Menu Item')),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: ListView(
//                   children: [
//                     TextFormField(
//                       decoration: InputDecoration(labelText: 'Name'),
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please enter a name';
//                         }
//                         return null;
//                       },
//                       onSaved: (value) {
//                         _name = value!;
//                       },
//                     ),
//                     DropdownButton(items: fetchC, onChanged: onChanged),
//                     TextFormField(
//                       decoration: InputDecoration(labelText: 'Description'),
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please enter a description';
//                         }
//                         return null;
//                       },
//                       onSaved: (value) {
//                         _description = value!;
//                       },
//                     ),
//                     TextFormField(
//                       decoration: InputDecoration(labelText: 'Price'),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please enter a price';
//                         }
//                         return null;
//                       },
//                       onSaved: (value) {
//                         _price = double.parse(value!);
//                       },
//                     ),
//                     SizedBox(height: 10),
//                     _imageFile != null
//                         /? Image.file(
//                             _imageFile!,
//                             height: 150,
//                           )
//                         : Container(),
//                     ElevatedButton(
//                       onPressed: _pickImage,
//                       child: Text('Pick Image'),
//                     ),
//                     SwitchListTile(
//                       title: Text('Available'),
//                       value: _isAvailable,
//                       onChanged: (bool value) {
//                         setState(() {
//                           _isAvailable = value;
//                         });
//                       },
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _submitForm,
//                       child: Text('Add Menu Item'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AddMenuItemPage extends StatefulWidget {
  @override
  _AddMenuItemPageState createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _price = 0.0;
  File? _imageFile;
  bool _isAvailable = true;
  bool _isLoading = false;
  String _category = 'Please select category';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _categories = ['Please select category'];
  bool _isFetchingCategories = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isFetchingCategories = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore.collection('Category').get();
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = path.basename(imageFile.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('menu_images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      if (_imageFile != null) {
        try {
          String imageUrl = await _uploadImage(_imageFile!);
          await FirebaseFirestore.instance.collection('menu_items').add({
            'name': _name,
            'description': _description,
            'price': _price,
            'imageUrl': imageUrl,
            'isAvailable': _isAvailable,
            'category': _category,
          });
          Navigator.pop(context);
        } catch (e) {
          print('Error uploading image: $e');
        }
      } else {
        print('Image not selected.');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Menu Item'),
        backgroundColor: const Color.fromARGB(255, 229, 202, 195),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: const Color.fromARGB(255, 248, 240, 238),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
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
                      _isFetchingCategories
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              decoration:
                                  const InputDecoration(labelText: 'Category'),
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
                                if (value == 'Please select category') {
                                  return 'Please select a valid category';
                                }
                                return null;
                              },
                            ),
                      TextFormField(
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
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _price = double.parse(value!);
                        },
                      ),
                      const SizedBox(height: 10),
                      _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              height: 150,
                            )
                          : Container(),
                      Row(
                        children: [
                          const Text("Upload product image: "),
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
                      SwitchListTile(
                        title: const Text('Available'),
                        value: _isAvailable,
                        activeColor: Colors.green,
                        onChanged: (bool value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 195, 133, 134),
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text(
                          'Add Menu Item',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
