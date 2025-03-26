import '../AST/Tipos.dart';
import '../RuntimeError.dart';
import '../Token.dart';
import 'ExValor.dart';

class ExCaracter extends ExValor
{
  late String? valor;

  ExCaracter(String? valor): super(EnumTipo.CARACTER)
  {
    this.valor = valor;
  }

  asignar(ExValor der, Token id)
  {
    if(der is! ExCaracter)
    {
      throw RuntimeError('Tipos incompatibles', id.fila, null, 2);
    }
    this.valor = der.valor;
  }

  @override
  String toString() {
    return valor.toString();
  }
}