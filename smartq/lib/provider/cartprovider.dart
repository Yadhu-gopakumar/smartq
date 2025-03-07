import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/menu_item.dart';

class CartNotifier extends StateNotifier<Map<String, int>> {
  CartNotifier() : super({}) {
    _loadCartFromStorage(); // Load cart on startup
  }

  Future<void> _loadCartFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString('cart_items');

    if (cartJson != null) {
      Map<String, int> cartData = Map<String, int>.from(jsonDecode(cartJson));
      state = cartData;
    }
  }

  Future<void> _saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart_items', jsonEncode(state));
  }

  // Add item to cart or increase quantity
  Future<void> increaseQuantity(String itemId) async {
    state = {...state, itemId: (state[itemId] ?? 0) + 1};
    await _saveCartToStorage();
  }

  // Decrease quantity or remove item if 0
  Future<void> decreaseQuantity(String itemId) async {
    if (state.containsKey(itemId)) {
      final newQuantity = state[itemId]! - 1;
      if (newQuantity > 0) {
        state = {...state, itemId: newQuantity};
      } else {
        state = {...state}..remove(itemId);
      }
      await _saveCartToStorage();
    }
  }

  void removeFromCart(String itemId) {
    state = {...state}..remove(itemId); // Remove item completely
  }

  // Calculate total price
  double getTotalPrice(Map<String, MenuItem> menuItems) {
    return state.entries.fold(0.0, (total, entry) {
      final menuItem = menuItems[entry.key];
      if (menuItem != null) {
        return total + (double.parse(menuItem.price) * entry.value);
      }
      return total;
    });
  }

  void clearCart() {
    state = {};
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, int>>((ref) {
  return CartNotifier();
});
