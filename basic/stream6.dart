

void main() async {
 
 //usando await
  var sum = await sumStream(stream);
  print(sum); // 55

//usando listen
  stream.listen((data){
    print(data);
  });
}


//Strema desde iterable
final numbers = [1, 2, 3, 5, 6, 7];
final stream = Stream.fromIterable(numbers);


//Promesa para sumar
Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (final value in stream) {
    sum += value;
  }
  return sum;
}