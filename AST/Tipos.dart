import '../Token.dart';
import 'Expresion.dart';

enum EnumTipo{
  ENTERO,
  REAL,
  CARACTER,
  CADENA,
  BOOLEANO,

  ARREGLO,

  IDENTIFICADOR
}

class Tipo
{
  late EnumTipo tipo;

  Tipo(this.tipo);
}

class IdentificadorTipo extends Tipo
{
  late Token identificador;
  IdentificadorTipo(EnumTipo tipo, Token identificador) : super(EnumTipo.IDENTIFICADOR)
  {
    this.identificador = identificador;
  }
}

class Arreglotipo extends Tipo
{
  late Tipo contenido;
  late Expresion dimension;

  Arreglotipo(this.contenido,this.dimension) : super(EnumTipo.ARREGLO);
}