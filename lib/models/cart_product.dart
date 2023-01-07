import 'dart:math';

class CartProduct {
  final String id;
  final String productId;
  final String productName;
  final double productPrice;
  final String productUrlImage;
  final int quantity;

  CartProduct({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productUrlImage,
    required this.quantity,
  });

  static String get cartItemId {
    return 'ci${Random().nextDouble().toString()}';
  }
}
