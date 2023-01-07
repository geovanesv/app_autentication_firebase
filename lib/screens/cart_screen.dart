import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/components/product_widget.dart';
import 'package:shop_firebase/components/util/exception_handler.dart';
import 'package:shop_firebase/components/util/snackbar_message.dart';
import 'package:shop_firebase/controllers/orders_controller.dart';

import '../models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Cart cart = Provider.of(context);
    final products = cart.products.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrinho"),
      ),
      body: Column(
        children: [
          CartResume(context: context, cart: cart),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (ctx, index) => ProductWidget(cartProduct: products[index]),
            ),
          ),
          CartResume(context: context, cart: cart),
        ],
      ),
    );
  }

  // o resumo do carrinho fica melhor como uma função para que possa
  // ser colocada no começo e no final da lista de produtos
}

class CartResume extends StatefulWidget {
  const CartResume({
    Key? key,
    required this.context,
    required this.cart,
  }) : super(key: key);

  final BuildContext context;
  final Cart cart;

  @override
  State<CartResume> createState() => _CartResumeState();
}

class _CartResumeState extends State<CartResume> {
  bool _isCreating = false;

  Future<void> _createOrder({required BuildContext context, required Cart cart}) async {
    if (cart.products.isEmpty) {
      SnackBarMessage(
        context: context,
        messageType: MessageType.info,
        messageText: 'Não existem produtos no carrinho.',
        durationInSeconds: 1,
      );
    } else {
      setState(() => _isCreating = true);

      try {
        // transformação do carrinho em um pedido
        await Provider.of<OrdersController>(context, listen: false).addOrder(
          cart: widget.cart,
          clearCart: true,
        );
        setState(() => _isCreating = false);
        SnackBarMessage(
          context: context,
          messageType: MessageType.sucess,
          messageText: 'Pedido enviado com sucesso',
        );
        // limpa a pilha de telas e retorna para a tela inicial
      } on ExceptionHandler catch (error) {
        SnackBarMessage(
          context: context,
          messageType: MessageType.error,
          messageText: error.toString(),
        );
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Chip(
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text(
                'R\$${widget.cart.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.headline6?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            _isCreating
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: () {
                      _createOrder(context: context, cart: widget.cart);
                    },
                    style: TextButton.styleFrom(textStyle: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    child: const Text("Finalizar Compra"),
                  )
          ],
        ),
      ),
    );
  }
}
