import 'package:a1/a1.dart';

void main() {
  // Using the class
  var a1 = A1.parse('A1');

  print(a1); // A1
  print(a1.column); // 0
  print(a1.row); // 0

  // Using the extensions
  print('b2'.a1); // A1
  print('b2'.a1.column); // 1
  print('b2'.a1.row); // 1

  // List of a1s
  print(['a1', 'b2', 'C3', 'z4'].a1); // List of A1 Classs A1,B2,C3,Z4

  print(['a1', 'b2', 'C3', 'z4'].a1.map((a1) => a1.column));
  // [0, 2, 3, 26]

  a1 = A1.parse('B234');
  print('The A1 $a1 has a column of ${a1.column} and row of ${a1.row}');
  // The A1 B234 has a column of 1 and row of 233

  print('The A1 above is ${a1.up}'); // B233
  print('The A1 left is ${a1.left}'); // A233
  print('The A1 right is ${a1.right}'); // B234
  print('The A1 below is ${a1.down}'); // C233
}
