import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/models/grocery_items.dart';
import 'package:shopping_list_app/new_item.dart';
import 'package:http/http.dart' as http;
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loaditems();
  }
 void _loaditems() async {
  final url = Uri.parse('https://flutterproject-d0387-default-rtdb.firebaseio.com/albums.json');
  final _response = await http.get(url);
  print(_response.body);

  if (_response.body.trim() == 'null') {
    setState(() {
      _groceryItems = [];
      isEmpty = true;
      _isLoading = false; // stop loading
    });
    return;
  }

  final Map<String, dynamic> data = json.decode(_response.body);
final List<GroceryItem> loadedItems = [];

for (final item in data.entries) {
  loadedItems.add(GroceryItem(
    id: item.key,
    name: item.value['name'],
    quantity: item.value['quantity'],
    category: categories.values.firstWhere((cat) => cat.name == item.value['category']),
  ));
}


  setState(() {
    _groceryItems = loadedItems;
    isEmpty = _groceryItems.isEmpty;
    _isLoading = false; // stop loading
  });
}

  
  bool isEmpty=false;
   List<GroceryItem> _groceryItems = [];
  void _addNewItem() async {
    await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(builder: (context)=>  NewItem() ),) ;
    // Logic to add a new grocery item
    _loaditems(); 
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Grocery List'),
  actions: [
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        _addNewItem();
      },
    ),
     IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        FirebaseAuth.instance.signOut();
      },
    ),
  ],
),

      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : isEmpty
        ? const Center(child: Text('No items in the list. Please add some items.'))
        : ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey(_groceryItems[index].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  setState(() {
                    final url = Uri.parse('https://flutterproject-d0387-default-rtdb.firebaseio.com/albums/${_groceryItems[index].id}.json');
                    http.delete(url);
                    _groceryItems.removeAt(index);
                    isEmpty = _groceryItems.isEmpty;
                  });
                },
                child: ListTile(
                  title: Text(_groceryItems[index].name),
                  leading: CircleAvatar(
                    backgroundColor: _groceryItems[index].category.color,
                    child: Text(_groceryItems[index].quantity.toString()),
                  ),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              );
            },
          ),

    );
  }
}