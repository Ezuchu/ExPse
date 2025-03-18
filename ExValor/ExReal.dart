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
  String toString() {
    return valor.toString();
  }
}