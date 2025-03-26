import '../AST/Tipos.dart';
import '../Token.dart';

abstract class ExValor 
{
  late EnumTipo tipo;
  bool constante = false;

  ExValor(this.tipo);

  get valor => null;

  asignar(ExValor valor, Token id);

  
  
}