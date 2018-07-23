import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'image_zoomable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_socket_channel/io.dart';
import 'package:soultalk/im/im.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  ChatScreen({
    this.channel,
    this.db,
    this.messages,
    this.myName,
    this.sheName,
    this.myPhone,
    this.shePhone,
    this.shePortrait,
    this.myPortrait,
  });
  final IOWebSocketChannel channel;
  final Database db;
  final String messages;
  final String myName;
  final String sheName;
  final String myPhone;
  final String shePhone;
  final String shePortrait;
  final String myPortrait;

  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = <ChatMessage>[];

  static final GlobalKey<ScaffoldState> _scaffoldKey =
  new GlobalKey<ScaffoldState>();
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;
  int cnt;
  List msgs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//      _getMessages().then((list){
//        setState(() {
//          this.cnt = list[0][0]['cnt'];
//          this.msgs = list[1];
//        });
//      });

  }

  Future _handleSubmitted(String text) async {
    if (text.trim() == "") return;
    setState(() {
      _textController.clear();
      _isComposing = false;
      _sendMessage(text: text);
    });

  }

  void _sendMessage({String text, String imageUrl}) {
    String time = new DateTime.now().toString();
    var sp = new Snapshot(text, widget.myName, widget.myPortrait);
    ChatMessage message = new ChatMessage(
      snapshot: sp,
      myName: widget.myName,
      myPortrait: widget.myPortrait,
      shePortrait: widget.shePortrait,
    );
    _messages.insert(0, message);
//      widget.db.transaction((txn) async {
//        return await txn.rawInsert("insert into messages(snd_name,image_url,portrait,text) values(${widget.myName},${imageUrl},${widget.myPortrait},${text})");
//      }).then((val) {
//        if ( val > 0) {
//          print("msg insert db success");
//        }else {
//          print("msg insert db fail");
//        }
//      });
  IMManager.instance().submit(json.encode({
    "id":1,
    "method":"submit",
    "params": {
      "name": widget.myName,
      "to": widget.sheName,
      "lastMessage": text,
      "phone": widget.myPhone,
      "portrait": widget.myPortrait
    }
    }));

  }

  Future _getMessages() async {
    var count = await widget.db.rawQuery("select count(*) as cnt from ${widget.messages}");
    List list = await widget.db.rawQuery("select snd_name,image_url,text from ${widget.messages}");
    return [count,list];
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Row(children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(Icons.photo_camera),
                    onPressed: () async {
                      File imageFile = await ImagePicker.pickImage();
                      int random = new Random().nextInt(100000);
                      _scaffoldKey.currentState.showSnackBar(new SnackBar(
                        content: new Text("上传原图中〜请稍候！"),
                      ));
                      _sendMessage(
                          text: "[图片]", imageUrl: "");
                    }),
              ),
              new Flexible(
                  child: new TextField(
                    controller: _textController,
                    onChanged: (String text) {
                      setState(() {
                        _isComposing = text.length > 0;
                      });
                    },
                    onSubmitted: _handleSubmitted,
                    decoration: new InputDecoration.collapsed(hintText: '发送消息'),
                  )),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(_textController.text)
                        : null),
              )
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(widget.sheName),
          centerTitle: true,
          elevation: 1.0,
          actions: <Widget>[
            new PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == "delete") {
                    _scaffoldKey.currentState.showSnackBar(new SnackBar(
                      content: new Text("删除成功！"),
                    ));
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  new PopupMenuItem<String>(
                      value: "delete", child: new Text('删除会话')),
                ])
          ]),
      body: new Stack(children: <Widget>[
        new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: new Container(
              decoration: new BoxDecoration(),
            )),
        new Column(
          children: <Widget>[
            new Flexible(

              child: new ListView.builder(
                reverse:true,
                itemBuilder: (_,int index) => _messages[index],
                itemCount:_messages.length,
              )
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _buildTextComposer(),
            )
          ],
        )
      ]),
    );
  }
}

class Snapshot {
  Snapshot(this.text,this.name,this.portrait);
  final String text;
  final String name;
  final String portrait;

  Snapshot.fromJson(Map<String,dynamic> json)
    : text = json['text'],
      name = json['name'],
      portrait = json['portrait'];

  Map<String,dynamic> ToJson() => {
    'text':text,
    'name':name,
    'portrait':portrait,
  };
}



class ChatMessage extends StatelessWidget {
  ChatMessage(
      {
        this.snapshot,
        this.myName,
        this.shePortrait,
        this.myPortrait});
  final Snapshot snapshot;
  final String myName;
  final String shePortrait;
  final String myPortrait;

  @override
  Widget build(BuildContext context) {
    Widget _sheSessionStyle() {
      return new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(child: new Text(myName[0])),
                  //backgroundImage: new NetworkImage(shePortrait)),
            ),
            new Flexible(
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(snapshot.name,
                          style: Theme.of(context).textTheme.subhead),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: snapshot.portrait!= null

                            ? new GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                                new MaterialPageRoute<Null>(
                                    builder: (BuildContext context) {
                                      return new ImageZoomable(
                                        new NetworkImage(snapshot.portrait),

                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                      );
                                    }));
                          },
                          child: new Image.network(
                            snapshot.portrait,
                            width: 150.0,
                          ),
                        )
                            : new Text(snapshot.text),
                      )
                    ])),
          ]);
    }

    Widget _mySessionStyle() {
      return new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Flexible(
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Text(snapshot.name,

                          style: Theme.of(context).textTheme.subhead),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: snapshot.name == null

                            ? new GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                                new MaterialPageRoute<Null>(
                                    builder: (BuildContext context) {
                                      return new ImageZoomable(
                                        new NetworkImage(snapshot.portrait),

                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                      );
                                    }));
                          },
                          child: new Image.network(
                            snapshot.portrait,
                            width: 150.0,
                          ),
                        )
                            : new Text(snapshot.text),

            )
                    ])),
            new Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: new CircleAvatar(child: new Text(myName[0])),
                  //backgroundImage: new NetworkImage(myPortrait)),
            ),
          ]);
    }

//    return new SizeTransition(
//        sizeFactor:
//        new CurvedAnimation(curve: Curves.easeOut),
//        axisAlignment: 0.0,
    return new Center(
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: myName == snapshot.name
              ? _mySessionStyle()
              : _sheSessionStyle(),
        ));
  }
}