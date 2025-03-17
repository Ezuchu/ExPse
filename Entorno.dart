import 'dart:collection';

import 'ExValor/ExValor.dart';
import 'Token.dart';

class Entorno 
{
  Map<String,ExValor> valores = new HashMap();

  Entorno();

  definir(String id, ExValor valor)
  {
    valores[id] = valor;
  }

  ExValor obtener(Token id)
  {
    ExValor? valor = valores[id.lexema];
    if(valor == null)
    {
      throw Exception('Variable no definida');
    }
    return valor;
  }
}