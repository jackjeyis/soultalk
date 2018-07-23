import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'chat_screen.dart';
import 'prompt_wait.dart';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class GroupChatListBodyItem extends StatelessWidget {
  GroupChatListBodyItem({
    this.channel,
    this.db,
    this.name,
    this.lastMessage,
    this.timestamp,
    this.messages,
    this.myName,
    this.myPhone,
    this.shePhone,
    this.shePortrait,
    this.myPortrait,
  });
  final IOWebSocketChannel channel;
  final Database db;
  final String name;
  final String lastMessage;
  final String timestamp;
  final String messages;
  final String myName;
  final String myPhone;
  final String shePhone;
  final String shePortrait;
  final String myPortrait;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return new ChatScreen(
                channel: channel,
                db: db,
                messages: messages,
                myName: myName,
                sheName: name,
                myPhone: myPhone,
                shePhone: shePhone,
                shePortrait: shePortrait,
                myPortrait: myPortrait,
              );
            },
          ));
        },
        child: new Container(
            decoration: new BoxDecoration(),
            padding: new EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: new Row(
              children: <Widget>[
                new CircleAvatar(
                    backgroundImage: new NetworkImage(shePortrait)),
                new Flexible(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text("  " + name, textScaleFactor: 1.2),
                              new Text(ReadableTime(timestamp),
                                  textAlign: TextAlign.right,
                                  style: new TextStyle(
                                      color: Theme.of(context).hintColor)),
                            ]),
                        new Container(
                            padding: new EdgeInsets.only(top: 2.0),
                            child: new Text("  " + lastMessage,
                                overflow: TextOverflow.ellipsis,
                                style: new TextStyle(
                                    color: Theme.of(context).hintColor))),
                      ],
                    ))
              ],
            )));
  }
}

class GroupChatListBody extends StatefulWidget {
  GroupChatListBody({
    this.channel,
    this.db,
    this.phone,
    this.myName,
    this.portrait,
    Key key,
  })
      : super(key: key);
  final IOWebSocketChannel channel;
  final Database db;
  final String phone;
  final String myName;
  final String portrait;
  @override
  _GroupChatListBodyState createState() => new _GroupChatListBodyState(phone);
}
class Session{}
class _GroupChatListBodyState extends State<GroupChatListBody> with TickerProviderStateMixin {
  _GroupChatListBodyState(this._phone);
  final String _phone;
  List sessions = [];

  Map existSessions = new Map();
  int num;

  @override
  void initState() {
    super.initState();
    _getSessions().then((list){
      setState(() {
        this.sessions = list[1];
        this.num = list[0][0]['cnt'];
      });
    });
  }

  Future _getSessions() async {
    var count = await widget.db.rawQuery("select count(*) as cnt from User");
    List list = await widget.db.rawQuery("select name,lastMessage,timestamp,messages,phone,portrait from User");
    return [count,list];
  }

  @override
  Widget build(BuildContext context) {
        return new SizeTransition(
          sizeFactor: new CurvedAnimation(
              parent: new AnimationController(
                  duration: new Duration(milliseconds: 300),
                  vsync: this
              ),
              curve: Curves.easeOut
          ),
          child: new ListView.builder(
            reverse: true,
            itemBuilder: _buildSessionTile,
            itemCount: num,
            ),
        );
  }


  Widget _buildSessionTile(BuildContext context,int index) {
    if (sessions.length == 0) return null;
    if (existSessions.containsKey(sessions[index]["sessionId"])){
      int idx= existSessions.remove(sessions[index]["sessionId"]);
      sessions.elementAt(idx)["lastMessage"] = sessions[index]["text"];
      }
    return new
    GroupChatListBodyItem(
      channel: widget.channel,
      db:widget.db,
      name: sessions[index]["name"],
      lastMessage: sessions[index]["lastMessage"],
      timestamp: sessions[index]["timestamp"],
      messages: sessions[index]["messages"],
      myName: widget.myName,
      myPhone: _phone,
      shePhone: sessions[index]["phone"],
      shePortrait: sessions[index]["portrait"],
      myPortrait: widget.portrait,
    );
  }
}
