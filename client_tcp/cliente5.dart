
import 'dart:io';
import 'dart:convert';
import 'dart:async';


class ConexionSocket {
  final String host;
  final int puerto;
  late Socket socket;
  int maxReintentos;
  int intentos = 0;
  Duration timeoutDuration;

  // Constructor que acepta el host, puerto, número máximo de reintentos y el timeout
  ConexionSocket(this.host, this.puerto, {this.maxReintentos = 3, this.timeoutDuration = const Duration(seconds: 5)});

  // Conectar al servidor con manejo de timeout y reconexión
  Future<void> conectar() async {
    while (intentos < maxReintentos) {
      try {
        socket = await Socket.connect(host, puerto).timeout(timeoutDuration);
        print('Conectado a $host:$puerto');
        
        // Escuchar los datos recibidos
        socket.listen((List<int> data) {
          String mensaje = utf8.decode(data);
          print('Mensaje recibido: $mensaje');
        });

        // Si la conexión es exitosa, salimos del bucle
        break;
      } on TimeoutException {
        print('Error: Timeout al conectar. Reintentando...');
      } on SocketException {
        print('Error al conectar. Intentando reconectar...');
      }

      intentos++;
      if (intentos >= maxReintentos) {
        print('Se alcanzó el máximo de reintentos. No se pudo conectar.');
        break;
      }

      // Esperar antes de intentar reconectar
      await Future.delayed(Duration(seconds: 2));
    }
  }

  // Enviar datos al servidor
  void enviarDatos(String mensaje) {
    if (socket != null) {
      socket.write(mensaje);
      print('Mensaje enviado: $mensaje');
    } else {
      print('No hay conexión activa.');
    }
  }

  // Cerrar la conexión
  void cerrar() {
    if (socket != null) {
      socket.close();
      print('Conexión cerrada.');
    } else {
      print('No hay conexión activa.');
    }
  }

  // Método para forzar la reconexión
  Future<void> reconectar() async {
    print('Intentando reconectar...');
    intentos = 0;
    await conectar();
  }
}



void main() async {
  var conexion = ConexionSocket('localhost', 8080, maxReintentos: 5, timeoutDuration: Duration(seconds: 3));

  // Intentar conectar al servidor
  await conexion.conectar();

  // Enviar un mensaje al servidor si la conexión es exitosa
  conexion.enviarDatos('¡Hola, servidor!');

  // Esperar y luego intentar reconectar (simulando que la conexión se pierde)
  Future.delayed(Duration(seconds: 10), () async {
    print('Intentando reconectar después de 10 segundos...');
    await conexion.reconectar();
    conexion.enviarDatos('¡Reconexión exitosa!');
    conexion.cerrar();
  });
}