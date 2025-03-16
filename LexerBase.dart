import 'Token.dart';
import 'TiposToken.dart';

abstract class LexerBase 
{
  List<Token> tokens = [];
  late String codigo;
  int fila = 1;
  int columna = 1;
  int inicio = 1;
  int indice = 0;
  String actualChar = '';

  LexerBase(String codigo)
  {
    this.codigo = codigo;
    this.actualChar = codigo[0];
  }

  List<Token> escanearTokens()
  {
    while(!llegoFinal())
    {
      sigToken();
    }
    sumarToken(TiposToken.EOF, 'EOF', null);
    return tokens;
  }

  

  void continuar()
  {
    if(!llegoFinal())
    {
      this.indice++;
      this.columna++;
      if(indice>=codigo.length)
      {
        actualChar = '';
      }
      else
      {
        actualChar = codigo[indice];
      }
    }
  }

  void sigFila()
  {
    while(actualChar=='\n')
    {
      columna = 0;
      fila++;
      continuar();
    }
  }


  void sumarToken(TiposToken tipo, String lexema, Object? literal)
  {
    tokens.add(new Token(tipo, fila, inicio, lexema, literal));
  }

  void sigToken()
  {
    indice++;
  }

  bool llegoFinal()
  {
    return(indice >= codigo.length);
  }
}