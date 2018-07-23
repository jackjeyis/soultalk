import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'package:soultalk/config/conf.dart';
import 'dart:convert';
import 'dart:collection';
import 'dart:io';

class Message {
  //会话id
  String sessionId;
  //消息正文
  String text;
  //message sender
  String from;
  Message fromMap(Map json) {
    if (json == null) return null;
    Message msg = new Message();

      msg.sessionId = json["sid"];
      return msg;
  }
}

class IMManager {
  static final IMManager _im = new IMManager._internal();
  //private internal constructor make it singleton
  IMManager._internal();

  static IMManager instance() {
    return _im;
  }
  IOWebSocketChannel _channel;

  bool init = false;

  Queue<Message> recv_queue = new DoubleLinkedQueue();
  List l = new List();

  Future<IOWebSocketChannel> getChannel() async {
    if (!init) await _init();
    return _channel;
  }

  Future _init() async {
    readLoginData().then((data) async {
      _channel = IOWebSocketChannel.connect('ws://10.12.164.130:3333/ws');
      _channel.stream.listen((data){
        print(data);
        Map js = json.decode(data);
        recv_queue.add(new Message().fromMap(js));
      });
      //sleep(new Duration(seconds: 2));

      await register(data["name"]);
      init = true;
    });
  }

  Future register(String name) async {
    _channel.sink.add(json.encode({
      "id":0,
      "method":"register",
      "params": {
        "name": name
      }
    }));
  }

  Future submit(String json) async {
    _channel.sink.add(json);
  }

  Future recv() async {

  }
}