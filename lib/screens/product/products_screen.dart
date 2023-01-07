import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/app_routes.dart';
import 'package:shop_firebase/components/app_drawer.dart';
import 'package:shop_firebase/components/product_item.dart';
import 'package:shop_firebase/components/util/custom_loading.dart';
import 'package:shop_firebase/components/util/custom_return.dart';
import 'package:shop_firebase/controllers/product_controller.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _reload = false;
  bool _isLoading = false;
  String _reloadMessage = 'Nenhum produto encontrado';

  _reloadProducts() {
    setState(() => _isLoading = true);
    setState(() => _reload = false);
    Provider.of<ProductController>(context, listen: false).loadProducts().then((value) {
      if (value.returnType == ReturnType.error) {
        _reloadMessage = value.message;
        setState(() => _reload = true);
      } else {
        setState(() => _isLoading = false);
        setState(() => _reload = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productList = Provider.of<ProductController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar produtos'),
        actions: [
          ElevatedButton(
            child: const Icon(Icons.refresh_outlined),
            onPressed: () {
              _reloadProducts();
            },
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: CustomLoading(context: context).builder(
        condition: _isLoading,
        loadingMessage: 'Carregando produtos',
        showReloadButton: _reload,
        reloadMessage: _reloadMessage,
        reloadButtonLabel: 'Carregar novamente',
        reloadMethod: _reloadProducts,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productList.itemsCount,
            itemBuilder: (cti, index) => ProductItem(product: productList.products[index]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.productForm),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
