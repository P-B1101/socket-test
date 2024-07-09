import 'dart:io';

import 'package:socket_file/socket_file.dart';
import 'package:args/args.dart';

const portNumber = 'port-number';
const isServer = 'is-server';
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(portNumber, abbr: 'p')
    ..addFlag(isServer, abbr: 's', negatable: false);
  final argResults = parser.parse(arguments);
  final server = argResults[isServer] as bool;
  final port = int.parse(argResults[portNumber]);
  if (server) {
    await _handleServer(port);
  } else {
    await _handleClient(port);
  }
}

Future<void> _handleServer(int port) async {
  final ip = await findMyIp() ?? InternetAddress.loopbackIPv4;
  await RawDatagramSocket.bind(ip.host, 0).then((socket) {
    print('listen on ${ip.address}:${socket.port}');
    socket.listen((event) {});
  });
}

Future<void> _handleClient(int port) async {
  final ip = await findMyIp() ?? InternetAddress.loopbackIPv4;
  final fileSocket = FileSocket(
    ConnectionConfig(ipAddress: ip.address, port: port),
  );
  await Future.delayed(const Duration(seconds: 2));
  fileSocket.connect();
}

Future<InternetAddress?> findMyIp() async {
  final interfaces = await NetworkInterface.list();
  if (interfaces.isEmpty) return null;
  for (var interface in interfaces) {
    if (interface.addresses.isEmpty) continue;
    for (var address in interface.addresses) {
      print('ip: ${address.address}');
      return address;
    }
  }
  return null;
}
