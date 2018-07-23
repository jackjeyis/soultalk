import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'image_zoomable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_socket_channel/io.dart';
import 'package:soultalk/im/im.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'webrtc_call.dart';


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
    this.sessions,
    this.msgs,
    Key key,
  }):super(key:key);
  final IOWebSocketChannel channel;
  final Database db;
  final String messages;
  final String myName;
  final String sheName;
  final String myPhone;
  final String shePhone;
  final String shePortrait;
  final String myPortrait;
  final List<Map> sessions;
  final List<Map> msgs;

  @override
  State createState() => new ChatScreenState();

}

enum DialogDemoAction {
  cancel,
  connect,
}

class ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  File file;
  final GlobalKey<ScaffoldState> _scaffoldKey =
  new GlobalKey<ScaffoldState>();
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;
  bool _focus = false;
  FocusNode _focusNode = new FocusNode();
  int cnt;
  String _serverAddress;

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
    if (widget.sessions != null) {
      for (var i = 0; i < widget.sessions.length; i++) {
        print(widget.sessions[i]);
        _messages.insert(0,
            new ChatMessage(
              new Snapshot(
                  widget.sessions[i]["params"]["lastMessage"],
                  widget.sessions[i]["params"]["name"],
                  widget.sessions[i]["params"]["portrait"]
              ),
              widget.myName,
              widget.myPortrait,
              widget.shePortrait,
              widget.myName ==  widget.sessions[i]["params"]["name"] ? null:_handleFocus,
            ));
      }
    }
    IMManager
        .instance()
        .streamController
        .stream
        .listen((data) {
      if (mounted) {
        setState(() {
          if(data["method"] != "submit") {
            _messages.insert(0, new ChatMessage(
              new Snapshot(
                  data["params"]["lastMessage"],
                  data["params"]["name"],
                  data["params"]["portrait"]
              ),
              widget.myName,
              widget.myPortrait,
              widget.shePortrait,
              _handleFocus,
            ));
          }
        });
      }
    });
  }

  @override
  void dispose(){
    super.dispose();
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
    var sp = new Snapshot(text, widget.myName, imageUrl);
    ChatMessage message = new ChatMessage(
      sp,
      widget.myName,
      widget.myPortrait,
      widget.shePortrait,
      null,
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
    IMManager
        .instance()
        .streamController.add({
      "id": 2,
      "method": "submit",
      "params": {
        "lastMessage": text,
        "name": widget.myName,
        "sname":widget.sheName,
        "portrait": imageUrl,
        "timestamp":new DateTime.now().millisecondsSinceEpoch,
      }
    });
    IMManager.instance().submit(json.encode({
      "id": 2,
      "method": "submit",
      "params": {
        "name": widget.myName,
        "to": widget.sheName,
        "lastMessage": text,
        "phone": widget.myPhone,
        "portrait": imageUrl,
      }
    }));
  }
    Future _getMessages() async {
      var count = await widget.db.rawQuery(
          "select count(*) as cnt from ${widget.messages}");
      List list = await widget.db.rawQuery(
          "select snd_name,image_url,text from ${widget.messages}");
      return [count, list];
    }

  Future<http.StreamedResponse> Upload(File imageFile) async {
    var stream = new http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();

    var uri = Uri.parse("http://eevee.petpika.cn/soultalk/api/user/upload");

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    return request.send();
  }

  Future<File> _selectImage() async {
    return showDialog<File>(
      context: this.context,
      //barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return new SimpleDialog(
          title: const Text('选择照片'),
          children: <Widget>[
            new SimpleDialogOption(
                child: const Text('拍照'),
                onPressed: () async {
                  File imageFile =
                  await ImagePicker.pickImage(source: ImageSource.camera);
                  setState(() {
                    file = imageFile;
                  });
                  Navigator.of(context).pop(imageFile);
                }),
            new SimpleDialogOption(
                child: const Text('相册'),
                onPressed: () async {
                  File imageFile =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    file = imageFile;
                  });
                  Navigator.of(context).pop(imageFile);
                }),
          ],
        );
      },
    );
  }
  void _handleFocus(bool focus) {
    print("_handle");
    setState(() {
      _focus = focus;
      FocusScope.of(this.context).requestFocus(_focusNode);
      _textController.text = "@asdf";
    });
  }


  void showDemoDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        if (value == DialogDemoAction.connect) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      CallSample(ip: _serverAddress)));
        }
      }
    });
  }

  _showAddressDialog(context) {
    showDemoDialog<DialogDemoAction>(
        context: context,
        child: new AlertDialog(
            title: const Text('Enter server address:'),
            content: TextField(
              onChanged: (String text) {
                setState(() {
                  _serverAddress = text;
                });
              },
              decoration: InputDecoration(
                hintText: _serverAddress,
              ),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context, DialogDemoAction.cancel);
                  }),
              new FlatButton(
                  child: const Text('CONNECT'),
                  onPressed: () {
                    Navigator.pop(context, DialogDemoAction.connect);
                  })
            ]));
  }

    Widget _buildTextComposer() {

      return new IconTheme(
          data: new IconThemeData(color: Theme
              .of(this.context)
              .accentColor),
          child: new Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: new Row(children: <Widget>[
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                      icon: new Icon(Icons.photo_camera),
                      onPressed: () async {
                        _selectImage().then((file) async {
                          Upload(file).then((resp){
                            resp.stream.transform(utf8.decoder).listen((value) {
                              print(value);
                              Map map = json.decode(value);
                              var hash = map["hash"];
                              _sendMessage(
                                  text: "[图片]", imageUrl: "http://eevee.petpika.cn/soultalk/api/user/image/"+hash);
                            });
                          });
                        });
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(
                          content: new Text("上传原图中〜请稍候！"),
                        ));
                      }),
                ),
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                      icon: new Icon(Icons.video_call),
                      onPressed: () async {
                        _showAddressDialog(this.context);
                      }),
                ),
                new Flexible(
                    child: new TextField(
                      autofocus: true,
                      focusNode: _focusNode,
                      controller: _textController,
                      onChanged: (String text) {
                        setState(() {
                          _isComposing = text.trim().length > 0;
                        });
                      },
                      onSubmitted: _handleSubmitted,
                      decoration: new InputDecoration.collapsed(
                          hintText: '发送消息'),
                    )),
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                      icon: new Icon(Icons.send),
                      onPressed:
                          () => _handleSubmitted(_textController.text)
                          ),
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
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                        value: "delete", child: new Text('删除会话')),
                  ])
            ]),
        body: new Container(
            child: new Stack(children: <Widget>[
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
                  addRepaintBoundaries:true,
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (_, int index) => _messages[index],
                  itemCount: _messages.length,
                ),
              ),
              new Divider(height: 1.0),
              new Container(
                decoration: new BoxDecoration(
                  color: Theme
                      .of(context)
                      .cardColor,
                ),
                child: _buildTextComposer(),
              )
            ],
          )
        ]),
          color: Colors.white10,
        )
      );
    }

    Widget showChatMessage(BuildContext context,int index){
      _messages[index].onChanged = _handleFocus;
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
class _BubbleShape extends ShapeBorder {

  double arrowBaseWidth =20.0 ;
  double arrowTipDistance=2.0;
  double borderRadius = 10.0;
  Color borderColor = Colors.black;
  double borderWidth = 10.0;

  double left = 0.0, top = 0.0, right = 0.0 , bottom = 0.0;

  _BubbleShape(
      this.borderRadius,
      this.arrowBaseWidth,
      this.arrowTipDistance,
      this.borderColor,
      this.borderWidth,
      this.left,
      this.top,
      this.right,
      this.bottom);

  @override
  EdgeInsetsGeometry get dimensions => new EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return new Path()
    /*..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero)*/;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    //
    double topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius;

    Path _getLeftTopPath(Rect rect) {
      return new Path()
        ..moveTo(rect.left, rect.bottom-5.0)

        ..lineTo(rect.left, rect.top+5.0)
        ..arcToPoint(Offset(rect.left+5.0, rect.top),
            radius: new Radius.circular(5.0),clockwise: true)
        ..lineTo(rect.right-5.0, rect.top)
        ..arcToPoint(Offset(rect.right, rect.top+5.0),
            radius: new Radius.circular(5.0), clockwise: true);
    }

    topLeftRadius = (left == 0 || top == 0) ? 0.0 : borderRadius;
    topRightRadius = (right == 0 || top == 0) ? 0.0 : borderRadius;
    bottomLeftRadius = (left == 0 || bottom == 0) ? 0.0 : borderRadius;
    bottomRightRadius = (right == 0 || bottom == 0) ? 0.0 : borderRadius;

    return _getLeftTopPath(rect)
      ..lineTo(
          rect.right,
          rect.top+10.0)
      ..lineTo(rect.right + 25.0, rect.top+15.0) // up to arrow tip   \
      ..lineTo(
          rect.right,
          rect.bottom-15.0)
      ..lineTo(rect.right, rect.bottom-5.0)
      ..arcToPoint(Offset(rect.right-5.0, rect.bottom),
          radius: new Radius.circular(5.0), clockwise: true)
      ..lineTo(rect.left+5.0, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom-5.0),
          radius: new Radius.circular(5.0), clockwise: true);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    Paint paint = new Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return new _BubbleShape( borderRadius, arrowBaseWidth,
        arrowTipDistance, borderColor, borderWidth, left, top, right, bottom);
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage(

        this.snapshot,
        this.myName,
        this.shePortrait,
        this.myPortrait,
        this.onChanged);
  final Snapshot snapshot;
  final String myName;
  final String shePortrait;
  final String myPortrait;
  ValueChanged<bool> onChanged;


  @override
  Widget build(BuildContext ctx) {
    Widget _sheSessionStyle() {
      return new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(

              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                  //backgroundImage: new NetworkImage(shePortrait),
                  child: new Text(snapshot.name[0])),
                  //backgroundImage: new NetworkImage(shePortrait)),
            ),
            new Flexible(
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /*new Text(snapshot.name,
                          style: Theme.of(context).textTheme.subhead),*/
                      new Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        child: snapshot.portrait== null

                            ? new GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).push(
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
                            : new Card(
          child:new InkWell(
            onTap: (){
              if(onChanged != null){
                print("focus");
                onChanged(true);
              }
            },
            child: new Padding(
                padding: const EdgeInsets.all(20.0),
                child: new Text(snapshot.text),
            ),
          )
            //shape: new _BubbleShape(10.0, 20.0, 2.0, Colors.green, 1.0, 0.0, 0.0, 0.0, 0.0),
      ),

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
                      /*new Text(snapshot.name,

                          style: Theme.of(context).textTheme.subhead),*/
                      new Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        child: snapshot.portrait != null

                            ? new GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).push(
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

