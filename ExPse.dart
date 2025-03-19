import 'AST/Expresion.dart';
import 'Interprete.dart';
import 'Lexer.dart';
import 'Parser.dart';
import 'Token.dart';

void main()
{
  try
  {
    Lexer lexer = new Lexer('constante casa = 19.8;\nInicio\nReal casa2 = casa+1\nEscribir(casa2);\nFin');
    Parser parser = new Parser(lexer.escanearTokens());
    parser.analisis();
    Interprete interprete = new Interprete();
    interprete.interpretar(parser.sentencias);
  }catch(e)
  {
    print(e);
  }
}