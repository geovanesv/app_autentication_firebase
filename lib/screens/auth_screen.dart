import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_firebase/app_routes.dart';
import 'package:shop_firebase/components/util/custom_return.dart';
import 'package:shop_firebase/components/util/snackbar_message.dart';
import 'package:shop_firebase/controllers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum ScreenMode { auth, signUp }

enum TextFormType { email, password, confirmPassword }

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  bool _hidePassword = true;
  bool _isLoading = false;
  ScreenMode _screenMode = ScreenMode.auth;

  final Map<String, String> _authData = {'email': '', 'password': ''};

  void _submit() async {
    setState(() => _isLoading = true);

    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      // se não encontrou erros no formulário segue com a execução

      // salva os dados no map
      _formKey.currentState?.save();

      AuthController authController = Provider.of(context, listen: false);
      CustomReturn retorno;
      try {
        // se estamos no modo de login
        if (_screenMode == ScreenMode.auth) {
          retorno = await authController.authenticate(
            email: _authData['email']!,
            password: _authData['password']!,
          );

          // caso o login tenha funcionado chama a tela de produtos
          if (retorno.returnType == ReturnType.sucess) {
            // ignore: use_build_context_synchronously
            Navigator.restorablePushNamedAndRemoveUntil(
              context,
              AppRoutes.productOverview,
              (route) => false,
            );
          }
        } else {
          // se estamos no modo de cadastro
          retorno = await authController.signUp(
            email: _authData['email']!,
            password: _authData['password']!,
          );

          // caso o processo de cadastro tenha fucionado altera o estado da tela para login
          if (retorno.returnType == ReturnType.sucess) {
            setState(() => _screenMode = ScreenMode.auth);
            SnackBarMessage(
              context: context,
              messageText: 'Usuário cadastrado com sucesso',
              messageType: MessageType.sucess,
            );
          }
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == ReturnType.error) {
          SnackBarMessage(
            context: context,
            messageText: retorno.message,
            messageType: MessageType.error,
          );
        }
      } finally {
        // força a retirada do loading da tela ao final do processo.
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // linha de botões com comandos do login (Login e cadastrar novo usuário)
    Widget rowLoginButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _isLoading
            ? const CircularProgressIndicator.adaptive()
            : ElevatedButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('Entrar'),
                ),
              ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  _screenMode = ScreenMode.signUp;
                  setState(() {});
                },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.secondary)),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text('Criar Conta'),
          ),
        ),
      ],
    );
    // linha de botões com comandos do Cadstro de novo usuário (Salvar cadastro ou cancelar)
    Widget rowSignUpButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _isLoading
            ? const CircularProgressIndicator.adaptive()
            : ElevatedButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text('Cadastrar'),
                ),
              ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            _screenMode = ScreenMode.auth;
            setState(() {});
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red)),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text('Cancelar'),
          ),
        ),
      ],
    );
    // tela
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Image.asset(
              'assets/imgs/login_logo.png',
              height: 100,
              width: 100,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text('Login',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    // campo e-mail
                    _textFormField(
                      textFormType: TextFormType.email,
                      controller: _emailController,
                      hintText: 'Informe seu e-mail',
                      labelText: 'E-mail',
                    ),
                    const SizedBox(height: 5),
                    // campo senha
                    _textFormField(
                      textFormType: TextFormType.password,
                      controller: _passwordController,
                      hintText: 'Informe sua senha',
                      labelText: 'Senha',
                    ),
                    const SizedBox(height: 5),
                    // campo confirmar senha
                    if (_screenMode == ScreenMode.signUp)
                      _textFormField(
                        textFormType: TextFormType.confirmPassword,
                        controller: _passwordConfirmController,
                        hintText: 'Confirme sua senha',
                        labelText: 'Repita a Senha',
                      ),
                    // ---- Botões Login --------------------------------------------
                    const SizedBox(height: 10),
                    if (_screenMode == ScreenMode.auth) rowLoginButtons,
                    // ---- Botões cadastro --------------------------------------------
                    if (_screenMode == ScreenMode.signUp) rowSignUpButtons
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  TextFormField _textFormField({
    required TextFormType textFormType,
    required TextEditingController controller,
    required String hintText,
    required String labelText,
  }) {
    return TextFormField(
      obscureText: textFormType == TextFormType.email ? false : _hidePassword,
      keyboardType: textFormType == TextFormType.email
          ? TextInputType.text
          : TextInputType.emailAddress,
      onSaved: (value) => {
        if (textFormType == TextFormType.email)
          _authData['email'] = value ?? ''
        else if (textFormType == TextFormType.password)
          _authData['password'] = value ?? ''
      },
      validator: (value) {
        final finalValue = value ?? '';
        if (textFormType == TextFormType.email) {
          if (finalValue.trim().isEmpty) {
            return 'Informe o e-mail';
          }
          if (!finalValue.contains('@') || !finalValue.contains('.')) {
            return 'Informe um e-mail válido';
          }
        } else if (textFormType == TextFormType.password) {
          if (finalValue.trim().isEmpty) {
            return 'Informe a senha';
          }
          if (finalValue.trim().length < 6) {
            return 'Senha deve possuir 6 ou mais caracteres';
          }
        } else {
          // só deve fazer validação se estiver no modo cadastro
          if (_screenMode == ScreenMode.signUp &&
              finalValue != _passwordController.text) {
            return 'Senhas informadas não conferem';
          }
        }
        return null;
      },
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: textFormType == TextFormType.email
            ? const Icon(Icons.mail)
            : const Icon(Icons.lock),
        // controle de exibição da senha
        suffixIcon: textFormType == TextFormType.email
            ? null
            : GestureDetector(
                onTap: () {
                  _hidePassword = !_hidePassword;
                  setState(() {});
                },
                child: Icon(
                    _hidePassword ? Icons.visibility : Icons.visibility_off),
              ),
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}
