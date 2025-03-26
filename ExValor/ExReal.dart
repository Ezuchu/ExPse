import '../AST/Tipos.dart';
import '../RuntimeError.dart';
import '../Token.dart';
import 'ExEntero.dart';
import 'ExValor.dart';

class ExReal extends ExValor 
{
  late double? valor;

  ExReal(double? valor):super(EnumTipo.REAL)
  {
    this.valor = valor;
  }

  @override
  asignar(ExValor der, Token id)
  {
    if(der is! ExReal && der is! ExEntero)
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