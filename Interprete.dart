import 'dart:io';

import 'AST/Expresion.dart';
import 'AST/Tipos.dart';
import 'Entorno.dart';
import 'ExValor/ExArreglo.dart';
import 'ExValor/ExBool.dart';
import 'ExValor/ExCadena.dart';
import 'ExValor/ExCaracter.dart';
import 'ExValor/ExEntero.dart';
import 'ExValor/ExReal.dart';
import 'ExValor/ExValor.dart';
import 'RuntimeError.dart';
import 'AST/Sentencia.dart';
import 'TiposToken.dart';
import 'Token.dart';

class Interprete implements VisitorExpresion,VisitorSentencia
{
  Entorno global = new Entorno();

  late Entorno entorno;

  Interprete()
  {
    this.entorno = global;
  }

  void interpretar(List<Sentencia> sentencias) {
    for(Sentencia sentencia in sentencias) {
      ejecutar(sentencia);
    }
  }

  void ejecutar(Sentencia sentencia) {
    sentencia.aceptar(this);
  }

  void conjunto(List<Sentencia> sentencias) {
    for(Sentencia sentencia in sentencias) {
      ejecutar(sentencia);
    }
  }

  ExValor evaluar(Expresion expresion) {
    return expresion.aceptar(this);
  }

  @override
  VisitaPrincipal(Principal principal) {
    Entorno previo = this.entorno;
    this.entorno = Entorno.local(previo);

    for(Sentencia sentencia in principal.sentencias) {
      ejecutar(sentencia);
    }

    this.entorno = previo;
    
  }

  @override
  VisitaDecVariable(DecVariable decVariable) {
    
    ExValor valor = genValor(decVariable.tipo,decVariable.valor,decVariable.identificador);
    this.entorno.definir(decVariable.identificador.lexema, valor);
    
  }

  @override  
  VisitaDecConstante(DecConstante decConstante) {
    ExValor valor = evaluar(decConstante.valor);
    valor.constante = true;
    this.entorno.definir(decConstante.identificador.lexema, valor);
  }

  @override
  VisitaEscribir(Escribir escribir) {
    ExValor valor = evaluar(escribir.expresion);
    print(valor);
  }

  @override  
  VisitaLeer(Leer leer) {
    Token id = leer.id;
    ExValor variable = evaluar(leer.variable);
    late ExValor nValor;

    if(variable.constante)
    {
      throw RuntimeError('No se puede modificar una constante', id.fila,null,2);
    }
    if(variable is ExBool)
    {
      throw RuntimeError('No se puede leer un booleano', id.fila,null,2);
    }

    String entrada = stdin.readLineSync()!;

    switch(variable.tipo)
    {
      case EnumTipo.ENTERO:
        esEntero(entrada,id);
        nValor = ExEntero(int.parse(entrada));
        break;
      case EnumTipo.REAL:
        esReal(entrada,id);
        nValor = ExReal(double.parse(entrada));
        break;
      case EnumTipo.CARACTER:
        nValor = ExCaracter(entrada);
        break;
      case EnumTipo.CADENA:
        nValor = ExCadena(entrada);
        break;
      default:
        throw RuntimeError('Tipo no soportado para lectura', id.fila,null,2);
    }

    variable.asignar(nValor,id);
  }

  @override
  VisitaAsignacion(Asignacion asignacion) {
    Expresion izq = asignacion.variable;
    Token id = asignacion.id;

    
    if(izq is! Variable && izq is! Indice)
    {
      throw RuntimeError('La expresion izquierda debe ser una variable', id.fila, null, 2);
    }

    ExValor inicial = evaluar(izq);
    
    if(inicial.constante)
    {
      throw RuntimeError('No se puede modificar una constante', id.fila,null,2);
    }

    ExValor valor = evaluar(asignacion.valor);
    valor.constante = false;

    
    
    inicial.asignar(valor,id);
  }

  @override  
  VisitaCondicional(Condicional condicional)
  {
    ExValor condicion = evaluar(condicional.condicion);

    Entorno previo = this.entorno;
    this.entorno = Entorno.local(previo);

    if(condicion.valor == true)
    {
      conjunto(condicional.Entonces);
    }else
    {
      if(condicional.Sino != null)
      {
        conjunto(condicional.Sino!);
      }
    }

    this.entorno = previo;
  }

