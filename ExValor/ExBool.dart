import '../AST/Tipos.dart';
import '../RuntimeError.dart';
import '../Token.dart';
import 'ExValor.dart';

class ExBool extends ExValor {
  late bool? valor;

  ExBool(bool? valor) : super(EnumTipo.BOOLEANO) {
    this.valor = valor;
  }

  asignar(ExValor der,Token id)
  {
    if(der is! ExBool)
    {
      throw RuntimeError('Tipos incompatibles', id.fila, null, 2);
    }
    this.valor = der.valor;
  }

  @override
  String toString() {
    switch (valor) {
      case true:
        return "Verdadero";
      case false:
        return "Falso";
      default:
        return "null";
    }
  }
}