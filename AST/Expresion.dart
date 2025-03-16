import '../Token.dart';

abstract class Expresion 
{
  R aceptar<R>(VisitorExpresion visitor);
}

abstract class VisitorExpresion<R>{
  R VisitaBinario(Binario binario);
  R VisitaGrupo(Grupo grupo);
  R VisitaLiteral(Literal literal);
  R VisitaUnario(Unario unario);
}

class Binario extends Expresion
{
  late Expresion izq;
  late Token operador;
  late Expresion der;

  Binario(Expresion izq,Token operador,Expresion der)
  {
    this.izq = izq;
    this.operador = operador;
    this.der = der;
  }
  
  @override
  R aceptar<R>(VisitorExpresion visitor) {
    return visitor.VisitaBinario(this);
  }
}

class Grupo extends Expresion
{
  late Expresion expresion;
  Grupo(Expresion expresion)
  {
    this.expresion = expresion;
  }

  @override
  R aceptar<R>(VisitorExpresion visitor) {
    return visitor.VisitaGrupo(this);
  }
}

class Literal extends Expresion
{
  late Object? valor;
  late int columna;
  late int fila;

  Literal(Object? valor,int columna,int fila)
  {
    this.valor = valor;
    this.columna = columna;
    this.fila = fila;
  }

  @override
  R aceptar<R>(VisitorExpresion visitor) {
    return visitor.VisitaLiteral(this);
  }
}

class Unario extends Expresion
{
  late Token operador;
  late Expresion operando;

  Unario(Token operador,Expresion expresion)
  {
    this.operador = operador;
    this.operando = expresion;
  }

  @override
  R aceptar<R>(VisitorExpresion visitor) {
    return visitor.VisitaUnario(this);
  }
}



