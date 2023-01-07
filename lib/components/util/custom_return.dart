enum ReturnType { error, sucess }

class CustomReturn {
  final ReturnType returnType;
  final String message;
  final int returnCode;

  CustomReturn({
    required this.returnType,
    required this.message,
    this.returnCode = 0,
  });

  static CustomReturn unauthorizedError() {
    return CustomReturn(
      returnType: ReturnType.error,
      message: 'Sem autorização de acesso',
      returnCode: 401,
    );
  }

  static CustomReturn authSignUpError(String error) {
    Map<String, String> authErrors = {
      'EMAIL_EXISTS': 'E-mail já existe',
      'OPERATION_NOT_ALLOWED': 'Erro interno, acesso por e-mail e senha desativado',
      'USER_DISABLED': 'Usuário desativado',
      'INVALID_PASSWORD': 'Senha inválida',
      'INVALID_EMAIL': 'E-mail inválido',
      'EMAIL_NOT_FOUND': 'E-mail não encontrado'
    };
    if (authErrors[error] == null) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro não tratado: $error');
    } else {
      return CustomReturn(returnType: ReturnType.error, message: authErrors[error] ?? '');
    }
  }

  static CustomReturn sucess() {
    return CustomReturn(
      returnType: ReturnType.sucess,
      message: 'Sucesso',
      returnCode: 0,
    );
  }
}
