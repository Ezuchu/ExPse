import 'LexerBase.dart';
import 'RuntimeError.dart';
import 'TiposToken.dart';

class Lexer extends LexerBase
{
  Lexer(super.codigo);
  

  @override
  void sigToken() {
    inicio = columna;
    switch(actualChar)
    {
      case '+':
        sumarToken(TiposToken.Mas, '+', null);
        continuar();
        break;
      case '-':
        sumarToken(TiposToken.Menos, '-', null);
        continuar();
        break;
      case '*':
        sumarToken(TiposToken.Por, '*', null);
        continuar();
        break;
      case '/':
        sumarToken(TiposToken.Div, '/', null);
        continuar();
        break;
      case '%':
        sumarToken(TiposToken.Mod, '%', null);
        continuar();
        break;

      case '>':
        continuar();
        if(actualChar == '=')
        {
          continuar();
          sumarToken(TiposToken.MayorIgual, '>=', null);
        }else
        {
          sumarToken(TiposToken.Mayor, '>', null);
        }
        break;

      case '<':
        continuar();
        if(actualChar == '=')
        {
          continuar();
          sumarToken(TiposToken.MenorIgual, '<=', null);
        }else
        {
          sumarToken(TiposToken.Menor, '<', null);
        }
        break;

      
      case '=':
        continuar();
        if(actualChar == '=')
        {
          continuar();
          sumarToken(TiposToken.DobleIgual, '==', null);
        }else
        {
          sumarToken(TiposToken.Igual, '=', null);
        }
        break;
      case '!':
        continuar();
        if(actualChar == '=')
        {
          continuar();
          sumarToken(TiposToken.Diferente, '!=', null);
        }else
        {
          sumarToken(TiposToken.Negacion, '!', null);
        }
        break;
      
      case 'Y':
        sumarToken(TiposToken.Y, 'Y', null);
        continuar();
        break;
      case 'O':
        sumarToken(TiposToken.O, 'O', null);
        continuar();
        break;

      case '(':
        sumarToken(TiposToken.PARENT_IZQ, '(', null);
        continuar();
        break;
      case ')':
        sumarToken(TiposToken.PARENT_DER, ')', null);
        continuar();
        break;
      case '{':
        sumarToken(TiposToken.LLAVE_IZQ, '{', null);
        continuar();
        break;
      case '}':
        sumarToken(TiposToken.LLAVE_DER, '}', null);
        continuar();
        break;
      case '[':
        sumarToken(TiposToken.CORCHETE_IZQ, '[', null);
        continuar();
        break;
      case ']':
        sumarToken(TiposToken.CORCHETE_DER, ']', null);
        continuar();
        break;

      
      case ' ':case '\t' :case '\r':
        continuar();
        break;

      case '\n':
        sigFila();
        break;

      case ',':
        sumarToken(TiposToken.COMA, ',', null);
        continuar();
        break;
      case ';':
        sumarToken(TiposToken.PUNTOYCOMA, ';', null);
        continuar();
        break;
      case ':':
        sumarToken(TiposToken.DOSPUNTOS, ':', null);
        continuar();
        break;

      case '\"':
        cadena();
        break;
      

      default:
        if(RegExp(r'[a-zñA-ZÑ_]').hasMatch(actualChar)){
          identificador();
        }
        else if(int.tryParse(actualChar) != null)
        {
          sumarNumero();
        }
        else
        {
          throw RuntimeError('Carácter $actualChar no reconocido', fila, columna, 0);
        }
    }
  }

  void caracter()
  {
    String caracter = '';
    continuar();
    if(actualChar == '\'')
    {
      throw RuntimeError('Caracter vacio',fila,columna,0);
    }
    caracter += actualChar;
    continuar();
    if(actualChar != '\'')
    {
      throw RuntimeError('Caracter no cerrado',fila,columna,0);
    }
    continuar();
    sumarToken(TiposToken.CARACTER, caracter, caracter);

  }


  void cadena()
  {
    String cadena = '';
    continuar();
    while(actualChar != '\"')
    {
      if(actualChar == '\n')
      {
       throw RuntimeError('Cadena no cerrada',fila,columna,0);
      }
      cadena += actualChar;
      continuar();
    }
    continuar();
    sumarToken(TiposToken.CADENA, cadena,cadena);
  }

  void identificador()
  {
    String lexema = '';
    while(RegExp(r'[a-zñA-ZÑ_0-9]').hasMatch(actualChar))
    {
      lexema += actualChar;
      continuar();
    }
    if(mapaTipos.containsKey(lexema.toLowerCase()))
    {
      
      sumarToken(mapaTipos[lexema.toLowerCase()]!, lexema, null);
    }else
    {
      sumarToken(TiposToken.IDENTIFICADOR, lexema, lexema);
    }
  }

  void sumarNumero()
  {
    String numero = '';
    while(int.tryParse(actualChar) != null)
    {
      numero += actualChar;
      continuar();
    }
    if(actualChar == '.')
    {
      numero += actualChar;
      continuar();
      while(int.tryParse(actualChar) != null)
      {
        numero += actualChar;
        continuar();
      }
      sumarToken(TiposToken.REAL, numero, double.parse(numero));
      
    }else
    {
      sumarToken(TiposToken.ENTERO, numero, int.parse(numero));
    }
  }
}