import 'AST/Expresion.dart';
import 'Interprete.dart';
import 'Lexer.dart';
import 'Parser.dart';
import 'Token.dart';

void main()
{
  try
  {
    Lexer lexer = new Lexer('Inicio\nentero casa;\ncasa = 8;\nEscribir(casa + 7);\nFin');
    Parser parser = new Parser(lexer.escanearTokens());
    parser.analisis();
    Interprete interprete = new Interprete();
    interprete.interpretar(parser.sentencias);
  }catch(e)
  {
    print(e);
  }
}