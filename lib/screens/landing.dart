import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/controllers/auth_controller.dart';
import 'package:shop_firebase/screens/auth_screen.dart';
import 'package:shop_firebase/screens/product/products_overview_screen.dart';

class Landing extends StatelessWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthController authController = Provider.of(context);
    return FutureBuilder(
      future: authController.tryAutoLogin(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.error != null) {
          return const Center(child: Text('erro'));
        } else {
          return authController.authData.isAuthenticated == false ? const AuthScreen() : const ProductsOverviewScreen();
        }
      },
    );
  }
}
