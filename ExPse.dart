import 'AST/Expresion.dart';
import 'Interprete.dart';
import 'Lexer.dart';
import 'Parser.dart';
import 'Token.dart';

void main()
{
  try
  {
    Lexer lexer = new Lexer('Real casa;\nInicio\nEscribir(casa);\nEntero casa;\nEscribir(casa);\nFin');
    Parser parser = new Parser(lexer.escanearTokens());
    parser.analisis();
    Interprete interprete = new Interprete();
    interprete.interpretar(parser.sentencias);
  }catch(e)
  {
    print(e);
  }
}