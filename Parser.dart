import 'AST/Expresion.dart';
import 'AST/Tipos.dart';
import 'ParserBase.dart';
import 'RuntimeError.dart';
import 'AST/Sentencia.dart';
import 'TiposToken.dart';
import 'Token.dart';

class Parser extends ParserBase
{
  Parser(super.tokens);

  
  List<TiposToken> tipos = [TiposToken.TipoEntero,TiposToken.TipoReal,TiposToken.TipoCaracter,TiposToken.TipoCadena,TiposToken.TipoBooleano];

  Map<TiposToken,EnumTipo> mapaTipos = {
    TiposToken.TipoEntero: EnumTipo.ENTERO,
    TiposToken.TipoReal: EnumTipo.REAL,
    TiposToken.TipoCaracter: EnumTipo.CARACTER,
    TiposToken.TipoCadena: EnumTipo.CADENA,
    TiposToken.TipoBooleano: EnumTipo.BOOLEANO
  };

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
    if(encontrar([TiposToken.TipoEntero,TiposToken.TipoReal,TiposToken.TipoCaracter,TiposToken.TipoCadena,TiposToken.TipoBooleano]))
    {
      return decVariable();
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

  Sentencia decVariable()
  {
    Token tipo = previo();
    late Tipo tipoVar;
    if(tipos.contains(tipo.tipo))
    {
      tipoVar = Tipo(mapaTipos[tipo.tipo]!);
    }else
    {
      tipoVar = IdentificadorTipo(EnumTipo.IDENTIFICADOR, tipo);
    }

    validar(TiposToken.IDENTIFICADOR, 'Se esperaba un identificador');
    Token identificador = previo();

    separador();
    return DecVariable(tipoVar, identificador);
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
