import 'dart:async';

void main() async {
  
  Stream<int> timedCounter(Duration interval, [int? maxCount]) async* {
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      yield i++;
      if (i == maxCount) break;
    }
  }

  //Usamos el mismo stream del ejemplo anterior
  
  Stream  ti;
  ti = timedCounter(Duration(seconds: 1), 10);
  // y usamos await para extraer los valores del stream
  // como si fuera un for loop; fijarse ahora que el main es async
  await for (final value in ti) {
    print(value);
  }
  
}
