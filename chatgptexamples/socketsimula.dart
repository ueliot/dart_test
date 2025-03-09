import 'dart:async';
import 'dart:convert';

void main() async {
  // Simulando un stream de datos, como los que podrías recibir de un socket.
  var socketStream = Stream.fromIterable([
    utf8.encode("Hello"),
    utf8.encode("tu"),
    utf8.encode("World\r\nFoo\r"),
    utf8.encode("\n"),
    utf8.encode("Noo"),
    utf8.encode("Bar\r"),
    utf8.encode("\n")
  ]);

  // Procesamos los datos del socket
  await processStream(socketStream);
}


Future<void> processStream(Stream<List<int>> stream) async {
  // Variable para almacenar los caracteres mientras se espera \r\n
  
  StringBuffer buffer = StringBuffer();

  // Iteramos sobre los fragmentos de datos del stream
  await for (var chunk in stream) {
    // Convertimos el fragmento de datos a String (asumiendo que está en UTF-8)
    var chunkString = utf8.decode(chunk);
   
    // Agregamos los caracteres al buffer
    buffer.write(chunkString);

    // Buscamos si ya hemos recibido una línea completa (terminada con \r\n)
    while (buffer.toString().contains('\r\n')) {
      // Separamos la primera línea completa
      var line = _extractLine(buffer);
      
      // Procesamos la línea (en este caso solo la imprimimos)
      print('Línea recibida: $line');

      // Continuamos procesando el siguiente fragmento de datos
    } 
  }
}

// Función para extraer la línea completa del buffer hasta \r\n
String _extractLine(StringBuffer buffer) {
  // Buscamos el índice de \r\n
  int index = buffer.toString().indexOf('\r\n');
 
  // Extraemos la línea hasta \r\n
  String line = buffer.toString().substring(0, index);
   
  // Eliminamos esa línea del buffer
  String resto=buffer.toString().substring(index +2);
  //print(resto);
  buffer.clear();
  buffer.write(resto);
  return line;
}
