import '../AST/Tipos.dart';
import '../RuntimeError.dart';
import '../Token.dart';
import 'ExValor.dart';

class ExEntero extends ExValor 
{
  late int? valor;

  ExEntero(int? valor) : super(EnumTipo.ENTERO)
  {
    this.valor = valor;
  }

  asignar(ExValor der, Token id)
  {
    if(der is! ExEntero)
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