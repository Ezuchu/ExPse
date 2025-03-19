import 'AST/Expresion.dart';
import 'AST/Tipos.dart';
import 'Entorno.dart';
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
  VisitaAsignacion(Asignacion asignacion) {
    Token identificador = asignacion.identificador;

    ExValor inicial = global.obtener(identificador);
    if(inicial.constante)
    {
      throw RuntimeError('No se puede modificar una constante', identificador.fila,null,2);
    }

    ExValor valor = evaluar(asignacion.valor);
    valor.constante = false;

    if(inicial.tipo != valor.tipo) {
      throw RuntimeError('Tipos incompatibles', identificador.fila, null, 2);
    }
    
    this.entorno.valores[identificador.lexema] = valor;
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
  ExValor VisitaGrupo(Grupo grupo) {
    return evaluar(grupo.expresion);
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
        

      default:
        return null;
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

      default:
        return ExEntero(5);
    }
  }
}