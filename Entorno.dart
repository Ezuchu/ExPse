import 'dart:collection';

import 'ExValor/ExValor.dart';
import 'RuntimeError.dart';
import 'Token.dart';

class Entorno 
{
  Map<String,ExValor> valores = new HashMap();

  Entorno? anterior;

  Entorno()
  {
    this.anterior = null;
  }

  Entorno.local(Entorno anterior)
  {
    this.anterior = anterior;
  }

  definir(String id, ExValor valor)
  {
    valores[id] = valor;
  }

  ExValor obtener(Token id)
  {
    ExValor? valor = valores[id.lexema];
    if(valor == null)
    {
      if(this.anterior != null)
      {
        
        return this.anterior!.obtener(id);
      }else
      {
        
        throw RuntimeError('Variable ${id.lexema} no definida',id.fila,null,2);
      }
    }
    return valor;
  }

  void asignar(Token id,ExValor valor)
  {
    if(valores.containsKey(id.lexema))
    {
      valores[id.lexema] = valor;
      return;
    }

    if(anterior != null)
    {
      
      anterior!.asignar(id,valor);
      return;
    }

  }

  void existe(Token id)
  {
    if(!valores.containsKey(id.lexema))
    {
      throw RuntimeError('Variable no definida',id.fila,null,2);
    }
  }
}