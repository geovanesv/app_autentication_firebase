import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/app_routes.dart';
import 'package:shop_firebase/controllers/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Bem Vindo'),
            // remove o botão do drawer quando ele está aberto
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop_2_sharp),
            title: const Text('Loja'),
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.productOverview),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment_sharp),
            title: const Text('Pedidos'),
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.orders),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.mode_edit_sharp),
            title: const Text('Gerenciar Produtos'),
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.products),
          ),
          const Spacer(),
          ListTile(
              leading: const Icon(Icons.exit_to_app_sharp),
              title: const Text('Sair'),
              onTap: () {
                Provider.of<AuthController>(context, listen: false).logout();
                Navigator.restorablePushNamedAndRemoveUntil(
                  context,
                  AppRoutes.landing,
                  (route) => false,
                );
              }),
        ],
      ),
    );
  }
}
