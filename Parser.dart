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

  
  List<TiposToken> tipos = [
    TiposToken.TipoEntero,
    TiposToken.TipoReal,
    TiposToken.TipoCaracter,
    TiposToken.TipoCadena,
    TiposToken.TipoBooleano,
    TiposToken.TipoArreglo];

  Map<TiposToken,EnumTipo> mapaTipos = {
    TiposToken.TipoEntero: EnumTipo.ENTERO,
    TiposToken.TipoReal: EnumTipo.REAL,
    TiposToken.TipoCaracter: EnumTipo.CARACTER,
    TiposToken.TipoCadena: EnumTipo.CADENA,
    TiposToken.TipoBooleano: EnumTipo.BOOLEANO,
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
    if(encontrar(tipos))
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
    
    if(encontrar(tipos))
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


    if(encontrar([TiposToken.Si]))
    {
      return condicional();
    }
    if(encontrar([TiposToken.Caso]))
    {
      return caso();
    }
    if(encontrar([TiposToken.Mientras]))
    {
      return mientras();
    }
    if(encontrar([TiposToken.Repetir]))
    {
      return repeticion();
    }
    if(encontrar([TiposToken.Para]))
    {
      return para();
    }
    throw RuntimeError('Sentencia ${tokenAct.lexema} no válida', tokenAct.fila, tokenAct.columna, 1);
  }

  

  Sentencia decVariable()
  {
    Token tipo = previo();
    late Tipo tipoVar;

    if(mapaTipos.containsKey(tipo.tipo))
    {
      tipoVar = Tipo(mapaTipos[tipo.tipo]!);
    }else
    {
      if(tipo.tipo == TiposToken.TipoArreglo)
      {
        tipoVar = tipoArreglo();
      }
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

  Sentencia condicional()
  {
    validar(TiposToken.PARENT_IZQ, 'Se esperaba \'(\'');
    Expresion condicion = expresion();
    validar(TiposToken.PARENT_DER, 'Se esperaba \')\'');

    List<Sentencia> entonces = [];
    while(!encontrar([TiposToken.Sino,TiposToken.Fsi]))
    {
      entonces.add(sentencia());
    }
    List<Sentencia> sino = [];

    

    if(previo().tipo == TiposToken.Sino)
    {
      while(!encontrar([TiposToken.Fsi]))
      {
        
        sino.add(sentencia());
      }
    }

    return Condicional(condicion, entonces, sino);
  }

  Sentencia caso()
  {
    validar(TiposToken.PARENT_IZQ, 'Se esperaba \'(\'');
    Expresion variable = literal();
    if(variable is! Variable)
    {
      throw RuntimeError('Se esperaba una variable', previo().fila, previo().columna, 1);
    }
    validar(TiposToken.PARENT_DER, 'Se esperaba \')\'');

    Map<Literal,List<Sentencia>> casos = {};

    while(!encontrar([TiposToken.Sino,TiposToken.FCaso]))
    {
      validarEOF('No se cerro la estructura de casos');
      Expresion valor = literal();
      if(valor is Grupo)
      {
        throw RuntimeError('Solo se aceptan valores literales', previo().fila, previo().columna, 1);
      }
      validar(TiposToken.DOSPUNTOS, 'Se esperaba \':\'');
      List<Sentencia> sentencias = [];
      while(!encontrar([TiposToken.Cierra]))
      {
        validarEOF('No se cerro el caso');
        sentencias.add(sentencia());
      }
      casos[valor as Literal] = sentencias;
    }

    List<Sentencia> casoDefault = [];

    if(previo().tipo == TiposToken.Sino)
    {
      while(!encontrar([TiposToken.FCaso]))
      {
        validarEOF('No se cerro el caso');
        casoDefault.add(sentencia());
      }
    }
    return Caso(variable,casos,casoDefault);
  }

  Sentencia mientras()
  {
    validar(TiposToken.PARENT_IZQ, 'Se esperaba \'(\'');
    Expresion condicion = expresion();
    validar(TiposToken.PARENT_DER, 'Se esperaba \')\'');

    List<Sentencia> entonces = [];
    while(!encontrar([TiposToken.Fmientras]))
    {
      entonces.add(sentencia());
    }

    return Mientras(condicion,entonces);
  }

  Sentencia repeticion()
  {
    List<Sentencia> sentencias = [];
    while(!encontrar([TiposToken.Hasta]))
    {
      sentencias.add(sentencia());
    }

    validar(TiposToken.PARENT_IZQ, 'Se esperaba \'(\'');
    Expresion condicion = expresion();
    validar(TiposToken.PARENT_DER, 'Se esperaba \')\'');

    separador();

    return Repeticion(condicion,sentencias);
  }

  

  Sentencia para()
  {
    validar(TiposToken.PARENT_IZQ,'Se esperaba \'(\'');
    validar(TiposToken.IDENTIFICADOR,'Se esperaba un identificador de variable');

    Token identificador = previo();

    validar(TiposToken.Igual,'Se esperaba \'=\'');

    Expresion inicial = expresion();

    validar(TiposToken.COMA,'Se esperaba\',\'');

    Expresion fin = expresion();

    validar(TiposToken.COMA,'Se esperaba \',\'');

    validar(TiposToken.IDENTIFICADOR,'Se esperaba un identificador de variable');

    if(previo().lexema != identificador.lexema)
    {
      throw RuntimeError('El identificador de la variable de control no coincide',previo().fila,previo().columna,1);
    }

    if(!encontrar([TiposToken.Incremento,TiposToken.Decremento]))
    {
      throw RuntimeError('Se esperaba un operador de incremento o decremento',tokenAct.fila,tokenAct.columna,1);
    }

    Token accion = previo();

    validar(TiposToken.PARENT_DER,'Se esperaba \')\'');

    List<Sentencia> sentencias = [];

    while(!encontrar([TiposToken.Fpara]))
    {
      validarEOF('Se esperaba el cierre del ciclo Para');
      sentencias.add(sentencia());
    }

    return Para(identificador,inicial,fin,accion,sentencias);
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
    return disyuncion();
  }

  Expresion disyuncion()
  {
    Expresion izq = conjucion();

    while(encontrar([TiposToken.O]))
    {
      Token operador = previo();
      Expresion der = conjucion();
      izq = Logico(izq, operador, der);
    }

    return izq;
  }

  Expresion conjucion()
  {
    Expresion izq = igualdad();

    while(encontrar([TiposToken.Y]))
    {
      Token operador = previo();
      Expresion der = igualdad();
      izq = Logico(izq, operador, der);
    }

    return izq;
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

    return index();
  }

  Expresion index()
  {
    Token id = tokenAct;
    Expresion expr = literal();
    List<Expresion> indices = [];

    while(encontrar([TiposToken.CORCHETE_IZQ]))
    {
      indices.add(expresion());
      validar(TiposToken.CORCHETE_DER, 'Se esperaba \']\'');
    }

    if(indices.isNotEmpty)
    {
      if(expr is! Variable)
      {
        throw RuntimeError('Se esperaba un identificador de variable', id.fila, id.columna, 1);
      }
      return Indice(expr, indices);
    }
    return expr;
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

    if(encontrar([TiposToken.CORCHETE_IZQ]))
    {
      Token inicio = previo();
      List<Expresion> elementos = [];
      while(!encontrar([TiposToken.CORCHETE_DER]))
      {
        validarEOF('No se cerró el arreglo');
        if(elementos.length >= 1)
        {
          validar(TiposToken.COMA, 'Se esperaba \',\' para separar elementos');
        }
        elementos.add(expresion());
      }
      return Arreglo(elementos, inicio.fila, inicio.columna);
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

  Tipo obtenerTipo()
  {
    if(!encontrar(tipos))
    {
      throw RuntimeError('${tokenAct.lexema} no es un tipo válido',tokenAct.fila,tokenAct.columna,1);
    }
    Token tipo = previo();

    if(mapaTipos.containsKey(tipo.tipo))
    {
      return Tipo(mapaTipos[tipo.tipo]!);
    }
    return tipoArreglo();
  }

  Arreglotipo tipoArreglo()
  {
    validar(TiposToken.Menor, 'Se esperaba \'<\'');
    Tipo contenido = obtenerTipo();
    validar(TiposToken.CORCHETE_IZQ, 'Se esperaba \'[\'');
    Expresion dimension = expresion();
    validar(TiposToken.CORCHETE_DER, 'Se esperaba \']\'');
    validar(TiposToken.Mayor, 'Se esperaba \'>\'');

    return Arreglotipo(contenido, dimension);
  }

  
}
