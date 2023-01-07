import 'dart:math';

import 'package:shop_firebase/models/cart_product.dart';

class Order {
  final String id;
  final double total;
  final List<CartProduct> products;
  final DateTime date;

  Order({
    required this.id,
    required this.total,
    required this.products,
    required this.date,
  });

  static String get orderId {
    return 'or${Random().nextDouble().toString()}';
  }
}
