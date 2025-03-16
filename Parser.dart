import 'AST/Expresion.dart';
import 'ParserBase.dart';
import 'RuntimeError.dart';
import 'Sentencia.dart';
import 'TiposToken.dart';
import 'Token.dart';

class Parser extends ParserBase
{
  Parser(super.tokens);

  void analisis()
  {
    while(!llegoFinal())
    {
      sentencias.add(declaracion());
    }
  }

  
  Sentencia declaracion()
  {
    if(encontrar([TiposToken.Inicio]))
    {
      return principal();
    }
    throw RuntimeError('Declaración no válida', tokenAct.fila, tokenAct.columna, 1);
  }


  Sentencia principal()
  {
    List<Sentencia> sentencias = [];
    while(!encontrar([TiposToken.Fin]))
    {
      sentencias.add(sentencia());
    }
    return Principal(sentencias);
  }

  Sentencia sentencia()
  {
    if(encontrar([TiposToken.Escribir]))
    {
      return escribir();
    }
    throw RuntimeError('Sentencia no válida', tokenAct.fila, tokenAct.columna, 1);
  }

  Sentencia escribir()
  {
    validar(TiposToken.PARENT_IZQ, 'Se esperaba \'(\'');

    Expresion expr = expresion();

    validar(TiposToken.PARENT_DER, 'Se esperaba \')\'');
    separador();

    return Escribir(expr);
  }

  Expresion expresion()
  {
    return igualdad();
  }

  Expresion igualdad()
  {
    Expresion izq = comparacion();
    

    while(encontrar([TiposToken.DobleIgual,TiposToken.Diferente]))
    {
      Token operador = previo();
      Expresion der = comparacion();
      

      izq = Binario(izq, operador, der);
    }

    return izq;
  }

  Expresion comparacion()
  {
    Expresion izq = adicion();
    

    while(encontrar([TiposToken.Mayor,TiposToken.MayorIgual,TiposToken.Menor,TiposToken.MenorIgual]))
    {
      Token operador = previo();
      Expresion der = adicion();
      

      izq = Binario(izq, operador, der);
    }
    return izq;
  }

  Expresion adicion()
  {
    Expresion izq = factor();
    
    while(encontrar([TiposToken.Mas,TiposToken.Menos]))
    {
      Token operador = previo();
      Expresion der = factor();

      izq = Binario(izq, operador, der);
    }

    return izq;
  }

  Expresion factor()
  {
    Expresion izq = unario();

    while(encontrar([TiposToken.Por,TiposToken.Div,TiposToken.Mod]))
    {
      Token operador = previo();
      Expresion der = unario();

      izq = Binario(izq, operador, der);
    }

    return izq;
  }

  Expresion unario()
  {
    if(encontrar([TiposToken.Negacion,TiposToken.Menos]))
    {
      Token operador = previo();
      Expresion der = unario();
      return Unario(operador, der);
    }

    return literal();
  }

  Expresion literal()
  {
    if(encontrar([TiposToken.VERDADERO])){return Literal(true,previo().columna,previo().fila);}
    if(encontrar([TiposToken.FALSO])){return Literal(false, previo().columna, previo().fila);}

    if(encontrar([TiposToken.ENTERO,TiposToken.REAL,TiposToken.CARACTER,TiposToken.CADENA])){return Literal(previo().literal,previo().columna,previo().fila);}

    if(encontrar([TiposToken.PARENT_IZQ]))
    {
      Expresion expr = expresion();
      validar(TiposToken.PARENT_DER, 'Se esperaba \')\'');
      return Grupo(expr);
    }
    throw RuntimeError('Expresión no válida',tokenAct.fila,tokenAct.columna,1);
  }
}
