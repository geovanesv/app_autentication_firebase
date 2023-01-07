import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/components/app_drawer.dart';
import 'package:shop_firebase/components/order_item_widget.dart';
import 'package:shop_firebase/components/util/custom_loading.dart';
import 'package:shop_firebase/controllers/orders_controller.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var isLoading = false;
  var reload = false;

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    setState(() => reload = false);
    Provider.of<OrdersController>(context, listen: false).loadOrders().then((value) {
      if (value == false) {
        setState(() => reload = true);
      } else {
        setState(() => isLoading = false);
        setState(() => reload = false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final OrdersController ordersController = Provider.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Meus Pedidos")),
      drawer: const AppDrawer(),
      body: CustomLoading(context: context).builder(
        condition: isLoading,
        loadingMessage: 'Carregando pedidos',
        showReloadButton: reload,
        reloadMessage: 'Nenhum pedido encontrado',
        reloadButtonLabel: 'Carregar novamente',
        reloadMethod: _loadOrders,
        child: RefreshIndicator(
          // o refreshindicator permite executar um método quando a tela é arrastada para baixo
          // para que isso funcione o método deve retornar um Future<void>
          onRefresh: _loadOrders,
          child: ListView.builder(
            itemCount: ordersController.products.length,
            itemBuilder: (ctx, index) => OrderItemWidget(order: ordersController.products[index]),
          ),
        ),
      ),
    );
  }
}
