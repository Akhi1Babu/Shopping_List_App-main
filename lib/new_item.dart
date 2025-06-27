import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_items.dart';
import 'package:http/http.dart' as http; // we have to buddle it in http..
import 'dart:convert';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  String? itemName = "";
  int quantity = 1;
  var selectedCategory = categories[Categories.vegetables];
  Future<http.Response> createAlbum(
      String name, int quantity, Category category) {
    return http.post(
      Uri.parse(
          'https://flutterproject-d0387-default-rtdb.firebaseio.com/albums.json'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(
        {
          "name": itemName,
          "quantity": quantity,
          "category": selectedCategory!.name,
        },
      ),
    );
  }

  void saveItem() async {
    // Logic to save the item
    // This function can be called when the form is submitted
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
     await createAlbum(itemName!, quantity, selectedCategory!);
     if (!mounted) return;
     Navigator.of(context).pop();
    }
  }

  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an item name';
                    }
                    if (value.length < 3) {
                      return 'Item name must be at least 3 characters long';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // Save the item name
                    // This can be used later to save the item in a database or list
                    itemName = value;
                    print(itemName);
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        initialValue: "1",
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a quantity';
                          } else if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          } else if (int.parse(value) <= 0) {
                            return 'Quantity must be greater than 0';
                          }
                          return null;
                        },
                        onSaved: (ValueKey) {
                          quantity = int.parse(ValueKey!);
                          // Save the quantity
                          // This can be used later to save the item in a database or list
                          print(quantity);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                        child: DropdownButtonFormField(
                            value: selectedCategory,
                            items: [
                              for (var category in categories.entries)
                                DropdownMenuItem(
                                  value: category.value,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 15,
                                        height: 15,
                                        color: category.value.color,
                                      ),
                                      SizedBox(width: 8),
                                      Text(category.value.name),
                                    ],
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                                print(selectedCategory);
                              });
                            }))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    _formkey.currentState!.reset();
                  },
                  child: Text("Reset"),
                  style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 30, 133, 193),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    saveItem();
                  },
                  child: Text("Add Item"),
                  style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 30, 133, 193),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                )
              ],
            )),
      ),
    );
  }
}
