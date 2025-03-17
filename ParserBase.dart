import 'RuntimeError.dart';
import 'AST/Sentencia.dart';
import 'TiposToken.dart';
import 'Token.dart';

abstract class ParserBase 
{
  List<Token> tokens = [];
  List<Sentencia> sentencias = [];
  int tActual = 0;
  late Token tokenAct;

  ParserBase(List<Token> tokens)
  {
    this.tokens = tokens;
    this.tokenAct = tokens[0];
  }

  

  Token previo()
  {
    return tokens[tActual-1];
  }

  avanzar()
  {
    tActual++;
    tokenAct = tokens[tActual];
  }

  bool encontrar(List<TiposToken> tipos)
  {
    for(TiposToken tipo in tipos)
    {
      if(encontrado(tipo))
      {
        avanzar();
        return true;
      }
    }
    return false;
  }

  bool encontrado(TiposToken tipo)
  {
    if(tokens[tActual].tipo == tipo)
    {
      return true;
    }
    return false;
  }

  void validar(TiposToken tipo, String mensaje)
  {
    if(!encontrado(tipo))
    {
      throw RuntimeError(mensaje,tokenAct.fila,tokenAct.columna,1);
    }
    avanzar();
  }
    

  bool separador()
  {
    if(!encontrar([TiposToken.PUNTOYCOMA]) && tokenAct.fila == previo().fila)
    {
      throw Exception('Se esperaba un punto y coma o un salto de linea');
    }
    return true;
  }

  bool llegoFinal()
  {
    return tokenAct.tipo == TiposToken.EOF;
  }
  
  
}