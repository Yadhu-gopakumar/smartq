import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  const OrderCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading:
            Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('₹${price.toStringAsFixed(2)} x $quantity'),
      ),
    );
  }
}
