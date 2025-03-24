import '../AST/Tipos.dart';
import 'ExValor.dart';

class ExBool extends ExValor {
  late bool? valor;

  ExBool(bool? valor) : super(EnumTipo.BOOLEANO) {
    this.valor = valor;
  }

  asignar(ExValor der)
  {
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