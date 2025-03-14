
import 'dart:io';


void main() async {
  final serverAddress = '192.168.1.9'; // Cambia esto por la IP de tu servidor
  final serverPort = 2020; // Cambia esto por el puerto del servidor

  // Intentar conectarse al servidor
  Socket? socket;
  bool success;

  try {
    socket = await Socket.connect(serverAddress, serverPort, timeout: Duration(seconds: 10));
    print('Conexión exitosa al servidor $serverAddress:$serverPort');
    success=true;
    

    // Gestionamos los datos recibidos desde el servidor
    socket.listen(
      (data) {
        // Parseamos los datos recibidos buscando EOL
        //String message = utf8.decode(data);
        String message = String.fromCharCodes(data);

        List<String> lines = message.split('\r\n'); // Suponiendo que EOL es '\n'
        // for (var line in lines) {
        //   if (line.isNotEmpty) {
        //     print('Servidor: $line');
        //   }
        // }
        print(lines[0]);
      },
      onError: (error) {
        print('Error en la conexión: $error');
        success = false;
        socket?.close();
      },
      onDone: () {
        print('Conexión cerrada por el servidor.');
        success = false;
        socket?.close();
        exit(-1);
      },
      cancelOnError: true,
    );

    // Enviar mensajes al servidor desde la consola

    stdin.listen((input)  {
      
      // String message = utf8.decode(input).trim();
      String message = String.fromCharCodes(input);
      if (message.toLowerCase() == 'exit\r\n') {
        print('Cerrando conexión...');
        //socket!.flush();
        socket!.close;
        exit(-1);
      }
      if (message.toLowerCase() == 'clear\r\n') {
        stdout.write('\x1B[2J\x1B[0;0H');  //clear terminal
      }

       if (!success){
          print('Socket closed');
          return; //if socket is close
       } 

       //If socket is close and write inside
       //using stdin, broken program and result
       //Unhandled exception:
        // Bad state: StreamSink is closed
        // #0      _StreamSinkImpl.add (dart:io/io_sink.dart:152:7)
        // #1      _IOSinkImpl.write (dart:io/io_sink.dart:287:5)
        //...........
        

      if (message.isEmpty) return; // Ignorar líneas vacías
      
        socket!.write(message + '\r\n'); // Enviamos el mensaje al servidor con EOL

      // Si el mensaje es "exit", cerramos el socket
     
    },
    ); //End Stdin
  } catch (e) {
  
    print('No se pudo conectar al servidor: $e');
  }

}


//Interesante forma de usar stdin
//https://stackoverflow.com/questions/15186821/how-can-i-do-stdin-close-with-the-new-streams-api-in-dart




