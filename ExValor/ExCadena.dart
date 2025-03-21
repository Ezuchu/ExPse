import '../AST/Tipos.dart';
import 'ExValor.dart';

class ExCadena extends ExValor
{
  late String? valor;

  ExCadena(String? valor): super(EnumTipo.CADENA)
  {
    this.valor = valor;
  }

  @override
  String toString() {
    return valor.toString();
  }
}