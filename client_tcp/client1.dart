// Dart client
//Pasea la recepcion de datos buscando EOL

import 'dart:io';
import 'terminal_service.dart';

Future<void> main() async {
  final socket = await Socket.connect("192.168.1.9", 2020);
  printRed('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

   // Procesamos los datos del socket
   processStream(socket);

   // Leer entrada del usuario SIN bloquear
  Future.microtask(()  {
    stdin.asBroadcastStream().listen((List<int> data) {
      String dato = String.fromCharCodes(data).trim();
      printGreen(dato.toString());
      socket.write(dato+"\r\n");
    });
  });

}


//Parseamos y extraemos EOL

Future<void> processStream(Stream<List<int>> stream) async {
  // Variable para almacenar los caracteres mientras se espera \r\n
  
  StringBuffer buffer = StringBuffer();

  // Iteramos sobre los fragmentos de datos del stream
  await for (var chunk in stream) {
    // Convertimos el fragmento de datos a String (asumiendo que está en UTF-8)
    var chunkString = String.fromCharCodes(chunk);
    
    // Agregamos los caracteres al buffer
    buffer.write(chunkString);

    // Buscamos si ya hemos recibido una línea completa (terminada con \r\n)
    while (buffer.toString().contains('\r\n')) {
      // Separamos la primera línea completa
      var line = _extractLine(buffer);
      
      // Procesamos la línea (en este caso solo la imprimimos)
      printRed('Línea recibida: $line');

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
  
  buffer.clear();
  buffer.write(resto);
  return line;
}


//: 0x0D 0x0A : \r\n  :  (Car Return - CR)  (Line Feed -LF)
//(EOL =  \r\n) end of line  (windows)
//\n  used in Linux and mac