import '../Token.dart';

enum Tipo{
  ENTERO,
  REAL,
  CARACTER,
  CADENA,
  BOOLEANO
}

class ExprTipo
{
  late Tipo tipo;

  ExprTipo(this.tipo);
}

class IdentificadorTipo extends ExprTipo
{
  late Token identificador;
  IdentificadorTipo(Tipo tipo, Token identificador) : super(tipo)
  {
    this.identificador = identificador;
  }
}