import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:shop_firebase/components/product_widget.dart';
import '../models/order.dart';

// statefull porque é necessário controlar se os detalhes do pedido estão aparecendo ou não.
class OrderItemWidget extends StatefulWidget {
  final Order order;
  const OrderItemWidget({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: const Icon(Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
            title: Text('R\$${widget.order.total.toStringAsFixed(2)}'),
            subtitle: Text(widget.order.id),
            trailing: Text(DateFormat('dd/MM/yyyy hh:mm').format(widget.order.date)),
          ),
          // esse if força que o containter abaixo dele só será exibido dependendo da variável _expandeds
          if (_expanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              // calcula o tamanho para garantir que todos os itens possam ser exibidos
              height: (widget.order.products.length * 85) + 10,
              child: ListView(
                children: widget.order.products.map((product) => ProductWidget(cartProduct: product, onlyProductList: true)).toList(),
              ),
            )
        ],
      ),
    );
  }
}