  @override  
  VisitaCaso(Caso caso) {
    Variable variable = caso.variable;
    ExValor valor = this.entorno.obtener(variable.identificador);
    bool encontrado = false;

    caso.casos.forEach((literal,sentencias)
    {
      ExValor caso = evaluar(literal);
      if(valor.valor == caso.valor)
      {
        encontrado = true;
        Entorno previo = this.entorno;
        this.entorno = Entorno.local(previo);

        conjunto(sentencias);
        this.entorno = previo;
        
        return;
      }
    });

    if(caso.casoDefault.isNotEmpty && !encontrado)
    {
      Entorno previo = this.entorno;
      this.entorno = Entorno.local(previo);
      conjunto(caso.casoDefault);
      this.entorno = previo;
    }

  }

  @override  
  VisitaMientras(Mientras mientras) {
    while(evaluar(mientras.condicion).valor == true)
    {
      Entorno previo = this.entorno;
      this.entorno = new Entorno.local(previo);
      conjunto(mientras.sentencias);

      this.entorno = previo;
    }
  }

  @override  
  VisitaRepeticion(Repeticion repeticion) {
    do
    {
      Entorno previo = this.entorno;
      this.entorno = Entorno.local(previo);

      conjunto(repeticion.sentencias);
      this.entorno = previo;
    }while(evaluar(repeticion.condicion).valor == false);
  }

  @override  
  VisitaPara(Para para)
  {
    Token identificador = para.identificador;

    ExValor inicial = evaluar(para.inicio);

    int paso = 1;

    if(para.accion == TiposToken.Decremento)
    {
      paso = -1;
    }

    if(inicial.tipo != EnumTipo.ENTERO)
    {
      throw RuntimeError('El valor de inicio debe ser un entero', identificador.fila,null,2);
    }

    this.entorno.valores[identificador.lexema] = inicial;

    while(evaluar(para.fin).valor == true)
    {
      Entorno previo = this.entorno;
      this.entorno = Entorno.local(previo);

      conjunto(para.sentencias);
      

      this.entorno = previo;

      ExEntero valor = entorno.obtener(identificador) as ExEntero;
      valor.valor = valor.valor! + paso;
    }

    this.entorno.valores.remove(identificador.lexema);

    
  }

  @override
  ExValor VisitaVariable(Variable variable)
  {
    return this.entorno.obtener(variable.identificador);
  }

  @override  
  ExValor VisitaLiteral(Literal literal) {
    switch(literal.tipo)
    {
      case EnumTipo.ENTERO : return ExEntero(literal.valor as int);
      case EnumTipo.REAL : return ExReal(literal.valor as double);
      case EnumTipo.CARACTER : return ExCaracter(literal.valor as String);
      case EnumTipo.CADENA : return ExCadena(literal.valor as String);
      case EnumTipo.BOOLEANO : return ExBool(literal.valor as bool);

      default:
        return ExEntero(5);
    }
  }

  @override
  ExValor VisitaArreglo(Arreglo arreglo)
  {
    List<ExValor> valores = [];
    for(Expresion elemento in arreglo.elementos)
    {
      valores.add(evaluar(elemento));
    }
    return ExArreglo(valores,null,valores.length);
  }

  @override  
  ExValor? VisitaIndice(Indice indice)
  {
    Token id = indice.variable.identificador;
    ExValor arreglo = entorno.obtener(id);
    if(arreglo is! ExArreglo && arreglo is! ExCadena)
    {
      throw RuntimeError('La variable ${id.lexema} no es un arreglo', id.fila, null, 2);
    }
    List<ExEntero> indices = [];
    for(Expresion expresion in indice.indices)
    {
      ExValor nIndice = evaluar(expresion);
      if(nIndice is! ExEntero)
      {
        throw RuntimeError('Se esperaba una expresion entera en los indices de ${id.lexema}', id.fila, null, 2);
      }
      indices.add(nIndice as ExEntero);
    }

    if(arreglo is ExCadena)
    {
      if(indices.length > 1)
      {
        throw RuntimeError('La cantidad de indices supera las dimensiones de la cadena', id.fila, null, 2);
      }
      return arreglo.obtener(indices[0].valor!, id);
    }

    return (arreglo as ExArreglo).obtener(indices,id);
  }

