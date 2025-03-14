
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

  // Constructor que acepta el host, puerto, número máximo de reintentos y el timeout
  ConexionSocket(this.host, this.puerto, {this.maxReintentos = 3, this.timeoutDuration = const Duration(seconds: 5), this.success=false});

  // Conectar al servidor con manejo de timeout y reconexión
  Future<void> conectar() async {
    while ((intentos < maxReintentos)) {
      try {
        // socket = await Socket.connect(host, puerto).timeout(timeoutDuration);
        socket = await Socket.connect(host, puerto);
        printRed('Conectado a $host:$puerto');
        success=true;

        processStream(socket);
        
     /*   
        // Escuchar los datos recibidos
        socket.listen((List<int> data) {
          String mensaje = String.fromCharCodes(data);
          //TODO:Parsing EOL
          printRed('RX: $mensaje');

        },
        onError: (e){
          print(e);
          success=false;
          cerrar();
          exit(-1);
        });

    */

        // Si la conexión es exitosa, salimos del bucle
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
        //exit(-1);
        break;
      }

      // Esperar antes de intentar reconectar
      await Future.delayed(Duration(seconds: 2));
      printGreen('esperando dentro de intentos $intentos');

    }
    
  }

  // Enviar datos al servidor
  void enviarDatos(String mensaje) {
    if (success) {
      socket.write(mensaje); //Aqui estoy enviado EOL \r\n ? aqui hay algo que al odac no le gusta
      printGreen('TX: ${mensaje.trim()}');  //aqui le quito el EOL
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
      printRed('RX: $line');

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

}


void main() async {
  var conexion = ConexionSocket('192.168.1.9', 2020);
   

  // Intentar conectar al servidor
  await conexion.conectar();

    // Enviar mensajes al servidor desde la consola

      // Leer entrada del usuario SIN bloquear
      Future.microtask(()  {
        

          stdin.asBroadcastStream().listen((List<int> data) {
          String message = String.fromCharCodes(data).trim();

           if (message.toLowerCase() == 'clear') {
            stdout.write('\x1B[2J\x1B[0;0H');  //clear terminal
            return;
            }
          
          try {
              
          conexion.enviarDatos(message + '\r\n'); // Enviamos el mensaje al servidor con EOL, para el odac \n

             
          } on SocketException catch (e){
            print("socket error: $e : recconecting......");
          }
        });
      });






    // stdin.listen((input)  {
    //     String message = String.fromCharCodes(input);
    //     if (message.toLowerCase() == 'exit\r\n') {
    //       print('Cerrando conexión...');
    //       conexion.cerrar();
    //       exit(-1);
    //     }
    //     if (message.toLowerCase() == 'clear\r\n') {
    //       stdout.write('\x1B[2J\x1B[0;0H');  //clear terminal
    //       return;
    //     }

    //     if (!conexion.success){
    //         print('Socket closed');
    //         return; //if socket is close
    //     } 
    
    //     if (message.isEmpty) return; // Ignorar líneas vacías
    //       conexion.enviarDatos(message + '\r\n'); // Enviamos el mensaje al servidor con EOL, para el odac \n
    //   },
    // ); //End Stdin

  // Esperar y luego intentar reconectar (simulando que la conexión se pierde)
  if(conexion.success) return;
  Future.delayed(Duration(seconds: 10), () async {
    print('Intentando reconectar después de 10 segundos...');
    await conexion.reconectar();
    exit(-1);
    //conexion.cerrar();
  });
}