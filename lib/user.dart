import 'package:flutter/material.dart';

class User {
  final String phone;
  final String name;
  final String email;
  final String portrait;
  User({this.phone,this.name,this.email,this.portrait});

}

class Session extends StatefulWidget{
  Session(
      this.msgs
      );
  /*Session(
      this.lastMessage,
      this.name,
      this.timestamp,
      this.messages,
      this.phone,
      this.potrait
      );

  final String lastMessage;
  final String name;
  final int timestamp;
  final String messages;
  final String phone;
  final String potrait;*/
  List<Map> msgs;
  @override
  State<StatefulWidget> createState() => new SessionState();
}

class SessionState extends State<Session> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}