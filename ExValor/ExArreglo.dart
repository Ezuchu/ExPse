import '../AST/Tipos.dart';
import '../RuntimeError.dart';
import '../Token.dart';
import 'ExEntero.dart';
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

  asignar(ExValor der)
  {
    this.valor = der.valor;
  }

  ExValor obtener(List<ExEntero> indice,Token id)
  {
    ExEntero act = indice[0];
    
    if(act.valor! < 0 || act.valor! >= this.valor!.length)
    {
      throw RuntimeError('El indice no se encuentra dentro del rango del arreglo de ${id.lexema}', id.fila, null, 2);
    }
    if(indice.length > 1)
    {
      if(valor![act.valor!] is! ExArreglo)
      {
        throw RuntimeError('Hay más indices que los esperados en ${id.lexema}', id.fila, null, 2);
      }
      indice.removeAt(0);
      
      return ((this.valor![act.valor!])as ExArreglo).obtener(indice,id);
    }

    return this.valor![act.valor!];

  }

  @override
  String toString() {
    return valor.toString();
  }
}