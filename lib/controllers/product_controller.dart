import 'dart:convert';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'package:shop_firebase/components/util/custom_return.dart';
import 'package:shop_firebase/components/util/exception_handler.dart';
import 'package:shop_firebase/controllers/auth_controller.dart';
import 'package:shop_firebase/data/firebase_consts.dart';
import 'package:shop_firebase/models/product.dart';

class ProductController with ChangeNotifier {
  final AuthData authData;

  final List<Product> _products;

  ProductController(this.authData, this._products);

  List<Product> get favoriteProducts => [
        ...products.where((p) => p.isFavorite)
      ];

  List<Product> get products => [
        ..._products
      ];

  int get itemsCount {
    return _products.length;
  }

    Future<CustomReturn> loadProducts() async {
    final response = await get(
      Uri.parse('${FirebaseConsts.productUrl}.json?auth=${authData.token}'),
    );

    Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 401) {
      return CustomReturn.unauthorizedError();
    } else {
      if (response.statusCode > 400) {
        return CustomReturn(returnType: ReturnType.error, message: 'Erro ao obter produtos');
      } else {
        final favoriteProductsResponse = await get(
          //url/id_usuario/id_produto.json
          Uri.parse('${FirebaseConsts.favoriteUserProductUrl}/${authData.userId}.json?auth=${authData.token}'),
        );

        Map<String, dynamic> favoriteProductsData = favoriteProductsResponse.body == 'null' ? {} : jsonDecode(favoriteProductsResponse.body);

        _products.clear();
        data.forEach((productId, productData) {
          _products.add(
            Product(
              id: productId,
              name: productData['name'],
              description: productData['description'],
              price: productData['price'].toDouble(),
              urlImage: productData['urlImage'],
              isFavorite: favoriteProductsData[productId] ?? false,
            ),
          );
        });
        notifyListeners();
        return CustomReturn.sucess();
      }
    }
  }

  Future<void> removeProduct({required Product product}) async {
    int index = _products.indexWhere((p) => p.id == product.id);

    if (index == -1) {
      throw ExceptionHandler(
        handledMessage: 'Erro interno, produto não encontrado.',
        statusCode: 000,
      );
    } else {
      // http.delete
      final response = await delete(
        //url/id_produto.json
        Uri.parse('${FirebaseConsts.productUrl}/${product.id}.json?auth=${authData.token}'),
      );

      // erros de 400 em diante representam problemas de requisição
      if (response.statusCode < 400) {
        _products.removeWhere((p) => p.id == product.id);
        notifyListeners();
      } else {
        throw ExceptionHandler(
          handledMessage: 'Erro ao excluir o produto.',
          statusCode: response.statusCode,
        );
      }
    }
  }

  Future<void> saveProduct({required Product product}) async {
    if (product.id == '') {
      _addProduct(product: product);
    } else {
      _updateProduct(product: product);
    }
  }

  Future<void> _updateProduct({required Product product}) async {
    int index = _products.indexWhere((p) => p.id == product.id);

    if (index == -1) {
      throw ExceptionHandler(
        handledMessage: 'Erro interno, produto não encontrado.',
        statusCode: 000,
      );
    } else {
      final Response response;
      // http.patch
      response = await patch(
        //url/id_produto.json
        Uri.parse('${FirebaseConsts.productUrl}/${product.id}.json?auth=${authData.token}'),
        body: jsonEncode({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'urlImage': product.urlImage
        }),
      );

      if (response.statusCode < 400) {
        _products[index] = product;
        notifyListeners();
      } else {
        throw ExceptionHandler(
          handledMessage: 'Erro interno, ao tentar alterar o produto.',
          statusCode: 000,
        );
      }
    }
  }

  // async permite utilizar o await, para que a execução aguarde o retorno de post
  Future<void> _addProduct({required Product product}) async {
    // await faz com que a execução aguarde o retorno de post
    // com isso o método não precisa ligar com retorno (future) de post
    final response = await post(
      // http.post
      Uri.parse('${FirebaseConsts.productUrl}.json?auth=${authData.token}'),
      // Id fica em branco pois será gerado no banco
      body: jsonEncode(
        {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'urlImage': product.urlImage
        },
      ),
    );

    if (response.statusCode >= 400) {
      throw ExceptionHandler(
        handledMessage: 'Erro ao tentar salvar os dados do produto no banco de dados',
        statusCode: response.statusCode,
      );
    } else {
      String id = jsonDecode(response.body)['name'];
      if (id.isEmpty) {
        throw ExceptionHandler(
          handledMessage: 'Erro interno, ao tentar salvar o novo produto.',
          statusCode: 000,
        );
      } else {
        product.id = id;
        _products.add(product);
        // retorna à todos os que estão ouvindo esta classe sejam notificados
        notifyListeners();
      }
    }
  }

  Future<void> toggleFavorite(Product product) async {
    product.toggleFavorite();

    final response = await put(
      // http://projeto/id_usuario/id_produto.json
      Uri.parse('${FirebaseConsts.favoriteUserProductUrl}/${authData.userId}/${product.id}.json?auth=${authData.token}'),
      body: jsonEncode(product.isFavorite),
    );

    if (response.statusCode < 400) {
      notifyListeners();
    } else {
      product.toggleFavorite();
      throw ExceptionHandler(
        handledMessage: 'Erro ao tentar salvar o produto',
        statusCode: response.statusCode,
      );
    }
  }

  // cast para transformar o map de dados em um objeto Product, para evitar fazer este cast fora
  // da classe
  static Product dataToProduct({required Map<String, Object> data}) {
    return Product(
      id: data['id'] == null ? '' : data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      urlImage: data['urlImage'] as String,
    );
  }
}
