import 'AST/Expresion.dart';
import 'RuntimeError.dart';
import 'AST/Sentencia.dart';
import 'TiposToken.dart';

class Interprete implements VisitorExpresion,VisitorSentencia
{

  Interprete();

  void interpretar(Sentencia sentencia) {
    sentencia.aceptar(this);
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
}