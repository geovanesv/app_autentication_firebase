import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/app_routes.dart';
import 'package:shop_firebase/components/util/custom_dialog.dart';
import 'package:shop_firebase/components/util/exception_handler.dart';
import 'package:shop_firebase/components/util/snackbar_message.dart';
import 'package:shop_firebase/models/product.dart';
import 'package:shop_firebase/controllers/product_controller.dart';

class ProductItem extends StatefulWidget {
  final Product product;

  const ProductItem({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  void _removeProduct({required BuildContext context}) async {
    String finalMessage = '';
    bool productDeleted = false;

    try {
      await Provider.of<ProductController>(
        context,
        listen: false,
      ).removeProduct(product: widget.product);
      productDeleted = true;
    } on ExceptionHandler catch (error) {
      finalMessage = error.toString();
    } finally {
      // se o produto não foi salvo ele deve mostrar a mensagem
      // se ele foi salvo deve voltar para a tela de produtos.
      if (!productDeleted) {
        CustomDialog(context).errorMessage(message: finalMessage);
      } else {
        finalMessage = '${widget.product.name} removido com sucesso';
      }
      SnackBarMessage(
        context: context,
        messageType: productDeleted ? MessageType.sucess : MessageType.error,
        messageText: finalMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      elevation: 1,
      child: ListTile(
        leading: Container(
          alignment: Alignment.center,
          width: 100,
          height: 100,
          child: Image.network(widget.product.urlImage, alignment: Alignment.center),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('(${widget.product.id})', style: const TextStyle(fontSize: 9)),
          ],
        ),
        subtitle: Text(widget.product.description),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.productForm, arguments: widget.product);
                },
              ),
              // delete buttom
              IconButton(
                icon: const Icon(Icons.delete),
                color: Theme.of(context).colorScheme.error,
                onPressed: () async {
                  final deletedConfirmed = await CustomDialog(context).confirmationDialog(
                    message: 'Confirma a exclusão do produto?',
                    yesButtonHighlight: true,
                  );
                  if (deletedConfirmed ?? false) {
                    _removeProduct(context: context);
                  } else {
                    SnackBarMessage(
                      context: context,
                      messageType: MessageType.info,
                      messageText: 'Exclusão cancelada',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
