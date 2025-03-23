import '../AST/Tipos.dart';
import 'ExValor.dart';

class ExArreglo extends ExValor
{
  late List<ExValor>? valor;
  late Tipo? contenido;

  ExArreglo(List<ExValor>? valor,Tipo? contenido):super(EnumTipo.ARREGLO)
  {
    this.valor = valor;
    this.contenido = contenido;
  }

  @override
  String toString() {
    return valor.toString();
  }
}