import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/components/util/custom_dialog.dart';
import 'package:shop_firebase/components/util/exception_handler.dart';
import 'package:shop_firebase/components/util/snackbar_message.dart';
import 'package:shop_firebase/models/product.dart';
import 'package:shop_firebase/controllers/product_controller.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({Key? key}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // utilizado para o controle de foco
  final _descriptionFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _imageUrlFocus = FocusNode();
  final imageUrlController = TextEditingController();

  // formKey irá ajudar a controlar o estado do form
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};

  // esta variável será utilizada para controlar se deve ou não ser exibido circular loading
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocus.addListener(updateUrlImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arguments = ModalRoute.of(context)?.settings.arguments;

      if (arguments != null) {
        Product product = arguments as Product;

        _formData["id"] = product.id;
        _formData["name"] = product.name;
        _formData["description"] = product.description;
        _formData["price"] = product.price;
        _formData["urlImage"] = product.urlImage;

        // força a execução do controller e preenchimento da imagem
        imageUrlController.text = product.urlImage;
      }
    }
  }

  // libera recursos da tela quando ela é fechada
  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageUrlFocus.removeListener(updateUrlImage);
    _imageUrlFocus.dispose();
  }

  void updateUrlImage() {
    setState(() {});
  }

  dynamic _validator({required ProductEnum field, required String? value}) {
    // ao retornar null campo foi validado com sucesso
    // se retornar alguma mensagem essa mensagem será considerada um erro
    if (field == ProductEnum.name) {
      if ((value ?? '').trim().isEmpty) {
        return 'Informe o nome do produto';
      } else if ((value ?? '').trim().length < 3) {
        return 'Nome deve ter mais de 3 caracteres';
      }
      return null;
    } else if (field == ProductEnum.description) {
      if ((value ?? '').trim().isEmpty) {
        return 'Informe a descrição do produto';
      } else if ((value ?? '').trim().length < 3) {
        return 'A descrição deve ter mais de 3 caracteres';
      }
      return null;
    } else if (field == ProductEnum.price) {
      if ((value ?? '').trim().isEmpty) {
        return 'Informe o valor do produto';
      } else if (double.tryParse(value ?? '') == null) {
        return 'O valor informado não é um número válido';
      }
      return null;
    } else if (field == ProductEnum.urlImage) {
      if ((value ?? '').trim().isEmpty) {
        return 'Informe a URL do produto';
      } else if (!(Uri.tryParse(value!)?.hasAbsolutePath ?? false)) {
        return 'A URL é inválida';
      }
      return null;
    }
  }

  Future<void> _submitForm() async {
    // validate() retorna null em caso de sucesso
    // quando temos erro ele retorna a mensagem encontrada.
    // para este caso não é necessário se preocupar pois as mensagens são exibidas na tela.
    if (!(_formKey.currentState?.validate() ?? true)) {
      SnackBarMessage(
        context: context,
        messageType: MessageType.error,
        messageText: 'Erros foram encontrados',
      );
    } else {
      // salva os dados do form, até aqui _formData está em branco
      _formKey.currentState?.save();
      // listen deve ser false pois ele está fora do método build.

      // como este é um statefull widget podemos chamar o setState para alterar a variável _isLoading
      // e atualizar a tela automaticamente.
      setState(() => _isLoading = true);

      try {
        await Provider.of<ProductController>(
          context,
          listen: false,
        ).saveProduct(product: ProductController.dataToProduct(data: _formData));

        SnackBarMessage(
          context: context,
          messageType: MessageType.sucess,
          messageText: '${_formData['name']} salvo com sucesso',
        );
      } on ExceptionHandler catch (error) {
        CustomDialog(context).errorMessage(message: error.toString());
      } finally {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulário de produtos')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      // valor inicial do campo, só será prenchido quando for edição.
                      // método didChangeDependencies é executado no carregamento da tela.
                      initialValue: _formData['name']?.toString(),
                      decoration: const InputDecoration(labelText: 'Nome'),
                      textInputAction: TextInputAction.next,
                      // informa qual focusNode deve ser ativado
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_descriptionFocus),
                      // indica que _formData['name'] deve receber name ou '' se for nulo
                      onSaved: (value) => _formData['name'] = value ?? '',
                      validator: (value) => _validator(field: ProductEnum.name, value: value),
                    ),
                    TextFormField(
                      initialValue: _formData['description']?.toString(),
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      keyboardType: TextInputType.multiline,
                      // informa quantidade de linhas que serão liberadas para digitação
                      maxLines: 3,
                      // indica qual o focusNode do componente
                      focusNode: _descriptionFocus,
                      // informa qual focusNode deve ser ativado
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_priceFocus),
                      onSaved: (value) => _formData['description'] = value ?? '',
                      validator: (value) => _validator(field: ProductEnum.description, value: value),
                    ),
                    TextFormField(
                      initialValue: _formData['price']?.toString(),
                      decoration: const InputDecoration(labelText: 'Preço'),
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      // indica qual o focusNode do componente
                      focusNode: _priceFocus,
                      // informa qual focusNode deve ser ativado
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_imageUrlFocus),
                      onSaved: (value) => _formData['price'] = double.parse(value ?? '0'),
                      validator: (value) => _validator(field: ProductEnum.price, value: value),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            //initialValue: _formData['urlImage']?.toString(),
                            decoration: const InputDecoration(labelText: 'Url Imagem'),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                            // indica qual o focusNode do componente
                            focusNode: _imageUrlFocus,
                            controller: imageUrlController,
                            onSaved: (value) => _formData['urlImage'] = value ?? '',
                            onFieldSubmitted: (_) => _submitForm(),
                            validator: (value) => _validator(field: ProductEnum.urlImage, value: value),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 10, left: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: Colors.purple,
                            width: 1,
                          )),
                          alignment: Alignment.center,
                          child: imageUrlController.text.isEmpty ? const Text("Infome a URL") : Image.network(imageUrlController.text),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _submitForm(),
        child: const Icon(Icons.save),
      ),
    );
  }
}
