class RuntimeError 
{
  final String message;
  final int line;
  final int? column;
  final int type;

  RuntimeError(this.message, this.line,this.column,this.type);

  @override
  String toString() 
  {
    switch(type)
    {
      case 0:
        return 'Error Léxico: $line:$column: $message';
      case 1:
        return 'Error Sintáctico: $line:$column: $message';
      default:
        return 'Error: $line: $message';
    }
  }
}