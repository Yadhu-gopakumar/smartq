import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:smartq/pages/loginpage.dart';
import 'package:smartq/provider/bottom_bar_provider.dart';
import 'package:smartq/provider/cartprovider.dart';
import '../main.dart';
import 'dart:convert';

import 'package:smartq/constants/constants.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;

  AuthState({required this.isAuthenticated, required this.isLoading});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isAuthenticated: false, isLoading: false));

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      state = AuthState(isAuthenticated: true, isLoading: false);
    }
  }

  Future<void> login(
      String username, String password, BuildContext context, WidgetRef ref) async {
    state = AuthState(isAuthenticated: false, isLoading: true); // Show loading

    final response = await http.post(
      Uri.parse('${baseUrl}login'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      state = AuthState(isAuthenticated: true, isLoading: false);
      ref.read(bottomBarIndexProvider.notifier).state = 0;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const BottomBar()));
    } else {
      state = AuthState(isAuthenticated: true, isLoading: false);
      final errorMessage =
          jsonDecode(response.body)['detail'] ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.horizontal,
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          content: Center(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> register(
      String username, String password, BuildContext context) async {
    state = AuthState(isAuthenticated: false, isLoading: true); // Show loading

    final response = await http.post(
      Uri.parse('${baseUrl}register'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      state = AuthState(isAuthenticated: false, isLoading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          dismissDirection: DismissDirection.horizontal,
          padding: EdgeInsets.only(top: 20, bottom: 20),
          content: Center(
            child: Text(
              'Registration successful. Please log in.',
              style: TextStyle(color: Colors.lightGreenAccent),
            ),
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else {
      state = AuthState(isAuthenticated: false, isLoading: false);
      final errorMessage =
          jsonDecode(response.body)['detail'] ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.horizontal,
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          content: Center(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> logout(BuildContext context, WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // Clear cart properly using ref.read
    ref.read(cartProvider.notifier).clearCart();

    state = AuthState(isAuthenticated: false, isLoading: false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }
}
