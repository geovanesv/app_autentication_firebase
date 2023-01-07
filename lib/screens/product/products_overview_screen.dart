import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/components/app_drawer.dart';
import 'package:shop_firebase/components/cart/cart_button.dart';
import 'package:shop_firebase/components/util/custom_loading.dart';
import 'package:shop_firebase/components/util/custom_return.dart';
import 'package:shop_firebase/controllers/product_controller.dart';
import '../../components/product_grid/product_grid.dart';

enum FilterOptions { all, onlyFavorites }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavorites = false;
  bool _isLoading = true;
  bool _reload = false;
  String _reloadMessage = 'Nenhum produto encontrado';

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    setState(() => _reload = false);
    Provider.of<ProductController>(context, listen: false).loadProducts().then((value) {
      if (value.returnType == ReturnType.error) {
        _reloadMessage = value.message;
        setState(() => _reload = true);
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Minha Loja")),
        actions: [
          const CartButton(),
          // menu lateral
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz_sharp),
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                _showOnlyFavorites = selectedValue == FilterOptions.onlyFavorites;
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: FilterOptions.all,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.apps_rounded, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 5),
                    const Text('Todos', textAlign: TextAlign.left),
                  ],
                ),
              ),
              PopupMenuItem(
                value: FilterOptions.onlyFavorites,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.favorite_border_rounded, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 5),
                    const Text('Somente favoritos', textAlign: TextAlign.left),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
      // este método faz o controle do circular loading removendo-o quando a variável de
      // controle condition é alterada para false.
      body: CustomLoading(context: context).builder(
        condition: _isLoading,
        loadingMessage: 'Carregando produtos',
        showReloadButton: _reload,
        reloadMessage: _reloadMessage,
        reloadButtonLabel: 'Carregar novamente',
        reloadMethod: _loadProducts,
        child: RefreshIndicator(
          // o refreshindicator permite executar um método quando a tela é arrastada para baixo
          // para que isso funcione o método deve retornar um Future<void>
          onRefresh: () => _loadProducts(),
          child: ProductGrid(showOnlyFavorites: _showOnlyFavorites),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
