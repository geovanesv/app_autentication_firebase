import 'dart:math';

import 'package:flutter/material.dart';

enum ProductEnum {
  id,
  name,
  description,
  price,
  urlImage,
  isFavorite,
}

class Product with ChangeNotifier {
  String id;
  final String name;
  final String description;
  final double price;
  final String urlImage;
  bool isFavorite;

  Product({
    this.id = '',
    required this.name,
    required this.description,
    required this.price,
    required this.urlImage,
    this.isFavorite = false,
  });

  static String get productNewId {
    return 'pd${Random().nextDouble().toString()}';
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
