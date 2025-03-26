import '../AST/Tipos.dart';
import '../RuntimeError.dart';
import '../Token.dart';
import 'ExCaracter.dart';
import 'ExValor.dart';

class ExCadena extends ExValor
{
  late String? valor;

  ExCadena(String? valor): super(EnumTipo.CADENA)
  {
    this.valor = valor;
  }

  asignar(ExValor der, Token id)
  {
    if(der is! ExCadena && der is! ExCaracter)
    {
      throw RuntimeError('Tipos incompatibles', id.fila, null, 2);
    }
    this.valor = der.valor;
  }

  ExCaracter obtener(int indice, Token id)
  {
    if(indice < 0 || indice >= this.valor!.length)
    {
      throw RuntimeError('El indice sobrepasa el largo de la cadena', id.fila, null, 2);
    }
    return ExCaracter(this.valor![indice]);
  }

  @override
  String toString() {
    return valor.toString();
  }
}