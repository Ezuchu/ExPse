import '../AST/Tipos.dart';
import 'ExValor.dart';

class ExReal extends ExValor 
{
  late double? valor;

  ExReal(double? valor):super(EnumTipo.REAL)
  {
    this.valor = valor;
  }

  @override
  asignar(ExValor der)
  {
    this.valor = der.valor;
  }

  @override
  String toString() {
    return valor.toString();
  }
}