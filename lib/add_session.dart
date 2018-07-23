import 'package:flutter/material.dart';
import 'dart:async';
import 'prompt_wait.dart';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:soultalk/db/appbase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




class AddSession extends StatefulWidget {
  AddSession(this.db,this.myPhone, this.myName, this.myPortrait);
  final Database db;
  final String myPhone;
  final String myName;
  final String myPortrait;

  @override
  State createState() => new _AddSessionState(myPhone, myPortrait);
}

class _AddSessionState extends State<AddSession> {
  _AddSessionState(this._myPhone, this._myPortrait);
  final String _myPhone;
  final String _myPortrait;

  final TextEditingController _phoneController = new TextEditingController();
  String _searchUsername = "";
  String _searchPhone = "";
  String _searchMessages = "";
  String _searchPortrait = "";
  String _errorPrompt = "";
  bool _nullText = true;

  void _handleAppend() {
    showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => new ShowAwait(_addSession())).then((int onValue) {
      if (onValue == 1 || onValue == 2) {
        Navigator.of(context).pop(null);
      } else if (onValue == 0) {
        Navigator.of(context).pop(
            [_searchUsername, _searchPhone, _searchMessages, _searchPortrait]);
      }
    });
  }

  void _handleFind() {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_phoneController.text.isEmpty) {
      setState(() {
        _errorPrompt = "手机号码不能为空！";
        _searchUsername = "";
      });
      return;
    } else if (_phoneController.text.trim() == widget.myPhone) {
      setState(() {
        _errorPrompt = "这是你的手机号码哦！";
        _searchUsername = "";
      });
      return;
    } else if (_phoneController.text.trim().length < 7 ||
        _phoneController.text.trim().length > 12) {
      setState(() {
        _errorPrompt = "手机号码的格式不正确！";
        _searchUsername = "";
      });
      return;
    }
    showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (context) => new ShowAwait(_findUser(_phoneController.text)))
        .then((int onValue) {
      if (onValue == 0) {
        setState(() {
          _errorPrompt = "该用户不存在！";
          _searchUsername = "";
        });
      } else if (onValue == 1) {
        setState(() {
          _errorPrompt = "";
        });
      }
    });
  }

  Future<int> _findUser(String phone) async {
    return await http
        .post(
        "http://eevee.petpika.cn/soultalk/api/user/find",
        body: json.encode({ 'phone': int.parse(phone)})
    )
        .timeout(new Duration(seconds: 1),onTimeout: (){print("timeout");})

        .then((resp){
      print(resp.body);
      var map = json.decode(resp.body);
      if (resp.statusCode == 200) {
        map = json.decode(map["msg"]);

        _searchUsername = map["username"];
        _searchPhone = phone;
        _searchPortrait = "sdf";
        return 1;
      }else{
        return 0;
      }
    }).catchError((error){
      print(error);
    });



  }

  Future<int> _addSession() async {
 //   String time = new DateTime.now().toString();
//    int random = new Random().nextInt(100000);
//    String message = time.split(' ')[0].replaceAll('-', '') + random.toString();
//    AppDatabase.get().getSessions().then((data){
//      if (data == null) {
//        AppDatabase.get().writeSession('$_myPhone$_searchPhone', {
//          "name": _searchUsername,
//          "phone": _searchPhone,
//          "messages": "$_myPhone$_searchPhone",
//          "lastMessage": "一起来聊天吧！",
//          "portrait": _searchPortrait
//        });
//        AppDatabase.get().writeSession('$_searchPhone/$_myPhone', {
//          "name": widget.myName,
//          "phone": _myPhone,
//          "messages": "$_myPhone$_searchPhone",
//          "lastMessage": "一起来聊天吧！",
//          "portrait": _myPortrait
//        });
//        return 1;
//      }
//    });
    return 0;
//    return await chatsReference
//        .child('$_myPhone/$_searchPhone')
//        .once()
//        .then((DataSnapshot onValue) {
//      if (onValue.value == null) {
//        _writeNewSession(time, message);
//        return 1;
//      } else {
//        if (onValue.value["activate"] == "true") {
//          _searchMessages = onValue.value["messages"];
//          return 0;
//        } else {
//          _writeNewSession(time, message);
//          return 2;
//        }
//      }
//    });
  }

  @override
  Widget build(BuildContext context) {
    return new SimpleDialog(
        title: new Text("添加会话"),
        contentPadding: const EdgeInsets.symmetric(horizontal: 23.0),
        children: <Widget>[
          new Container(
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Flexible(
                    child: new TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration:
                      new InputDecoration.collapsed(hintText: '点击此处输入手机号码'),
                      onChanged: (text) {
                        if (text == "") {
                          _nullText = true;
                        } else {
                          _nullText = false;
                        }
                        setState(() {});
                      },
                    )),
                _nullText
                    ? new Text("")
                    : new IconButton(
                  icon: new Icon(Icons.clear),
                  onPressed: () {
                    _phoneController.clear();
                    _nullText = true;
                    _searchUsername = "";
                    _errorPrompt = "";
                    setState(() {});
                  },
                ),
              ],
            ),
            height: 40.0,
          ),
          new Container(
            child: _searchUsername == ""
                ? _errorPrompt == ""
                ? new Text("")
                : new Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: new Text(
                  _errorPrompt,
                  style: new TextStyle(color: Colors.red),
                ))
                : new Row(
              children: <Widget>[
                new CircleAvatar(
                    backgroundImage: new NetworkImage(_searchPortrait)),
                new Flexible(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          "  " + _searchUsername,
                          textScaleFactor: 1.2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        new Text("  " + _searchPhone)
                      ],
                    ))
              ],
            ),
            height: 40.0,
          ),
          new Container(
              margin: const EdgeInsets.only(top: 19.0, bottom: 23.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new RaisedButton(
                    elevation: 0.0,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    colorBrightness: Brightness.dark,
                    color: Theme.of(context).hintColor,
                    child: new Text('取消'),
                  ),
                  new RaisedButton(
                    elevation: 0.0,
                    onPressed:
                    _searchUsername == "" ? _handleFind : _handleAppend,
                    colorBrightness: Brightness.dark,
                    child:
                    _searchUsername == "" ? new Text('查找') : new Text('添加'),
                  ),
                ],
              ))
        ]);
  }
}