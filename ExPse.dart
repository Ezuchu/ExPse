import 'AST/Expresion.dart';
import 'AST/Interprete.dart';
import 'Lexer.dart';
import 'Parser.dart';
import 'Token.dart';

void main()
{
  try
  {
    Lexer lexer = new Lexer('Inicio\nEscribir("a");\nFin');
    Parser parser = new Parser(lexer.escanearTokens());
    parser.analisis();
    Interprete interprete = new Interprete();
    interprete.interpretar(parser.sentencias[0]);
  }catch(e)
  {
    print(e);
  }
}