  @override
  ExValor VisitaGrupo(Grupo grupo) {
    return evaluar(grupo.expresion);
  }

  @override
  ExValor? VisitaLogico(Logico logico)
  {
    ExValor izquierda = evaluar(logico.izq);
    ExValor derecha = evaluar(logico.der);

    if(izquierda.tipo != EnumTipo.BOOLEANO || derecha.tipo != EnumTipo.BOOLEANO)
    {
      throw RuntimeError('Ambos operandos deben ser booleanos', logico.operador.fila, null, 2);
    }

    switch(logico.operador.tipo)
    {
      case TiposToken.Y:
        return new ExBool(izquierda.valor! && derecha.valor!);
      case TiposToken.O:
        return new ExBool(izquierda.valor! || derecha.valor!);
      default:
        return null;
    }
  }

  @override
  ExValor? VisitaUnario(Unario unario) {
    ExValor valor = evaluar(unario.operando);

    switch (unario.operador.tipo) {
      case TiposToken.Menos:
        if(valor is ExEntero) {
          return new ExEntero(-valor.valor!);
        }
        if(valor is ExReal) {
          return new ExReal(-valor.valor!);
        }
        throw RuntimeError('Ambos operandos deben ser numéricos', unario.operador.fila, null, 2);
        
      case TiposToken.Negacion:
        if(valor is ExBool)
        {
          return new ExBool(!valor.valor!);
        }
        throw RuntimeError('Ambos operandos deben ser booleanos', unario.operador.fila, null, 2);
      default:
        return null;
    }
  }

  @override
  ExValor? VisitaBinario(Binario binario) {
    ExValor izquierda = evaluar(binario.izq);
    ExValor derecha = evaluar(binario.der);

    switch(binario.operador.tipo)
    {
      case TiposToken.Mas:
        if((izquierda.tipo == EnumTipo.REAL || izquierda.tipo == EnumTipo.ENTERO) && (derecha.tipo == EnumTipo.REAL || derecha.tipo == EnumTipo.ENTERO)) {
          if(izquierda.tipo == EnumTipo.REAL || derecha.tipo == EnumTipo.REAL)
          {
            return new ExReal(izquierda.valor! + derecha.valor!);
          }else
          {
            return new ExEntero(izquierda.valor! + derecha.valor!);
          }
        }
        if(izquierda is ExCadena || derecha is String) {
          return new ExCadena(izquierda.valor.toString() + derecha.valor.toString());
        }
        throw RuntimeError("Operador '+' solo puede aplicarse entre números o entre cadenas", binario.operador.fila, null, 2);
        

      case TiposToken.Menos:
        if((izquierda.tipo == EnumTipo.REAL || izquierda.tipo == EnumTipo.ENTERO) && (derecha.tipo == EnumTipo.REAL || derecha.tipo == EnumTipo.ENTERO)) {
          if(izquierda.tipo == EnumTipo.REAL || derecha.tipo == EnumTipo.REAL)
          {
            return new ExReal(izquierda.valor! - derecha.valor!);
          }else
          {
            return new ExEntero(izquierda.valor! - derecha.valor!);
          }
        }
        throw RuntimeError("Operador '-' solo puede aplicarse entre números", binario.operador.fila, null, 2);

      case TiposToken.Por:
        if((izquierda.tipo == EnumTipo.REAL || izquierda.tipo == EnumTipo.ENTERO) && (derecha.tipo == EnumTipo.REAL || derecha.tipo == EnumTipo.ENTERO)) {
          if(izquierda.tipo == EnumTipo.REAL || derecha.tipo == EnumTipo.REAL)
          {
            return new ExReal(izquierda.valor! * derecha.valor!);
          }else
          {
            return new ExEntero(izquierda.valor! * derecha.valor!);
          }
        }
        throw RuntimeError("Operador '*' solo puede aplicarse entre números", binario.operador.fila, null, 2);

      case TiposToken.Div:
        try
        {
          return new ExReal(izquierda.valor! / derecha.valor!);
        }catch(e)
        {
          throw RuntimeError("Solo puede haber numeros en la division", binario.operador.fila, null, 2);
        } 

      case TiposToken.Mod:
        if(izquierda.tipo == EnumTipo.ENTERO && derecha.tipo == EnumTipo.ENTERO) {
          return new ExEntero(izquierda.valor! % derecha.valor!);
        }
        throw RuntimeError("Operador '%' solo puede aplicarse entre enteros", binario.operador.fila, null, 2);
      

      case TiposToken.DobleIgual:
        return new ExBool(izquierda.valor == derecha.valor);
      
      case TiposToken.Diferente:
        return new ExBool(izquierda.valor != derecha.valor);

      case TiposToken.Mayor:
        ambosNumeros(izquierda.valor,derecha.valor,binario.operador);
        return new ExBool(izquierda.valor! > derecha.valor!);

      case TiposToken.Menor:
        ambosNumeros(izquierda.valor,derecha.valor,binario.operador);
        return new ExBool(izquierda.valor! < derecha.valor!);
      
      case TiposToken.MayorIgual:
        ambosNumeros(izquierda.valor,derecha.valor,binario.operador);
        return new ExBool(izquierda.valor! >= derecha.valor!);

      case TiposToken.MenorIgual:
        ambosNumeros(izquierda.valor,derecha.valor,binario.operador);
        return new ExBool(izquierda.valor! <= derecha.valor!);

      default:
        throw RuntimeError('Operador no soportado', binario.operador.fila, null, 2);
    }
    
  }

