import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:smartq/constants/constants.dart';
import 'dart:convert';
import '../provider/cartprovider.dart';
import '../screens/cartpage.dart';
import '../reusable/itemcard.dart';
import '../models/menu_item.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<MenuItem> allItems = [];
  List<MenuItem> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
    searchController.addListener(filterItems);
  }

  void filterItems() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = allItems
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> fetchMenuItems() async {
    setState(() => isLoading = true); //  Start loading
    try {
      final response = await http.get(Uri.parse('${baseUrl}menu'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          allItems = jsonList
              .map((json) => json as Map<String, dynamic>)
              .where((json) => json['available'] == true)
              .map((json) => MenuItem.fromJson(json))
              .toList();
          filteredItems = allItems;
        });
      } else {
        throw Exception('Failed to load menu items');
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartQ',
          style: TextStyle(
            letterSpacing: 2,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Stack(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(menuItems: allItems),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                ),
                if (cartItems.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red,
                      ),
                      child: Center(
                        child: Text(
                          '${cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchMenuItems,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No items found',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return ItemCard(menuItem: filteredItems[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
