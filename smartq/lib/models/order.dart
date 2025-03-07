class Order {
  final String id;
  final String itemName;
  final String imageUrl;
  final double price;
  final String status;
  final DateTime dateTime;

  Order({
    required this.id,
    required this.itemName,
    required this.imageUrl,
    required this.price,
    required this.status,
    required this.dateTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      itemName: json['itemName'],
      imageUrl: json['imageUrl'],
      price: double.parse(json['price'].toString()),
      status: json['status'],
      dateTime: DateTime.parse(json['dateTime']),
    );
  }
}
