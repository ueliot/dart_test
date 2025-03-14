¡Claro! A continuación te presento un programa cliente TCP/IP en Dart que gestiona los errores de conexión, el cierre de sockets, el timeout y también parsea la data recibida buscando los **End Of Line (EOL)** para imprimir cada línea recibida por separado. Además, permite que el usuario ingrese texto por consola para enviarlo al servidor, y terminará la secuencia con un **Enter**.

Este es el código que puedes usar como base:

### Código del cliente TCP/IP en Dart:

```dart
import 'dart:io';
import 'dart:convert';

void main() async {
  final serverAddress = '192.168.1.9'; // Cambia esto por la IP de tu servidor
  final serverPort = 51149; // Cambia esto por el puerto del servidor

  // Intentar conectarse al servidor
  Socket? socket;

  try {
    socket = await Socket.connect(serverAddress, serverPort, timeout: Duration(seconds: 10));
    print('Conexión exitosa al servidor $serverAddress:$serverPort');

    // Gestionamos los datos recibidos desde el servidor
    socket.listen(
      (data) {
        // Parseamos los datos recibidos buscando EOL
        String message = utf8.decode(data);
        List<String> lines = message.split('\n'); // Suponiendo que EOL es '\n'
        for (var line in lines) {
          if (line.isNotEmpty) {
            print('Servidor: $line');
          }
        }
      },
      onError: (error) {
        print('Error en la conexión: $error');
        socket?.close();
      },
      onDone: () {
        print('Conexión cerrada por el servidor.');
        socket?.close();
      },
      cancelOnError: true,
    );

    // Enviar mensajes al servidor desde la consola
    stdin.listen((input) {
      String message = utf8.decode(input).trim();
      if (message.isEmpty) return; // Ignorar líneas vacías
      socket.write(message + '\n'); // Enviamos el mensaje al servidor con EOL

      // Si el mensaje es "exit", cerramos el socket
      if (message.toLowerCase() == 'exit') {
        print('Cerrando conexión...');
        socket.close();
      }
    });
  } catch (e) {
    print('No se pudo conectar al servidor: $e');
  }
}
```

### Explicación del código:

1. **Conexión al servidor**:
   - Se intenta conectar al servidor especificado (en este caso `192.168.1.9` y puerto `51149`) usando `Socket.connect`.
   - Si la conexión no puede establecerse dentro de 10 segundos (timeout), se lanza una excepción que será capturada.

2. **Manejo de datos recibidos**:
   - La función `socket.listen` se usa para escuchar los datos que llegan desde el servidor.
   - Cuando llegan datos, se convierten en una cadena utilizando `utf8.decode` y luego se separan en líneas usando `split('\n')` (suponiendo que cada línea está separada por el carácter EOL `\n`).
   - Se imprimen todas las líneas que contienen texto, ignorando las líneas vacías.

3. **Manejo de errores**:
   - Si hay un error en la conexión o el socket, el programa imprime el error y cierra el socket.
   - Cuando el servidor cierra la conexión, también se imprime un mensaje y se cierra el socket.

4. **Entrada del usuario**:
   - El programa escucha la entrada del usuario desde la consola con `stdin.listen`.
   - Cada vez que el usuario escribe algo y presiona Enter, el mensaje se envía al servidor con un `\n` al final (simulando EOL).
   - Si el usuario escribe "exit", el cliente cerrará la conexión y terminará la ejecución.

### ¿Cómo ejecutar el programa?

1. **Configura el servidor**: Asegúrate de que el servidor al que te estás conectando esté activo y esperando conexiones en la IP y puerto que has especificado (`192.168.1.9` y `51149` en este caso).

2. **Ejecuta el cliente**: Copia el código en un archivo Dart (por ejemplo, `client.dart`), y luego ejecútalo desde la terminal con:
   ```bash
   dart client.dart
   ```

3. **Interacción con el cliente**:
   - El programa se conectará al servidor.
   - Puedes escribir mensajes en la terminal, los cuales se enviarán al servidor.
   - Cada vez que el servidor envíe datos, el cliente los imprimirá en la terminal, separando las líneas por el carácter EOL.
   - Si escribes "exit" y presionas Enter, el cliente cerrará la conexión.

### Notas adicionales:

- **Timeout**: El tiempo de espera (`timeout: Duration(seconds: 10)`) puede ajustarse según sea necesario. Esto significa que el cliente esperará hasta 10 segundos para conectarse antes de dar un error.
- **Manejo de caracteres especiales**: El código asume que las líneas recibidas están separadas por `\n` (End of Line). Si el servidor utiliza otro carácter o secuencia (como `\r\n`), simplemente ajusta el delimitador en `split()`.

Este programa debe cubrir las necesidades básicas que mencionaste: manejo de errores, cierre de sockets, timeout y parsing de la data recibida. ¡Espero que te sea útil!
