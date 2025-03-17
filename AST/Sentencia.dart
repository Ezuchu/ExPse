import '../Token.dart';
import 'Expresion.dart';
import 'Tipos.dart';

abstract class Sentencia 
{
  R aceptar<R>(VisitorSentencia<R> visitor);
}

abstract class VisitorSentencia<R>
{
  /*R VisitaExpresion(ExpresionSentencia expresion);
  
  R VisitaVariable(Variable variable);
  R VisitaBloque(Bloque bloque);
  R VisitaSi(Si si);
  R VisitaMientras(Mientras mientras);
  R VisitaPara(Para para);
  R VisitaFuncion(Funcion funcion);
  R VisitaRetorno(Retorno retorno);
  R VisitaClase(Clase clase);*/

  R VisitaPrincipal(Principal principal);
  R VisitaEscribir(Escribir escribir);
  R VisitaDecVariable(DecVariable decVariable);
}

class Principal extends Sentencia
{
  late List<Sentencia> sentencias;

  Principal(List<Sentencia> sentencias)
  {
    this.sentencias = sentencias;
  }

  @override
  R aceptar<R>(VisitorSentencia<R> visitor) {
    return visitor.VisitaPrincipal(this);
  }
}

class DecVariable extends Sentencia
{
  late Tipo tipo;
  late Token identificador;

  DecVariable(this.tipo, this.identificador);

  @override  
  R aceptar<R>(VisitorSentencia<R> visitor) 
  {
    return visitor.VisitaDecVariable(this);
  }
}

class Escribir extends Sentencia
{
  late Expresion expresion;

  Escribir(Expresion expresion)
  {
    this.expresion = expresion;
  }

  @override
  R aceptar<R>(VisitorSentencia<R> visitor) {
    return visitor.VisitaEscribir(this);
  }
}