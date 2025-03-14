
import 'dart:io';
import 'dart:async';
import 'terminal_service.dart';


class ConexionSocket {
  final String host;
  final int puerto;
  late Socket socket;
  late StreamSubscription reader;
  bool success;
  int maxReintentos;
  int intentos = 0;
  Duration timeoutDuration;

  
  ConexionSocket(this.host, this.puerto, {this.maxReintentos = 3, this.timeoutDuration = const Duration(seconds: 5), this.success=false});

  Future<void> conectar() async {
    while ((intentos < maxReintentos)) {
      try {
        
        socket = await Socket.connect(host, puerto);
        printRed('Conectado a $host:$puerto');
        success=true;
        processStream(socket);
        break;

      } on TimeoutException {
        print('Error: Timeout al conectar. Reintentando...');
      } on SocketException {
        print('Error al conectar. Intentando reconectar...');
      }

      intentos++;
      printGreen('nº intentos: $intentos');
      if (intentos >= maxReintentos) {
        print('Se alcanzó el máximo de reintentos. No se pudo conectar.');
        break;
      }

      await Future.delayed(Duration(seconds: 2));
      printGreen('esperando dentro de intentos $intentos');
    }
  }

  // Enviar datos al servidor
  void enviarDatos(String mensaje) {
    if (success) {
      socket.write(mensaje);
      printGreen('TX: ${mensaje.trim()}'); 
    } else {
      print('No hay conexión activa.');
    }
  }

  // Cerrar la conexión
  void cerrar() {
    if (success) {
      socket.close();
      print('Conexión cerrada.');
    } else {
      print('No hay conexión activa.');
    }
  }

  // Método para forzar la reconexión
  Future<void> reconectar() async {
    print('Intentando reconectar...$intentos veces');
    intentos = 0;
    await conectar();
  }


  Future<void> processStream(Stream<List<int>> stream) async {
    StringBuffer buffer = StringBuffer();
    await for (var chunk in stream) {
      var chunkString = String.fromCharCodes(chunk);
      buffer.write(chunkString);
      while (buffer.toString().contains('\r\n')) {
        var line = _extractLine(buffer);
        printRed('RX: $line');
      } 
    } 
  }

  String _extractLine(StringBuffer buffer) {
    int index = buffer.toString().indexOf('\r\n');
    String line = buffer.toString().substring(0, index);
    String resto=buffer.toString().substring(index +2);
    buffer.clear();
    buffer.write(resto);
    return line;
  }
}


void main() async {
  var conexion = ConexionSocket('192.168.1.9', 2020);
  await conexion.conectar();
      Future.microtask(()  {
          stdin.asBroadcastStream().listen((List<int> data) {
          String message = String.fromCharCodes(data).trim();
           if (message.toLowerCase() == 'clear') {
            stdout.write('\x1B[2J\x1B[0;0H');  //clear terminal
            return;
            }
          try { 
            conexion.enviarDatos(message + '\r\n'); 
          } on SocketException catch (e){
            print("socket error: $e : recconecting......");
          }
        });
      });


  if(conexion.success) return;
  Future.delayed(Duration(seconds: 10), () async {
    print('Intentando reconectar después de 10 segundos...');
    await conexion.reconectar();
    exit(-1);
  });
}