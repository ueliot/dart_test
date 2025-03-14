//Cliente no bloqueante 
//Sin parsear /r/n


import 'terminal_service.dart';
import 'dart:io';

void main() async {
  Socket socket = await Socket.connect('192.168.1.9', 2020);
  print('Conectado al servidor');


  // Escuchar mensajes del servidor en un stream separado
  //En este caso nos envian asccis por esto usamos String.fromCharcodes
  //si nos enviarán otra cosa digital o utf hay que convertir
  socket.listen(
    (List<int> data) {
      printRed('RX: ${String.fromCharCodes(data).trim()}');
    },
    onDone: () {
      print('Desconectado del servidor');
      socket.destroy();
      exit(0);
    },
  );
  


  // Leer entrada del usuario SIN bloquear
  Future.microtask(() {
    stdin.asBroadcastStream().listen((List<int> data) {
      var dato = String.fromCharCodes(data).trim(); 
      socket.write(dato+"\r\n");
      printGreen("TX: $dato" );
      //socket.add(data); // Enviar datos al servidor
    });
  });

  print('Puedes escribir mensajes...');
}



