import '../AST/Tipos.dart';
import 'ExValor.dart';

class ExArreglo extends ExValor
{
  late List<ExValor>? valor;

  ExArreglo(List<ExValor>? valor):super(EnumTipo.ARREGLO)
  {
    this.valor = valor;
  }

  @override
  String toString() {
    return valor.toString();
  }
}