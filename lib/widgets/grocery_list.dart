import 'dart:convert';
//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/data/categories.dart';
//import 'package:flutter/widgets.dart';
//import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/providers/ad_provider.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http; //package for connecting to firebase
//import 'package:google_mobile_ads/google_mobile_ads.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  /*InterstitialAd? _interstitialAd;
  /*final adUnitId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/1033173712'
    : 'ca-app-pub-3940256099942544/4411468910';
*/
  BannerAd? _bannerAd;*/

  @override
  void initState() {
    super.initState();
    Adprovider adProvider = Provider.of<Adprovider>(context,listen: false);
    adProvider.initializeHomePageBanner();
    _loadItems();

    
    //loadInterstital();
    //loadBannerAd();
  }

  /*void loadBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? "ca-app-pub-3940256099942544/9214589741"
            : "ca-app-pub-3940256099942544/2435281174",
        listener: BannerAdListener(),
        request: AdRequest());
    _bannerAd?.load();
  }*/

  /* void loadInterstital() {
    //var platform = Theme.of(context).platform;

    String interstialadId = Platform.isAndroid
        ? "ca-app-pub-3940256099942544/1033173712"
        : "ca-app-pub-3940256099942544/4411468910";
    InterstitialAd.load(
        adUnitId: interstialadId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;

            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                  loadInterstital();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                  loadInterstital();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }*/

  void _loadItems() async {
    final url = Uri.https('shopping-list-app-990e8-default-rtdb.firebaseio.com',
        'shopping-list.json');

    final response = await http.get(url); //getting data command from firebase

    if (response.statusCode >= 400) {
      //error handling, if unablle to fetch data from firebase
      setState(() {
        _error = 'Failed  to fetch data, please try again later';
      });
    }

    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
        return;
      });
    }

    final Map<String, dynamic> listData =
        json.decode(response.body); //decoding json data to map
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category),
      );
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem()),
    );
    //_loadItems();
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('shopping-list-app-990e8-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json'); // a / is added after shopping list to point towards a particular data to be deleted and wholle list

    final response = await http.delete(url); //delete command to firebase
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
    //_interstitialAd?.show();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          ),
          /*Container(
            alignment: Alignment.center,
            child: AdWidget(ad: _bannerAd!),
            width: _bannerAd?.size.width.toDouble(),
            height: _bannerAd?.size.height.toDouble(),
          )*/
        ],
      ),
      body: content,
      bottomNavigationBar: Consumer<Adprovider>(
        builder: (context, adprovider, child) {
          if (adprovider.isHomePageBannerLoaded) {
            return Container(
              height: adprovider.homePageBanner.size.height.toDouble(),
              child: AdWidget(ad: adprovider.homePageBanner),
            );
          } else {
            return Container(height: 0);
          }
        },
      ),
    );
  }
}
