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

  Map<TiposToken,EnumTipo> mapaTiposLiteral = 
  {
    TiposToken.ENTERO: EnumTipo.ENTERO,
    TiposToken.REAL: EnumTipo.REAL,
    TiposToken.CARACTER: EnumTipo.CARACTER,
    TiposToken.CADENA: EnumTipo.CADENA
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
    if(encontrar([TiposToken.TipoEntero,TiposToken.TipoReal,TiposToken.TipoCaracter,TiposToken.TipoCadena,TiposToken.TipoBooleano]))
    {
      return decVariable();
    }
    if(encontrar([TiposToken.Constante]))
    {
      return decConstante();
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
    
    if(encontrar([TiposToken.TipoEntero,TiposToken.TipoReal,TiposToken.TipoCaracter,TiposToken.TipoCadena,TiposToken.TipoBooleano]))
    {
      return decVariable();
    }
    if(encontrar([TiposToken.Constante]))
    {
      return decConstante();
    }

    if(encontrar([TiposToken.IDENTIFICADOR]))
    {
      Token identificador = previo();
      if(!encontrar([TiposToken.PARENT_IZQ]))
      {
        return asignacion(identificador);
      }
    }

    if(encontrar([TiposToken.Escribir]))
    {
      return escribir();
    }
    if(encontrar([TiposToken.Leer]))
    {
      return leer();
    }
    throw RuntimeError('Sentencia no válida', tokenAct.fila, tokenAct.columna, 1);
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

    if(encontrar([TiposToken.Igual]))
    {
      Expresion valor = expresion();
      separador();
      return DecVariable.inicializar(tipoVar, identificador, valor);
    }

    separador();
    return DecVariable(tipoVar, identificador);
  }

  Sentencia decConstante()
  {
    validar(TiposToken.IDENTIFICADOR, 'Se esperaba un identificador');
    Token identificador = previo();

    validar(TiposToken.Igual, 'Se esperaba \'=\'');
    Expresion valor = expresion();
    separador();

    return DecConstante(identificador, valor);
  }

  Sentencia escribir()
  {
    validar(TiposToken.PARENT_IZQ, 'Se esperaba \'(\'');

    Expresion expr = expresion();

    validar(TiposToken.PARENT_DER, 'Se esperaba \')\'');
    separador();

    return Escribir(expr);
  }

  Sentencia leer()
  {
    Expresion variable = literal();
    if(variable is! Variable)
    {
      throw RuntimeError('Se esperaba una variable', tokenAct.fila, tokenAct.columna, 1);
    }
    separador();
    return Leer(variable as Variable);
  }

  Sentencia asignacion(Token identificador)
  {
    validar(TiposToken.Igual, 'Se esperaba \'=\'');
    Expresion expr = expresion();
    separador();

    return Asignacion(identificador, expr);
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
    if(encontrar([TiposToken.VERDADERO])){return Literal(true,EnumTipo.BOOLEANO,previo().columna,previo().fila);}
    if(encontrar([TiposToken.FALSO])){return Literal(false, EnumTipo.BOOLEANO,previo().columna, previo().fila);}

    if(encontrar([TiposToken.ENTERO,TiposToken.REAL,TiposToken.CARACTER,TiposToken.CADENA]))
    {
      EnumTipo tipo = mapaTiposLiteral[previo().tipo]!;
      return Literal(previo().literal,tipo,previo().columna,previo().fila);
    }

    if(encontrar([TiposToken.IDENTIFICADOR]))
    {
      return Variable(previo());
    }

    if(encontrar([TiposToken.PARENT_IZQ]))
    {
      Expresion expr = expresion();
      validar(TiposToken.PARENT_DER, 'Se esperaba \')\'');
      return Grupo(expr);
    }
    throw RuntimeError('Expresión no válida',tokenAct.fila,tokenAct.columna,1);
  }
}
