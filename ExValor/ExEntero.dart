import '../AST/Tipos.dart';
import 'ExValor.dart';

class ExEntero extends ExValor 
{
  late int? valor;

  ExEntero(int? valor) : super(EnumTipo.ENTERO)
  {
    this.valor = valor;
  }

  @override
  String toString() {
    return valor.toString();
  }
}