  void esEntero(String entrada,Token id)
  {
    try
    {
      int.parse(entrada);
    }catch(e)
    {
      throw RuntimeError('Valor no es un entero', id.fila,null,2);
    }
  }

  void esReal(String entrada,Token id)
  {
    try
    {
      double.parse(entrada);
    }catch(e)
    {
      throw RuntimeError('Valor no es un real', id.fila,null,2);
    }
  }

  void ambosNumeros(Object izquierda,Object derecha,Token operador)
  {
    if(izquierda is! num || derecha is! num)
    {
      throw RuntimeError('Ambos operandos deben ser numéricos', operador.fila,null,2);
    }
  }

  ExValor genValor(Tipo tipo,Expresion? valor,Token id)
  {
    Object? inicial = null;
    if(valor != null)
    {
      ExValor val = evaluar(valor);
      if(val.tipo != tipo.tipo)
      {
        throw RuntimeError('Tipos incompatibles', id.fila, null, 2);
      }
      inicial = val.valor;
    }

    switch(tipo.tipo)
    {
      case EnumTipo.ENTERO : return ExEntero(inicial as int?);
      case EnumTipo.REAL : return ExReal(inicial as double?);
      case EnumTipo.CARACTER : return ExCaracter(inicial as String?);
      case EnumTipo.CADENA : return ExCadena(inicial as String?);
      case EnumTipo.BOOLEANO : return ExBool(inicial as bool?);
      case EnumTipo.ARREGLO : return decArreglo(tipo as Arreglotipo,inicial as List<ExValor>?,id);

      default:
        return ExEntero(5);
    }
  }

  ExArreglo decArreglo(Arreglotipo tipo,List<ExValor>? inicial,Token id)
  {
    ExValor dimension = evaluar(tipo.dimension);
    EnumTipo contenido = tipo.contenido.tipo;
    if(dimension is! ExEntero)
    {
      throw RuntimeError('La dimension debe ser un numero entero', id.fila, null, 2);
    }
    int cantidad = dimension.valor!;
    List<ExValor> valor = [];

    if(inicial != null)
    {
      if(inicial.length != cantidad)
      {
        throw RuntimeError('La dimension de los arreglos no coincide', id.fila, null, 2);
      }
      for(ExValor elemento in inicial)
      {
        if(elemento.tipo != contenido)
        {
          throw RuntimeError('los tipos de los arreglos no coinciden', id.fila, null, 2);
        }
      }
      valor = inicial;
    }else
    {
      valor = List<ExValor>.generate(cantidad, (int index) => genValor(tipo.contenido, null, id));
    }

    return ExArreglo(valor,tipo.contenido,cantidad);
  }
}