// ignore: depend_on_referenced_packages
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'package:flutter/widgets.dart';
import 'package:shop_firebase/components/util/exception_handler.dart';
import 'package:shop_firebase/controllers/auth_controller.dart';
import 'package:shop_firebase/data/firebase_consts.dart';
import 'package:shop_firebase/models/cart.dart';
import 'package:shop_firebase/models/cart_product.dart';
import 'package:shop_firebase/models/order.dart';

class OrdersController with ChangeNotifier {
  final AuthData _authData;
  final List<Order> _products;

  OrdersController(this._authData, this._products);

  List<Order> get products {
    return [
      ..._products
    ];
  }

  int get ordersCount {
    return _products.length;
  }

  Future<bool> loadOrders() async {
    final response = await get(
      Uri.parse('${FirebaseConsts.orderUrl}/${_authData.userId}.json/?auth=${_authData.token}'),
    );

    if (response.body == 'null') {
      return false;
    } else {
      Map<String, dynamic> orderData = jsonDecode(response.body);

      _products.clear();

      orderData.forEach(
        (orderId, orderData) {
          _products.add(
            Order(
              id: orderId,
              date: DateTime.parse(orderData['date']),
              total: orderData['total'],
              products: (orderData['products'] as List<dynamic>).map((productOrder) {
                return CartProduct(
                  id: productOrder['id'],
                  productId: productOrder['productId'],
                  productName: productOrder['productName'],
                  productPrice: productOrder['productPrice'],
                  productUrlImage: productOrder['productUrlImage'],
                  quantity: productOrder['quantity'],
                );
              }).toList(),
            ),
          );
        },
      );
      notifyListeners();
      return true;
    }
  }

  Future<void> addOrder({required Cart cart, required bool clearCart}) async {
    final date = DateTime.now();
    final response = await post(
      // http.post
      Uri.parse('${FirebaseConsts.orderUrl}/${_authData.userId}.json/?auth=${_authData.token}'),
      // Id fica em branco pois será gerado no banco
      body: jsonEncode({
        'total': cart.totalAmount,
        'date': date.toIso8601String(),
        'products': cart.products.values.map((cartProduct) {
          return {
            'id': cartProduct.id,
            'productId': cartProduct.productId,
            'productName': cartProduct.productName,
            'productPrice': cartProduct.productPrice,
            'productUrlImage': cartProduct.productUrlImage,
            'quantity': cartProduct.quantity,
          };
        }).toList()
      }),
    );

    if (response.statusCode >= 400) {
      throw ExceptionHandler(
        handledMessage: 'Erro ao tentar salvar os dados do pedido',
        statusCode: response.statusCode,
      );
    } else {
      String orderId = jsonDecode(response.body)['name'];
      if (orderId.isEmpty) {
        throw ExceptionHandler(
          handledMessage: 'Erro interno, ao tentar salvar o novo pedido.',
          statusCode: 000,
        );
      } else {
        _products.insert(
            0,
            // como cart.items retorna uma lista de produtos, ela se encaixa com o que queremos para as ordern;
            Order(
              id: orderId,
              total: cart.totalAmount,
              date: date,
              products: cart.products.values.toList(),
            ));

        if (clearCart) {
          cart.clear();
        }
        // retorna à todos os que estão ouvindo esta classe sejam notificados
        notifyListeners();
      }
    }
  }
}
