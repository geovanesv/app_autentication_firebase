import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/models/cart.dart';

import '../../app_routes.dart';
import '../badge.dart';

class CartButton extends StatelessWidget {
  const CartButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      // o parâmtro child do Consumer é para algo que é estático no código, ou seja, que não será
      // alterado com a notificação do provider. Com isso ele pode ser acesso no builder através
      // do parâmetro child.
      child: IconButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
        icon: const Icon(Icons.shopping_cart),
      ),
      builder: (ctx, cart, child) => Badge(
        value: cart.totalQuantityProducts.toString(),
        color: Colors.red,
        // Como o parâmetro child não é obrigatório é necessário colocar o ! para indicar ao compilador que
        // o programador se responsabiliza pelo preenchimento da variável.
        child: child!,
      ),
    );
  }
}
