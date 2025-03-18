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

class Interprete implements VisitorExpresion,VisitorSentencia
{

  Entorno global = new Entorno();

  Interprete();

  void interpretar(List<Sentencia> sentencias) {
    for(Sentencia sentencia in sentencias) {
      ejecutar(sentencia);
    }
  }

  void ejecutar(Sentencia sentencia) {
    sentencia.aceptar(this);
  }

  Object evaluar(Expresion expresion) {
    return expresion.aceptar(this);
  }

  @override
  VisitaPrincipal(Principal principal) {
    for(Sentencia sentencia in principal.sentencias) {
      ejecutar(sentencia);
    }
  }

  @override
  VisitaDecVariable(DecVariable decVariable) {
    print(decVariable.tipo.tipo);
    ExValor valor = genValor(decVariable.tipo);
    global.definir(decVariable.identificador.lexema, valor);

    print(global.valores[decVariable.identificador.lexema]!);
  }

  @override
  VisitaEscribir(Escribir escribir) {
    Object valor = evaluar(escribir.expresion);
    print(valor);
  }

  @override  
  VisitaLiteral(Literal literal) {
    return literal.valor;
  }

  @override
  VisitaGrupo(Grupo grupo) {
    return evaluar(grupo.expresion);
  }

  @override
  VisitaUnario(Unario unario) {
    Object valor = evaluar(unario.operando);

    switch (unario.operador.tipo) {
      case TiposToken.Menos:
        if(valor is num) {
          return -(valor as num);
        }
        throw RuntimeError('Ambos operandos deben ser numéricos', unario.operador.fila, null, 2);
        
      case TiposToken.Negacion:
        return !(valor as bool);
      default:
        return null;
    }
  }

  @override
  VisitaBinario(Binario binario) {
    Object izquierda = evaluar(binario.izq);
    Object derecha = evaluar(binario.der);

    switch(binario.operador.tipo)
    {
      case TiposToken.Mas:
        if(izquierda is num && derecha is num) {
          return (izquierda) + (derecha);
        }
        if(izquierda is String || derecha is String) {
          return izquierda.toString() + derecha.toString();
        }
        throw RuntimeError("Operador '+' solo puede aplicarse entre números o entre cadenas", binario.operador.fila, null, 2);
        

      case TiposToken.Menos:
        if(izquierda is num && derecha is num) {
          return (izquierda ) - (derecha);
        }
        throw RuntimeError("Operador '-' solo puede aplicarse entre números", binario.operador.fila, null, 2);
        

      default:
        return null;
    }
    
  }

  ExValor genValor(Tipo tipo)
  {
    switch(tipo.tipo)
    {
      case EnumTipo.ENTERO : return ExEntero(5);
      case EnumTipo.REAL : return ExReal(7.8);
      case EnumTipo.CARACTER : return ExCaracter('a');
      case EnumTipo.CADENA : return ExCadena('xde');
      case EnumTipo.BOOLEANO : return ExBool(true);

      default:
        return ExEntero(5);
    }
  }
}