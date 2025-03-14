En Dart, un **`Future`** se ejecuta solo una vez. Un `Future` es un objeto que representa el resultado de una operación asincrónica que puede completarse en el futuro, y su propósito es **representar un valor que aún no está disponible** pero que lo estará en algún momento.

### Explicación de `Future`:

- Un `Future` puede completarse en uno de los siguientes tres estados:
  1. **No completado**: El `Future` aún no ha recibido un valor o no ha fallado.
  2. **Completado con éxito**: El `Future` se resuelve y proporciona un valor.
  3. **Completado con error**: El `Future` falla y lanza una excepción.

Una vez que un `Future` se completa, ya no puede volver a ejecutarse. Es decir, un `Future` **no es reutilizable** ni ejecutable más de una vez.

### Ejemplo básico de un `Future`:

```dart
Future<void> ejemplo() async {
  print('Operación asincrónica en progreso...');
  await Future.delayed(Duration(seconds: 2));
  print('Operación completada');
}

void main() {
  var f = ejemplo();  // El Future se ejecuta una vez
  f.then((_) => print('Finalizado 1'));

  // Intentamos ejecutar el Future nuevamente
  // Pero como el Future ya está completo, no hace nada:
  f.then((_) => print('Finalizado 2')); // No se ejecutará
}
```

En el código anterior:
- El `Future` se ejecuta cuando se llama a la función `ejemplo()`, y después de dos segundos imprime "Operación completada".
- Usamos `.then()` para escuchar cuando se complete el `Future` y mostrar el mensaje "Finalizado 1".
- Intentamos usar `.then()` nuevamente en el mismo `Future`, pero no se ejecutará. Un `Future` solo puede completar su operación una vez, y una vez completado, no se vuelve a ejecutar.

### ¿Qué hacer si necesitas ejecutar una operación varias veces?

Si deseas realizar una operación repetidamente o varias veces, necesitas crear un nuevo `Future` cada vez que lo desees. Por ejemplo:

#### 1. **Crear un nuevo `Future` cada vez**:

```dart
Future<void> ejemplo() async {
  print('Operación asincrónica en progreso...');
  await Future.delayed(Duration(seconds: 2));
  print('Operación completada');
}

void main() {
  // Ejecutamos el futuro varias veces
  ejemplo();  // Ejecución 1
  ejemplo();  // Ejecución 2
  ejemplo();  // Ejecución 3
}
```

#### 2. **Usar un `Stream` si necesitas múltiples valores a lo largo del tiempo**:
Si deseas una secuencia de resultados (y no un solo valor), puedes utilizar un **`Stream`**, que sí puede emitir valores múltiples a lo largo del tiempo.

```dart
Stream<int> contador() async* {
  for (var i = 0; i < 5; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;  // Emitir el valor
  }
}

void main() async {
  await for (var valor in contador()) {
    print('Valor recibido: $valor');
  }
}
```

En este ejemplo, el `Stream` emite un valor cada segundo, y el `Stream` puede seguir emitiendo valores hasta que se complete. A diferencia de los `Future`, los `Stream` pueden emitir múltiples valores a lo largo del tiempo.

### Resumen:

- Un **`Future`** en Dart se ejecuta **solo una vez** y no puede ser reutilizado después de completarse.
- Si necesitas ejecutar una operación varias veces o recibir múltiples valores de forma asincrónica, considera usar un **`Stream`** en su lugar, ya que un `Stream` puede emitir múltiples valores a lo largo del tiempo.
