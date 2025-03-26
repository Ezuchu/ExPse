import '../AST/Tipos.dart';
import '../RuntimeError.dart';
import '../Token.dart';
import 'ExEntero.dart';
import 'ExValor.dart';

class ExArreglo extends ExValor
{
  late List<ExValor> valor;
  late Tipo? contenido;
  late int dimension;

  ExArreglo(List<ExValor> valor,Tipo? contenido,int index):super(EnumTipo.ARREGLO)
  {
    /*if(valor == null)
    {
      if(contenido != Arreglotipo)
      {
        this.valor = List<ExValor?>.filled(index, null);
      }else
      {
        Arreglotipo nContenido = (contenido as Arreglotipo).contenido as Arreglotipo;
        this.valor = List<ExValor>.filled(index,ExArreglo(null,nContenido,index));
      }
      
    }else
    {
      this.valor = valor;
    }*/

    this.valor = valor;
    this.dimension = index;
    this.contenido = contenido;
    
    
  }

  asignar(ExValor der, Token id)
  {
    if(der is! ExArreglo || der.contenido != this.contenido)
    {
      throw RuntimeError('Tipos incompatibles', id.fila, null, 2);
    }
    this.valor = der.valor;
  }

  ExValor? obtener(List<ExEntero> indice,Token id)
  {
    ExEntero act = indice[0];
    
    if(act.valor! < 0 || act.valor! >= this.dimension)
    {
      throw RuntimeError('El indice ${act.valor!} no se encuentra dentro del rango del arreglo de ${id.lexema}', id.fila, null, 2);
    }
    if(indice.length > 1)
    {
      if(contenido is! Arreglotipo)
      {
        throw RuntimeError('Hay más indices que los esperados en ${id.lexema}', id.fila, null, 2);
      }
      
      indice.removeAt(0);
      
      return ((this.valor![act.valor!])as ExArreglo).obtener(indice,id);
    }

    return this.valor[act.valor!];

  }

  @override
  String toString() {
    return valor.toString();
  }
}