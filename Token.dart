import 'TiposToken.dart';

class Token 
{
  late TiposToken tipo;
  late int fila;
  late int columna;
  late String lexema;
  Object? literal;

  Token(TiposToken tipo, int fila, int columna, String lexema, Object? literal)
  {
    this.tipo = tipo;
    this.fila = fila;
    this.columna = columna;
    this.lexema = lexema;
    this.literal = literal;
  }
}