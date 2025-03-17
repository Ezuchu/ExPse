import '../Token.dart';

enum EnumTipo{
  ENTERO,
  REAL,
  CARACTER,
  CADENA,
  BOOLEANO,



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