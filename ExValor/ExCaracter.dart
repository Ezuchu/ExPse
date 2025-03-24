import '../AST/Tipos.dart';
import 'ExValor.dart';

class ExCaracter extends ExValor
{
  late String? valor;

  ExCaracter(String? valor): super(EnumTipo.CARACTER)
  {
    this.valor = valor;
  }

  asignar(ExValor der)
  {
    this.valor = der.valor;
  }

  @override
  String toString() {
    return valor.toString();
  }
}