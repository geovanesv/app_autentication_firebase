import 'package:flutter/material.dart';
import 'package:shop_firebase/models/cart_product.dart';
import 'package:shop_firebase/models/product.dart';

class Cart with ChangeNotifier {
  // id do produto e item do carrinho
  final Map<String, CartProduct> _products = {};

  Map<String, CartProduct> get products {
    return {
      ..._products
    };
  }

  void addProduct(Product product, int newQuantity) {
    // verifica se existe e incrementa quantidade
    if (_products.containsKey(product.id)) {
      _products.update(
        product.id,
        (actualProduct) => CartProduct(
          id: actualProduct.id,
          productId: product.id,
          productName: product.name,
          productPrice: product.price,
          productUrlImage: product.urlImage,
          quantity: actualProduct.quantity + newQuantity,
        ),
      );
    } else {
      // insere se não existe.
      _products.putIfAbsent(
        product.id,
        () => CartProduct(
          id: CartProduct.cartItemId,
          productId: product.id,
          productName: product.name,
          productPrice: product.price,
          productUrlImage: product.urlImage,
          quantity: newQuantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeAllProducts(String productId) {
    _products.remove(productId);
    notifyListeners();
  }

  void removeSingleProduct(Product product) {
    // verifica se produto está na lista
    if (_products.containsKey(product.id)) {
      if (_products[product.id]?.quantity == 1) {
        _products.remove(product.id);
      } else {
        _products.update(
          product.id,
          (actualProduct) => CartProduct(
            id: actualProduct.id,
            productId: product.id,
            productName: product.name,
            productPrice: product.price,
            productUrlImage: product.urlImage,
            quantity: actualProduct.quantity - 1,
          ),
        );
      }
      notifyListeners();
    }
  }

  void clear() {
    _products.clear();
    notifyListeners();
  }

  int get productsCount {
    return _products.length;
  }

  int get totalQuantityProducts {
    int totalQuantity = 0;
    _products.forEach((key, cartItem) {
      totalQuantity += cartItem.quantity;
    });
    return totalQuantity;
  }

  double get totalAmount {
    double totalAmount = 0;
    _products.forEach((key, cartItem) {
      totalAmount += cartItem.quantity * cartItem.productPrice;
    });
    return totalAmount;
  }
}
