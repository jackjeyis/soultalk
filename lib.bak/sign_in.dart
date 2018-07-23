import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'sign_up.dart';
import 'prompt_wait.dart';
import 'group_chat_list.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';



class SignIn extends StatefulWidget {
  SignIn(this.db,this.channel);
  final IOWebSocketChannel channel;
  final Database db;
  @override
  State createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
  new GlobalKey<ScaffoldState>();
  final TextEditingController _phoneController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  bool _correctPhone = true;
  bool _correctPassword = true;

  void _handleSubmitted() {
    FocusScope.of(context).requestFocus(new FocusNode());
    _checkInput();
    if (_phoneController.text == '' || _passwordController.text == '') {
      showMessage(context, "登录信息填写不完整！");
      return;
    } else if (!_correctPhone || !_correctPassword) {
      showMessage(context, "登录信息的格式不正确！");
      return;
    }
    showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder:(context) => new ShowAwait(
            _userLogIn(_phoneController.text,_passwordController.text)))
        .then((int onValue) {
      if (onValue == 0) {
        showMessage(context, "这个手机号码没有被注册！");
      } else if (onValue == 1) {
        showMessage(context, "手机号码或登陆密码不正确！");
      } else if (onValue == 2) {
        Navigator
            .of(context)
            .push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
          return new GroupChatList(widget.db,widget.channel);
        }));
      }
    });
  }

  Future<int> _userLogIn(String phone, String password)  async {
    return await http
        .post(
        "http://10.12.164.130:8080/api/user/login",
        body: json.encode({ 'phone': '1234567','password': '123456'})
        )
        .then((resp){
          print(resp.body);
          if (resp.statusCode == 200) {
            _saveLogin(phone, password,"abc");
            return 2;
          }else{
            return 1;
          }
    });
  }

  Future<Null> _saveLogin(String phone, String password,String portrait) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    await new File('$dir/LandingInformation').writeAsString(
        '{"phone":"$phone","name":"$password","portrait":"$portrait"}');
  }

  void _openSignUp() {
    setState(() {
      Navigator.of(context).push(new MaterialPageRoute<List<String>>(
        builder: (BuildContext context) {
          return new SignUp();
        },
      )).then((onValue) {
        if (onValue != null) {
          _phoneController.text = onValue[0];
          _passwordController.text = onValue[1];
          FocusScope.of(context).requestFocus(new FocusNode());
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text("注册成功！"),
          ));
        }
      });
    });
  }

  void _checkInput() {
    if (_phoneController.text.isNotEmpty &&
        (_phoneController.text.trim().length < 7 ||
            _phoneController.text.trim().length > 12)) {
      _correctPhone = false;
    } else {
      _correctPhone = true;
    }
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.trim().length < 6) {
      _correctPassword = false;
    } else {
      _correctPassword = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        body: new Stack(children: <Widget>[
          new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _checkInput();
              },
              child: new Container(
                decoration: new BoxDecoration(),
              )),
          new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Center(
                  child: new Image.asset(
                    'images/talk_casually.png',
                    width: MediaQuery.of(context).size.width * 0.4,
                  )),
              new Container(
                  width: MediaQuery.of(context).size.width * 0.96,
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: new InputDecoration(
                            hintText: '手机号码',
                            errorText: _correctPhone ? null : '号码的长度应该在7到12位之间',
                            icon: new Icon(
                              Icons.phone,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                          onSubmitted: (value) {
                            _checkInput();
                          },
                        ),
                        new TextField(
                          controller: _passwordController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: new InputDecoration(
                            hintText: '登陆密码',
                            errorText: _correctPassword ? null : '密码的长度应该大于6位',
                            icon: new Icon(
                              Icons.lock_outline,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                          onSubmitted: (value) {
                            _checkInput();
                          },
                        ),
                      ])),
              new FlatButton(
                child: new Container(
                  decoration: new BoxDecoration(
                    color: Theme.of(context).buttonColor,
                  ),
                  child: new Center(
                      child: new Text(
                        "登 录",
                        textScaleFactor: 1.1,
                        style: new TextStyle(color: Theme.of(context).primaryColor),
                      )),
                ),
                onPressed: () {
                  _handleSubmitted();
                },
              ),
              new Center(
                  child: new FlatButton(
                    child: new Text("没有帐户？ 注册"),
                    onPressed: _openSignUp,
                  ))
            ],
          )
        ]));
  }
}