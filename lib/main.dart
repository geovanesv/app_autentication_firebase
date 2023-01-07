import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/app_routes.dart';
import 'package:shop_firebase/controllers/auth_controller.dart';
import 'package:shop_firebase/controllers/orders_controller.dart';
import 'package:shop_firebase/controllers/product_controller.dart';
import 'package:shop_firebase/my_theme.dart';
import 'package:shop_firebase/screens/auth_screen.dart';
import 'package:shop_firebase/screens/cart_screen.dart';
import 'package:shop_firebase/screens/landing.dart';
import 'package:shop_firebase/screens/orders_screen.dart';
import 'package:shop_firebase/screens/product/product_detail_screen.dart';
import 'package:shop_firebase/screens/product/product_form_screen.dart';
import 'package:shop_firebase/screens/product/products_screen.dart';
import 'package:shop_firebase/screens/product/products_overview_screen.dart';
import 'package:shop_firebase/screens/screen_not_found.dart';

import 'models/cart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        // ProductController depende do AuthController e por isso deve ser usado o ChangeNotifierProxyProvider
        // ele deve
        ChangeNotifierProxyProvider<AuthController, ProductController>(
          // inicializa o controller com token em branco e lista de produtos vazia
          create: (_) => ProductController(AuthData.emptyData(), []),
          // em caso de update deve enviar os dados de ayth mais uma versão anterior dos dados
          update: (ctx, authController, previous) {
            return ProductController(
              authController.authData,
              previous?.products ?? [],
            );
          },
        ),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProxyProvider<AuthController, OrdersController>(
          create: (_) => OrdersController(AuthData.emptyData(), []),
          update: (ctx, authController, previous) {
            return OrdersController(
              authController.authData,
              previous?.products ?? [],
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'Store Demo',
        theme: MyTheme.theme,
        // remove o indicador de debug na tela
        debugShowCheckedModeBanner: false,
        routes: {
          AppRoutes.landing: (ctx) => const Landing(),
          AppRoutes.auth: (ctx) => const AuthScreen(),
          AppRoutes.productOverview: (ctx) => const ProductsOverviewScreen(),
          AppRoutes.productDetail: (ctx) => const ProductDetailScreen(),
          AppRoutes.cart: (ctx) => const CartScreen(),
          AppRoutes.orders: (ctx) => const OrdersScreen(),
          AppRoutes.products: (ctx) => const ProductsScreen(),
          AppRoutes.productForm: (ctx) => const ProductFormScreen(),
          //AppRoutes.productDetail: (ctx) => const CounterPage()
        },
        initialRoute: AppRoutes.landing,
        // Executado quando uma tela não é encontrada
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) {
            return ScreenNotFound(settings.name.toString());
          });
        },
      ),
    );
  }
}
