import 'dart:io';
import 'dart:convert';
import 'dart:collection';

class Pair<U, V> {
  U first;
  V second;
  Pair(this.first, this.second);
}

class Data {
  HashMap<String, dynamic> contents;

  Data() : contents = HashMap();
  Data.fromString(String s) : contents = HashMap.from(json.decode(s));

  dynamic operator [](String s) {
    return contents[s];
  }

  void operator []=(String s, dynamic x) {
    contents[s] = x;
  }

  String toString() {
    return json.encode(contents);
  }
}
