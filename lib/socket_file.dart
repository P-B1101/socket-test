import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

typedef Callback<E> = void Function(E event);

class FileSocket {
  Socket? _socket;
  bool _connected = false;
  final ConnectionConfig config;
  FileSocket(this.config);

  Future<bool> connect() async {
    int k = 1;
    while (true) {
      try {
        _socket = await Socket.connect(
          config.ipAddress,
          config.port,
          timeout: Duration(milliseconds: config.timeout),
        );
        _connected = true;
        print('$k attemps. Socket connected successfully');
        return true;
      } on Exception catch (error) {
        print('$k attemps. Socket not connected (Timeout reached)');
        print('Details:');
        print(error);
        if (k >= config.attempts) {
          await disconnect();
          return false;
        }
        k++;
      }
    }
  }

  Future<void> disconnect() async {
    try {
      await _socket?.close();
    } on Exception catch (error) {
      print(error);
    }
    _connected = false;
    print('Socket disconnected.');
  }

  StreamSubscription<Uint8List> listen(Callback<Uint8List> callback) {
    assert(_connected, 'call `connectWithSocket` first');
    assert(_socket != null, 'call `connectWithSocket` first');
    return _socket!.listen(callback);
  }

  void sendMessage(Uint8List bytes) {
    assert(_connected, 'call `connectWithSocket` first');
    assert(_socket != null, 'call `connectWithSocket` first');
    _socket!.add(bytes);
  }
}

class ConnectionConfig {
  final String ipAddress;
  final int port;
  final int timeout;
  final int attempts;

  const ConnectionConfig({
    required this.ipAddress,
    required this.port,
    this.timeout = 500,
    this.attempts = 3,
  });

  @override
  String toString() => '$ipAddress:$port';
}
