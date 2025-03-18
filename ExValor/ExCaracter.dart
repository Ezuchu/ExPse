import '../AST/Tipos.dart';
import 'ExValor.dart';

class ExCaracter extends ExValor
{
  late String? valor;

  ExCaracter(String? valor): super(EnumTipo.CARACTER)
  {
    this.valor = valor;
  }

  @override
  String toString() {
    return valor.toString();
  }
}