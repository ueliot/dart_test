
// Dart client
//Pasea la recepcion de datos buscando EOL
//Y funcion de reconexion automatica   Tiene algun problema que aveces no parsea y no se devuelve nada departe de receptor
//para evaluar
//para capturar los errores en Futuros es mejor usar
//Completer https://medium.com/@jessicajimantoro/completer-in-dart-flutter-e15f5739e96d
//lo recomienda dart cuando estamos usando futuros, microtask y otros
// Curso de Dart:  https://www.youtube.com/playlist?list=PLl_hIu4u7P65OQk_zAxogUjP4YJLQQT1W 

import 'dart:async';
import 'dart:io';
import 'terminal_service.dart';


void main() async {


  String host= "192.168.1.9";
  int port =2020;
 

  connect(host,port).catchError((e){
    
    print("socket: $e :Reconeccting.......");
    reconnect(host, port);
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



 // Función para reconectar automáticamente
  void reconnect(String host, int port) {
    print('Intentando reconectar...');
    Future.delayed(Duration(seconds: 5), () {
      connect(host,port);
    });
  }


  Future<void> connect(String host, int port) async{
    Socket? socket;
    final Completer<String> completer = Completer<String>();


      print('Intentando conectar...');
      socket = await Socket.connect(host, port);
      printRed('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
          // Procesamos los datos del socket
      processStream(socket);

        // Leer entrada del usuario SIN bloquear
      Future.microtask(()  {
        

        stdin.asBroadcastStream().listen((List<int> data) {
          String dato = String.fromCharCodes(data).trim();
          printGreen(dato.toString());
          
          try {
              
            socket!.write(dato+"\r\n");
            //completer.complete('Complete!!');
             
          } on SocketException catch (e){
            print("socket error: $e : recconecting......");
            reconnect(host, port);
            completer.completeError(e);
          }
         
        });
      });
  
 }
 


