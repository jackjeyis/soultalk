import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'chat_screen.dart';
import 'chat.dart';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'prompt_wait.dart';


class GroupChatListBodyItem extends StatefulWidget {
  GroupChatListBodyItem({
    this.sessions,
    this.msgs,
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

  List<Map> sessions;
  List<Map> msgs;
  final IOWebSocketChannel channel;
  final Database db;
  final String name;
  final String lastMessage;
  final int timestamp;
  final String messages;
  final String myName;
  final String myPhone;
  final String shePhone;
  final String shePortrait;
  final String myPortrait;

  @override
  State<StatefulWidget> createState() => new GroupChatListBodyItemState();
}
class GroupChatListBodyItemState extends State<GroupChatListBodyItem> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
             return new ChatScreen(
                channel: widget.channel,
                db: widget.db,
                messages: widget.messages,
                myName: widget.myName,
                sheName: widget.name,
                myPhone: widget.myPhone,
                shePhone: widget.shePhone,
                shePortrait: widget.shePortrait,
                myPortrait: widget.myPortrait,
                sessions: widget.sessions,
               msgs: widget.msgs,
              );
            },
          ));
        },
        child: new Container(
            decoration: new BoxDecoration(
            ),
            padding: new EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: new Column(
            children: <Widget>[
              new Divider(height: 1.0),
              new Row(
              children: <Widget>[
                new CircleAvatar(
                  backgroundImage: new NetworkImage(widget.shePortrait),
                  child: new Text(widget.name[0]),
                ),
                new Flexible(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text("  " + widget.name, style: new TextStyle(color: Colors.green), textScaleFactor: 1.2),
                             // new Text("${new DateFormat.MEd().add_Hm().format(new DateTime.fromMillisecondsSinceEpoch(widget.timestamp))}",
                              new Text(getTimeStamp(new DateTime.fromMillisecondsSinceEpoch(widget.timestamp)),
                                  textAlign: TextAlign.right,
                                  style: new TextStyle(
                                      color: Colors.green/*Theme.of(context).hintColor*/)),
                            ]),
                        new Container(
                            padding: new EdgeInsets.only(top: 2.0),
                            child: Text("  " + widget.lastMessage,
                                overflow: TextOverflow.ellipsis,
                                style: new TextStyle(
                                    color: Colors.green))),
                      ],
                    ))
              ],
            ),
          new Divider(height: 1.0),
          ]
        )));
  }
}

class GroupChatListBody extends StatefulWidget {
  GroupChatListBody({
    this.sessions,
    this.channel,
    this.db,
    this.phone,
    this.myName,
    this.sheName,
    this.portrait,
    Key key,
  })
      : super(key: key);
  List<Chat> sessions;
  final IOWebSocketChannel channel;
  final Database db;
  final String phone;
  final String myName;
  final String sheName;
  final String portrait;
  @override
  _GroupChatListBodyState createState() => new _GroupChatListBodyState();
}
class _GroupChatListBodyState extends State<GroupChatListBody> with TickerProviderStateMixin {
  _GroupChatListBodyState();
  List sessions;
  int num;

  @override
  void initState() {
    super.initState();/*
    _getSessions().then((list){
      setState(() {
        //this.sessions = list[1];
      });
    });*/
  }

  Future _getSessions() async {
    List list = await widget.db.rawQuery("select sid,name,lastMessage,timestamp,messages,phone,portrait from User");
    return list;
  }

  @override
  Widget build(BuildContext context) {
        return new Center(
         /* sizeFactor: new CurvedAnimation(
              parent: new AnimationController(
                  duration: new Duration(milliseconds: 300),
                  vsync: this
              ),
              curve: Curves.easeOut
          ),*/
          child: /*widget.sessions.isEmpty ? new Text("Nobody has said anything yet... Break the silence!"):*/
          ListView.builder(
            //reverse: true,
              itemBuilder: (_, int index) =>
              new
            GroupChatListBodyItem(
                sessions:widget.sessions[index].sessions,
                msgs: widget.sessions[index].msgs,
                channel: widget.channel,
              db:widget.db,
            name: widget.sessions[index].sheName,
            lastMessage: widget.sessions[index].sessions.last["params"]["lastMessage"],
            timestamp: widget.sessions[index].sessions.last["params"]["timestamp"],
            messages: widget.sessions[index].sessions.last["params"]["messages"],
            myName: widget.myName,
            myPhone: widget.phone,
            shePhone: widget.sessions[index].sessions.last["params"]["phone"],
            shePortrait: widget.sessions[index].sessions.last["params"]["portrait"],
            myPortrait: widget.portrait,
          ),
            itemCount: widget.sessions.length,
            ),
        );
  }
}