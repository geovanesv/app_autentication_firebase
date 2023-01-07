import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/models/cart.dart';
import 'package:shop_firebase/models/cart_product.dart';

class ProductWidget extends StatelessWidget {
  final CartProduct cartProduct;
  final bool onlyProductList;
  const ProductWidget({
    Key? key,
    required this.cartProduct,
    this.onlyProductList = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onlyProductList) {
      return ProductData(cartProduct: cartProduct);
    } else {
      // Dismissible permite que o card seja arrastado para os lados
      return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.startToEnd,
        background: Container(
          color: Theme.of(context).errorColor.withAlpha(60),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Icon(
            Icons.delete,
            color: Theme.of(context).errorColor,
            size: 50,
          ),
        ),
        // método para validar se deve ser feita a ação do onDesmissed, neste caso mensagem de confirmação
        // para exclusão do produto
        confirmDismiss: (direction) {
          return showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirmação'),
              content: Text('Confirma a exclusão de ${cartProduct.productName}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Não'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Sim',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              ],
            ),
          );
        },
        onDismissed: (direction) => {
          Provider.of<Cart>(
            context,
            listen: false,
          ).removeAllProducts(cartProduct.productId)
        },
        child: ProductData(cartProduct: cartProduct),
      );
    }
  }
}

class ProductData extends StatelessWidget {
  const ProductData({
    Key? key,
    required this.cartProduct,
  }) : super(key: key);

  final CartProduct cartProduct;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ListTile(
        leading: SizedBox(
          width: 90,
          height: 90,
          child: Image.network(
            cartProduct.productUrlImage,
            alignment: Alignment.center,
          ),
        ),
        title: Text(cartProduct.productName),
        subtitle: Text('Total: R\$ ${(cartProduct.quantity * cartProduct.productPrice).toStringAsFixed(2)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Vlr. Unit: R\$ ${cartProduct.productPrice}'),
            Text('Quantidade: ${cartProduct.quantity}x')
          ],
        ),
      ),
    );
  }
}
