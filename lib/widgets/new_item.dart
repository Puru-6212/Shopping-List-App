import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http; //package for connecting to firebase
import 'package:provider/provider.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shopping_list/providers/ad_provider.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
          'shopping-list-app-990e8-default-rtdb.firebaseio.com',
          'shopping-list.json'); //the post method requires a unique url/uri ,  shopping-list is a heading created in firebase
      final response = await http.post(
        url, //it will generate a unique id in firebase to  store each data
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          //encoding map to json
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category':
              _selectedCategory.title, //all these 3 will be  stored in database
        }),
      );
      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        //check if context is mounted before popping back
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory));
    }
  }

  @override
  void initState() {
    super.initState();
    Adprovider adProvider = Provider.of<Adprovider>(context, listen: false);
    adProvider.initializeFulPageAd();
    }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( //used to note that the page is being popped 
        onWillPop: () async {
          Adprovider adProvider =
              Provider.of<Adprovider>(context, listen: false);
          if (adProvider.isFullPageAdLoaded) {
            adProvider.fullPageAD.show();
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Add a new Item')),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text('Name'),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length >= 50) {
                        return 'Must be between 1 and 50 character!!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredName = value!;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            label: Text('Quantity'),
                          ),
                          initialValue: _enteredQuantity.toString(),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null ||
                                int.tryParse(value)! <= 0) {
                              return 'Must be valid, positive number!!';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _enteredQuantity = int.parse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: DropdownButtonFormField(
                          value: _selectedCategory,
                          items: [
                            for (final category in categories.entries)
                              DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(category.value.title)
                                  ],
                                ),
                              )
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                _formkey.currentState!.reset();
                              },
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: _isSending ? null : _saveItem,
                        child: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Add Item'),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
