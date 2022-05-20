import 'package:flutter/foundation.dart';

class Measure {
  num TVOC = 0;
  num eCO2 = 0;
  late DateTime date;

  Measure(num tvoc, num eco2) {
    this.TVOC = tvoc;
    this.eCO2 = eco2;
    date = DateTime.now();
  }
}
