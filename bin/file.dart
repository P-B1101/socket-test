import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';

const filePath = 'file-path';

void main(List<String> arguments) async {
  final parser = ArgParser()..addOption(filePath, abbr: 'p');
  final argResults = parser.parse(arguments);
  final path = argResults[filePath] as String;
  final file = File(path);
  if (file.existsSync()) {
    _handleFile(file);
  } else {
    print('file not found');
  }
}

void _handleFile(File file) {
  final header = {
    'type': 'FILE',
  };
  final headerByte = utf8.encode(json.encode(header));
  final fileByte = file.readAsBytesSync();
  final headerIndex = headerByte.length + 1;
  final data = <int>[headerIndex];
  data
    ..addAll(headerByte)
    ..addAll(fileByte);
  _sendData(Uint8List.fromList(data));
}

void _sendData(Uint8List data) {
  if (data.isEmpty) return;
  final headerIndex = data.first;
  final headerByte = data.sublist(1, headerIndex);
  final fileByte = data.sublist(headerIndex);
  final header = json.decode(utf8.decode(headerByte));
  print(header);
  final file = File('${Directory.current.path}/file.txt');
  if (file.existsSync()) {
    file.deleteSync();
  }
  file.createSync();
  file.writeAsBytesSync(fileByte);
}
