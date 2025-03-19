import '../AST/Tipos.dart';

abstract class ExValor 
{
  late EnumTipo tipo;
  bool constante = false;

  ExValor(this.tipo);

  get valor => null;

  
}