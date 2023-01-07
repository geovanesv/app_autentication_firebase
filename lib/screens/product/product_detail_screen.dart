import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/components/cart/cart_button.dart';
import 'package:shop_firebase/models/cart.dart';
import 'package:shop_firebase/models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // o ? antes de .settings serve para indicar que settings só será chamado se houver dados
    final Product product = ModalRoute.of(context)?.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: const [
          CartButton()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              height: 300,
              width: double.infinity,
              alignment: Alignment.center,
              child: Image.network(
                product.urlImage,
                fit: BoxFit.cover,
              ),
            ),
            Card(
              elevation: 1,
              child: Container(
                alignment: Alignment.center,
                height: 40,
                width: double.infinity,
                child: Text(
                  'R\$${product.price}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 40,
              width: double.infinity,
              child: Text(
                product.description,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<Cart>(context, listen: false).addProduct(product, 1),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.shopping_bag),
      ),
    );
  }
}
