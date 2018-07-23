import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'package:soultalk/config/conf.dart';
import 'dart:convert';
import 'dart:io';

class IMManager {
  static final IMManager _im = new IMManager._internal();
  //private internal constructor make it singleton
  IMManager._internal();
  static IMManager instance() {
    return _im;
  }
  IOWebSocketChannel _channel;

  final StreamController<Map> streamController = new StreamController<Map>.broadcast(sync: true);
  bool init = false;

  List<Map> msgs = [];

  List getMsgs() {
    return msgs;
  }

  Future<IOWebSocketChannel> getChannel() async {
    if (!init) await _init();
    return _channel;
  }

  Future _init() async {
    readLoginData().then((data) async {
      _channel = IOWebSocketChannel.connect('ws://eevee.petpika.cn:443/ws');
      _channel.sink.add(
          json.encode({
            "id":0,
            "method":"register",
            "params": {
              "name": data["name"],
            }})
      );
      _channel.stream.listen((data){
        print(data);
        Map js = json.decode(data);
        msgs.add(js);
        streamController
            .add(js);
      });
    });
    init = true;
  }

  Future register(String name) async {
    _channel.sink.add(json.encode({
      "id":0,
      "method":"register",
      "params": {
        "from": name
      }
    }));
  }

  Future submit(String json) async {
    _channel.sink.add(json);
  }

  Future recv() async {
    _channel.stream.listen((data){
      print(data);
    });
  }
}