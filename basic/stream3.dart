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
  
  Stream<int>  ti;   //le indicamos de tipo <int>
  ti = timedCounter(Duration(seconds: 1), 10);
  // usaremos un futuro para una vez resuleto
  // retornemos un valor
  
  
  //Creamos el Futuro  ("La promesa de Javascript")
  Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (final value in stream ) {
    sum += value;
  }
  return sum;
  }
  
  //Usamos el future
  print( await sumStream(ti));
  
}
