class ProductModel {
  final int? id;
  final String name;
  final double price;
  final int stock;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  /// Factory constructor to create a Product from a JSON map.
  /// Used when fetching data from the backend.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['PRODUCTID'],
      name: json['PRODUCTNAME'],
      price: json['PRICE'].toDouble(),
      stock: json['STOCK'],
    );
  }

  /// Converts this Product instance to a JSON map.
  /// Used when sending data to the backend (POST/PUT).
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'PRODUCTID': id,
      'PRODUCTNAME': name,
      'PRICE': price,
      'STOCK': stock,
    };
  }

  /// Creates a copy of this Product with updated values.
  ProductModel copyWith({int? id, String? name, double? price, int? stock}) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
}
