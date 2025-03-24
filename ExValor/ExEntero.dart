import '../AST/Tipos.dart';
import 'ExValor.dart';

class ExEntero extends ExValor 
{
  late int? valor;

  ExEntero(int? valor) : super(EnumTipo.ENTERO)
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