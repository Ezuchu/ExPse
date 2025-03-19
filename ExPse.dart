import 'dart:io';
import 'AST/Expresion.dart';
import 'Interprete.dart';
import 'Lexer.dart';
import 'Parser.dart';
import 'Token.dart';

void main()
{
  try
  {
    String codigo = File("Ejemplo.exp").readAsStringSync();

    Lexer lexer = new Lexer(codigo);
    Parser parser = new Parser(lexer.escanearTokens());
    parser.analisis();
    Interprete interprete = new Interprete();
    interprete.interpretar(parser.sentencias);
  }catch(e)
  {
    print(e);
  }
}