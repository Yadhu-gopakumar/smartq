class MenuItem {
  final String id;
  final String name;
  final String price;
  final String rating;
  final String imageUrl;
  final int quantity;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.quantity = 1,
  });

  factory MenuItem.empty() {
    return MenuItem(
        id: '',
        name: 'Unknown',
        imageUrl: '',
        price: '0',
        rating: '1',
        quantity: 0);
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'].toString(),
      name: json['name'],
      price: json['price'].toString(),
      rating: json['rating'].toString(),
      imageUrl: json['image_url'] != null
          ? 'https://smartq.pythonanywhere.com${json['image_url']}'
          : 'no image',
      quantity: json.containsKey('quantity') ? json['quantity'] as int : 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  MenuItem copyWith({int? quantity}) {
    return MenuItem(
      id: id,
      name: name,
      price: price,
      rating: rating,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price &&
          rating == other.rating &&
          imageUrl == other.imageUrl &&
          quantity == other.quantity;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      price.hashCode ^
      rating.hashCode ^
      imageUrl.hashCode ^
      quantity.hashCode;
}
