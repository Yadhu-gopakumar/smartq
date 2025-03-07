import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:smartq/constants/constants.dart';
import 'dart:convert';

import '../models/order.dart';


final orderProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) => OrderNotifier());

class OrderState {
  final List<Order> orders;
  final bool isLoading;

  OrderState({required this.orders, required this.isLoading});
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(OrderState(orders: [], isLoading: false));

  Future<void> fetchOrders() async {
    state = OrderState(orders: state.orders, isLoading: true); // Set loading true

    try {
      final response = await http.get(Uri.parse('${baseUrl}bookings/user'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        state = OrderState(
          orders: jsonData.map((order) => Order.fromJson(order)).toList(),
          isLoading: false,
        );
      }
    } catch (e) {
      print("Error fetching orders: $e");
      state = OrderState(orders: state.orders, isLoading: false);
    }
  }
}

