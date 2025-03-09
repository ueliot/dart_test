import 'dart:async';

void main() {
  
Stream<int> timedCounter(Duration interval, [int? maxCount]) async* {
  int i = 0;
  while (true) {
    await Future.delayed(interval);
    yield i++;
    if (i == maxCount) break;
  }
}
  
 StreamSubscription?  ti;
 ti = timedCounter(Duration(microseconds: 500), 10).listen(
    (data){
         print("resp: $data"); 
          if(data >=6){
            ti!.cancel();
          }     
    },
    onDone: (){print("Done");}
  );
}